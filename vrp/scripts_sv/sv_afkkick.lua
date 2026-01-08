
local safe = {1, 2, 3, 4, 21,22, 5, 37434, 22349}
local function passAfk(user_id)
	for _, id in ipairs(safe) do
		if user_id == id then return true end
	end
	return false
end

local sleepTable = {}

RegisterServerEvent("kickForBeingAnAFKDouchebag")
AddEventHandler("kickForBeingAnAFKDouchebag", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		if not passAfk(user_id) then
			local sleeping = vRP.isUserSleeping(player) or false
			if not sleeping then
				if not sleepTable[player] then
					DropPlayer(player, "ArmyLegends: Ai fost AFK prea mult.")
				else
					sleepTable[player] = sleepTable[player] - 1
					if sleepTable[player] <= 0 then
						sleepTable[player] = nil
					end
				end
			else
				sleepTable[player] = 5
				if os.time() - sleeping > 18000 then
					DropPlayer(player, "ArmyLegends: Ai dormit mai mult de 5 ore.")
				end
			end

		end
	else
		DropPlayer(player, "ArmyLegends: Ai fost AFK prea mult.")
	end
end)

function tvRP.canWashVehicle()
    local player = source
    local user_id = vRP.getUserId(player)

	exports.vrp:achieve(user_id, 'CarWashEasy', 1)

    return vRP.tryPayment(user_id,100,false,"Car Wash")
end

RegisterServerEvent("chatForKick")
AddEventHandler("chatForKick", function()
    local sleeping = vRP.isUserSleeping(source) or false
	if not sleeping then
		TriggerClientEvent("chatMessage", source, "^1AFK: ^7O sa primesti kick in 2 minute!")
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
	if first_spawn then
		local vipRank = vRP.getUserVipRank(user_id)

		if vipRank > 1 then
			TriggerClientEvent("afk-kick:setPrime", player, 3600)
		end
	end
end)

local afkTime = 300 -- The amount of time (in seconds) before a player is considered AFK
local checkInterval = 60 -- The frequency (in seconds) at which the server checks for AFK players