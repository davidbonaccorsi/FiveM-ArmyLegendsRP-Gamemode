local cfg = {}

cfg.bunkers = {
    ['bunker-1'] = vector3(-3031.4558105469,3334.0966796875,10.187383651733),
    ['bunker-2'] = vector3(39.581951141357,2930.4641113281,55.80135345459),
    ['bunker-3'] = vector3(492.2594909668,3014.359375,40.958919525146),
    ['bunker-4'] = vector3(849.53326416016,3021.4367675781,41.312595367432),
    ['bunker-5'] = vector3(2110.486328125,3326.0090332031,45.353942871094),
    ['bunker-6'] = vector3(2489.4057617188,3161.2216796875,48.978870391846),
    ['bunker-7'] = vector3(1803.4659423828,4705.474609375,40.07995223999),
    ['bunker-8'] = vector3(-756.51812744141,5943.32421875,19.938722610474),
    ['bunker-9'] = vector3(-3158.9758300781,1376.5303955078,16.649263381958),
    ['bunker-10'] = vector3(1572.1090087891,2227.0048828125,78.23494720459),
    ['bunker-11'] = vector3(-389.39242553711,4342.5014648438,56.216918945313)
}

cfg.stealVehicle = {
    {
        vehicle = 'adder',
        minReward = 50000,
        maxReward = 100000,
        spawnLocation = vector3(1134.0863037109,-1748.98828125,29.18337059021),
        dropLocation = vector3(-3051.4558105469,3334.0966796875,10.187383651733),
    },
}

cfg.specialTransports = {
    {
        minReward = 50000,
        maxReward = 100000,
        dropLocation = vector3(1134.0863037109,-1748.98828125,29.18337059021),
    },
}

cfg.stealDrugs = {
    {
        minReward = 50000,
        maxReward = 100000,
        spawnLocation = vector3(2939.17, 2772.42, 39.27),
        dropLocation = vector3(785.97302246094,-2494.486328125,20.583826065063),
    }
}

cfg.bunkerCraftings = {
    ['crafting-fnx45'] = {
        name = "Productie de Armament (FNX-45)",
        price = 150000,
        time = 30,
        amount = 1,
        craftingChance = 95,
        item = 'weapon_fnx45',
        need = {
            {item = 'otel', amount = 2},
            {item = 'suruburi', amount = 25},
        },
        npc = {
            position = vector3(899.08465576172,-3223.8288574219,-98.26392364502),
            rotation = 30,
            model = "s_f_y_factory_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Lucia Vladsceanu'
        },
    },
    ['crafting-de'] = {
        name = "Productie de Armament (Desert Eagle)",
        price = 550000,
        time = 30,
        amount = 1,
        craftingChance = 95,
        item = 'weapon_de',
        need = {
            {item = 'otel', amount = 2},
            {item = 'suruburi', amount = 25},
        },
        npc = {
            position = vector3(898.06555175781,-3221.6520996094,-98.248313903809),
            rotation = 200,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Eugen Georgescu'
        },
    },
    ['crafting-m1911'] = {
        name = "Productie de Armament (M1911)",
        price = 125000,
        time = 30,
        amount = 1,
        craftingChance = 95,
        item = 'weapon_m1911',
        need = {
            {item = 'otel', amount = 2},
            {item = 'suruburi', amount = 25},
        },
        npc = {
            position = vector3(896.46038818359,-3217.4284667969,-98.225524902344),
            rotation = 60,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Ovidiu Negoita'
        },
    },
    ['crafting-uzi'] = {
        name = "Productie de Armament (UZI)",
        price = 250000,
        time = 30,
        amount = 1,
        craftingChance = 95,
        item = 'weapon_uzi',
        need = {
            {item = 'otel', amount = 2},
            {item = 'suruburi', amount = 25},
        },
        npc = {
            position = vector3(905.85766601563,-3230.7592773438,-98.294410705566),
            rotation = 160,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Florin Dinescu'
        },
    },
    ['crafting-mac10'] = {
        name = "Productie de Armament (MAC-10)",
        price = 250000,
        time = 30,
        amount = 1,
        craftingChance = 95,
        item = 'weapon_mac10',
        need = {
            {item = 'otel', amount = 2},
            {item = 'suruburi', amount = 25},
        },
        npc = {
            position = vector3(910.05767822266,-3222.4255371094,-98.266639709473),
            rotation = 270,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Victor Munteanu'
        },
    },

    -- Ammo Box
    ['crafting-ammobox_9mm'] = {
        name = "Productie de Munitie (Gloante 9MM)",
        price = 65000,
        time = 30,
        amount = 1,
        craftingChance = 93,
        item = 'ammobox_9mm',
        need = {
            {item = 'prafdepusca', amount = 2},
            {item = 'metal_fragmentat', amount = 5},
        },
        npc = {
            position = vector3(891.91326904297,-3196.9580078125,-98.196189880371),
            rotation = 20,
            model = "s_f_y_factory_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Andreea Busa'
        },
    },
    ['crafting-ammobox_762'] = {
        name = "Productie de Munitie (Gloante 7.62MM)",
        price = 77000,
        time = 30,
        amount = 1,
        craftingChance = 93,
        item = 'ammobox_762',
        need = {
            {item = 'prafdepusca', amount = 3},
            {item = 'metal_fragmentat', amount = 7},
        },
        npc = {
            position = vector3(888.64495849609,-3206.8286132813,-98.196235656738),
            rotation = 20,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Mirel Dinescu'
        },
    },
    ['crafting-ammobox_556'] = {
        name = "Productie de Munitie (Gloante 5.56MM)",
        price = 50000,
        time = 30,
        amount = 1,
        craftingChance = 93,
        item = 'ammobox_556',
        need = {
            {item = 'prafdepusca', amount = 4},
            {item = 'metal_fragmentat', amount = 10},
        },
        npc = {
            position = vector3(887.41723632813,-3209.6916503906,-98.196235656738),
            rotation = 220,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Lucian Iancu'
        },
    },
    -- Arme Albe

    ['crafting-knife'] = {
        name = "Productie de Arme Albe (Baioneta)",
        price = 100000,
        time = 30,
        amount = 1,
        craftingChance = 90,
        item = 'weapon_knife',
        need = {
            {item = 'otel', amount = 3},
        },
        npc = {
            position = vector3(909.70874023438,-3210.2075195313,-98.222267150879),
            rotation = 20,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Laurentiu Tabacu'
        },
    },
    ['crafting-machete'] = {
        name = "Productie de Arme Albe (Macheta de Vanatoare)",
        price = 100000,
        time = 30,
        amount = 1,
        craftingChance = 90,
        item = 'weapon_machete',
        need = {
            {item = 'otel', amount = 5},
        },
        npc = {
            position = vector3(907.85900878906,-3211.1518554688,-98.222106933594),
            rotation = 20,
            model = "s_m_m_scientist_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Codrut Teodorescu'
        },
    },
    ['crafting-bat'] = {
        name = "Productie de Arme Albe (Bata)",
        price = 80000,
        time = 30,
        amount = 1,
        craftingChance = 90,
        item = 'weapon_bat',
        need = {
            {item = 'wooden_plank', amount = 5},
        },
        npc = {
            position = vector3(884.65881347656,-3199.9560546875,-98.196220397949),
            rotation = 60,
            model = "s_f_y_factory_01",
            scenario = {
                name = "WORLD_HUMAN_STAND_IMPATIENT_FACILITY"
            },
            name = 'Casiana Bratosin'
        },
    },    
}

return cfg