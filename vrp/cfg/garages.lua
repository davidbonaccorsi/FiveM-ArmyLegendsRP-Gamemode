local cfg = {}

cfg.already_out_tax = 250

cfg.repair_tax = 500

cfg.unmarked_vehicles = {
  ['mercedesunmarked'] = true,
  ['14ram'] = true,
  ['16bugatti'] = true,
  ['e63unmark'] = true,
  ['pd_bmwr'] = true,
  ['745le'] = true,
  ['umdemon'] = true
}

cfg.garage_types = {
  ["Personal"] = {
    _config = {vtype = "ds", blipid = 357, blipcolor = 32, iconColor = {255, 255, 255, 150}, text = "Acceseaza garajul personal"},
  },

  ["Cayo"] = {
    _config = {vtype = "cayo", blipid = 811, blipcolor = 71, iconColor = {247, 247, 142, 130}},
  },

  ["Boat Garage"] = {
    _config = {vtype = "boat", blipid = 356, blipcolor = 3, icon = 35, iconColor = {255, 255, 255, 130}},
  },
  
  ["Avioane"] = {
    _config = {vtype = "avion", blipid = 307, blipcolor = 62, icon = 7, iconColor = {255, 255, 255 , 130}, text = "Acceseaza hangar avioane"},
  },
  
  ["Elicoptere"] = {
    _config = {vtype = "elicopter", blipid = 64, blipcolor = 62, icon = 34, iconColor = {255, 255, 255, 130}, text = "Acceseaza hangar elicoptere"},
  },

  ["Dube"] = {
    _config = {vtype = "van", blipid = 616, blipcolor = 10, iconColor = {255, 255, 255, 130}},
  },
    ----------

  ["Camioane"] = {
    _config = {vtype = "truck", blipid = 477, blipcolor = 62, iconColor = {255, 255, 255, 130}},
  },

  ["Remorci"] = {
    _config = {vtype = "trailer", blipid = 479, blipcolor = 31, iconColor = {255, 255, 255, 130}},
  },
  
	-- Mafii

  --[[ Default:

    ["bmm"] = {"Bentley Continental Supersports"},
    ["19x7m"] = {"BMW X7M"},
    ["bf400"] = {"KTM SX"},
    ["patroly60"] = {"Nissan Patrol Y60"},
    ["blazer4"] = {"ATV Blazer"},
    ["ztype"] = {"Ztype"},
    ["btype"] = {"Btype"},
    ["brabus500"] = {"Mercedes Brabus G500"},
    ["ctsv16"] = {"Cadillac 2016 CTS-V"},
    ["gmt900escalade"] = {"Cadillac Escalade"},
    ["dodgetrx"] = {"Dodge Ram TRX"},
    ["gle53"] = {"Mercedes-Benz GLE Coupe 53 AMG"},
    ["hammer"] = {"Hammer H2"},
    ["g63amg6x6"] = {"Mercedes G63 AMG 6x6"},
    ["w140"] = {"Mercedes AMG W120"}
  --]]

	-- ["DIABLOS"] = {
	-- 	_config = {vtype="car",blipid=229,blipcolor=57,faction="DIABLOS"},
    --     ["bmm"] = {"Bentley Continental Supersports"},
    --     ["19x7m"] = {"BMW X7M"},
    --     ["bf400"] = {"KTM SX"},
    --     ["patroly60"] = {"Nissan Patrol Y60"},
    --     ["blazer4"] = {"ATV Blazer"},
    --     ["ztype"] = {"Ztype"},
    --     ["btype"] = {"Btype"},
    --     ["brabus500"] = {"Mercedes Brabus G500"},
    --     ["ctsv16"] = {"Cadillac 2016 CTS-V"},
    --     ["gmt900escalade"] = {"Cadillac Escalade"},
    --     ["dodgetrx"] = {"Dodge Ram TRX"},
    --     ["gle53"] = {"Mercedes-Benz GLE Coupe 53 AMG"},
    --     ["hammer"] = {"Hammer H2"},
    --     ["g63amg6x6"] = {"Mercedes G63 AMG 6x6"},
    --     ["w140"] = {"Mercedes AMG W120"}
	-- },
	-- ["DIABLOS Helipad"] = {
	-- 	_config = {vtype="car",blipid=43,blipcolor=85,faction="DIABLOS"},
	-- 	["maverick"] = {"Elicopter Maverick"}
	-- },

  ----------

  ["police"] = {
    _config = {vtype = "car",blipid = 56,blipcolor = 38,iconColor = {23,41,234, 130},faction = "Politie", vehPlate = "MAI"},
    ["14ram"] = {"Dodge Ram Unmarked"},
    ["16bugatti"] = {"Bugatti Chiron Unmarked"},
    ["e63unmark"] = {"Mercedes E63S Unmarked"},
    ["mercedesunmarked"] = {"Mercedes E63 Unmarked"},
    ["pd_bmwr"] = {"BMW M5 Unmarked"},
    ["pdmercedesv"] = {"Mercedes-Benz Vito Unmarked"},
    ["polnspeedo"] = {"Vapid Speedo Unmarked"},
    ["audis4"] = {"Audi S4 Politie"},
    ["dacia2"] = {"Dacia Duster Politie"},
    ["g63amg6x6cop"] = {"Mercedes-AMG G63 6X6 Politie"},
    ["ghispo2"] = {"Maserati Ghibli"},
    ["jp"] = {"Jeep Wrangler Politie"},
    ["passat"] = {"Volkswagen Passat Politie"},
    ["polchiron"] = {"Bugatti Chiron Politie", ""},
    ["polf430"] = {"Ferrari Scuderia F430 Politie"},
    ["polgs350"] = {"Lexus GS350 Politie", ""},
    ["porschecayenne"] = {"Porsche Cayenne Politie"},
    ["skoda"] = {"Skoda Octavia Politie", ""},
    ["volvopolitie"] = {"Volvo V70 Politie"},
    ["policeb1"] = {"Moto High Speed Politie"},
    ["policeb2"] = {"Moto Off-Road Politie"},
    ["pbike"] = {"Bicicleta Politie"},
    ["polmp4"] = {"McLaren MP4 Politie"},
    ["gcma4sedan2021"] = {"Audi A4"},
    ["audirs3sedan22"] = {"Audi RS3"},
    ["al_politie_dacialogan"] = {"Dacia Logan Politie"},
    ["brisa_mvito"] = {"Mercedes Vito I.S.C.T.R"},
    ["al_politie_bmwm3"] = {"BMW G80 M3 Competition 2021 Politie"},
    ["al_politie_bmwm5"] = {"BMW M5 E60 Police"},
    ["al_politie_fordraptorf150"] = {"Ford F150 Raptor Politie"},
    ["al_politie_jeepunmark"] = {"Hennessey Jeep Trackhawk HPE1000 2021 Unmarked"},
    ["al_politie_lotusunmark"] = {"Lotus Evora GT 430 2017 Politie"},
    ["al_politie_mercedess63unmark"] = {"Mercedes Benz S63 AMG 2023 UnMark"},
    ["al_politie_insurgent"] = {"Terradyne Gurkha Unmark"},
    ["al_politie_volkswagentiguan"] = {"Volkswagen Tiguan 2021 Politie"}
  },

	["emergency"] = {
		_config = {vtype="car",blipid=56,blipcolor=1,icon=36,iconColor={255,0,0,130},faction="Smurd", vehPlate = "Smurd"},	
        ["ghispo3"] = {"Maserati Ghibli SMURD"},
        ["jp2"] = {"Jeep Wrengler SMURD"},
        ["al_smurd_daciaduster"] = {"Dacia Duster SMURD"},
        ["rsb_mbsprinter"] = {"Mercedes-Benz Sprinter Ambulanta"},
        ["22trans"] = {"Ford Transit"},
        ["al_smurd_bmwx1"] = {"BMW X1 sDrive 20D 2016 Smurd"},
        ["al_smurd_ramcruiser"] = {"Dodge Bruiser Smurd"},
        ["al_smurd_dodgerammini"] = {"Dodge Ram 2023 Smurd"}, 
        ["al_smurd_gmchummer"] = {"GMC HUMMER EV 2022 Smurd"},
        ["al_smurd_jeeprubicon"] = {"Jeep Gladiator Rubicon 2019 Smurd"},
        ["al_smurd_lotus"] = {"Lotus Emira 2023 Smurd"},
        ["al_smurd_barca"] = {"Zodiac Smurd"},
	},

  ["Police Helicopters"] = {
	_config = {vtype="car",blipid=43,blipcolor=38,radius=5.1,icon=34,iconColor={23,41,234,130},faction="Politie"},
    ["polmav"] = {"Elicopter Politia Romana"}
  },

  ["Emergency Helicopters"] = {
	_config = {vtype="car",blipid=43,blipcolor=1,radius=5.1,icon=34,iconColor={255,0,0,130},faction="Smurd"},
    ["lguardmav"] = {"Elicopter Smurd"}
  },

  ["Police Dock"] = {
	_config = {vtype="car",blipid=780,blipcolor=38,radius=5.1,icon=34,iconColor={23,41,234,130},faction="Politie"},
    ["dinghy3"] = {"Barca Politia Romana"},
  },

  ["Emergency Dock"] = {
	_config = {vtype="car",blipid=780,blipcolor=1,radius=5.1,icon=34,iconColor={255,0,0,130},faction="Smurd"},
    ["al_smurd_barca"] = {"Zodiac Smurd"},
  },
}

cfg.defaultTunning = {
  ["adder"] = {
    windows_tint = false,
    tunning = true,
  },
  ["cprotection"] = {
      windows_tint = false,
      tunning = true,
  },
  ['ghispo3'] = {
      windows_tint = false,
      tunning = true,
  },
  ['jp2'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_daciaduster'] = {
      windows_tint = false,
      tunning = true,
  },
  ['rsb_mbsprinter'] = {
      windows_tint = false,
      tunning = true,
  },
  ['ems_gs1200'] = {
      windows_tint = false,
      tunning = true,
  },
  ['22trans'] = {
      windows_tint = false,
      tunning = true,
  },
  ['3gator'] = {
      windows_tint = false,
      tunning = true,
  },
  ['vitomab'] = {
      windows_tint = false,
      tunning = true,
  },
  ['ambtouran'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_bmwx1'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_ramcruiser'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_dodgerammini'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_gmchummer'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_jeeprubicon'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_lotus'] = {
      windows_tint = false,
      tunning = true,
  },
  ['al_smurd_barca'] = {
      windows_tint = false,
      tunning = true,
  },
  ["14ram"] = {
    windows_tint = true,
    tunning = true,
  },
  ['16bugatti'] = {
      windows_tint = false,
      tunning = true,
  },
  ['e63unmark'] = {
      windows_tint = true,
      tunning = true,
  },
  ['mercedesunmarked'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['pd_bmwr'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['pdmercedesv'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['polnspeedo'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['audis4'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['dacia2'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['g63amg6x6cop'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['ghispo2'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['jp'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['logan'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['polchiron'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['polf430'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['polgs350'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['porschecayenne'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['skoda'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['volvopolitie'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['policeb1'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['policeb2'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['pbike'] = {
      windows_tint = false,
      tunning = true,
  },   
  ['polamggtr'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['polmp4'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['gcma4sedan2021'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['audirs3sedan22'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['al_politie_dacialogan'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['art2'] = {
      windows_tint = false,
      tunning = true,
  },    
  ['brisa_mvito'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['polmav'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['dinghy3'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['al_politie_bmwm3'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['al_politie_bmwm5'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['al_politie_fordraptorf150'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['al_politie_jeepunmark'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['al_politie_lotusunmark'] = {
      windows_tint = false,
      tunning = true,
  },  
  ['al_politie_mercedess63unmark'] = {
      windows_tint = true,
      tunning = true,
  },  
  ['al_politie_insurgent'] = {
      windows_tint = true,
      tunning = true,
  },   
  ['al_politie_volkswagentiguan'] = {
      windows_tint = false,
      tunning = true,
  },  
}


cfg.garages = {
  {"emergency", vector3(328.92434692383,-558.15740966797,28.74374961853)}, --LS JOS
  {"emergency", vector3(1740.1613769531,3608.5,34.823680877686)}, --SANDY
  {"emergency", vector3(-275.71643066406,6330.5541992188,32.426265716553)}, --PALETO
  {"police", vector3(453.37313842773, -1020.825012207, 28.335729598999)}, --LS
  {"police", vector3(1814.5589599609,3665.3076171875,34.133750915527)}, -- SANDY PD
  {"police", vector3(-479.38247680664,6027.669921875,31.340389251709)}, --PALETO
  {"Emergency Helicopters", vector3(351.65045166016, -587.90142822266, 74.165672302246)}, --LS
  {"Emergency Helicopters", vector3(-252.45724487305,6319.009765625,39.659603118896)}, -- PALETO
  {"Emergency Helicopters", vector3(1786.9810791016,3609.0593261719,34.716156005859)}, --SANDY
  {"Police Helicopters", vector3(449.28994750977, -981.22943115234, 43.691677093506)}, --LS
  {"Police Helicopters", vector3(-475.55993652344,5988.3740234375,31.336685180664)}, --PALETO
  {"Police Helicopters", vector3(1833.3266601563,3669.1728515625,38.930541992188)}, -- SANDY
  {"Police Dock", vector3(-277.6728515625,-2734.3754882812,1.55046729147434)}, -- OCEAN
  {"Police Dock", vector3(1253.7012939453,4302.5815429688,30.349235534668)}, -- SANDY LAKE
  {"Emergency Dock", vector3(1270.1552734375,4280.9946289063,30.373779296875)},
  {"Emergency Dock", vector3(-228.32220458984,-2699.6870117188,-0.15189650654793)}, -- OCEAN
  {"Avioane", vector3(-980.078125, -2995.7172851562, 13.945067405701)},
  {"Elicoptere", vector3(-1112.4562988281, -2883.9125976562, 13.946009635925)},
  {"Elicoptere", vector3(-1145.9416503906, -2864.2241210938, 13.946026802063)},
  {"Elicoptere", vector3(-1178.0534667969, -2845.5378417969, 13.945781707764)},
  {"Avioane", vector3(1731.7465820312, 3310.8176269531, 41.223457336426)},
  {"Elicoptere", vector3(1770.0776367188, 3239.4909667969, 42.131782531738)},
  {"Avioane", vector3(-2251.0561523438, 3248.6369628906, 32.810207366943)},
  {"Elicoptere", vector3(-2186.46875, 3172.7097167969, 32.810111999512)},
  {"Elicoptere", vector3(-724.57415771484, -1444.04296875, 5.0006771087646)},
  {"Boat Garage", vector3(-798.18200683594, -1503.2603759766, 0.2006773352623)},
  {"Boat Garage", vector3(90.720680236816, -2456.4106445312, -0.039310656487942)},
  {"Boat Garage", vector3(1247.9733886719,4283.54296875,29.599578857422)},
  {"Boat Garage", vector3(769.70947265625, -2884.8823242188, 0.44043385982513)},
  {"Boat Garage", vector3(-190.32582092285,-2735.3266601563,-0.96954679489136)},
  {"Remorci", vector3(827.162109375, -3209.7260742188, 5.9008121490479)},
  {"Camioane", vector3(848.93804931641, -3209.7377929688, 5.9008188247681)},
  {"Remorci", vector3(-163.44906616211, -2707.6149902344, 6.009313583374)},
  {"Camioane", vector3(-164.35456848145, -2686.9711914062, 6.0122027397156)},
  {"Personal", vector3(855.23419189453, -3208.3537597656, 5.9007277488708)},
  {"Personal", vector3(143.34262084961, -2498.6643066406, 5.9999871253967)},
  {"Personal", vector3(-543.55596923828,-915.77740478516,23.861295700073)},
  {"Personal", vector3(1753.1596679688,3616.173828125,34.822025299072)},
  {"Personal", vector3(-928.77508544922, -2922.5983886719, 13.944427490234)},
  {"Personal", vector3(-425.45532226562, -1689.5164794922, 19.029088973999)},
  {"Personal", vector3(-289.67932128906, -887.28491210938, 31.08060836792)},
  {"Personal", vector3(392.67178344727, -644.27166748047, 28.500558853149)},
  {"Personal", vector3(337.12826538086, -210.61405944824, 54.086269378662)},
  {"Personal", vector3(-2193.9733886719, 3305.3737792969, 32.813690185547)},
  {"Personal", vector3(-674.44885253906, 5779.134765625, 17.330934524536)},
  {"Avioane", vector3(2133.388671875, 4783.3530273438, 40.970314025879)},
  {"Elicoptere", vector3(2132.7233886719, 4811.4926757812, 41.191143035889)},
  {"Personal", vector3(2110.6831054688, 4767.7573242188, 41.17032623291)},
  {"Personal", vector3(294.6296081543,-607.00323486328,43.325992584229)},
  {"Personal", vector3(-9.4589509963989,-1095.7607421875,27.017030715942)},
  --{"Grove Street", vector3(-141.05865478516, -594.70568847656, 32.424468994141)},
  {"Personal", vector3(869.62359619141, -11.610187530518, 78.764053344727)},
  {"Personal", vector3(2468.2666015625, 1589.2572021484, 32.72029876709)},
  {"Personal", vector3(449.57424926758, -1025.2935791016, 28.58270072937)},
  {"Personal", vector3(-482.31936645508, -596.1982421875, 31.174425125122)},
  {"Personal", vector3(-1328.0966796875, -925.71453857422, 11.202126502991)},
  {"Personal", vector3(-133.86851501465,6348.8212890625,31.490682601929)},
  {"Personal", vector3(-277.81430053711,6327.2563476563,32.426139831543)},
  {"Personal", vector3(-1617.1890869141,-805.89117431641,10.098882675171)},
  {"Personal", vector3(-1870.8215332031,-1213.5264892578,13.017110824585)},
  {"Personal", vector3(1338.3237304688,4379.1010742188,44.355690002441)},
  {"Personal", vector3(1832.6571044922, 2542.0161132812, 45.880596160889)},
  {"Personal", vector3(-1120.4357910156,-2829.8967285156,13.9443359375)},
  {"Personal", vector3(-1039.1937255859,-2678.5297851563,13.830699920654)},
  {"Personal", vector3(135.22604370117, -1051.1928710938, 29.155416488647)},
  {"Personal", vector3(-164.53024291992, -2658.818359375, 6.0010299682617)},
  {"Personal", vector3(-892.0986328125, -149.68539428711, 37.098762512207)},
  {"Dube", vector3(136.83715820312, -2477.4663085938, 5.999988079071)},
  {"Dube", vector3(834.57922363281, -3208.6164550781, 5.9008193016052)},
  {"Cayo", vector3(4501.7587890625, -4547.716796875, 4.0278363227844)},
  {"Elicoptere", vector3(4487.2485351562, -4451.7836914062, 4.1423797607422)},
  {"Avioane", vector3(4441.7387695313,-4465.8154296875,4.3284411430359)},
  {"Personal", vector3(-106.93689727783, 832.47521972656, 235.72337341309), hidden = true},
  --{"Camorra", vector3(-1549.2442626953, -586.28125, 25.707901000977)},
  --{"Mala Del Brenta", vector3(-97.080894470215, -804.83502197266, 36.496173858643)},
  {"Boat Garage", vector3(4761.76953125, -4756.6635742188, 0.52629542350769)},
  {"Personal", vector3(-744.15972900391, -1503.9307861328, 4.2672572135925)},
  {"Puente", vector3(-589.67376708984, 196.73152160645, 71.438720703125)},
  {"Elicoptere", vector3(4881.8139648438, -5282.5239257812, 8.4240312576294)},
  --{"Los Vagos", vector3(495.39068603516, -2738.6303710938, 3.0685770511627)},
  {"Elicoptere", vector3(4888.5395507812, -5736.6665039062, 26.35089302063)},
  {"Personal", vector3(-2328.5603027344, 294.01647949219, 169.46705627441)},
  --{"Sons Of Anarchy", vector3(967.34100341797, -139.80816650391, 74.404724121094)},
  --{"Camorra", vector3(964.6142578125, -1823.3824462891, 31.097169876099)},
  {"Boat Garage", vector3(3865.9763183594, 4497.0209960938, 0.73292881250381)},
  {"Personal", vector3(3801.5952148438, 4454.5668945312, 4.5739412307739)},
  --{"Crips", vector3(-355.6735534668, 32.683372497559, 47.799362182617)},
  --{"Bloods", vector3(-1566.7536621094, -389.01858520508, 41.981315612793)},
  --{"Yakuza", vector3(-1539.9093017578, -560.31622314453, 25.707626342773)},
  --{"Groove Street", vector3(197.23823547363, 1235.0513916016, 225.45985412598)},
  --{"Mayans", vector3(-77.060607910156, -823.86151123047, 284.99993896484)},
}

return cfg