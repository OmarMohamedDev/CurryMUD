{-# LANGUAGE OverloadedStrings #-}

module Mud.TheWorld.Zones.Warehouse (createWarehouse) where

import           Mud.Data.State.MudData
import           Mud.Data.State.Util.Make
import           Mud.Data.State.Util.Put
import qualified Mud.Misc.Logging as L (logNotice)
import           Mud.TheWorld.Zones.WarehouseIds

import           Data.Bits (zeroBits)
import           Data.Text (Text)
import qualified Data.Map.Strict as M (empty)


logNotice :: Text -> Text -> MudStack ()
logNotice = L.logNotice "Mud.TheWorld.Zones.Warehouse"


-- ==================================================
-- Zone definition:


createWarehouse :: MudStack ()
createWarehouse = do
  logNotice "createWarehouse" "creating the warehouse."

  putRm iWarehouseWelcome
        []
        mempty
        (mkRm (RmTemplate "Welcome to the warehouse"
            "This is the warehouse. Items to be cloned are stored here.\n\
            \There's just one rule: you can look, but don't touch!"
            Nothing
            Nothing
            zeroBits
            [ StdLink South iDwarfKit 0 ]
            (0, 0, 0)
            InsideEnv
            (Just "Welcome")
            M.empty [] []))
  putRm iDwarfKit
        []
        mempty
        (mkRm (RmTemplate "Dwarf kit"
            "This room holds the dwarf kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iWarehouseWelcome 0
            , StdLink South iElfKit           0 ]
            (0, -1, 0)
            InsideEnv
            (Just "Dwarf")
            M.empty [] []))
  putRm iElfKit
        []
        mempty
        (mkRm (RmTemplate "Elf kit"
            "This room holds the elf kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iDwarfKit    0
            , StdLink South iFelinoidKit 0 ]
            (0, -2, 0)
            InsideEnv
            (Just "Elf")
            M.empty [] []))
  putRm iFelinoidKit
        []
        mempty
        (mkRm (RmTemplate "Felinoid kit"
            "This room holds the felinoid kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iElfKit    0
            , StdLink South iHobbitKit 0 ]
            (0, -3, 0)
            InsideEnv
            (Just "Felinoid")
            M.empty [] []))
  putRm iHobbitKit
        []
        mempty
        (mkRm (RmTemplate "Hobbit kit"
            "This room holds the hobbit kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iFelinoidKit 0
            , StdLink South iHumanKit    0 ]
            (0, -4, 0)
            InsideEnv
            (Just "Hobbit")
            M.empty [] []))
  putRm iHumanKit
        []
        mempty
        (mkRm (RmTemplate "Human kit"
            "This room holds the human kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iHobbitKit    0
            , StdLink South iLagomorphKit 0 ]
            (0, -5, 0)
            InsideEnv
            (Just "Human")
            M.empty [] []))
  putRm iLagomorphKit
        []
        mempty
        (mkRm (RmTemplate "Lagomorph kit"
            "This room holds the lagomorph kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iHumanKit 0
            , StdLink South iNymphKit 0 ]
            (0, -6, 0)
            InsideEnv
            (Just "Lagomorph")
            M.empty [] []))
  putRm iNymphKit
        []
        mempty
        (mkRm (RmTemplate "Nymph kit"
            "This rooms holds the nymph kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iLagomorphKit 0
            , StdLink South iVulpenoidKit 0 ]
            (0, -7, 0)
            InsideEnv
            (Just "Nymph")
            M.empty [] []))
  putRm iVulpenoidKit
        []
        mempty
        (mkRm (RmTemplate "Vulpenoid"
            "This room holds the vulpenoid kit."
            Nothing
            Nothing
            zeroBits
            [ StdLink North iNymphKit 0 ]
            (0, -8, -0)
            InsideEnv
            (Just "Vulpenoid")
            M.empty [] []))

  putRmTeleName iWarehouseWelcome "warehouse"
