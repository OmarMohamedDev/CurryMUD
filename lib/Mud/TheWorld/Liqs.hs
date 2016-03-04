{-# LANGUAGE OverloadedStrings #-}

module Mud.TheWorld.Liqs ( distinctLiqList
                         , potHealingLiq
                         , potInstantHealingLiq
                         , potInstantStLiq
                         , potInstantTinnitusLiq
                         , potStLiq
                         , potTinnitusLiq
                         , waterLiq ) where

import Mud.Data.State.MudData
import Mud.Misc.EffectFuns
import Mud.TheWorld.LiqIds


distinctLiqList :: [(Id, DistinctLiq)]
distinctLiqList = [ (iLiqPotHealing,         potHealingDistinctLiq        )
                  , (iLiqPotInstantHealing,  potInstantHealingDistinctLiq )
                  , (iLiqPotInstantSt,       potInstantStDistinctLiq      )
                  , (iLiqPotInstantTinnitus, potInstantTinnitusDistinctLiq)
                  , (iLiqPotSt,              potStDistinctLiq             )
                  , (iLiqPotTinnitus,        potTinnitusDistinctLiq       )
                  , (iLiqWater,              waterDistinctLiq             ) ]


-----


waterLiq :: Liq
waterLiq = Liq (DistinctLiqId iLiqWater)
               "water" -- TODO: "a water"
               "The water is entirely odorless."
               "The water is entirely tasteless."
               "The cool, clear water feels refreshing as it goes down."


waterDistinctLiq :: DistinctLiq
waterDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Nothing
                                             , _consumpEffects = Nothing }


-----


potHealingLiq :: Liq
potHealingLiq = Liq (DistinctLiqId iLiqPotHealing)
                    "milky, off-white liquid"
                    "" -- TODO
                    ""
                    ""


potHealingDistinctLiq :: DistinctLiq
potHealingDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Just el
                                                  , _consumpEffects = Nothing }
  where
    el = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub = MobInstaEffectPts CurHp
                     , _instaEffectVal = Just . DefiniteVal $ 2 }


potInstantHealingLiq :: Liq
potInstantHealingLiq = Liq (DistinctLiqId iLiqPotInstantHealing)
                           "murky, rust-colored liquid"
                           "" -- TODO
                           ""
                           ""


potInstantHealingDistinctLiq :: DistinctLiq
potInstantHealingDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Nothing
                                                         , _consumpEffects = Just ce }
  where
    ce = ConsumpEffects 4 30 el
    el = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub = MobInstaEffectPts CurHp
                     , _instaEffectVal = Just . RangeVal $ (8, 12) }

-----


potStLiq :: Liq
potStLiq = Liq (DistinctLiqId iLiqPotSt)
               "thick, muddy liquid"
               "" -- TODO
               ""
               ""


potStDistinctLiq :: DistinctLiq
potStDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Just el
                                             , _consumpEffects = Nothing }
  where
    el = EffectList . pure . Right $ e
    e  = Effect { _effectSub = MobEffectAttrib St
                , _effectVal = Just . DefiniteVal $ 2
                , _dur       = 5 * 60 }


potInstantStLiq :: Liq
potInstantStLiq = Liq (DistinctLiqId iLiqPotInstantSt)
                      "brown, frothy liquid"
                      "" -- TODO
                      ""
                      ""


potInstantStDistinctLiq :: DistinctLiq
potInstantStDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Nothing
                                                    , _consumpEffects = Just ce }
  where
    ce = ConsumpEffects 4 30 el
    el = EffectList . pure . Right $ e
    e  = Effect { _effectSub = MobEffectAttrib St
                , _effectVal = Just . RangeVal $ (8, 12)
                , _dur       = 5 * 60 }


-----


potTinnitusLiq :: Liq
potTinnitusLiq = Liq (DistinctLiqId iLiqPotTinnitus)
                     "olive-green liquid"
                     "" -- TODO
                     ""
                     ""


potTinnitusDistinctLiq :: DistinctLiq
potTinnitusDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Just el
                                                   , _consumpEffects = Nothing }
  where
    el = EffectList . pure . Left $ ie
    ie = InstaEffect { _instaEffectSub = InstaEffectOther tinnitusInstaEffectFunName
                     , _instaEffectVal = Nothing }


potInstantTinnitusLiq :: Liq
potInstantTinnitusLiq = Liq (DistinctLiqId iLiqPotInstantTinnitus)
                            "oily, puce liquid"
                            "" -- TODO
                            ""
                            ""


potInstantTinnitusDistinctLiq :: DistinctLiq
potInstantTinnitusDistinctLiq = DistinctLiq EdibleEffects { _digestEffects  = Nothing
                                                          , _consumpEffects = Just ce }
  where
    ce = ConsumpEffects 4 30 el
    el = EffectList . pure . Right $ e
    e  = Effect { _effectSub = EffectOther tinnitusEffectFunName
                , _effectVal = Nothing
                , _dur       = 2 * 60 }
