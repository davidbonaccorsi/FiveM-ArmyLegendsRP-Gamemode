
local sponsorCooldown = {}
local sponsorVehs = {}
local sponsorTags = {}

local function checkCooldown(player, cb)
	if (sponsorCooldown[player] or 0) <= os.time() then
		sponsorCooldown[player] = os.time() + 120

		cb(player)
	else
		vRPclient.notify(player, {"Cooldown: "..sponsorCooldown[player] - os.time().." secunde", "error"})
	end
end

function vRP.getSponsorTag(player)
	return sponsorTags[player] or false
end

vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		if vRP.hasGroup(user_id, "sponsors") then
			choices["Sponsor Menu"] = {function(player)

				if not vRP.isInAdminJail(user_id) then
					if GetPlayerRoutingBucket(player) == 0 then

						local menu = {
							name = "Sponsor Menu",
							css= {top="75px", header_color="rgba(200,0,0,0.75)"},
							onclose = function(player) vRP.openMainMenu(player) end
						}

						-- menu["Fix Masina"] = {function(player)
						-- 	checkCooldown(player, function(player)
						-- 		TriggerClientEvent('vehicle:fix', player)
						-- 		vRPclient.msg(-1, {"^5Sponsor^7: "..GetPlayerName(player).." ["..user_id.."] si-a fixat masina!"})
						-- 	end)
						-- end, '<i class="fa-duotone fa-car-wrench"></i>'}
						menu["Refa Mancare/Apa"] = {function(player)
							checkCooldown(player, function(player)
								vRP.setHunger(user_id, 100)
        						vRP.setThirst(user_id, 100)
								vRPclient.msg(-1, {"^5Sponsor^7: "..GetPlayerName(player).." ["..user_id.."] si-a dat mancare/apa full!"})
								sponsorCooldown[player] = os.time() + 900
							end)
						end, '<i class="fa-duotone fa-car-wrench"></i>'}
						menu["Heal"] = {function(player)
							checkCooldown(player, function(player)
								-- vRPclient.varyHealth(player, {200})
								vRP.giveItem(user_id, "bandage", 2)
								SetTimeout(500, function()
									vRPclient.msg(-1, {"^5Sponsor^7: "..GetPlayerName(player).." ["..user_id.."] si-a dat revive!"})
								end)
							end)
						end, '<i class="fa-duotone fa-notes-medical"></i>'}
						-- menu["Refill Gloante"] = {function(player)
						-- 	checkCooldown(player, function(player)
						-- 		TriggerClientEvent("ples:refillBulets", player)
						-- 	end)
						-- end, '<i class="fa-duotone fa-chart-bullet"></i>'}
						menu["Masina Sponsor"] = {function(player)
							vRPclient.getHealth(player,{}, function(health)
								if health and health > 105 then
									checkCooldown(player, function(player)
										TriggerEvent("ac:getSpawnPoint", player)
										TriggerClientEvent("sponsor:spawnVehicle", player, "deluxo")
									end)
								else
									vRPclient.notify(player,{"Nu poti spawna masina cat timp esti mort."})
								end
							end)
						end, '<i class="fa-duotone fa-car"></i>'}
						menu["Custom Chat Tag"] = {function(player)
							vRP.prompt(player, "Chat tag", "Scrie in caseta tagul dorit si apoi apasa butonul de confirmare.", false, function(tag)
								if not tag then return end
                                if tag:len() <= 15 then
									sponsorTags[player] = tag
                                    vRP.updateUser(user_id, "chatTag", tag)
								else
									vRPclient.notify(player, {"Maxim 15 caractere", "error"})
								end
							end)
						end, '<i class="fa-duotone fa-user-tag"></i>'}

						vRP.openMenu(player, menu)
					else
						vRPclient.notify(player, {"Nu poti folosii acest meniu acum", "error"})
					end
				else
					vRPclient.notify(player, {"Nu poti folosii acest meniu in admin jail"})
				end

			end, '<i class="fa-duotone fa-star"></i>'}
		end
		add(choices)
	end
end)

RegisterServerEvent("vrp-sponsor:spawnedVeh")
AddEventHandler("vrp-sponsor:spawnedVeh", function(nid)
	local player = source
	if sponsorVehs[player] then
		local vehicle = NetworkGetEntityFromNetworkId(sponsorVehs[player])
		if DoesEntityExist(vehicle) then
			DeleteEntity(vehicle)
		end
		sponsorVehs[player] = nil
	end

	sponsorVehs[player] = nid
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	sponsorCooldown[player] = nil
	if sponsorVehs[player] then
		local vehicle = NetworkGetEntityFromNetworkId(sponsorVehs[player])
		if DoesEntityExist(vehicle) then
			DeleteEntity(vehicle)
		end
		sponsorVehs[player] = nil
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		if dbdata.chatTag then
			if vRP.hasGroup(user_id, "sponsors") then
				sponsorTags[player] = dbdata.chatTag
			else
                vRP.updateUser(user_id, "chatTag", false)
			end
		end
	end
end)