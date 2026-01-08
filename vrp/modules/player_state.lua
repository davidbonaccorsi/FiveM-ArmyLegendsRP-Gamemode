local firstSpawn = vector3(-1049.4223632813,-2759.9516601563,21.36169052124)
local deathPosition = vector3(323.19982910156,-584.79174804688,43.267627716064)
local policeRespawn = vector3(449.93057250977,-976.24603271484,30.7243309021)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		Citizen.Wait(2500)

		-- if dbdata.userIdentity then
		-- 	exports["vrp"]:loadCharacter(user_id, player)
		-- elseif dbdata.discordData then
		-- 	exports["vrp"]:createCharacter(user_id, player)
		-- end
		
		if dbdata.userIdentity then
			exports["vrp"]:loadCharacter(user_id, player)
		else
			exports["vrp"]:createCharacter(user_id, player)
		end 

		local coords = dbdata.userCoords or firstSpawn

		local playerPed = GetPlayerPed(player)
		SetEntityCoords(playerPed, coords.x, coords.y, coords.z + 1, true, false, false, true)

		FreezeEntityPosition(playerPed, true)
		Wait(500)
		FreezeEntityPosition(playerPed, false)

		local health = tonumber(dbdata.health) or 200
		vRPclient.setHealth(player, {health})

		local armour = tonumber(dbdata.armour) or 0
		vRPclient.setArmour(player, {armour})
		Player(player).state.user_id = user_id
		Player(player).state.faction = dbdata.userFaction and dbdata.userFaction.faction

		TriggerClientEvent("vrp-hud:updateUid", player, user_id)
		TriggerClientEvent("getOnlinePly", -1, GetNumPlayerIndices())
	else
		Citizen.CreateThread(function()
			vRP.clearInventory(user_id)
			exports["vrp"]:loadCharacter(user_id, player)
		end)
		
		SetPlayerRoutingBucket(player, 0)

		vRP.setMoney(user_id, 0)

		vRP.usersData[user_id].health = 200
		vRPclient.setHealth(player, {200})

		vRPclient.setHandcuff(player,{false})

		local x, y, z = deathPosition.x, deathPosition.y, deathPosition.z
		if vRP.isUserPolitist(user_id) then
			x, y, z = policeRespawn.x, policeRespawn.y, policeRespawn.z
		end

		vRP.usersData[user_id].userCoords = {x = x, y = y, z = z}

		Citizen.CreateThread(function()
			local playerPed = GetPlayerPed(player)
			
			SetEntityCoords(playerPed, x, y, z, true, false, false, true)

			FreezeEntityPosition(playerPed, true)
			Wait(500)
			FreezeEntityPosition(playerPed, false)
		end)
	end
end)

RegisterServerEvent('vrp-login:createCharacter', function()
	local player = source
	local user_id = vRP.getUserId(player)

	if vRP.usersData[user_id] and vRP.usersData[user_id].userIdentity then
		exports["vrp"]:loadCharacter(user_id, player)
	else
		exports["vrp"]:createCharacter(user_id, player)
	end
end)


AddEventHandler("vRP:playerLeave", function(user_id, player, isSpawned, reason)
	if isSpawned then
	
		updatePlayerState(user_id, player, reason)
		Citizen.Wait(100)
		
		local setQuery = {}
		setQuery.userCoords, setQuery.health, setQuery.armour = vRP.usersData[user_id].userCoords, vRP.usersData[user_id].health, vRP.usersData[user_id].armour

		Citizen.Wait(100)

		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = setQuery}})
		TriggerClientEvent("getOnlinePly", -1, GetNumPlayerIndices())
	end
end)

RegisterCommand("savepos", function(player)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) >= 4 or user_id == 21 or user_id == 22 then
		local playerPed = GetPlayerPed(player)
		local newPos = GetEntityCoords(playerPed)

		vRP.usersData[user_id].userCoords = {x = newPos.x, y = newPos.y, z = newPos.z}
		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {userCoords = vRP.usersData[user_id].userCoords}}})

		vRPclient.notify(player, {"Pozitia ti-a fost salvata!", "info"})
	else
		vRPclient.notify(player, {"Nu ai acces la aceasta comanda", "error"})
	end
end)

local inHouse = {}
RegisterServerEvent("playerhousing:Enter")
AddEventHandler("playerhousing:Enter", function(house)
	inHouse[source] = house
end)

RegisterServerEvent("playerhousing:Leave")
AddEventHandler("playerhousing:Leave", function()
	inHouse[source] = nil
end)

function updatePlayerState(user_id, player, reason)
	local playerPed = GetPlayerPed(player)
 
	local newPos = GetEntityCoords(playerPed)
	local newHealth = GetEntityHealth(playerPed)
	local newArmour = GetPedArmour(playerPed)

	if not inHouse[player] then
		vRP.usersData[user_id].userCoords = {x = newPos.x, y = newPos.y, z = newPos.z}
	end
	vRP.usersData[user_id].health = newHealth
	vRP.usersData[user_id].armour = newArmour
end
