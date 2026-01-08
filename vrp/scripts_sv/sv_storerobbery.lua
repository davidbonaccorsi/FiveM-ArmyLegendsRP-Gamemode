
local storeCooldown = 2700
local policeSecconds = 15
local minCops = 4
local minLevel = 5
local robLaptop = false
local globalCooldown = 0
local store2Cooldown = 600
local stores = {
	{pos = {-47.861663818359, -1759.3719482422, 28.421010971069}, tip = 1, lastRobbed = 0},
	{pos = {-46.668876647949, -1758.0550537109, 28.421010971069}, tip = 1, lastRobbed = 0},
	{pos = {1134.1508789063, -982.48638916016, 45.415809631348}, tip = 1, lastRobbed = 0},
	{pos = {-1221.9808349609, -908.28363037109, 11.326354026794}, tip = 1, lastRobbed = 0},

	{pos = {-1486.2336425781, -377.97994995117, 39.163421630859}, tip = 1, lastRobbed = 0},
	
	{pos = {-2966.4196777344, 390.85485839844, 14.043313026428}, tip = 1, lastRobbed = 0},

	{pos = {373.07879638672, 328.72894287109, 102.56639099121}, tip = 1, lastRobbed = 0},
	{pos = {372.50723266602, 326.4162902832, 102.56639099121}, tip = 1, lastRobbed = 0},
	{pos = {24.464073181152, -1344.9854736328, 28.497026443481}, tip = 1, lastRobbed = 0},
	{pos = {24.404426574707, -1347.2951660156, 28.497026443481}, tip = 1, lastRobbed = 0},
	{pos = {2554.8881835938, 380.85437011719, 107.62294769287}, tip = 1, lastRobbed = 0},
	{pos = {2557.2954101563, 380.78680419922, 107.62294769287}, tip = 1, lastRobbed = 0},
	{pos = {-3041.2126464844, 583.82006835938, 6.9089317321777}, tip = 1, lastRobbed = 0},
	{pos = {-3038.9929199219, 584.50128173828, 6.9089317321777}, tip = 1, lastRobbed = 0},
	{pos = {-3244.6044921875, 1000.2213134766, 11.830711364746}, tip = 1, lastRobbed = 0},
	{pos = {-3242.2651367188, 999.96533203125, 11.830711364746}, tip = 1, lastRobbed = 0},
	{pos = {1164.9465332031, -322.81149291992, 68.205146789551}, tip = 1, lastRobbed = 0},
	{pos = {1165.0662841797, -324.4753112793, 68.205146789551}, tip = 1, lastRobbed = 0}
}

local storesBeingRobbed = 0
RegisterServerEvent("vrp-storerob:cancel")
AddEventHandler("vrp-storerob:cancel", function(storeId)
	local user_id = vRP.getUserId(source)
	if stores[storeId].lastRobber == user_id then
		stores[storeId].cancelRob = true
		stores[storeId].lastRobber = nil
		stores[storeId].lastRobbed = 0
		globalCooldown = 0
	end
end)

RegisterServerEvent("vrp-storerob:try")
AddEventHandler("vrp-storerob:try", function(storeId)
	local player = source
	if storeId then
		local user_id = vRP.getUserId(player)

		if not vRP.hasItem(user_id,"lockpick") then return vRPclient.notify(player, {"Trebuie sa ai un lockpick pentru a porni jaful."}) end
		if GetPlayerRoutingBucket(player) == 0 then

			if globalCooldown <= os.time() then
				stores[storeId].lastRobbed = os.time() + 10
				globalCooldown = os.time() + 10
				local cops = 0
				vRP.doFactionFunction("Politie", function(src)
					cops = cops + 1
				end)

				Citizen.Wait(100)
				if cops >= minCops then
					if vRP.hasLevel(user_id, minLevel) then
						

						if storesBeingRobbed <= math.floor(cops/minCops) then
							stores[storeId].lastRobber = user_id
							stores[storeId].lastRobbed = os.time() + storeCooldown
							globalCooldown = os.time() + store2Cooldown

							local combination = {}

							for i=1, 3 do table.insert(combination, math.random(0, 99)) end
							if stores[storeId].tip == 2 then
								for i=1, 2 do table.insert(combination, math.random(0, 99)) end
							end
							
							TriggerEvent("vrp-wanted:addWanted", 1, "Jaf la Magazin")

							TriggerClientEvent("vrp-storerob:start", player, storeId, combination, policeSecconds)
							Citizen.Wait(1000)
							if not stores[storeId].cancelRob then
								TriggerClientEvent("vrp-storerob:addBlip", player, storeId, stores[storeId].pos)
								storesBeingRobbed = storesBeingRobbed + 1
								Citizen.Wait((policeSecconds-1) * 1000)
								TriggerClientEvent("vrp-storerob:addBlip", -1, storeId, stores[storeId].pos)
								vRP.doFactionFunction("Politie", function(src)
									vRPclient.subtitle(src, {"Un magazin este ~r~JEFUIT~w~ chiar acum !", 5})
								end)
								Citizen.Wait(240000)
								storesBeingRobbed = storesBeingRobbed - 1
							else
								stores[storeId].cancelRob = nil
							end
						else
							vRPclient.notify(player, {"Deja exista prea multe jafuri in desfasurare !", "error"})
						end
					else
						vRPclient.notify(player, {"Ai nevoie de nivel "..minLevel.." pentru a jefuii magazine", "error"})
					end
				else
					vRPclient.notify(player, {"Trebuie sa fie minim "..minCops.." politisti online pentru a jefuii un magazin", "error"})
				end
			else
				local remainTime = globalCooldown - os.time()
				vRPclient.notify(player, {"Cooldown "..math.floor(remainTime / 60)..":"..(remainTime % 60)})
			end
		else
			vRPclient.notify(player, {"Trebuie sa fi in virtual world 0 pentru a da jaf"})
		end
	end
end)

RegisterServerEvent("vrp-storerob:check")
AddEventHandler("vrp-storerob:check", function(storeId, res)
	local player = source
	local user_id = vRP.getUserId(player)
	if res == true then
		if type(storeId) == "number" then
			local store = stores[storeId]

			local plyPed = GetPlayerPed(player)
			local plyPos = GetEntityCoords(plyPed)
			local storePos = vector3(store.pos[1], store.pos[2], store.pos[3])

			if store.lastRobber == user_id and #(plyPos - storePos) <= 10 then
				store.lastRobber = nil

				SetEntityCoords(plyPed, storePos + vector3(0, 0, .5))

				if store.tip == 1 then
					vRP.giveInventoryItem(user_id, "dirty_money", math.random(10000, 20000), true)	
					vRP.giveXp(user_id, 15)
				elseif store.tip == 2 then
					vRP.giveInventoryItem(user_id, "dirty_money", math.random(15000, 30000), true)	
					vRP.giveXp(user_id, math.random(20, 40))
					if robLaptop and math.random(1, 2) == 1 then
						vRP.giveInventoryItem(user_id, "hacking_device", 1, false)
						vRPclient.notify(player, {"Ai gasit un laptop sub casa de marcat!", "info"})
					end
				end
			else
				DropPlayer(player, "[ArmyLegendsAnticheat] Injection detected")
			end
			
		end
	else
		vRPclient.notify(player, {"Furt esuat !", "error"})
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		TriggerClientEvent("vrp-storerob:initBlips", player, #stores)
	end
end)