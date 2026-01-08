function tvRP.showXpBar(startXp, endXp, beforeXp, currentXp, currentLevel)
	local RankBarColor = 9
	if beforeXp > currentXp then
		RankBarColor = 6
	end
	
	if not HasHudScaleformLoaded(19) then
        RequestHudScaleform(19)
		while not HasHudScaleformLoaded(19) do
			Wait(1)
		end
    end
	
	BeginScaleformMovieMethodHudComponent(19, "SET_COLOUR")
	PushScaleformMovieFunctionParameterInt(RankBarColor)
    EndScaleformMovieMethodReturn()
	
	--[[
	    PURE_WHITE 	= 0
		WHITE 		= 1
		BLACK 		= 2
		GREY 		= 3
		GREYLIGHT 	= 4
		GREYDARK 	= 5
		RED 		= 6
		REDLIGHT 	= 7
		REDDARK 	= 8
		BLUE 		= 9
		BLUELIGHT 	= 10
		BLUEDARK 	= 11
		YELLOW 		= 12
		YELLOWLIGHT = 13
		YELLOWDARK 	= 14
		ORANGE 		= 15
		ORANGELIGHT = 16
		ORANGEDARK 	= 17
		GREEN 		= 18
		GREENLIGHT 	= 19
		GREENDARK 	= 20
		PURPLE 		= 21
		PURPLELIGHT	= 22
		PURPLEDARK 	= 23
		PINK 		= 24
		BRONZE 		= 107
		SILVER 		= 108
		GOLD 		= 109
		PLATINUM 	= 110
		FREEMODE 	= 116
	]]

    BeginScaleformMovieMethodHudComponent(19, "SET_RANK_SCORES")
	PushScaleformMovieFunctionParameterInt(startXp)
	PushScaleformMovieFunctionParameterInt(endXp)
	PushScaleformMovieFunctionParameterInt(beforeXp)
	PushScaleformMovieFunctionParameterInt(currentXp)
	PushScaleformMovieFunctionParameterInt(currentLevel)
	PushScaleformMovieFunctionParameterInt(70)
	
    EndScaleformMovieMethodReturn()
end

local lvlBar = false
RegisterCommand("showlevel", function()
    if not lvlBar then
        vRPserver.getLevelInfo({}, function(data)
            tvRP.showXpBar(0, data.need, data.xp, data.xp, data.level)
        end)

        lvlBar = true

        Citizen.CreateThread(function()
            Citizen.Wait(10000)
            lvlBar = false
        end)
    end
end)

RegisterKeyMapping("showlevel", "Vezi bara de nivel", "keyboard", "f1")
