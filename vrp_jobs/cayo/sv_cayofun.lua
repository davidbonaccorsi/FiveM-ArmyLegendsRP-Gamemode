
local deltaCooldown = 0
local deltas = {}
RegisterServerEvent("cayo:rentDelta")
AddEventHandler("cayo:rentDelta", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		if not deltas[player] then
			if (deltaCooldown or 0) <= os.time() then

				if vRP.tryPayment(user_id, 5000, false, "Rent Deltaplan") then

					deltaCooldown = os.time() + 30
					TriggerEvent("ac:getSpawnPoint", player)
					TriggerClientEvent("cayo:spawnDelta", player, {pos = {4476.38, -4461.24, 3.70, 175.94}, hash = `microlight`})
				else
					vRPclient.notify(player, {"Nu ai destui bani !", "error"})
				end
			else
				vRPclient.notify(player, {"Asteapta "..(deltaCooldown - os.time()).." secunde", "error"})
			end
		else
			vRPclient.notify(player, {"Ai deja un deltaplan inchiriat", "error"})
		end
	end
end)

RegisterServerEvent("cayo:setPlaneObj")
AddEventHandler("cayo:setPlaneObj", function(nid, remove)
	local player = source

	if not remove then
		deltas[player] = nid
	else
		deltas[player] = nil
	end
end)

-- local vehCooldown = 0
-- local rentVehs = {
-- 	["Jeep Crew Chief"] = {`kamacho`, 5000},
-- 	["KTM 450SXF"] = {`sanchez2`, 2500},
-- 	["Jeep Wrangler"] = {`mesa`, 3000},
-- 	["Toyota Hilux"] = {`rebel`, 3000},
-- 	["Dodge WM300 Power Wagon"] = {`dloader`, 1500},
-- 	["Toyota Hilux AT37"] = {`everon`, 4000},
-- 	["Can Am Maverik X3"] = {`outlaw`, 5000},
-- 	["Sandrail"] = {`dune`, 3000},
-- 	["Ford Super Duty"] = {`sandking`, 7500},
-- 	["Ford F150"] = {`caracara2`, 7500},
-- 	["Citroen Mehari"] = {`kalahari`, 2000}
-- }

-- RegisterServerEvent("cayo:rentVeh")
-- AddEventHandler("cayo:rentVeh", function()
-- 	local player = source
-- 	local user_id = vRP.getUserId(player)
-- 	if user_id then
-- 		if not deltas[player] then
-- 			if (vehCooldown or 0) <= os.time() then

-- 				local function rentVeh(veh, price)
-- 					if vRP.tryPayment(user_id, price) then
-- 						vRP.closeMenu(player)

-- 						vehCooldown = os.time() + 30
-- 						TriggerEvent("ac:getSpawnPoint", player)
-- 						TriggerClientEvent("cayo:spawnRentedVeh", player, {pos = {4499.97, -4543.49, 3.59, 21.15}, hash = veh})
-- 					else
-- 						vRPclient.notify(player, {"~r~Nu ai destui bani"})
-- 					end
-- 				end

-- 				local rentMenu = {
-- 					name = "Rent Menu",
-- 				}

-- 				for name, data in pairs(rentVehs) do
-- 					rentMenu[name] = {function(player)
-- 						rentVeh(data[1], data[2])
-- 					end, "<i class='fas fa-chevron-right'></i>", "Pret: $<span style='color: lightgreen'>"..vRP.formatMoney(data[2]).."</span>"}
-- 				end

-- 				vRP.openMenu(player, rentMenu)
				
-- 			else
-- 				vRPclient.notify(player, {"Asteapta "..(os.time() - vehCooldown).." secunde"})
-- 			end
-- 		else
-- 			vRPclient.notify(player, {"Ai deja un vehicul inchiriat"})
-- 		end
-- 	end
-- end)


AddEventHandler("vRP:playerLeave", function(user_id, player)
	if deltas[player] then
	
		local vehicle = NetworkGetEntityFromNetworkId(deltas[player])
		if DoesEntityExist(vehicle) then
			DeleteEntity(vehicle)
		end
		
		deltas[player] = nil
	end
end)