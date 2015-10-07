{-# OPTIONS_GHC -fno-warn-type-defaults #-}
{-# LANGUAGE LambdaCase, MonadComprehensions, NamedFieldPuns, OverloadedStrings, PatternSynonyms, TupleSections, TypeFamilies, ViewPatterns #-}

module Mud.Cmds.Debug ( debugCmds
                      , purgeThreadTbls
                      , ) where

import Mud.Cmds.Util.Advice
import Mud.Cmds.Util.CmdPrefixes
import Mud.Cmds.Util.Misc
import Mud.Cmds.Util.Pla
import Mud.Cmds.Util.Sorry
import Mud.Data.Misc
import Mud.Data.State.ActionParams.ActionParams
import Mud.Data.State.MsgQueue
import Mud.Data.State.MudData
import Mud.Data.State.Util.Calc
import Mud.Data.State.Util.Get
import Mud.Data.State.Util.Misc
import Mud.Data.State.Util.Output
import Mud.Data.State.Util.Random
import Mud.Misc.ANSI
import Mud.Misc.Persist
import Mud.TheWorld.AdminZoneIds (iLoggedOut)
import Mud.TopLvlDefs.Chars
import Mud.TopLvlDefs.Misc
import Mud.TopLvlDefs.Msgs
import Mud.Util.Misc hiding (patternMatchFail)
import Mud.Util.Operators
import Mud.Util.Padding
import Mud.Util.Quoting
import Mud.Util.Text
import Mud.Util.Token
import Mud.Util.Wrapping
import qualified Mud.Misc.Logging as L (logAndDispIOEx, logNotice, logPlaExec, logPlaExecArgs)
import qualified Mud.Util.Misc as U (patternMatchFail)

import Control.Applicative (Const)
import Control.Arrow ((***))
import Control.Concurrent (forkIO, myThreadId)
import Control.Concurrent.Async (asyncThreadId, poll)
import Control.Concurrent.STM (atomically)
import Control.Concurrent.STM.TQueue (writeTQueue)
import Control.Exception (ArithException(..), IOException)
import Control.Exception.Lifted (throwIO, try)
import Control.Lens (at, both, view, views)
import Control.Lens.Operators ((%~), (&), (.~), (^.))
import Control.Lens.Type (Optical)
import Control.Monad ((>=>), replicateM_, unless, void)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader (asks, runReaderT)
import Data.Char (ord, digitToInt, isDigit, toLower)
import Data.Ix (inRange)
import Data.List (delete, intercalate, sort)
import Data.Maybe (fromJust)
import Data.Monoid ((<>), Sum(..))
import GHC.Conc (ThreadStatus(..), threadStatus)
import Numeric (readInt)
import Prelude hiding (pi)
import qualified Data.IntMap.Lazy as IM (IntMap, assocs, keys, toList)
import qualified Data.Map.Lazy as M (assocs, elems, keys, toList)
import qualified Data.Text as T
import System.Console.ANSI (Color(..), ColorIntensity(..))
import System.CPUTime (getCPUTime)
import System.Directory (getTemporaryDirectory, removeFile)
import System.Environment (getEnvironment)
import System.IO (hClose, hGetBuffering, openTempFile)


-- TODO: Looks like we still need to move some functions to Advice and Sorry.

patternMatchFail :: T.Text -> [T.Text] -> a
patternMatchFail = U.patternMatchFail "Mud.Cmds.Debug"


-----


logAndDispIOEx :: MsgQueue -> Cols -> T.Text -> IOException -> MudStack ()
logAndDispIOEx mq cols = L.logAndDispIOEx mq cols "Mud.Cmds.Debug"


logNotice :: T.Text -> T.Text -> MudStack ()
logNotice = L.logNotice "Mud.Cmds.Debug"


logPlaExec :: CmdName -> Id -> MudStack ()
logPlaExec = L.logPlaExec "Mud.Cmds.Debug"


logPlaExecArgs :: CmdName -> Args -> Id -> MudStack ()
logPlaExecArgs = L.logPlaExecArgs "Mud.Cmds.Debug"


-- ==================================================


debugCmds :: [Cmd]
debugCmds =
    [ mkDebugCmd "?"          debugDispCmdList "Display or search this command list."
    , mkDebugCmd "boot"       debugBoot        "Boot all players (including yourself)."
    , mkDebugCmd "broad"      debugBroad       "Broadcast (to yourself) a multi-line message."
    , mkDebugCmd "buffer"     debugBuffCheck   "Confirm the default buffering mode for file handles."
    , mkDebugCmd "cins"       debugCins        "Dump all channel ID/names for a given player ID."
    , mkDebugCmd "color"      debugColor       "Perform a color test."
    , mkDebugCmd "cpu"        debugCPU         "Display the CPU time."
    , mkDebugCmd "env"        debugDispEnv     "Display or search system environment variables."
    , mkDebugCmd "id"         debugId          "Search the \"MudState\" tables for a given ID."
    , mkDebugCmd "keys"       debugKeys        "Dump a list of \"MudState\" table keys."
    , mkDebugCmd "log"        debugLog         "Put the logging service under heavy load."
    , mkDebugCmd "number"     debugNumber      "Display the decimal equivalent of a given number in a given base."
    , mkDebugCmd "out"        debugOut         "Dump the inventory of the logged out room."
    , mkDebugCmd "params"     debugParams      "Show \"ActionParams\"."
    , mkDebugCmd "persist"    debugPersist     "Attempt to persist the world multiple times in quick succession."
    , mkDebugCmd "purge"      debugPurge       "Purge the thread tables."
    , mkDebugCmd "random"     debugRandom      "Generate and dump a series of random numbers."
    , mkDebugCmd "remput"     debugRemPut      "In quick succession, remove from and put into a sack on the ground."
    , mkDebugCmd "rnt"        debugRnt         "Dump your random names table, or generate a random name for a given PC."
    , mkDebugCmd "rotate"     debugRotate      "Send the signal to rotate your player log."
    , mkDebugCmd "talk"       debugTalk        "Dump the talk async table."
    , mkDebugCmd "thread"     debugThread      "Dump the thread table."
    , mkDebugCmd "throw"      debugThrow       "Throw an exception."
    , mkDebugCmd "throwlog"   debugThrowLog    "Throw an exception on your player log thread."
    , mkDebugCmd "token"      debugToken       "Test token parsing."
    , mkDebugCmd "underline"  debugUnderline   "Test underlining."
    , mkDebugCmd "weight"     debugWeight      "Calculate weight for a given ID."
    , mkDebugCmd "wrap"       debugWrap        "Test the wrapping of a line containing ANSI escape sequences."
    , mkDebugCmd "wrapindent" debugWrapIndent  "Test the indented wrapping of a line containing ANSI escape \
                                               \sequences." ]
  where


mkDebugCmd :: T.Text -> Action -> CmdDesc -> Cmd
mkDebugCmd (prefixDebugCmd -> cn) act cd = Cmd { cmdName           = cn
                                               , cmdPriorityAbbrev = Nothing
                                               , cmdFullName       = cn
                                               , action            = act
                                               , cmdDesc           = cd }


-----


debugBoot :: Action
debugBoot (NoArgs' i mq) = ok mq >> (massMsg . MsgBoot $ dfltBootMsg) >> logPlaExec (prefixDebugCmd "boot") i
debugBoot p              = withoutArgs debugBoot p


-----


debugBroad :: Action
debugBroad (NoArgs'' i) = (bcastNl . mkBroadcast i $ msg) >> logPlaExec (prefixDebugCmd "broad") i
  where
    msg = "[1] abcdefghij\n\
          \[2] abcdefghij abcdefghij\n\
          \[3] abcdefghij abcdefghij abcdefghij\n\
          \[4] abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[5] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[6] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[7] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[8] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[9] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n\
          \[0] abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij"
debugBroad p = withoutArgs debugBroad p


-----


debugBuffCheck :: Action
debugBuffCheck (NoArgs i mq cols) = do
    helper |&| try >=> eitherRet (logAndDispIOEx mq cols "debugBuffCheck")
    logPlaExec (prefixDebugCmd "buffer") i
  where
    helper = liftIO (flip openTempFile "temp" =<< getTemporaryDirectory) >>= \(fn, h) -> do
        send mq . nl =<< [ T.unlines . wrapIndent 2 cols $ msg | (mkMsg fn -> msg) <- liftIO . hGetBuffering $ h ]
        liftIO $ hClose h >> removeFile fn
    mkMsg (dblQuote . T.pack -> fn) (dblQuote . showText -> mode) =
        T.concat [ parensQuote "Default", " buffering mode for temp file ", fn, " is ", mode, "." ]
debugBuffCheck p = withoutArgs debugBuffCheck p


-----


debugCins :: Action
debugCins p@AdviseNoArgs       = advise p [] adviceDCinsNoId
debugCins (OneArg i mq cols a) = case reads . T.unpack $ a :: [(Int, String)] of
  [(targetId, "")] -> helper targetId
  _                -> wrapSend mq cols . sorryParseId $ a
  where
    helper targetId@(showText -> targetIdTxt)
      | targetId < 0 = sorryWtf mq cols
      | otherwise    = getState >>= \ms -> do
          multiWrapSend mq cols . (header :) . pure . showText =<< getAllChanIdNames i ms
          logPlaExecArgs (prefixDebugCmd "cins") (pure a) i
      where
        header = T.concat [ "All channel ID/names "
                          , parensQuote "IM.IntMap [(Id, T.Text)]"
                          , " for ID "
                          , targetIdTxt
                          , ":" ]
debugCins p = advise p [] adviceDCinsArgs


-----


debugColor :: Action
debugColor (NoArgs' i mq) = (send mq . nl . T.concat $ msg) >> logPlaExec (prefixDebugCmd "color") i
  where
    msg :: [] T.Text
    msg = [ nl . T.concat $ [ pad 15 . showText $ ansi, mkColorDesc fg bg, ansi, " CurryMUD ", dfltColor ]
          | fgi <- intensities, fgc <- colors, bgi <- intensities, bgc <- colors
          , let fg = (fgi, fgc), let bg = (bgi, bgc), let ansi = mkColorANSI fg bg ]
    mkColorDesc (mkColorName -> fg) (mkColorName -> bg) = fg <> "on " <> bg
    mkColorName = uncurry (<>) . (pad 6 . showText *** padColorName . showText)
debugColor p = withoutArgs debugColor p


-----


debugCPU :: Action
debugCPU (NoArgs i mq cols) = do
    wrapSend mq cols =<< [ "CPU time: " <> time | time <- liftIO cpuTime ]
    logPlaExec (prefixDebugCmd "cpu") i
  where
    cpuTime = showText . (`divide` 10 ^ 12) <$> getCPUTime
debugCPU p = withoutArgs debugCPU p


-----


debugDispCmdList :: Action
debugDispCmdList p@(LowerNub' i as) = dispCmdList debugCmds p >> logPlaExecArgs (prefixDebugCmd "?") as i
debugDispCmdList p                  = patternMatchFail "debugDispCmdList" [ showText p ]


-----


debugDispEnv :: Action
debugDispEnv (NoArgs i mq cols)  = do
    pager i mq =<< [ concatMap (wrapIndent 2 cols) . mkEnvListTxt $ env | env <- liftIO getEnvironment ]
    logPlaExecArgs (prefixDebugCmd "env") [] i
debugDispEnv p@(ActionParams { plaId, args }) = do
    dispMatches p 2 =<< [ mkEnvListTxt env | env <- liftIO getEnvironment ]
    logPlaExecArgs (prefixDebugCmd "env") args plaId


mkEnvListTxt :: [(String, String)] -> [T.Text]
mkEnvListTxt = map (mkAssocTxt . (both %~ T.pack))
  where
    mkAssocTxt (a, b) = T.concat [ envVarColor, a, ": ", dfltColor, b ]


-----


debugId :: Action
debugId p@AdviseNoArgs       = advise p [] adviceDIdNoId
debugId (OneArg i mq cols a) = case reads . T.unpack $ a :: [(Int, String)] of
  [(searchId, "")] -> helper searchId
  _                -> wrapSend mq cols . sorryParseId $ a
  where
    helper searchId@(showText -> searchIdTxt)
      | searchId < 0 = sorryWtf mq cols
      | otherwise    = getState >>= \ms -> do
          let f     = commas . map (showText . fst)
              mkTxt =
                  [ [ "Tables containing key " <> searchIdTxt <> ":"
                    , commas . map fst . filter ((searchId `elem`) . snd) . mkTblNameKeysList $ ms ]
                  , [ T.concat [ "Channels with an ", dblQuote "chanId", " of ", searchIdTxt, ": " ]
                    , f . filter ((== searchId) . view chanId . snd) . tblToList chanTbl $ ms ]
                  , [ T.concat [ "Entities with an ", dblQuote "entId", " of ", searchIdTxt, ": " ]
                    , f . filter ((== searchId) . view entId . snd) . tblToList entTbl $ ms ]
                  , [ T.concat [ "Equipment maps containing ID ", searchIdTxt, ": " ]
                    , f . filter ((searchId `elem`) . M.elems . snd) . tblToList eqTbl $ ms ]
                  , [ T.concat [ "Inventories containing ID ", searchIdTxt, ": " ]
                    , f . filter ((searchId `elem`) . snd) . tblToList invTbl $ ms ]
                  , [ T.concat [ "PCs with a ", dblQuote "rmId", " of ", searchIdTxt, ": " ]
                    , f . filter ((== searchId) . view rmId . snd) . tblToList pcTbl $ ms ]
                  , [ T.concat [ "Players being peeped by ID ", searchIdTxt, ": " ]
                    , f . filter ((searchId `elem`) . view peepers . snd) $ plaTblList ]
                  , [ T.concat [ "Players peeping ID ", searchIdTxt, ": " ]
                    , f . filter ((searchId `elem`) . view peeping . snd) $ plaTblList ]
                  , [ T.concat [ "Players with a ", dblQuote "lastRmId", " of ", searchIdTxt, ": " ]
                    , f . filter ((== Just searchId) . view lastRmId . snd) $ plaTblList ] ]
              plaTblList = tblToList plaTbl ms
          mapM_ (multiWrapSend mq cols) mkTxt
          logPlaExecArgs (prefixDebugCmd "id") (pure a) i
debugId p = advise p [] adviceDIdArgs


sorryWtf :: MsgQueue -> Cols -> MudStack ()
sorryWtf mq cols = wrapSend mq cols $ wtfColor <> "He don't." <> dfltColor


tblToList :: Optical (->) (->) (Const [(Id, a)]) MudState MudState (IM.IntMap a) (IM.IntMap a) -> MudState -> [(Id, a)]
tblToList lens = views lens IM.toList


mkTblNameKeysList :: MudState -> [(T.Text, Inv)]
mkTblNameKeysList ms = [ ("Arm",              tblKeys armTbl           ms)
                       , ("Chan",             tblKeys chanTbl          ms)
                       , ("Cloth",            tblKeys clothTbl         ms)
                       , ("Coins",            tblKeys coinsTbl         ms)
                       , ("Con",              tblKeys conTbl           ms)
                       , ("Ent",              tblKeys entTbl           ms)
                       , ("EqMap",            tblKeys eqTbl            ms)
                       , ("Inv",              tblKeys invTbl           ms)
                       , ("Mob",              tblKeys mobTbl           ms)
                       , ("MsgQueue",         tblKeys msgQueueTbl      ms)
                       , ("Obj",              tblKeys objTbl           ms)
                       , ("PC",               tblKeys pcTbl            ms)
                       , ("PlaLogTbl",        tblKeys plaLogTbl        ms)
                       , ("Pla",              tblKeys plaTbl           ms)
                       , ("Rm",               tblKeys rmTbl            ms)
                       , ("RmTeleNameTbl",    tblKeys rmTeleNameTbl    ms)
                       , ("RndmNamesMstrTbl", tblKeys rndmNamesMstrTbl ms)
                       , ("TeleLinkMstrTbl",  tblKeys teleLinkMstrTbl  ms)
                       , ("TeleLinkTbl",      tblKeys teleLinkMstrTbl  ms)
                       , ("Type",             tblKeys typeTbl          ms)
                       , ("Wpn",              tblKeys wpnTbl           ms) ]


tblKeys :: Optical (->) (->) (Const [Id]) MudState MudState (IM.IntMap a) (IM.IntMap a) -> MudState -> [Id]
tblKeys lens = views lens IM.keys


-----


debugKeys :: Action
debugKeys (NoArgs i mq cols) = getState >>= \ms -> do
    multiWrapSend mq cols . intercalate [""] . map mkKeysTxt . mkTblNameKeysList $ ms
    logPlaExec (prefixDebugCmd "keys") i
  where
    mkKeysTxt (tblName, ks) = [ tblName <> ": ", showText ks ]
debugKeys p = withoutArgs debugKeys p


-----


debugLog :: Action
debugLog (NoArgs' i mq) = helper >> ok mq >> logPlaExec (prefixDebugCmd "log") i
  where
    helper       = replicateM_ 100 . onEnv $ liftIO . void . forkIO . runReaderT heavyLogging
    heavyLogging = replicateM_ 100 . logNotice "debugLog heavyLogging" =<< mkMsg
    mkMsg        = [ "Logging from " <> ti <> "." | (showText -> ti) <- liftIO myThreadId ]
debugLog p = withoutArgs debugLog p


-----


type Base = Int


debugNumber :: Action
debugNumber p@AdviseNoArgs     = advise p [] adviceDNumberNoArgs
debugNumber p@(AdviseOneArg _) = advise p [] adviceDNumberNoBase
debugNumber (WithArgs i mq cols [ numTxt, baseTxt ]) =
    case reads . T.unpack $ baseTxt :: [(Base, String)] of
      [(base, "")] | not . inRange (2, 36) $ base -> sorryParseBase
                   | otherwise -> case numTxt `inBase` base of
                     [(res, "")] -> do
                         send mq . nlnl . showText $ res
                         logPlaExecArgs (prefixDebugCmd "number") [ numTxt, baseTxt ] i
                     _ -> sorryParseNum base
      _ -> sorryParseBase
  where
    sorryParseBase     = wrapSend mq cols $ dblQuote baseTxt <> " is not a valid base."
    sorryParseNum base = wrapSend mq cols . T.concat $ [ dblQuote numTxt
                                                       , " is not a valid number in base "
                                                       , showText base
                                                       , "." ]
debugNumber p = advise p [] adviceDNumberArgs


inBase :: T.Text -> Base -> [(Int, String)]
numTxt `inBase` base = readInt base (isValidDigit base) letterToNum . T.unpack $ numTxt


isValidDigit :: Base -> Char -> Bool
isValidDigit base (toLower -> c) | isDigit c                    = digitToInt c < base
                                 | not . inRange ('a', 'z') $ c = False
                                 | otherwise                    = let val = fromJust . lookup c . zip ['a'..] $ [11..]
                                                                  in val <= base


letterToNum :: Char -> Int
letterToNum c | isDigit c = digitToInt c
              | otherwise = ord c - ord 'a' + 10


-----


debugOut :: Action
debugOut (NoArgs i mq cols) = getState >>= \ms -> do
    wrapSend mq cols . showText . getInv iLoggedOut $ ms
    logPlaExec (prefixDebugCmd "out") i
debugOut p = withoutArgs debugOut p


-----


debugParams :: Action
debugParams p@(WithArgs i mq cols _) = (wrapSend mq cols . showText $ p) >> logPlaExec (prefixDebugCmd "params") i
debugParams p = patternMatchFail "debugParams" [ showText p ]


-----


debugPersist :: Action
debugPersist (NoArgs' i mq) = do
    replicateM_ 10 $ persist >> ok mq
    logPlaExec (prefixDebugCmd "persist") i
debugPersist p = withoutArgs debugPersist p


-----


debugPurge :: Action
debugPurge (NoArgs' i mq) = purgeThreadTbls >> ok mq >> logPlaExec (prefixDebugCmd "purge") i
debugPurge p              = withoutArgs debugPurge p


purgeThreadTbls :: MudStack ()
purgeThreadTbls = do
    sequence_ [ purgePlaLogTbl, purgeTalkAsyncTbl, purgeThreadTbl ]
    logNotice "purgeThreadTbls" "purging the thread tables."


purgePlaLogTbl :: MudStack ()
purgePlaLogTbl = getState >>= \(views plaLogTbl (unzip . IM.assocs) -> (is, map fst -> asyncs)) -> do
    zipped <- [ zip is statuses | statuses <- liftIO . mapM poll $ asyncs ]
    modifyState $ \ms -> let plt = foldr purger (ms^.plaLogTbl) zipped in (ms & plaLogTbl .~ plt, ())
  where
    purger (_poo, Nothing) tbl = tbl
    purger (i,    _poo   ) tbl = tbl & at i .~ Nothing


purgeTalkAsyncTbl :: MudStack ()
purgeTalkAsyncTbl = getState >>= \(views talkAsyncTbl M.elems -> asyncs) -> do
    zipped <- [ zip asyncs statuses | statuses <- liftIO . mapM poll $ asyncs ]
    modifyState $ \ms -> let tat = foldr purger (ms^.talkAsyncTbl) zipped in (ms & talkAsyncTbl .~ tat, ())
  where
    purger (_poo,                Nothing) tbl = tbl
    purger (asyncThreadId -> ti, _poo   ) tbl = tbl & at ti .~ Nothing


purgeThreadTbl :: MudStack ()
purgeThreadTbl = getState >>= \(views threadTbl M.keys -> threadIds) -> do
    zipped <- [ zip threadIds statuses | statuses <- liftIO . mapM threadStatus $ threadIds ]
    modifyState $ \ms -> let tt = foldr purger (ms^.threadTbl) zipped in (ms & threadTbl .~ tt, ())
  where
    purger (ti, status) tbl = status == ThreadFinished ? tbl & at ti .~ Nothing :? tbl


-----


debugRnt :: Action
debugRnt (NoArgs i mq cols) = wrapSend mq cols . showText . M.toList . getRndmNamesTbl i =<< getState
debugRnt (OneArgNubbed i mq cols (capitalize -> a)) = getState >>= \ms ->
    let notFound    = wrapSend mq cols $ "There is no PC by the name of " <> a <> "."
        found match = (updateRndmName i . getIdForPCSing match $ ms) >>= \rndmName ->
            wrapSend mq cols . T.concat $ [ dblQuote rndmName
                                          , " has been randomly generated for "
                                          , match
                                          , "." ]
        pcSings = [ ms^.entTbl.ind pcId.sing | pcId <- views pcTbl IM.keys ms ]
    in findFullNameForAbbrev a pcSings |&| maybe notFound found
debugRnt ActionParams { plaMsgQueue, plaCols } = wrapSend plaMsgQueue plaCols "Sorry, but you can only generate a \
                                                                              \random name for one PC at a time."


-----


debugRandom :: Action
debugRandom (NoArgs i mq cols) = do
    wrapSend mq cols . showText =<< rndmRs 10 (0, 99)
    logPlaExec (prefixDebugCmd "random") i
debugRandom p = withoutArgs debugRandom p


-----


debugRemPut :: Action
debugRemPut (NoArgs' i mq) = do
    mapM_ (fakeClientInput mq) . take 10 . cycle . map (<> rest) $ [ "remove", "put" ]
    logPlaExec (prefixDebugCmd "remput") i
  where
    rest = T.concat [ " ", T.singleton allChar, " ", T.singleton selectorChar, "sack" ]
debugRemPut p = withoutArgs debugRemPut p


fakeClientInput :: MsgQueue -> T.Text -> MudStack ()
fakeClientInput mq = liftIO . atomically . writeTQueue mq . FromClient . nl


-----


debugRotate :: Action
debugRotate (NoArgs' i mq) = getState >>= \ms -> let lq = getLogQueue i ms in do
    liftIO . atomically . writeTQueue lq $ RotateLog
    ok mq
    logPlaExec (prefixDebugCmd "rotate") i
debugRotate p = withoutArgs debugRotate p


-----


debugTalk :: Action
debugTalk (NoArgs i mq cols) = getState >>= \(views talkAsyncTbl M.elems -> asyncs) -> do
    send mq =<< [ frame cols . multiWrap cols $ descs | descs <- mapM mkDesc asyncs ]
    logPlaExec (prefixDebugCmd "talk") i
  where
    mkDesc a    = [ T.concat [ "Talk async ", showText . asyncThreadId $ a, ": ", statusTxt, "." ]
                  | statusTxt <- mkStatusTxt <$> (liftIO . poll $ a) ]
    mkStatusTxt = \case Nothing                                    -> "running"
                        Just (Left  (parensQuote . showText -> e)) -> "exception " <> e
                        Just (Right ()                           ) -> "finished"
debugTalk p = withoutArgs debugTalk p


-----


debugThread :: Action
debugThread (NoArgs i mq cols) = do
    (uncurry (:) . ((, Notice) *** pure . (, Error)) -> logAsyncKvs) <- asks $ (both %~ asyncThreadId) . getLogAsyncs
    (plt, M.assocs -> threadTblKvs) <- (view plaLogTbl *** view threadTbl) . dup <$> getState
    let plaLogTblKvs = [ (asyncThreadId . fst $ v, PlaLog k) | (k, v) <- IM.assocs plt ]
    send mq . frame cols . multiWrap cols =<< (mapM mkDesc . sort $ logAsyncKvs ++ threadTblKvs ++ plaLogTblKvs)
    logPlaExec (prefixDebugCmd "thread") i
  where
    mkDesc (ti, bracketPad 18 . mkTypeName -> tn) = [ T.concat [ padOrTrunc 16 . showText $ ti, tn, ts ]
                                                    | (showText -> ts) <- liftIO . threadStatus $ ti ]
    mkTypeName (PlaLog  (showText -> pi)) = padOrTrunc 10 "PlaLog"  <> pi
    mkTypeName (Receive (showText -> pi)) = padOrTrunc 10 "Receive" <> pi
    mkTypeName (Server  (showText -> pi)) = padOrTrunc 10 "Server"  <> pi
    mkTypeName (Talk    (showText -> pi)) = padOrTrunc 10 "Talk"    <> pi
    mkTypeName (showText -> tt)           = tt
debugThread p = withoutArgs debugThread p


getLogAsyncs :: MudData -> (LogAsync, LogAsync)
getLogAsyncs = (getAsync noticeLog *** getAsync errorLog) . dup
  where
    getAsync = flip views (fst . fromJust)


-----


debugThrow :: Action
debugThrow (NoArgs'' i) = logPlaExec (prefixDebugCmd "throw") i >> throwIO DivideByZero
debugThrow p            = withoutArgs debugThrow p


-----


debugThrowLog :: Action
debugThrowLog (NoArgs' i mq) = getState >>= \ms -> let lq = getLogQueue i ms in
    (liftIO . atomically . writeTQueue lq $ Throw) >> ok mq >> logPlaExec (prefixDebugCmd "throwlog") i
debugThrowLog p = withoutArgs debugThrowLog p


-----


debugToken :: Action
debugToken (NoArgs i mq cols) = do
    multiWrapSend mq cols . T.lines . parseTokens . T.unlines $ tokenTxts
    logPlaExec (prefixDebugCmd "token") i
  where
    tokenTxts = [ charTokenDelimiter  `T.cons` charTokenDelimiter `T.cons` " literal charTokenDelimiter"
                , charTokenDelimiter  `T.cons` "a allChar"
                , charTokenDelimiter  `T.cons` "c adverbCloseChar"
                , charTokenDelimiter  `T.cons` "d adminCmdChar"
                , charTokenDelimiter  `T.cons` "e emoteNameChar"
                , charTokenDelimiter  `T.cons` "h chanTargetChar"
                , charTokenDelimiter  `T.cons` "i indexChar"
                , charTokenDelimiter  `T.cons` "l selectorChar"
                , charTokenDelimiter  `T.cons` "m amountChar"
                , charTokenDelimiter  `T.cons` "o adverbOpenChar"
                , charTokenDelimiter  `T.cons` "p expCmdChar"
                , charTokenDelimiter  `T.cons` "r emoteTargetChar"
                , charTokenDelimiter  `T.cons` "s slotChar"
                , charTokenDelimiter  `T.cons` "t sayToChar"
                , charTokenDelimiter  `T.cons` "x emoteChar"
                , styleTokenDelimiter `T.cons` styleTokenDelimiter `T.cons` " literal styleTokenDelimiter"
                , styleTokenDelimiter `T.cons` ("aabbrevColor"       <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("ddfltColor"         <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("hheaderColor"       <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("lselectorColor"     <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("nnoUnderlineANSI"   <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("pprefixColor"       <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("qquoteColor"        <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("rarrowColor"        <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("ssyntaxSymbolColor" <> dfltColorStyleToken  )
                , styleTokenDelimiter `T.cons` ("uunderlineANSI"     <> noUnderlineStyleToken)
                , styleTokenDelimiter `T.cons` ("zzingColor"         <> dfltColorStyleToken  )
                , "literal msgTokenDelimiter: " <> (T.pack . replicate 2 $ msgTokenDelimiter)
                , "dfltBootMsg: "     <> (msgTokenDelimiter `T.cons` "b")
                , "dfltShutdownMsg: " <> (msgTokenDelimiter `T.cons` "s") ]
    dfltColorStyleToken   = styleTokenDelimiter `T.cons` "d"
    noUnderlineStyleToken = styleTokenDelimiter `T.cons` "n"
debugToken p = withoutArgs debugToken p


-----


debugUnderline :: Action
debugUnderline (NoArgs i mq cols) = do
    wrapSend mq cols $ showText underlineANSI <> underline " This text is underlined. " <> showText noUnderlineANSI
    logPlaExec (prefixDebugCmd "underline") i
debugUnderline p = withoutArgs debugUnderline p


-----


debugWeight :: Action
debugWeight p@AdviseNoArgs       = advise p [] adviceDWeightNoArgs
debugWeight (OneArg i mq cols a) = case reads . T.unpack $ a :: [(Int, String)] of
  [(searchId, "")] -> helper searchId
  _                -> wrapSend mq cols $ dblQuote a <> " is not a valid ID."
  where
    helper searchId
      | searchId < 0 = sorryWtf mq cols
      | otherwise    = do
          send mq . nlnl . showText . calcWeight searchId =<< getState
          logPlaExecArgs (prefixDebugCmd "weight") (pure a) i
debugWeight p = advise p [] adviceDWeightArgs


-----


debugWrap :: Action
debugWrap p@AdviseNoArgs       = advise p [] adviceDWrapNoArgs
debugWrap (OneArg i mq cols a) = case reads . T.unpack $ a :: [(Int, String)] of
  [(lineLen, "")] -> helper lineLen
  _               -> sorryParse
  where
    sorryParse = wrapSend mq cols $ dblQuote a <> " is not a valid line length."
    helper lineLen | lineLen < 0                                = sorryWtf         mq cols
                   | not . inRange (minCols, maxCols) $ lineLen = sorryWrapLineLen mq cols
                   | otherwise                                  = do
                       send mq . frame lineLen . wrapUnlines lineLen $ wrapMsg
                       logPlaExecArgs (prefixDebugCmd "wrap") (pure a) i
debugWrap p = advise p [] adviceDWrapArgs


wrapMsg :: T.Text
wrapMsg = (<> dfltColor) . T.unwords $ wordy
  where
    wordy :: [] T.Text
    wordy = [ T.concat [ u
                       , mkFgColorANSI (Dull, c)
                       , "This is "
                       , showText c
                       , " text." ] | c <- Black `delete` colors, u <- [ underlineANSI, noUnderlineANSI ] ]


-----


debugWrapIndent :: Action
debugWrapIndent p@AdviseNoArgs     = advise p [] adviceDWrapIndentNoArgs
debugWrapIndent p@(AdviseOneArg _) = advise p [] adviceDWrapIndentNoAmt
debugWrapIndent (WithArgs i mq cols [a, b]) = do
    parsed <- (,) <$> parse a sorryParseLineLen <*> parse b sorryParseIndent
    unless (uncurry (||) $ parsed & both %~ (()#)) . uncurry helper $ parsed & both %~ (getSum . fromJust)
  where
    parse txt sorry = case reads . T.unpack $ txt :: [(Int, String)] of
      [(x, "")] -> unadulterated . Sum $ x
      _         -> emptied sorry
    sorryParseLineLen = wrapSend mq cols $ dblQuote a <> " is not a valid line length."
    sorryParseIndent  = wrapSend mq cols $ dblQuote b <> " is not a valid width amount."
    helper lineLen indent | any (< 0) [ lineLen, indent ]              = sorryWtf         mq cols
                          | not . inRange (minCols, maxCols) $ lineLen = sorryWrapLineLen mq cols
                          | indent >= lineLen                          = sorryIndent
                          | otherwise                                  = do
                              send mq . frame lineLen . T.unlines . wrapIndent indent lineLen $ wrapMsg
                              logPlaExecArgs (prefixDebugCmd "wrapindent") [a, b] i
    sorryIndent = wrapSend mq cols "The indent amount must be less than the line length."
debugWrapIndent p = advise p [] adviceDWrapIndentArgs
