local hadJailCPThisSession = {}
local jailCp = {}
local jailSecret = {}
local jailPos = {-470.38882446289,6098.7236328125,29.832361221313}
local jailCps = {
	{-468.48532104492,6095.42578125,29.910448074341},
	{-442.96310424805,6092.2958984375,31.525228500366},
	{-451.86029052734,6091.1176757813,30.975294113159},
	{-447.41577148438,6100.1352539063,31.118591308594},
	{-445.7795715332,6109.1577148438,31.035173416138},
	{-445.10452270508,6118.0625,30.81028175354},
	{-439.7287902832,6125.7080078125,30.723505020142},
	{-452.5407409668,6132.1245117188,29.895311355591},
	{-459.10403442383,6125.3740234375,29.740747451782},
	{-460.63729858398,6117.4697265625,29.963117599487},
	{-465.99697875977,6113.8291015625,29.77615737915},
	{-469.11270141602,6106.6494140625,29.962940216064},
	{-467.64266967773,6099.4731445313,29.923160552979},
	{-468.77032470703,6093.5434570313,29.983528137207},
	{-460.4049987793,6104.4536132813,30.281251907349},
	{-455.69256591797,6108.1142578125,30.478553771973},
	{-446.3503112793,6111.0747070313,30.962280273438},
	{-457.96624755859,6110.2612304688,30.275451660156},
	{-459.0403137207,6080.654296875,31.246566772461},
	{-443.39862060547,6111.0581054688,31.099405288696}
}

local jailAnims = {
	"WORLD_HUMAN_GARDENER_PLANT",
	"WORLD_HUMAN_GARDENER_LEAF_BLOWER",
	"WORLD_HUMAN_PUSH_UPS",
	"WORLD_HUMAN_SIT_UPS"
}

local function getOutOfJail(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		SetPlayerRoutingBucket(player, 0)
		vRPclient.teleport(player, {168.2825012207,-672.04315185547,43.140892028809})
		TriggerClientEvent("vrp-jail:stopWeapons", player, false)
	end
end

RegisterCommand("checkpoints", function(player, args)
	if vRP.getUserAdminLevel(vRP.getUserId(player)) >= 1 then
        if args[1] and tonumber(args[1]) then
            vRPclient.sendInfo(player, {"Jucatorul are "..(jailCp[tonumber(args[1])] or 0).." checkpoint-uri ramase"})
        else
            vRPclient.sendSyntax(player, {"/checkpoints <user_id>"})
        end
    end
end)

RegisterServerEvent("vrp-jail:checkCheckpoint")
AddEventHandler("vrp-jail:checkCheckpoint", function(cpData)
	local player = source
	local user_id = vRP.getUserId(player)
	if jailSecret[user_id] then
		if jailCps[jailSecret[user_id]][1] == cpData[1] then

			jailCp[user_id] = jailCp[user_id] - 1

			if jailCp[user_id] <= 0 then
				getOutOfJail(user_id)
			else
				local newRnd = math.random(1, #jailCps)
				while newRnd == jailSecret[user_id] do
					newRnd = math.random(1, #jailCps)
				end

				jailSecret[user_id] = newRnd
				TriggerClientEvent("vrp-jail:sendCoords", player, jailCps[jailSecret[user_id]], jailAnims[math.random(1, #jailAnims)], jailCp[user_id])
			end
		else
			DropPlayer(player, "[AntiCheat] Injection detected")
		end
	end
end)

local function jailTick()

	for uid, cps in pairs(jailCp) do
		local src = vRP.getUserSource(uid)
		if src then
			if cps > 0 then

				local playerPed = GetPlayerPed(src)
				local playerPos = GetEntityCoords(playerPed)

				local dist = #((playerPos or vector3(0)) - vector3(jailPos[1], jailPos[2], 0.0))

				if dist >= 60.0 then
					SetPlayerRoutingBucket(src, 30)
					SetEntityCoords(playerPed, vector3(jailPos[1], jailPos[2], jailPos[3]))
				end
				TriggerClientEvent("vrp-jail:stopWeapons", src, true)

				vRPclient.subtitle(src, {"~r~Admin Jail~n~~w~Trebuie sa faci munca in folosul comunitatii !", 10})
				
			else
				jailCp[uid] = nil
			end
		else
			jailCp[uid] = nil
		end
	end

	Citizen.CreateThread(function()
		Citizen.Wait(60000)
		jailTick()
	end)
end
jailTick()

local function checkJail(user_id, player)
	if jailCp[user_id] or 0 > 0 then
		Citizen.Wait(1000)
		SetPlayerRoutingBucket(player, 30)
		vRPclient.teleport(player, {jailPos[1], jailPos[2], jailPos[3]})

		TriggerClientEvent("vrp-jail:stopWeapons", player, true)

		jailSecret[user_id] = math.random(1, #jailCps)
		TriggerClientEvent("vrp-jail:sendCoords", player, jailCps[jailSecret[user_id]], jailAnims[math.random(1, #jailAnims)], jailCp[user_id])
	end
end

function vRP.removeAdminJail(user_id)
	jailCp[user_id] = nil
	getOutOfJail(user_id)
end

function vRP.isInAdminJail(user_id)
	return (jailCp[user_id] or 0 > 0)
end

function vRP.setInAdminJail(user_id, cps, admin, reason)
	if (jailCp[user_id] or 0) == 0 then
		if cps > 0 and cps <= 600 then
			local player = vRP.getUserSource(user_id)
			
            vRP.updateUser(user_id, "ajail", cps)
            vRP.updateUser(user_id, "jailData", {admin = admin, reason = reason})
            
            if vRP.usersData[user_id] then
                vRP.usersData[user_id].adminJails = (vRP.usersData[user_id].adminJails or 0) + 1
            end
            
            exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
                ["$inc"] = {adminJails = 1}
            }})

            if player then
				hadJailCPThisSession[player] = true
				jailCp[user_id] = cps
				checkJail(user_id, player)
				return 3
			else
				return 2
			end
		else
			return 1
		end
	end
	return 4
end

function vRP.getAdminJails(user_id)
    return vRP.usersData[user_id].adminJails or 0
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		
		local jailCheckpoints = dbdata.ajail or 0

		if jailCheckpoints > 0 then
			hadJailCPThisSession[player] = true
			jailCp[user_id] = jailCheckpoints
			Citizen.Wait(2000)
			checkJail(user_id, player)
		end

	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, isSpawned)
	if isSpawned and hadJailCPThisSession[player] then
		if jailCp[user_id] then
            vRP.updateUser(user_id, "ajail", jailCp[user_id])
			Citizen.Wait(5000)
			jailCp[user_id] = nil
		else
	        vRP.updateUser(user_id, "ajail", false)
            vRP.updateUser(user_id, "jailData", false)
		end
	end
	
	jailCp[user_id] = nil
	hadJailCPThisSession[player] = nil
end)


