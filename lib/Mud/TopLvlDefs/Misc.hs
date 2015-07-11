{-# LANGUAGE OverloadedStrings #-}

module Mud.TopLvlDefs.Misc where

import Mud.Misc.ANSI

import Data.Monoid ((<>))
import System.Posix.Types (FileOffset)
import qualified Data.Text as T


aggregateCoinNames :: [T.Text]
aggregateCoinNames = [ "coin", "coins" ]


allCoinNames :: [T.Text]
allCoinNames = coinNames ++ aggregateCoinNames


chanDbTblsRecCounterDelay :: Int
chanDbTblsRecCounterDelay = 10


coinNames :: [T.Text]
coinNames = [ "cp", "sp", "gp" ]


coinFullNames :: [T.Text]
coinFullNames = [ "copper piece", "silver piece", "gold piece" ]


dfltPrompt :: T.Text
dfltPrompt = promptColor <> "->" <> dfltColor


isDebug :: Bool
isDebug = True


logRotationDelay :: Int
logRotationDelay = 5 * 60


maxCmdLen :: Int
maxCmdLen = 11


maxCols, minCols :: Int
maxCols = 200
minCols = 30


maxHelpTopicLen :: Int
maxHelpTopicLen = 12


maxInacSecs :: Integer
maxInacSecs = 10 * 60


maxNameLen,    minNameLen    :: Int
maxNameLenTxt, minNameLenTxt :: T.Text
maxNameLen    = 12
maxNameLenTxt = "twelve"
minNameLen    = 3
minNameLenTxt = "three"


maxPageLines, minPageLines :: Int
maxPageLines = 150
minPageLines = 8


maxLogSize :: FileOffset
maxLogSize = 100000


noOfLogFiles :: Int
noOfLogFiles = 10


noOfPersistedWorlds :: Int
noOfPersistedWorlds = 25


noOfTitles :: Int
noOfTitles = 33


port :: Int
port = 9696


stdLinkNames :: [T.Text]
stdLinkNames = [ "n", "ne", "e", "se", "s", "sw", "w", "nw", "u", "d" ]


threadTblPurgerDelay :: Int
threadTblPurgerDelay = 60 * 60


ver :: T.Text
ver = "0.1.0.0 (in development since 2013-10)"


worldPersisterDelay :: Int
worldPersisterDelay = 10 * 60
