
local existingBlips = {}

RegisterNetEvent("eblips:addOne", function(src, info)
	existingBlips[src] = info
end)

RegisterNetEvent("eblips:remove")
AddEventHandler("eblips:remove", function(src)
	local possbileBlip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
	if possbileBlip then
		RemoveBlip(possbileBlip)
		existingBlips[src] = nil
	end
end)

Citizen.CreateThread(function()
	while true do
		for src, info in pairs(existingBlips) do
			local player = GetPlayerFromServerId(src)
			local ped = GetPlayerPed(player)
			
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
		Wait(1000)
	end
end)
