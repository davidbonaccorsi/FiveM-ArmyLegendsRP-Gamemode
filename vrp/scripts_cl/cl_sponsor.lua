local hasSponsor = false

RegisterNetEvent("sponsor:spawnVehicle")
AddEventHandler("sponsor:spawnVehicle", function()
	local i, model = 0, "deluxo"
    local mhash = GetHashKey(model)
    while not HasModelLoaded(mhash) and i < 1000 do
	  if math.fmod(i,100) == 0 then
	    tvRP.notify("Vehiculul se incarca..")
	  end
      RequestModel(mhash)
      Citizen.Wait(30)
	  i = i + 1
    end

    -- spawn car if model is loaded
    if HasModelLoaded(mhash) then
        local nveh = CreateVehicle(mhash, pedPos.x,pedPos.y,pedPos.z+0.5, GetEntityHeading(tempPed), true, false) -- added player heading
        SetVehicleFuelLevel(nveh, 100.0)
        SetVehicleOnGroundProperly(nveh)
        SetEntityInvincible(nveh,false)
        SetPedIntoVehicle(tempPed,nveh,-1) -- put player inside
        Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
        SetVehicleHasBeenOwnedByPlayer(nveh,true)
        SetModelAsNoLongerNeeded(mhash)

	  	hasSponsor = true
	    TriggerServerEvent("vrp-sponsor:spawnedVeh", NetworkGetNetworkIdFromEntity(nveh))
	end
end)

local function checkDeluxoSpawn(veh)
    local deluxoModel = GetHashKey("deluxo")

    if not hasSponsor then
        if GetEntityModel(veh) == deluxoModel then
            TaskLeaveVehicle(tempPed, veh, 16)
            tvRP.notify("Doar cei cu gradul de sponsor au acces la aceasta masina.", "error")
        end
    end
end

AddEventHandler("vrp:onPlayerShuffleSeat", function(veh, seat)
    if seat == 0 or seat == -1 then
        checkDeluxoSpawn(veh)
    end
end)

AddEventHandler("vrp:onPlayerEnterVehicle", function(veh, isDriver)
    if isDriver then
        checkDeluxoSpawn(veh)
    end
end)