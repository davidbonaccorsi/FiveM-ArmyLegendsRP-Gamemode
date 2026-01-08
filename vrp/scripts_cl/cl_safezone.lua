local inSafeZone = false
local inSlowZone = false

local safeZone = nil

local safeZones = {
	-- {x, y, z, arie, isSafeZone (!slowZone), blip (name, sprite, color)}
	["aeroport"] = {-1182.3858642578,-2989.0874023438,13.94614315033, 500, true},
	["legendsmall"] = {-551.12127685547,-604.56469726562,34.681793212891, 200, true, {"Legends Mall", 793, 0}},
	["veronamall"] = {-331.05999755859,-1968.1561279297,35.614810943604, 200, true, {"Verona Mall", 793, 0}},
	-- ["paintball"] = {230.11630249023,-24.016855239868,69.782211303711, 40, true},
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		
		local playerPos = pedPos
		local px,py,pz = playerPos.x, playerPos.y, playerPos.z
		
		for i, v in pairs(safeZones)do
			x, y, z = v[1], v[2], v[3]
			radius = v[4]
			if(GetDistanceBetweenCoords(x, y, z, px, py, pz, false) < radius) then
				if v[5] then
					inSafeZone = true
				else
					inSlowZone = true
				end
				safeZone = i
			end
		end
		if safeZone ~= nil then
			x2, y2, z2 = safeZones[safeZone][1], safeZones[safeZone][2], safeZones[safeZone][3]
			radius2 = safeZones[safeZone][4]
			if(GetDistanceBetweenCoords(x2, y2, z2, px, py, pz, false) > radius2)then
				inSafeZone = false
				inSlowZone = false
				safeZone = nil
			end
		end
	end
end)

function tvRP.isInSafeZone()
	return inSafeZone
end

exports("isInSafeZone", function(acceptSlowZone)
	return inSafeZone or (acceptSlowZone and inSlowZone)
end)

Citizen.CreateThread(function()
	local wasInSafezone = true

	for safezone, v in pairs(safeZones) do
		if v[6] then
			local name, sprite, color = table.unpack(v[6])
			local blip = AddBlipForCoord(v[1], v[2], v[3])
			SetBlipSprite(blip, sprite)
			SetBlipScale(blip, 0.6)
			SetBlipAsShortRange(blip, true)
			SetBlipColour(blip, color)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(name)
			EndTextCommandSetBlipName(blip)
		end
	end

	while true do
		Citizen.Wait(1000)
		local ped = tempPed

		while inSafeZone and not (LocalPlayer.state.faction == "Politie") do
			Citizen.Wait(1)
			DisableControlAction(0,25,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,264,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,143,true)
			
			DisablePlayerFiring(PlayerId(), true)
			SetEntityInvincible(ped, true)
			SetPlayerInvincible(PlayerId(), true)
			ClearPedBloodDamage(ped)
			ResetPedVisibleDamage(ped)
			ClearPedLastWeaponDamage(ped)
			SetEntityProofs(ped, true, true, true, true, true, true, true, true)
			-- SetEntityMaxSpeed(GetVehiclePedIsIn(ped, false), 8.0)
			SetEntityCanBeDamaged(ped, false)
			
			-- 

            if not wasInSafezone then
                wasInSafezone = true
                SendNUIMessage({ interface = "safezone", show = true })
            end
		end
        
        if wasInSafezone then
            SendNUIMessage({ interface = "safezone", show = false })
            wasInSafezone = false
        end


		-- while inSlowZone do
		-- 	Citizen.Wait(1)
		-- 	SetEntityMaxSpeed(GetVehiclePedIsIn(ped, false), 8.0)
		-- end

		DisablePlayerFiring(PlayerId(), false)
		SetEntityInvincible(ped, false)
		SetPlayerInvincible(PlayerId(), false)
		ClearPedLastWeaponDamage(ped)
		SetEntityProofs(ped, false, false, false, false, false, false, false, false)
		SetEntityCanBeDamaged(ped, true)
		-- SetEntityMaxSpeed(GetVehiclePedIsIn(ped, false), GetVehicleEstimatedMaxSpeed(GetVehiclePedIsIn(ped, false)))
	end
end)
