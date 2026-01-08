
local tdCords = {-424.06857299804,-1711.6420898438,19.291410446166}


local fullPriceVehs = {
	['retinue'] = true
}

local rematCooldowns = {}

RegisterServerEvent("vrp-garages:rematOwned", function()
	local player = source
	local user_id = vRP.getUserId(player)
	
	if (rematCooldowns[user_id] or 0) <= os.time() then
		rematCooldowns[user_id] = os.time() + 30
		vRPclient.getNearestOwnedVehicle(player, {15}, function(name)
			if name then
				local vtype = vRP.getVehicleType(user_id, name)
				if vtype == "ds" then
					local vehName, price = vRP.checkVehicleName(name)

					if price ~= nil or price == 0 or price == 1 then
						if not fullPriceVehs[name] then
							price = math.ceil(price*0.5)
						end
					else
						price = 0
					end

					vRP.request(player, "Esti sigur ca doresti sa vinzi masina "..vehName.." pentru $"..vRP.formatMoney(price), 10, function(player, ok2)
						if ok2 then
							vRPclient.despawnGarageVehicle(player, {name, 50}, function(ok)
								vRPclient.getPosition(player, {}, function(x, y)
									local dst = (tdCords[1] - x)*(tdCords[1] - x) + (tdCords[2] - y)*(tdCords[2] - y)
									if dst <= 5 then
										if name then
											vRPclient.notify(player, {"Ai acceptat sa-ti vinzi masina", "success"})

											exports.mongodb:deleteOne({collection = "userVehicles", query = {user_id = user_id, vehicle = name}})

											vRP.giveMoney(user_id, price, "Remat")
											vRP.removeCacheVehicle(user_id, name)
										end
									else
										vRPclient.notify(player, {"Trebuie sa fii aproape de punctul de remat", "error"})
									end
								end)
							end)
						end
					end)
				else
					vRPclient.notify(player, {"Nu poti vinde vehicule ne personale", "error"})
				end
			else
				vRPclient.notify(player, {"Nu deti nici o masina in apropiere.", "error"})
			end
		end)
	else
		vRPclient.notify(player, {"Asteapta "..( rematCooldowns[user_id] - os.time() ).." secunde", "error"})
	end
end)