RegisterNetEvent("vrp:onPlayerShuffleSeat")

RegisterNUICallback("vehmenu:switchSeat", function(data, cb)
	local theSeat = data.seat
	if not theSeat then
		return
	end

	if (theSeat == -1) or (theSeat == 0) then
		local firstSeat = GetPedInVehicleSeat(playerVehicle, 1)
		local secondSeat = GetPedInVehicleSeat(playerVehicle, 2)

		if (firstSeat == tempPed) or (secondSeat == tempPed) then
			cb("ok")
			return tvRP.notify("Nu te poti muta in fata!", "error")
		end
	elseif (theSeat == 1) or (theSeat == 2) then
		local firstSeat = GetPedInVehicleSeat(playerVehicle, -1)
		local secondSeat = GetPedInVehicleSeat(playerVehicle, 0)

		if (firstSeat == tempPed) or (secondSeat == tempPed) then
			cb("ok")
			return tvRP.notify("Nu te poti muta in spate!", "error")
		end
	end

	SetPedIntoVehicle(tempPed, playerVehicle, theSeat)
	TriggerEvent("vrp:onPlayerShuffleSeat", playerVehicle, theSeat)
	cb("ok")
end)

RegisterNUICallback('vehmenu:toggleNeons', function(data, cb)
	if (playerVehicle == 0) then
		return
	end

	if not (GetPedInVehicleSeat(playerVehicle, -1) == tempPed) then
		return tvRP.notify("Doar soferul poate face acest lucru", 'error')
	end

	local neonState = IsVehicleNeonLightEnabled(playerVehicle, 0)

	for i=0, 3 do
		SetVehicleNeonLightEnabled(playerVehicle, i, not neonState)
	end

	cb('ok')
end)

RegisterNUICallback("vehmenu:switchEngine", function(_, cb)
	if (playerVehicle == 0) or (GetPedInVehicleSeat(playerVehicle, -1) ~= tempPed) then
		return
	end

    local running = GetIsVehicleEngineRunning(playerVehicle)
    SetVehicleEngineOn(playerVehicle, not running, true, true)

    if running then
        SetVehicleUndriveable(playerVehicle, true)
    else
        SetVehicleUndriveable(playerVehicle, false)
    end
	
	cb("ok")
end)

RegisterNUICallback("vehmenu:toggleDoor", function(data, cb)
	local theDoor = data.door
	if not theDoor then
		return
	end

	if not (GetPedInVehicleSeat(playerVehicle, -1) == tempPed) and theDoor < 2  then
		return tvRP.notify("Doar soferul poate face acest lucru", 'error')
	end

    local doorAngle = GetVehicleDoorAngleRatio(playerVehicle, theDoor)
    local doorOpen = doorAngle > 0.0

    if not doorOpen then
    	SetVehicleDoorOpen(playerVehicle, theDoor, false, false)
    else
    	SetVehicleDoorShut(playerVehicle, theDoor, false)
	end
	
	cb("ok")
end)

RegisterNUICallback("vehmenu:toggleAllDoors", function(data, cb)
	if not (GetPedInVehicleSeat(playerVehicle, -1) == tempPed) then
		return tvRP.notify("Doar soferul poate face acest lucru", 'error')
	end

	for theDoor=0, 3 do
    	local doorAngle = GetVehicleDoorAngleRatio(playerVehicle, theDoor)
    	local doorOpen = doorAngle > 0.0

    	if not doorOpen then
    		SetVehicleDoorOpen(playerVehicle, theDoor, false, false)
    	else
    		SetVehicleDoorShut(playerVehicle, theDoor, false)
		end
	end
	
	cb("ok")
end)

RegisterNUICallback("vehmenu:toggleWindow", function(data, cb)
	local theWindow = data.windowId
	if not theWindow then
		return
	end

	if not (GetPedInVehicleSeat(playerVehicle, -1) == tempPed) and theWindow < 2 then
		return tvRP.notify("Doar soferul poate face acest lucru", 'error')
	end

    if not IsVehicleWindowIntact(playerVehicle, theWindow) then
        RollUpWindow(playerVehicle, theWindow)

        if not IsVehicleWindowIntact(playerVehicle, theWindow) then
            RollDownWindow(playerVehicle, theWindow)
        end
    else
        RollDownWindow(playerVehicle, theWindow)
    end
	
	cb("ok")
end)

RegisterNUICallback("vehmenu:togLights", function(_, cb)
	if (playerVehicle == 0) then
		return
	end

	if not (GetPedInVehicleSeat(playerVehicle, -1) == tempPed) then
		return tvRP.notify("Doar soferul poate face acest lucru", 'error')
	end

	for i=0, 3 do
		local lightsState = IsVehicleNeonLightEnabled(playerVehicle, i)
	
		SetVehicleNeonLightEnabled(playerVehicle, i, not lightsState)
	end

	cb("ok")
end)

RegisterCommand("newVehicleMenu", function()
	if playerVehicle == 0 then
		return
	end

	SendNUIMessage({
		interface = "vehicleMenu",
	})

	TriggerEvent("vrp:interfaceFocus", true)
end)

RegisterKeyMapping("newVehicleMenu", "Meniu vehicul", "keyboard", "Z")