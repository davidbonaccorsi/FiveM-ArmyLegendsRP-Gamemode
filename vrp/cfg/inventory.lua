
local cfg = {}

cfg.inventory_weight_per_strength = 5 -- weight for an user inventory per strength level (no unit, but thinking in "kg" is a good norm)

--[[
	Vehicle trunk KG
	["spawncode"] = kg
]]

cfg.chest_weights = {
  
  -- SUPER --
    ["thrax"] = 30,
    ["italigts"] = 30,
    ["italirsx"] = 30,
    ["entity3"] = 30,
    ["osiris"] = 30,
    ["adder"] = 30,
    ["entity2"] = 30,
    ["entityxf"] = 30,
    ["reaper"] = 30,
    ["emerus"] = 30,
    ["t20"] = 30,
    ["nero2"] = 30,
    ["zentorno"] = 30,
    ["jb700"] = 30,
    ["windsor2"] = 30,
    ["superd"] = 30,
    ["paragon"] = 30,

  -- B --
    ["voltic"] = 30,
    ["astron"] = 30,
    ["growler"] = 30,
    ["oracle2"] = 30,
    ["blista"] = 30,
    ["omnisegt"] = 30,
    ["raiden"] = 30,
    ["jubilee"] = 30,
    ["baller3"] = 30,
    ["dubsta2"] = 30,
    ["schwarzer"] = 30,
    ["surano"] = 30,
    ["bullet"] = 30,
    ["vigero2"] = 30,
    ["gauntlet4"] = 30,
    ["rebla"] = 30,
    ["oracle"] = 30,
    ["rocoto"] = 30,
    ["ninef"] = 30,
    ["feltzer2"] = 30,
    ["drafter"] = 30,
    ["specter"] = 30,
    ["massacro"] = 30,
    ["formula"] = 30,
    ["ninef2"] = 30,
    ["tailgater2"] = 30,

  -- C --
    ["zion"] = 30,
    ["tailgater"] = 30,
    ["sandking"] = 30,
    ["sentinel"] = 30,
    ["sentinel2"] = 30,
    ["sultan"] = 30,
    ["sentinel3"] = 30,
    ["coquette"] = 30,
    ["dominator"] = 30,
    ["club"] = 30,
    ["baller"] = 30,
    ["schafter2"] = 30,
    ["schafter3"] = 30,
    ["xls"] = 30,
    ["kuruma"] = 30,

  -- D --
    ["glendale"] = 30,
    ["warrener"] = 30,
    ["bjxl"] = 30,
    ["dune"] = 30,
    ["rebel"] = 30,
    ["tornado"] = 30,
    ["mesa"] = 30,
    ["phoenix"] = 30,
    ["ruiner"] = 30,
    ["sadler"] = 30,
    ["emperor"] = 30,
    ["dloader"] = 30,
    ["stanier"] = 30,
    ["stratum"] = 30,
    ["futo"] = 30,
    ["ingot"] = 30,
    ["primo"] = 30,
    ["picador"] = 30,
    ["regina"] = 30,
    ["ratloader"] = 30,

  -- Lowriders --
    ["voodoo"] = 30,
    ["virgo2"] = 30,
    ["moonbeam2"] = 30,
    ["sabregt2"] = 30,
    ["primo2"] = 30,
    ["faction2"] = 30,
    ["faction3"] = 30,
    ["hermes"] = 30,

  -- Wanted --
    ["kanjo"] = 30,
    ["blista2"] = 30,
    ["prairie"] = 30,
    ["omnis"] = 30,
    ["zr350"] = 30,
    ["penumbra2"] = 30,
    ["elegy"] = 30,
    ["elegy2"] = 30,
    ["remus"] = 30,
    ["vigero"] = 30,
    ["jester3"] = 30,

  -- Epoca --
    ["rapidgt3"] = 30,
    ["gp1"] = 30,
    ["feltzer3"] = 30,
    ["issi3"] = 30,
    ["comet6"] = 30,
    ["gauntlet5"] = 30,
    ["ellie"] = 30,
    ["weevil"] = 30,

  -- Dube --
    ["speedo"] = 250,
    ["rumpo3"] = 250,
    ["burrito3"] = 300,
    ["youga2"] = 250,
    ["youga3"] = 250,
    
  -- camioane  --
    ["brickade"] = 350,
    ["rallytruck"] = 350,
    ["rubble"] = 500,
    ["tiptruck"] = 400,
    ["hauler"] = 50,
    ["phantom"] = 50,
    ["packer"] = 50,
    ["pounder2"] = 500,
    
  -- Remorci  --
    ["graintrailer"] = 250,
    ["tanker"] = 1000,
    ["trailers2"] = 1000,
    ["trailerlogs"] = 1000,

  -- Motoare --
    ["akuma"] = 10,
    ["avarus"] = 10,
    ["bagger"] = 10,
    ["bati"] = 10,
    ["bati2"] = 10,
    ["carbonrs"] = 10,
    ["chimera"] = 10,
    ["cliffhanger"] = 10,
    ["daemon"] = 10,
    ["defiler"] = 10,
    ["diablous"] = 10,
    ["diablous2"] = 10,
    ["double"] = 10,
    ["enduro"] = 10,
    ["esskey"] = 10,
    ["faggio2"] = 10,
    ["faggio"] = 10,
    ["fcr"] = 10,
    ["fcr2"] = 10,
    ["gargoyle"] = 10,
    ["hakuchou"] = 10,
    ["hakuchou2"] = 10,
    ["hexer"] = 10,
    ["lectro"] = 10,
    ["manchez"] = 10,
    ["nemesis"] = 10,
    ["pcj"] = 10,
    ["powersurge"] = 10,
    ["reever"] = 10,
    ["ruffian"] = 10,
    ["shinobi"] = 10,
    ["stryder"] = 10,
    ["thrust"] = 10,
    ["vader"] = 10,
    ["vindicator"] = 10,
    ["vortex"] = 10,
    ["wolfsbane"] = 10,

  -- Premium --
    ["akumac"] = 45,
    ["asteropers"] = 45,
    ["auroras"] = 45,
    ["auroras2"] = 45,
    ["buffalo4h"] = 45,
    ["callista"] = 45,
    ["cheetahfel"] = 45,
    ["clique2"] = 45,
    ["coquette4c"] = 45,
    ["elegyrace"] = 45,
    ["euros"] = 45,
    ["f620d"] = 45,
    ["feltzer9"] = 45,
    ["gauntletc"] = 45,
    ["gauntletstx"] = 45,
    ["gstyosemite1"] = 45,
    ["hachura"] = 45,
    ["hotringfr"] = 45,
    ["kampfer"] = 45,
    ["kawaii"] = 45,
    ["kriegerc"] = 45,
    ["m420"] = 45,
    ["meteor"] = 45,
    ["missile"] = 45,
    ["nerops"] = 45,
    ["paragonxr"] = 45,
    ["picadorexr"] = 45,
    ["playboy"] = 45,
    ["raidenz"] = 45,
    ["rh4"] = 45,
    ["roxanne"] = 45,
    ["sheavas"] = 45,
    ["spritzerdtm"] = 45,
    ["spzr250"] = 45,
    ["stardust"] = 45,
    ["stingersc"] = 45,
    ["sunrise1"] = 45,
    ["toreador2"] = 45,
    ["turismo2lm"] = 45,
    ["zion4"] = 45,
    ["zr380s"] = 45,
    ["serv_electricscooter"] = 5,

  -- Avioane --
    ["velum"] = 100,
    ["vestra"] = 100,
    ["duster"] = 100,
    ["dodo"] = 500,
    ["luxor"] = 500,
    ["luxor2"] = 1000,
    ["mammatus"] = 100,
    ["seabreeze"] = 100,

  -- Elicoptere --
    ["buzzard2"] = 100,
    ["conada"] = 100,
    ["havok"] = 100,
    ["maverick"] = 100,
    ["seasparrow"] = 100,
    ["seasparrow2"] = 100,
    ["swift2"] = 100,
    ["volatus"] = 100,

  -- Barci  --
    ["dinghy3"] = 100,
    ["avisa"] = 100,
    ["jetmax"] = 100,
    ["submersible"] = 100,
    ["submersible2"] = 100,
    ["longfin"] = 100,
    ["marquis"] = 100,
    ["seashark"] = 100,
    ["speeder"] = 100,
    ["squalo"] = 100,
    ["suntrap"] = 100,
    ["tug"] = 5000,
    ["tropic"] = 100,

  -- CAYO --
    ["surfer2"] = 45,
    ["vetir"] = 500,
    ["sanchez2"] = 15,
    ["hellion"] = 300,
    ["kamacho"] = 45,
    ["bifta"] = 45,
    ["cheburek"] = 45,
    ["blazer"] = 30,

  -- Mafie --
    ["gburrito"] = 300,
    ["impaler2"] = 45,
    ["brutus"] = 45,
    ["monster3"] = 45,
    ["dukes3"] = 45,
    ["arbitergt"] = 45,
    ["blade"] = 45,
    ["buccaneer2"] = 45,
    ["buffalo4"] = 45,
    ["chino2"] = 45,
    ["btype2"] = 45,
    ["btype"] = 45,
    ["stretch"] = 45,
    ["sanctus"] = 15,
    ["zombiea"] = 15,

  -- Events / Daily Reward / Refferal --
    ["pfister811"] = 30,
    
  --SMURD
    ["al_smurd_daciaduster"] = 50,
    ["al_smurd_ramcruiser"] = 50,
    ["al_smurd_dodgerammini"] = 80,
    ["al_smurd_gmchummer"] = 80,
    ["al_smurd_jeeprubicon"] = 80,
    ["al_smurd_lotus"] = 50,
    ["al_smurd_bmwx1"] = 50,
    ["al_smurd_barca"] = 100,

  --POLICE
    ["al_politie_bmwm3"] = 50,
    ["al_politie_bmwm5"] = 50,
    ["al_politie_fordraptorf150"] = 80,
    ["al_politie_jeepunmark"] = 80,
    ["al_politie_dacialogan"] = 50,
    ["al_politie_lotusunmark"] = 50,
    ["al_politie_mercedess63unmark"] = 50,
    ["al_politie_insurgent"] = 100,
    ["al_politie_volkswagentiguan"] = 50,
}

cfg.clothes = {
  ["hat"] = {
      Emote = {
          On = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600},
          Off = {Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200}
      },
      type = "prop",
      id = 0
  },
  ["glasses"] = {
  Emote = {
    On = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400},
    Off = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400}
  },
      type = "prop",
      id = 1
  },
  ["watch"] = {
  Emote = {
    On = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200},
    Off = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200}
  },
  type = "prop",
      id = 6
},
["bracelet"] = {
  Emote = {
    On = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200},
    Off = {Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200}
  },
      type = "prop",
      id = 7
},
  ["glasses"] = {
      Emote = {
          On = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400},
          Off = {Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400}
      },
      type = "prop",
      id = 1
  },
  ["mask"] = {
      Emote = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 800},
      type = "drawable",
      id = 1,

      male = {-1, 0},
      female = {-1, 0}
  },
  ["vest"] = {
      Emote = {Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200},
      type = "drawable",
      id = 9,

      male = {0, 0},
      female = {0, 0}
  },
  ["shirt"] = {
      Emote = {Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200},
      type = "multiple",
      male = {
          -- {drawableId, modelId}
          [11] = {15, 0},
          [8] = {15, 0},
          [3] = {15, 0},
          [10] = {0, 0}
      },
      female = {
          -- {drawableId, modelId}
          [11] = {15, 0},
          [8] = {15, 0},
          [3] = {15, 0},
          [10] = {0, 0}
      }
  },
  ["pants"] = {
      Emote = {Dict = "re@construction", Anim = "out_of_breath", Move = 51, Dur = 1300},
      type = "drawable",
      id = 4,

      male = {61, 5},
      female = {15, 0}
  },
  ["shoes"] = {
      Emote = {Dict = "random@domestic", Anim = "pickup_low", Move = 0, Dur = 1200},
      type = "drawable",
      id = 6,

      male = {34, 0},
      female = {35, 0}
  }
}

cfg.bags = {
    ghiozdanMic = {
        space = 15,
        name = "Ghiozdan Mic",
    },

    ghiozdanMediu = {
        space = 35,
        name = "Ghiozdan Mediu",
    },

    ghiozdanMare = {
        space = 60,
        name = "Ghiozdan Mare",
    }
}

cfg.weapons = {
    -- == [NEW WEAPONS] == 
    ['weapon_ak47'] = {
      name = "AK-47",
      weapon = "weapon_ak47",
      description = 'Arma de calibru mare care foloseste munitie de 7.62mm',
      ammo = "ammo_762",
      meele = false
    },
    ['weapon_de'] = {
      name = "Desert Eagle",
      weapon = "weapon_de",
      description = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_fnx45'] = {
      name = "FNX-45",
      weapon = "weapon_fnx45",
      description = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_m70'] = {
      name = "M70",
      weapon = "weapon_m70",
      description = 'Arma de calibru mare care foloseste munitie de 7.62mm',
      ammo = "ammo_762",
      meele = false
    },
    ['weapon_m1911'] = {
      name = "M1911",
      weapon = "weapon_m1911",
      description = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_uzi'] = {
      name = "UZI",
      weapon = "weapon_uzi",
      description = 'Pistol mitraliera de calibru mic care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_mac10'] = {
      name = "MAC-10",
      weapon = "weapon_mac10",
      description = 'Pistol mitraliera de calibru mic care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_mossberg'] = {
      name = "Mossberg 500",
      weapon = "weapon_mossberg",
      description  = 'Arma de calibru mare care foloseste gloante de tip 9mm',
      ammo = "ammo_9mm",
      meele = false
    },
    ['weapon_doubleaction'] = {
      name = "Double Action",
      weapon = "weapon_doubleaction",
      description  = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_navyrevolver'] = {
      name = "Navy Revolver",
      weapon = "weapon_navyrevolver",
      description  = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_gadgetpistol'] = {
      name = "Gadget Pistol",
      weapon = "weapon_gadgetpistol",
      description  = 'Pistol de calibru mare care foloseste munitie de tip 45 ACP',
      ammo = "ammo_45acp",
      meele = false
    },
    ['weapon_hk416'] = {
      name = "HK-416",
      weapon = "weapon_hk416",
      description = 'Arma de calibru mare care foloseste munitie de 7.62mm',
      ammo = "ammo_762",
      meele = false
    },
    ['weapon_katana'] = {
      name = "Katana",
      weapon = "weapon_katana",
      description = 'Arma alba',
      meele = true
    },
    ['weapon_sledgehammer'] = {
      name = "Sledge Hammer",
      weapon = "weapon_sledgehammer",
      description = 'Arma alba',
      meele = true
    },
    ['weapon_shiv'] = {
      name = "Shiv",
      weapon = "weapon_knife",
      description = 'Arma alba',
      meele = true
    },
    ['weapon_stungun'] = {
      name = 'Stungun',
      weapon = 'weapon_stungun',
      description = 'Aceasta arma este folosita pentru a imobiliza persoanele',
      meele = false,
    },

    -- PD Weapons
    ['weapon_glock17'] = {
      name = "PD Glock 17",
      weapon = "weapon_glock17",
      ammo = "ammo_45acp_pd",
      meele = false
    },
    ['weapon_nightstick'] = {
      name = "Baston",
      weapon = "weapon_nightstick",
      description = 'Arma alba',
      meele = true
    },
    ['weapon_flashlight'] = {
      name = "Laterna",
      weapon = "weapon_flashlight",
      description = 'Arma alba',
      meele = true
    },
    ['weapon_m9'] = {
      name = "PD Beretta M9A3",
      weapon = "weapon_m9",
      ammo = "ammo_45acp_pd",
      meele = false
    },
    ['weapon_m4'] = {
      name = "PD M4A1",
      weapon = "weapon_m4",
      ammo = "ammo_556_pd",
      meele = false
    },
    ['weapon_scarh'] = {
      name = "PD SCAR-H",
      weapon = "weapon_scarh",
      ammo = "ammo_762_pd",
      meele = false
    },
    ['weapon_ar15'] = {
      name = "PD AR-15",
      weapon = "weapon_ar15",
      ammo = "ammo_762_pd",
      meele = false
    },
    ['weapon_mk14'] = {
      name = "PD MK14",
      weapon = "weapon_mk14",
      ammo = "ammo_762_pd",
      meele = false
    },
    ['weapon_remington'] = {
      name = "PD Remington 870",
      weapon = "weapon_remington",
      ammo = "ammo_9mm_pd",
      meele = false
    },

    -- Hunter
    ['weapon_musket'] = {
      name = "Musket",
      weapon = "weapon_musket",
      ammo = "ammo_222rem",
      meele = false,
    }
}

return cfg
