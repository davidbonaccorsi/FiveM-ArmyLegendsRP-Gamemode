local cfg = {}

cfg.grade_discord = { 
    {type ="Staff", discord = 1215577017152700476, rank = 7}, -- Developer
    {type ="Staff", discord = 1213538807874584626, rank = 7}, -- Fondator
    {type ="Staff", discord = 1213941432214102046, rank = 6}, -- Manager
    {type ="Staff", discord = 1213941926169149471, rank = 5}, -- Supervizor
    {type ="Staff", discord = 1213942186714857542, rank = 4}, -- Admin
    {type ="Staff", discord = 1213942700747923579, rank = 3}, -- Moderator
    {type ="Staff", discord = 1213942764400672899, rank = 2}, -- Helper
    {type ="Staff", discord = 1215636025720967168, rank = 1}, -- Trial Helper

    {type ="Grade", discord = 1226472047392067584, group = "Manager Factiuni"},
    {type ="Grade", discord = 1226471857738354759, group = "event"},

    {type ="vip", discord = 1248614631962837073, vipLvl = 1},
    {type ="vip", discord = 1248614654997958719, vipLvl = 2},
}


   -- [[    Felurile de grade ce pot fii puse la functia "type" sunt Staff, Faction sau Grade. De la mine Edishor#2838 pentru toti fanii mei. ]]


function getDiscordConfig()
	return cfg
end