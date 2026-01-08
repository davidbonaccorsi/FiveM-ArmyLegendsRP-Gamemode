local cfg = {}

cfg.storage_types = {
    ["Smurd"] = {
        _config = {faction="Smurd", blipid = 478, blipcolor = 41, iconColor = {255, 0, 0, 200}},

        ["medkit"] = {1},
        ["adrenaline"] = {1},
        ["bandage"] = {1},
        ["paracetamol"] = {1},
        ['weapon_stungun'] = {1},
        ['furazolidon'] = {1},
    },
    ["Politie"] = {
        _config = {faction="Politie", blipid = 175, blipcolor = 3, iconColor = {93, 182, 229, 200}},

        ['weapon_glock17'] = {1},
        ['weapon_stungun'] = {1},
        ['weapon_m9'] = {1},
        ['weapon_m4'] = {1},
        ['weapon_scarh'] = {1},
        ['weapon_ar15'] = {1},
        ['weapon_mk14'] = {1},
        ['weapon_remington'] = {1},
        ["weapon_nightstick"] = {1},
        ["weapon_flashlight"] = {1},
        ["adrenaline"] = {1},
        ["paracetamol"] = {1},
        ["radio"] = {1},
        ["scubakit"] = {1},
        ["body_armor"] = {1},
        ["medkit"] = {1},
        ["bandage"] = {1},
        ["ghiozdanMediu"] = {1},
    },
}

cfg.storages = {
    {326.12115478516,-592.15216064453,38.322799682617,"Smurd"}, --LS
    {1778.0620117188,3650.6062011719,34.852577209473,"Smurd"}, -- SANDY
    {-253.0221862793,6310.7436523438,32.427223205566,"Smurd"}, -- PALETO
    {458.08413696289,-1000.1953125,35.062419891357,"Politie"}, --LS
    {1837.8442382813,3681.2036132813,38.929306030273,"Politie"}, -- SANDY
    {-445.8981628418,6018.5400390625,36.995643615723,"Politie"}, --PALETO
}

return cfg