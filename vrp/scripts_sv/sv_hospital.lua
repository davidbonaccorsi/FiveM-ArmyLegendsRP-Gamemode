local inBedPlayers = {}

local allBeds = {
	["Pillbox"] = {
		{pos = vec4(314.93408203125,-570.90093994141,49.118633270264, 222.0), ocuppied = 0},
		{pos = vec4(316.57476806641,-566.48059082031,49.118698120117, 222.0), ocuppied = 0},
		{pos = vec4(319.91387939453,-567.69006347656,49.118701934814, 45.0), ocuppied = 0},
		{pos = vec4(318.25323486328,-572.01110839844,49.118686676025, 45.0), ocuppied = 0},
		{pos = vec4(323.19400024414,-568.84326171875,49.118629455566, 45.0), ocuppied = 0},
	},

	["Sandy"] = {
		{pos = vec4(1733.6455078125,3637.4089355469,35.694358825684, 30.0), ocuppied = 0},
		{pos = vec4(1735.234375,3634.7658691406,35.694362640381, 30.0), ocuppied = 0},
		{pos = vec4(1736.7659912109,3632.3620605469,35.694362640381, 30.0), ocuppied = 0},
		{pos = vec4(1738.8520507813,3629.5402832031,35.694362640381, 30.0), ocuppied = 0},
		{pos = vec4(1739.9306640625,3626.7131347656,35.694362640381, 30.0), ocuppied = 0},
		{pos = vec4(1741.2054443359,3624.6005859375,35.694366455078, 30.0), ocuppied = 0},
	},

	["wantedoras"] = {
		{pos = vec4(807.56939697266,-495.62817382813,31.517963409424, 317.26), ocuppied = 0}, -- spital mafioti
	},

	["paleto"] = {
	    {pos = vec4(-257.46575927734,6321.9848632813,33.351661682129, 317.26), ocuppied = 0}, -- spital paleto
	    {pos = vec4(-259.99957275391,6324.3681640625,33.351680755615, 317.26), ocuppied = 0}, -- spital paleto
	    {pos = vec4(-262.28866577148,6326.5458984375,33.35164642334, 317.26), ocuppied = 0}, -- spital paleto
	    {pos = vec4(-258.87515258789,6329.9672851563,33.351676940918, 317.26), ocuppied = 0}, -- spital paleto
	    {pos = vec4(-256.58660888672,6327.7080078125,33.351676940918, 317.26), ocuppied = 0}, -- spital paleto
	},

	["wantedout"] = {
		{pos = vec4(2811.4189453125,5975.4194335938,351.84210205078, 317.26), ocuppied = 0}, -- spital maafioti in afara orasului
	},

	["alcatraz"] = {
		{pos = vec4(-3700.1057128906,-4067.8942871094,58.59009552002, 338.0), ocuppied = 0},
		{pos = vec4(-3700.1181640625,-4065.5141601562,58.590072631836, 327.0), ocuppied = 0},
		{pos = vec4(-3700.0053710938,-4063.5556640625,58.590072631836, 329.0), ocuppied = 0},
		{pos = vec4(-3696.2729492188,-4062.9606933594,58.590072631836, 153.0), ocuppied = 0},
		{pos = vec4(-3696.2155761719,-4064.9448242188,58.590072631836, 151.0), ocuppied = 0},
	}
}

local locations = {
	{vec3(303.77243041992,-590.19451904297,43.274806976318), "Pillbox"}, -- spital Pillbox
	{vec3(1767.5628662109,3640.1162109375,34.852588653564), "Sandy"}, -- spital Sandy Shores
	{vec3(806.83288574219,-493.33157348633,30.688301086426), "wantedoras", true}, -- spital mafioti oras
	{vec3(-251.97573852539,6334.1850585938,32.427181243896), "paleto"}, -- spital paleto
	{vec3(2809.8732910156,5977.9755859375,350.91870117188), "wantedout", true}, -- spital mafioti in afara orasului
	{vec3(-3700.2983398438,-4071.4880371094,57.665546417236), "alcatraz"},
}

local secsInBed <const> = 200

registerCallback("hospital:getBed", function(player, place)
	for index, data in next, allBeds[place] do
		if os.time() > parseInt(data.ocuppied) then
			allBeds[place][index].ocuppied = os.time() + secsInBed

			return index
		end
	end
end)


function tvRP.canReviveAtHospital()
	local user_id = vRP.getUserId(source)
	return vRP.tryPayment(user_id, 500, true, "Hospital Revive")
end

RegisterServerEvent("vrp-hospitals:getInBed", function(hospital, bed)
	local player = source
	local user_id = vRP.getUserId(player)

	inBedPlayers[user_id] = {hospital, bed}
end)

RegisterServerEvent("vrp-hospitals:leaveBed", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if inBedPlayers[user_id] then
		local hospital = allBeds[inBedPlayers[user_id][1]]
		if hospital then
			hospital[tonumber(inBedPlayers[user_id][2])].ocuppied = nil
		end
		inBedPlayers[user_id] = nil
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	if inBedPlayers[user_id] then
		local hospital = allBeds[inBedPlayers[user_id][1]]
		if hospital then
			hospital[tonumber(inBedPlayers[user_id][2])] = nil
		end
		inBedPlayers[user_id] = nil
	end
end)

AddEventHandler("vRP:playerSpawn", function(uid, src, first_spawn)
	if first_spawn then
		TriggerClientEvent("populateHospitals", src, allBeds, locations)
	end
end)