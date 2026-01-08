local ACTIVE = false
local ACTIVE_EMERGENCY_PERSONNEL = {}

RegisterNetEvent("pd_eblips:toggle")
AddEventHandler("pd_eblips:toggle", function(on)
	-- toggle blip display --
	ACTIVE = on
	-- remove all blips if turned off --
	if not ACTIVE then
		for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
			local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
			if possible_blip ~= 0 then
				RemoveBlip(possible_blip)
				ACTIVE_EMERGENCY_PERSONNEL[src] = nil
			end
		end
	end
end)

RegisterNetEvent("pd_eblips:updateAll")
AddEventHandler("pd_eblips:updateAll", function(personnel)
	ACTIVE_EMERGENCY_PERSONNEL = personnel
end)

RegisterNetEvent("pd_eblips:update")
AddEventHandler("pd_eblips:update", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
end)

RegisterNetEvent("pd_eblips:remove")
AddEventHandler("pd_eblips:remove", function(id)
	local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(id)))
	if possible_blip ~= 0 then
		RemoveBlip(possible_blip)
		ACTIVE_EMERGENCY_PERSONNEL[id] = nil
	end
end)


Citizen.CreateThread(function()
	while not ACTIVE do Citizen.Wait(5000) end
	while true do
		for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
			local player = GetPlayerFromServerId(src)
			local ped = GetPlayerPed(player)
			if GetPlayerPed(-1) ~= ped then
				if GetBlipFromEntity(ped) == 0 then
					local blip = AddBlipForEntity(ped)
					SetBlipSprite(blip, 1)
					SetBlipColour(blip, info.color)
					SetBlipAsShortRange(blip, true)
					SetBlipDisplay(blip, 4)
					SetBlipShowCone(blip, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(info.name)
					EndTextCommandSetBlipName(blip)
				end
			end
		end
		Wait(500)
	end
end)