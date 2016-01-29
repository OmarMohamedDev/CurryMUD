{-# LANGUAGE LambdaCase, OverloadedStrings, RecordWildCards, ViewPatterns #-}

module Mud.Cmds.Msgs.Sorry ( sorryAdminChanSelf
                           , sorryAdminChanTargetName
                           , sorryAdminName
                           , sorryAlreadyPossessed
                           , sorryAlreadyPossessing
                           , sorryAlteredRm
                           , sorryAsAdmin
                           , sorryAsSelf
                           , sorryAsType
                           , sorryBanAdmin
                           , sorryBanSelf
                           , sorryBootSelf
                           , sorryBracketedMsg
                           , sorryChanIncog
                           , sorryChanMsg
                           , sorryChanName
                           , sorryChanNoOneListening
                           , sorryChanTargetName
                           , sorryChanTargetNameFromContext
                           , sorryCmdNotFound
                           , sorryCon
                           , sorryConInEq
                           , sorryConnectAlready
                           , sorryConnectChanName
                           , sorryConnectIgnore
                           , sorryDisconnectIgnore
                           , sorryDropInEq
                           , sorryDropInRm
                           , sorryEmoteExcessTargets
                           , sorryEmoteTargetCoins
                           , sorryEmoteTargetInEq
                           , sorryEmoteTargetInInv
                           , sorryEmoteTargetRmOnly
                           , sorryEmoteTargetType
                           , sorryEquipCoins
                           , sorryEquipInvLook
                           , sorryExpCmdCoins
                           , sorryExpCmdIllegalTarget
                           , sorryExpCmdInInvEq
                           , sorryExpCmdLen
                           , sorryExpCmdName
                           , sorryExpCmdRequiresTarget
                           , sorryExpCmdTargetType
                           , sorryGetEmptyRm
                           , sorryGetEnc
                           , sorryGetInEq
                           , sorryGetInInv
                           , sorryGetNothingHere
                           , sorryGetType
                           , sorryGiveEnc
                           , sorryGiveExcessTargets
                           , sorryGiveInEq
                           , sorryGiveInRm
                           , sorryGiveToCoin
                           , sorryGiveToEq
                           , sorryGiveToInv
                           , sorryGiveType
                           , sorryGoExit
                           , sorryGoParseDir
                           , sorryHelpName
                           , sorryIgnoreLocPref
                           , sorryIgnoreLocPrefPlur
                           , sorryIncog
                           , sorryIndent
                           , sorryInterpNameBanned
                           , sorryInterpNameDict
                           , sorryInterpNameExcessArgs
                           , sorryInterpNameIllegal
                           , sorryInterpNameLen
                           , sorryInterpNameLoggedIn
                           , sorryInterpNameProfanityBoot
                           , sorryInterpNameProfanityLogged
                           , sorryInterpNamePropName
                           , sorryInterpNameTaken
                           , sorryInterpPager
                           , sorryIntroAlready
                           , sorryIntroCoin
                           , sorryIntroInEq
                           , sorryIntroInInv
                           , sorryIntroNoOneHere
                           , sorryIntroType
                           , sorryLinkAlready
                           , sorryLinkCoin
                           , sorryLinkInEq
                           , sorryLinkInInv
                           , sorryLinkIntroSelf
                           , sorryLinkIntroTarget
                           , sorryLinkNoOneHere
                           , sorryLinkType
                           , sorryLoggedOut
                           , sorryLookEmptyRm
                           , sorryLookNothingHere
                           , sorryMsgIncog
                           , sorryNewChanExisting
                           , sorryNewChanName
                           , sorryNoAdmins
                           , sorryNoConHere
                           , sorryNoLinks
                           , sorryNoOneHere
                           , sorryNotPossessed
                           , sorryParseArg
                           , sorryParseBase
                           , sorryParseChanId
                           , sorryParseId
                           , sorryParseIndent
                           , sorryParseInOut
                           , sorryParseLineLen
                           , sorryParseNum
                           , sorryParseSetting
                           , sorryPCName
                           , sorryPCNameLoggedIn
                           , sorryPeepAdmin
                           , sorryPeepSelf
                           , sorryPickInEq
                           , sorryPickInInv
                           , sorryPickNotFlower
                           , sorryPossessType
                           , sorryPp
                           , sorryPutEmptyRm
                           , sorryPutExcessCon
                           , sorryPutInCoin
                           , sorryPutInEq
                           , sorryPutInRm
                           , sorryPutInsideSelf
                           , sorryPutVol
                           , sorryQuitCan'tAbbrev
                           , sorryReadSign
                           , sorryReadyAlreadyWearing
                           , sorryReadyAlreadyWearingRing
                           , sorryReadyAlreadyWielding
                           , sorryReadyAlreadyWieldingTwoHanded
                           , sorryReadyAlreadyWieldingTwoWpns
                           , sorryReadyClothFull
                           , sorryReadyClothFullOneSide
                           , sorryReadyCoins
                           , sorryReadyInEq
                           , sorryReadyInRm
                           , sorryReadyRol
                           , sorryReadyType
                           , sorryReadyWpnHands
                           , sorryReadyWpnRol
                           , sorryRegPlaName
                           , sorryRemCoin
                           , sorryRemEmpty
                           , sorryRemEnc
                           , sorryRemExcessCon
                           , sorryRemIgnore
                           , sorrySayCoins
                           , sorrySayExcessTargets
                           , sorrySayInEq
                           , sorrySayInInv
                           , sorrySayNoOneHere
                           , sorrySayTargetType
                           , sorrySearch
                           , sorrySetName
                           , sorrySetRange
                           , sorryShowExcessTargets
                           , sorryShowInRm
                           , sorryShowTarget
                           , sorrySudoerDemoteRoot
                           , sorrySudoerDemoteSelf
                           , sorryTeleAlready
                           , sorryTeleLoggedOutRm
                           , sorryTeleRmName
                           , sorryTeleSelf
                           , sorryTrashInEq
                           , sorryTrashInRm
                           , sorryTunedOutChan
                           , sorryTunedOutICChan
                           , sorryTunedOutOOCChan
                           , sorryTunedOutPCSelf
                           , sorryTunedOutPCTarget
                           , sorryTuneName
                           , sorryTwoWayLink
                           , sorryTwoWayTargetName
                           , sorryUnlinkIgnore
                           , sorryUnlinkName
                           , sorryUnreadyCoins
                           , sorryUnreadyInInv
                           , sorryUnreadyInRm
                           , sorryWireAlready
                           , sorryWrapLineLen
                           , sorryWtf ) where

import Mud.Cmds.Util.CmdPrefixes
import Mud.Data.Misc
import Mud.Data.State.MudData
import Mud.Data.State.Util.Misc
import Mud.Misc.ANSI
import Mud.TopLvlDefs.Chars
import Mud.TopLvlDefs.Misc
import Mud.Util.Misc hiding (patternMatchFail)
import Mud.Util.Quoting
import Mud.Util.Text
import qualified Mud.Util.Misc as U (patternMatchFail)

import Data.Char (toLower)
import Data.Monoid ((<>))
import Data.Text (Text)
import qualified Data.Text as T


{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}


-----


patternMatchFail :: Text -> [Text] -> a
patternMatchFail = U.patternMatchFail "Mud.Cmds.Msgs.Sorry"


-- ==================================================


sorryIgnoreLocPref :: Text -> Text
sorryIgnoreLocPref msg = parensQuote $ msg <> " need not be given a location prefix. The location prefix you provided \
                                              \will be ignored."


sorryIgnoreLocPrefPlur :: Text -> Text
sorryIgnoreLocPrefPlur msg = parensQuote $ msg <> " need not be given location prefixes. The location prefixes you \
                                                  \provided will be ignored."


-----


sorryAdminChanSelf :: Text
sorryAdminChanSelf = "You talk to yourself."


sorryAdminChanTargetName :: Text -> Text
sorryAdminChanTargetName = sorryChanTargetName "admin"


-----


sorryAdminName :: Text -> Text
sorryAdminName n = "There is no administrator by the name of " <> dblQuote n <> "."


-----


sorryAlreadyPossessed :: Sing -> Sing -> Text
sorryAlreadyPossessed a b = but . T.concat $ [ theOnLower a, " is already possessed by ", b, "." ]


-----


sorryAlreadyPossessing :: Sing -> Text
sorryAlreadyPossessing s = "You are already possessing " <> theOnLower s <> "."


-----


sorryAlteredRm :: Text
sorryAlteredRm = "Too late! You moved."


-----


sorryAsAdmin :: Text
sorryAsAdmin = can'tTarget $ "an admin" <> withAs


can'tTarget :: Text -> Text
can'tTarget = can't . ("target " <>)


can't :: Text -> Text
can't = ("You can't " <>)


withAs :: Text
withAs = " with the " <> dblQuote (prefixAdminCmd "as") <> " command."


sorryAsSelf :: Text
sorryAsSelf = can'tTarget $ "yourself" <> withAs


sorryAsType :: Type -> Text
sorryAsType t = can'tTarget $ aOrAnType t <> withAs


-----


sorryBanAdmin :: Text
sorryBanAdmin = can't "ban an admin."


sorryBanSelf :: Text
sorryBanSelf = can't "ban yourself."


-----


sorryBootSelf :: Text
sorryBootSelf = can't "boot yourself."


-----


sorryBracketedMsg :: Text
sorryBracketedMsg = can't "open or close your message with brackets."


-----


sorryChanIncog :: Text -> Text
sorryChanIncog t = can't $ "send a message on " <> t <> " channel while incognito."


sorryChanMsg :: Text
sorryChanMsg = "You must also provide a message to send."


sorryChanName :: ChanName -> Text
sorryChanName cn = "You are not connected to a channel named " <> dblQuote cn <> "."


sorryChanNoOneListening :: Text -> Text
sorryChanNoOneListening t = "You are the only person tuned in to the " <> t <> " channel."


sorryChanTargetName :: Text -> Text -> Text
sorryChanTargetName cn n = T.concat [ "There is no one by the name of "
                                    , dblQuote n
                                    , " currently tuned in to the "
                                    , cn
                                    , " channel." ]


sorryChanTargetNameFromContext :: Text -> ChanContext -> Text
sorryChanTargetNameFromContext n ChanContext { .. } = sorryChanTargetName effChanName n
  where
    effChanName = maybe someCmdName dblQuote someChanName


-----


sorryCmdNotFound :: Text
sorryCmdNotFound = "What?"


-----


sorryCon :: Sing -> Text
sorryCon s = theOnLowerCap s <> " isn't a container."


sorryConInEq :: PutOrRem -> Text
sorryConInEq por =
    let (a, b) = expand por
    in butCan't . T.concat $ [ a
                             , " an item "
                             , b
                             , " a container in your readied equipment. Please unready the container first." ]
  where
    expand = \case Put -> ("put",    "into")
                   Rem -> ("remove", "from")


butCan't :: Text -> Text
butCan't = but . ("you can't " <>)


but :: Text -> Text
but = ("Sorry, but " <>)


-----


sorryConnectAlready :: Sing -> ChanName -> Text
sorryConnectAlready s cn = T.concat [ s, " is already connected to the ", dblQuote cn, " channel." ]


sorryConnectChanName :: Sing -> ChanName -> Text
sorryConnectChanName s cn = T.concat [ s, " is already connected to a channel named ", dblQuote cn, "." ]


sorryConnectIgnore :: Text
sorryConnectIgnore = sorryIgnoreLocPrefPlur "The names of the people you would like to connect"


-----


sorryDisconnectIgnore :: Text
sorryDisconnectIgnore = sorryIgnoreLocPrefPlur "The names of the people you would like to disconnect"


-----


sorryDropInEq :: Text
sorryDropInEq = butCan't "drop an item in your readied equipment. Please unready the item(s) first."


sorryDropInRm :: Text
sorryDropInRm = can't "drop an item that's already in your current room. If you're intent on dropping it, try picking \
                      \it up first!"


-----


sorryEmoteExcessTargets :: Text
sorryEmoteExcessTargets = but "you can only target one person at a time."


sorryEmoteTargetCoins :: Text
sorryEmoteTargetCoins = can'tTarget "coins."


sorryEmoteTargetInEq :: Text
sorryEmoteTargetInEq = can'tTarget "an item in your readied equipment."


sorryEmoteTargetInInv :: Text
sorryEmoteTargetInInv = can'tTarget "an item in your inventory."


sorryEmoteTargetRmOnly :: Text
sorryEmoteTargetRmOnly = "You can only target a person in your current room."


sorryEmoteTargetType :: Sing -> Text
sorryEmoteTargetType s = can'tTarget $ aOrAn s <> "."


-----


sorryEquipCoins :: Text
sorryEquipCoins = "You don't have any coins among your readied equipment."


-----


sorryEquipInvLook :: EquipInvLookCmd -> EquipInvLookCmd -> Text
sorryEquipInvLook a b = T.concat [ "You can only use the "
                                 , dblQuote . showText $ a
                                 , " command to examine items in your "
                                 , loc a
                                 , ". To examine items in your "
                                 , loc b
                                 , ", use the "
                                 , dblQuote . showText $ b
                                 , " command." ]
  where
    loc = \case EquipCmd -> "readied equipment"
                InvCmd   -> "inventory"
                LookCmd  -> "current room"


-----


sorryExpCmdCoins :: Text
sorryExpCmdCoins = but "expressive commands cannot be used with coins."


sorryExpCmdInInvEq :: InInvEqRm -> Text
sorryExpCmdInInvEq loc = can'tTarget $ "an item in your " <> loc' <> " with an expressive command."
  where
    loc' = case loc of InEq  -> "readied equipment"
                       InInv -> "inventory"
                       _     -> patternMatchFail "sorryExpCmdInInvEq loc'" [ showText loc ]


sorryExpCmdLen :: Text
sorryExpCmdLen = "An expressive command sequence may not be more than 2 words long."


sorryExpCmdName :: Text -> Text
sorryExpCmdName cn = "There is no expressive command by the name of " <> dblQuote cn <> "."


sorryExpCmdIllegalTarget :: ExpCmdName -> Text
sorryExpCmdIllegalTarget cn =  "The " <> dblQuote cn <> " expressive command cannot be used with a target."


sorryExpCmdRequiresTarget :: ExpCmdName -> Text
sorryExpCmdRequiresTarget cn = "The " <> dblQuote cn <> " expressive command requires a single target."


sorryExpCmdTargetType :: Text
sorryExpCmdTargetType = but "expressive commands can only target people."


-----


sorryGetEmptyRm :: Text
sorryGetEmptyRm = "You don't see anything to pick up on the ground here."


sorryGetEnc :: Text
sorryGetEnc = "You are too encumbered to carry "


sorryGetInEq :: Text
sorryGetInEq = butCan't $ "get an item in your readied equipment. If you want to move a readied item to your \
                          \inventory, use the " <>
                          dblQuote "unready"    <>
                          " command."


sorryGetInInv :: Text
sorryGetInInv = can't "get an item that's already in your inventory. If you're intent on picking it up, try dropping \
                      \it first!"


sorryGetNothingHere :: Text
sorryGetNothingHere = "You don't see anything here to pick up."


sorryGetType :: Text -> Text
sorryGetType t = can't $ "pick up " <> t <> "."


-----


sorryGiveEnc :: Text -> Text
sorryGiveEnc = (<> " is too encumbered to hold ")


sorryGiveExcessTargets :: Text
sorryGiveExcessTargets = but "you can only give things to one person at a time."


sorryGiveInEq :: Text
sorryGiveInEq = butCan't "give an item in your readied equipment. Please unready the item(s) first."


sorryGiveInRm :: Text
sorryGiveInRm = butCan't "give an item in your current room. Please pick up the item(s) first."


sorryGiveToCoin :: Text
sorryGiveToCoin = can't "give something to a coin."


sorryGiveToEq :: Text
sorryGiveToEq = can't "give something to an item in your readied equipment."


sorryGiveToInv :: Text
sorryGiveToInv = can't "give something to an item in your inventory."


sorryGiveType :: Type -> Text
sorryGiveType t = can't $ "give something to " <> aOrAnType t <> "."


-----


sorryGoExit :: Text
sorryGoExit = can't "go that way."


sorryGoParseDir :: Text -> Text
sorryGoParseDir t = dblQuote t <> " is not a valid exit."


-----


sorryHelpName :: Text -> Text
sorryHelpName t = "No help is available on " <> dblQuote t <> "."


-----


sorryIncog :: Text -> Text
sorryIncog cn = can't $ "use the " <> dblQuote cn <> " command while incognito."


-----


sorryIndent :: Text
sorryIndent = "The indent amount must be less than the line length."


-----


sorryInterpNameBanned :: Sing -> Text
sorryInterpNameBanned s = colorWith bootMsgColor $ s <> " has been banned from CurryMUD!"


sorryInterpNameDict :: Text
sorryInterpNameDict = "Your name cannot be an English word. Please choose an original fantasy name."


sorryInterpNameExcessArgs :: Text
sorryInterpNameExcessArgs = "Your name must be a single word."


sorryInterpNameIllegal :: Text
sorryInterpNameIllegal = "Your name cannot include any numbers or symbols."


sorryInterpNameLen :: Text
sorryInterpNameLen = T.concat [ "Your name must be between "
                              , minNameLenTxt
                              , " and "
                              , maxNameLenTxt
                              , " characters long." ]


sorryInterpNameLoggedIn :: Sing -> Text
sorryInterpNameLoggedIn s = s <> " is already logged in."


sorryInterpNameProfanityLogged :: Text
sorryInterpNameProfanityLogged = "Nice try. Your IP address has been logged. Keep this up and you'll get banned."


sorryInterpNameProfanityBoot :: Text
sorryInterpNameProfanityBoot = "Come back when you're ready to act like an adult!"


sorryInterpNamePropName :: Text
sorryInterpNamePropName = "Your name cannot be a real-world proper name. Please choose an original fantasy name."


sorryInterpNameTaken :: Text
sorryInterpNameTaken = but "that name is already taken."


-----


sorryInterpPager :: Text
sorryInterpPager = T.concat [ "Enter a blank line or "
                            , dblQuote "n"
                            , " for the next page, "
                            , dblQuote "b"
                            , " for the previous page, or "
                            , dblQuote "q"
                            , " to stop reading." ]


-----


sorryIntroAlready :: Text -> Text
sorryIntroAlready n = "You've already introduced yourself to " <> n <> "."


sorryIntroCoin :: Text
sorryIntroCoin = can't "introduce yourself to a coin."


sorryIntroInEq :: Text
sorryIntroInEq = can't "introduce yourself to an item in your readied equipment."


sorryIntroInInv :: Text
sorryIntroInInv = can't "introduce yourself to an item in your inventory."


sorryIntroNoOneHere :: Text
sorryIntroNoOneHere = "You don't see anyone here to introduce yourself to."


sorryIntroType :: Sing -> Text
sorryIntroType s = can't $ "introduce yourself to " <> theOnLower s <> "."


-----


sorryLinkAlready :: Text -> Text -> Text
sorryLinkAlready t n = T.concat [ "You've already established a ", t, " link with ", n, "." ]


sorryLinkCoin :: Text
sorryLinkCoin = can't "establish a telepathic link with a coin."


sorryLinkInEq :: Text
sorryLinkInEq = can't "establish a telepathic link with an item in your readied equipment."


sorryLinkInInv :: Text
sorryLinkInInv = can't "establish a telepathic link with an item in your inventory."


sorryLinkIntroSelf :: Sing -> Text
sorryLinkIntroSelf s = "You must first introduce yourself to " <> s <> "."


sorryLinkIntroTarget :: Text -> Text
sorryLinkIntroTarget n = "You don't know the " <> n <> "'s name."


sorryLinkNoOneHere :: Text
sorryLinkNoOneHere = "You don't see anyone here to link with."


sorryLinkType :: Sing -> Text
sorryLinkType s = can't $ "establish a telepathic link with " <> theOnLower s <> "."


-----


sorryLoggedOut :: Sing -> Text
sorryLoggedOut s = s <> " is not logged in."


-----


sorryLookEmptyRm :: Text
sorryLookEmptyRm = "You don't see anything to look at on the ground here."


sorryLookNothingHere :: Text
sorryLookNothingHere = "You don't see anything here to look at."


-----


sorryMsgIncog :: Text
sorryMsgIncog = can't "send a message to a player who is logged in while you are incognito."


-----


sorryNewChanExisting :: ChanName -> Text
sorryNewChanExisting cn = "You are already connected to a channel named " <> dblQuote cn <> "."


sorryNewChanName :: Text -> Text -> Text
sorryNewChanName a msg = T.concat [ dblQuote a, " is not a legal channel name ", parensQuote msg, "." ]


-----


sorryNoAdmins :: Text
sorryNoAdmins = "No administrators exist!"


-----


sorryNoConHere :: Text
sorryNoConHere = "You don't see any containers here."


-----


sorryNoOneHere :: Text
sorryNoOneHere = "You don't see anyone here."


-----


sorryNotPossessed :: Sing -> CmdName -> Text
sorryNotPossessed s cn = T.concat [ "You must first possess "
                                  , theOnLower s
                                  , " before you can use the "
                                  , dblQuote cn
                                  , " command." ]


-----


sorryNoLinks :: Text
sorryNoLinks = "You haven't established a telepathic link with anyone."


-----


sorryPCName :: Text -> Text
sorryPCName n = "There is no PC by the name of " <> dblQuote n <> "."


sorryPCNameLoggedIn :: Text -> Text
sorryPCNameLoggedIn n = "No PC by the name of " <> dblQuote n <> " is currently logged in."


-----


sorryParseArg :: Text -> Text
sorryParseArg a = dblQuote a <> " is not a valid argument."


sorryParseBase :: Text -> Text
sorryParseBase a = dblQuote a <> " is not a valid base."


sorryParseChanId :: Text -> Text
sorryParseChanId a = dblQuote a <> " is not a valid channel ID."


sorryParseId :: Text -> Text
sorryParseId a = dblQuote a <> " is not a valid ID."


sorryParseInOut :: Text -> Text -> Text
sorryParseInOut value n = T.concat [ dblQuote value
                                   , " is not a valid value for the "
                                   , dblQuote n
                                   , " setting. Please specify one of the following: "
                                   , inOutOrOnOff
                                   , "." ]
  where
    inOutOrOnOff = T.concat [ dblQuote "in"
                            , "/"
                            , dblQuote "out"
                            , " or "
                            , dblQuote "on"
                            , "/"
                            , dblQuote "off" ]


sorryParseIndent :: Text -> Text
sorryParseIndent a = dblQuote a <> " is not a valid width amount."


sorryParseLineLen :: Text -> Text
sorryParseLineLen a = dblQuote a <> " is not a valid line length."


sorryParseNum :: Text -> Text -> Text
sorryParseNum numTxt base = T.concat [ dblQuote numTxt, " is not a valid number in base ", base, "." ]


sorryParseSetting :: Text -> Text -> Text
sorryParseSetting value name = T.concat [ dblQuote value, " is not a valid value for the ", dblQuote name, " setting." ]


-----


sorryPeepAdmin :: Text
sorryPeepAdmin = can't "peep an admin."


sorryPeepSelf :: Text
sorryPeepSelf = can't "peep yourself."


-----


sorryPickNotFlower :: Text -> Text
sorryPickNotFlower t = can't $ "pick " <> aOrAn t <> "."


sorryPickInEq :: Text
sorryPickInEq = can't "pick an item in your readied equipment."


sorryPickInInv :: Text
sorryPickInInv = can't "pick an item in your inventory."


-----



sorryPossessType :: Type -> Text
sorryPossessType t = can't $ "possess " <> aOrAnType t <> "."


-----


sorryPp :: Text -> Text
sorryPp t = "You don't have enough psionic energy to " <> t <> "."


-----


sorryPutEmptyRm :: Text -> Text
sorryPutEmptyRm t = "You don't see " <> aOrAn t <> " here."


sorryPutExcessCon :: Text
sorryPutExcessCon = "You can only put things into one container at a time."


sorryPutInCoin :: Text
sorryPutInCoin = can't "put something inside a coin."


sorryPutInEq :: Text
sorryPutInEq = butCan't "put an item in your readied equipment into a container. Please unready the item(s) first."


sorryPutInRm :: Text
sorryPutInRm = butCan't "put item in your current room into a container. Please pick up the item(s) first."


sorryPutInsideSelf :: Sing -> Text
sorryPutInsideSelf s = can't $ "put the " <> s <> " inside itself."


sorryPutVol :: Sing -> Text
sorryPutVol s = "The " <> s <> " is too full to contain "


-----


sorryQuitCan'tAbbrev :: Text
sorryQuitCan'tAbbrev = T.concat [ "The "
                                , dblQuote "quit"
                                , " command may not be abbreviated. Type "
                                , dblQuote "quit"
                                , " with no arguments to quit CurryMUD." ]


-----


sorryReadSign :: Text
sorryReadSign = "The only thing to read here is the sign."


-----


sorryReadyAlreadyWearing :: Text -> Text
sorryReadyAlreadyWearing t = "You're already wearing " <> aOrAn t <> "."


sorryReadyAlreadyWearingRing :: Slot -> Sing -> Text
sorryReadyAlreadyWearingRing sl s = T.concat [ "You're already wearing "
                                             , aOrAn s
                                             , " on your "
                                             , pp sl
                                             , "." ]


sorryReadyAlreadyWielding :: Sing -> Slot -> Text
sorryReadyAlreadyWielding s sl = T.concat [ "You're already wielding ", aOrAn s, " with your ", pp sl, "." ]


sorryReadyAlreadyWieldingTwoHanded :: Text
sorryReadyAlreadyWieldingTwoHanded = "You're already wielding a two-handed weapon."


sorryReadyAlreadyWieldingTwoWpns :: Text
sorryReadyAlreadyWieldingTwoWpns = "You're already wielding two weapons."


sorryReadyClothFull :: Text -> Text
sorryReadyClothFull t = can't $ "wear any more " <> t <> "s."


sorryReadyClothFullOneSide :: Cloth -> Slot -> Text
sorryReadyClothFullOneSide (pp -> c) (pp -> s) = can't . T.concat $ [ "wear any more ", c, "s on your ", s, "." ]


sorryReadyCoins :: Text
sorryReadyCoins = can't "ready coins."


sorryReadyInEq :: Text
sorryReadyInEq = can't "ready an item that's already in your readied equipment."


sorryReadyInRm :: Text
sorryReadyInRm = butCan't "ready an item in your current room. Please pick up the item(s) first."


sorryReadyRol :: Sing -> RightOrLeft -> Text
sorryReadyRol s rol = can't . T.concat $ [ "wear ", aOrAn s, " on your ", pp rol, "." ]


sorryReadyType :: Sing -> Text
sorryReadyType s = can't $ "ready " <> aOrAn s <> "."


sorryReadyWpnHands :: Sing -> Text
sorryReadyWpnHands s = "Both hands are required to wield the " <> s <> "."


sorryReadyWpnRol :: Sing -> Text
sorryReadyWpnRol s = can't $ "wield " <> aOrAn s <> " with your finger!"


-----


sorryRegPlaName :: Text -> Text
sorryRegPlaName n = "There is no regular player by the name of " <> dblQuote n <> "."


-----


sorryRemEmpty :: Sing -> Text
sorryRemEmpty s = "The " <> s <> " is empty."


sorryRemEnc :: Text
sorryRemEnc = sorryGetEnc


sorryRemCoin :: Text
sorryRemCoin = can't "remove something from a coin."


sorryRemExcessCon :: Text
sorryRemExcessCon = "You can only remove things from one container at a time."


sorryRemIgnore :: Text
sorryRemIgnore = sorryIgnoreLocPrefPlur "The names of the items to be removed from a container"


-----


sorrySayCoins :: Text
sorrySayCoins = "You're talking to coins now?"


sorrySayExcessTargets :: Text
sorrySayExcessTargets = but "you can only say something to one person at a time."


sorrySayInEq :: Text
sorrySayInEq = can't "talk to an item in your readied equipment. Try saying something to someone in your current room."


sorrySayInInv :: Text
sorrySayInInv = can't "talk to an item in your inventory. Try saying something to someone in your current room."


sorrySayNoOneHere :: Text
sorrySayNoOneHere = "You don't see anyone here to talk to."


sorrySayTargetType :: Sing -> Text
sorrySayTargetType s = can't $ "talk to " <> aOrAn s <> "."


-----


sorrySearch :: Text
sorrySearch = "No matches found."


-----


sorrySetName :: Text -> Text
sorrySetName n = dblQuote n <> " is not a valid setting name."


sorrySetRange :: Text -> Int -> Int -> Text
sorrySetRange settingName minVal maxVal = T.concat [ capitalize settingName
                                                   , " must be between "
                                                   , showText minVal
                                                   , " and "
                                                   , showText maxVal
                                                   , "." ]


-----


sorryShowExcessTargets :: Text
sorryShowExcessTargets = but "you can only show something to one person at a time."


sorryShowInRm :: Text
sorryShowInRm = can't "show an item in your current room."


sorryShowTarget :: Text -> Text
sorryShowTarget t = can't $ "show something to " <> aOrAn t <> "."


-----


sorrySudoerDemoteRoot :: Text
sorrySudoerDemoteRoot = can't "demote Root."


sorrySudoerDemoteSelf :: Text
sorrySudoerDemoteSelf = can't "demote yourself."


-----


sorryTeleAlready :: Text
sorryTeleAlready = "You're already there!"


sorryTeleLoggedOutRm :: Text
sorryTeleLoggedOutRm = can't "teleport to the logged out room."


sorryTeleRmName :: Text -> Text
sorryTeleRmName n = T.concat [ dblQuote n
                             , " is not a valid room name. Type "
                             , colorWith quoteColor . prefixAdminCmd $ "telerm"
                             , " with no arguments to get a list of valid room names." ]


sorryTeleSelf :: Text
sorryTeleSelf = can't "teleport to yourself."


-----


sorryTrashInEq :: Text
sorryTrashInEq = butCan't "dispose of an item in your readied equipment. Please unready the item(s) first."


sorryTrashInRm :: Text
sorryTrashInRm = butCan't "dispose of an item in your current room. Please pick up the item(s) first."


-----


sorryTuneName :: Text -> Text
sorryTuneName n = "You don't have a connection by the name of " <> dblQuote n <> "."


-----


sorryTunedOutICChan :: ChanName -> Text
sorryTunedOutICChan = sorryTunedOutChan "tune" DoQuote


sorryTunedOutChan :: CmdName -> ShouldQuote -> Text -> Text
sorryTunedOutChan x sq y = T.concat [ "You have tuned out the "
                                    , onTrue (sq == DoQuote) dblQuote y
                                    , " channel. Type "
                                    , colorWith quoteColor . T.concat $ [ x, " ", y, "=in" ]
                                    , " to tune it back in." ]


sorryTunedOutOOCChan :: Text -> Text
sorryTunedOutOOCChan = sorryTunedOutChan "set" Don'tQuote


sorryTunedOutPCSelf :: Sing -> Text
sorryTunedOutPCSelf s = "You have tuned out " <> s <> "."


sorryTunedOutPCTarget :: Sing -> Text
sorryTunedOutPCTarget s = s <> " has tuned you out."


-----


sorryTwoWayLink :: Text -> Text
sorryTwoWayLink t = "You haven't established a two-way telepathic link with anyone named " <> dblQuote t <> "."


sorryTwoWayTargetName :: ExpCmdName -> Sing -> Text
sorryTwoWayTargetName cn s = T.concat [ "In a telepathic message to "
                                      , s
                                      , ", the only possible target is "
                                      , s
                                      , ". Please try "
                                      , colorWith quoteColor . T.concat $ [ T.singleton expCmdChar
                                                                          , cn
                                                                          , " "
                                                                          , T.singleton . toLower . T.head $ s ]
                                      , " instead." ]


-----


sorryUnlinkIgnore :: Text
sorryUnlinkIgnore = sorryIgnoreLocPrefPlur "The names of the people with whom you would like to unlink"


sorryUnlinkName :: Text -> Text
sorryUnlinkName t = "You don't have a link with " <> dblQuote t <> "."


-----


sorryUnreadyCoins :: Text
sorryUnreadyCoins = can't "unready coins."


sorryUnreadyInInv :: Text
sorryUnreadyInInv = can't "unready an item in your inventory."


sorryUnreadyInRm :: Text
sorryUnreadyInRm = can't "unready an item in your current room."


-----


sorryWireAlready :: ChanName -> Text
sorryWireAlready cn = "As you are already connected to the " <> dblQuote cn <> " channel, there is no need to tap it."


-----


sorryWrapLineLen :: Text
sorryWrapLineLen = T.concat [ "The line length must be between "
                            , showText minCols
                            , " and "
                            , showText maxCols
                            , " characters." ]


-----


sorryWtf :: Text
sorryWtf = colorWith wtfColor "He don't."
