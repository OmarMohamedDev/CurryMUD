{-# OPTIONS_GHC -fno-warn-type-defaults #-}
{-# LANGUAGE MonadComprehensions, OverloadedStrings, TypeFamilies, ViewPatterns #-}

module Mud.Threads.ThreadTblPurger ( purgeThreadTbls
                                   , threadThreadTblPurger ) where

import Mud.Data.State.MudData
import Mud.Data.State.Util.Misc
import Mud.Threads.Misc
import Mud.TopLvlDefs.Misc
import Mud.Util.Operators
import qualified Mud.Misc.Logging as L (logNotice)

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (asyncThreadId, poll)
import Control.Exception.Lifted (catch, handle)
import Control.Lens (at, views)
import Control.Lens.Operators ((&), (.~), (^.))
import Control.Monad (forever)
import Control.Monad.IO.Class (liftIO)
import GHC.Conc (ThreadStatus(..), threadStatus)
import qualified Data.IntMap.Lazy as IM (assocs)
import qualified Data.Map.Lazy as M (elems, keys)
import qualified Data.Text as T


default (Int)


-----


logNotice :: T.Text -> T.Text -> MudStack ()
logNotice = L.logNotice "Mud.Threads.ThreadTblPurger"


-- ==================================================


threadThreadTblPurger :: MudStack ()
threadThreadTblPurger = handle (threadExHandler "thread table purger") $ do
    setThreadType ThreadTblPurger
    logNotice "threadThreadTblPurger" "thread table purger started."
    let loop = (liftIO . threadDelay $ threadTblPurgerDelay * 10 ^ 6) >> purgeThreadTbls
    forever loop `catch` die "thread table purger" Nothing


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
