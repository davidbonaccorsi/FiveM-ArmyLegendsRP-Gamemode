local garages = module('cfg/garages').garage_types
local radarOn, radar = false, {
    stop = false,
    front = "",
    back = "",
}

RegisterCommand("pdradar", function()
    local cop = exports.vrp:isCop()

    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    print(veh)

    for k,v in pairs(garages["police"]) do
        print(v)
        if v == veh then return TriggerEvent("vrp-hud:notify", "Poti sa pornesti radar-ul doar dintr-o masina a politiei.") end
    end


    if not cop then return end

    radarOn = not radarOn


    if radarOn then

        local function isFrontSeat()
            local veh = playerVehicle
            if ((GetPedInVehicleSeat(veh, -1) ~= tempPed) and (GetPedInVehicleSeat(veh, 0) ~= tempPed)) then
                return false
            end
            return true
        end
        
        Citizen.CreateThread(function()
            if IsPedInAnyVehicle(tempPed, true) then

                if not isFrontSeat() then
                    radarOn = false
                    return
                end
            
                SendNUIMessage({interface = "pdradar", show = true, stop = not radar.stop})
                TriggerEvent("vrp-hud:notify", "Apasa NUMPAD 8 pentru a pune pe pauza radarul sau NUMPAD 5 pentru a opri radarul.")

                local lastSpeeds = {-1, -1}
                while radarOn do
                    local foundNew = false
                    local veh = playerVehicle

                    if not radar.stop then
                        local coordA = GetOffsetFromEntityInWorldCoords(veh, 0.0, 1.0, 1.0)
                        local coordB = GetOffsetFromEntityInWorldCoords(veh, 0.0, 105.0, 0.0)
                        local frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, veh, 7)
                        local a, b, c, d, e = GetShapeTestResult(frontcar)

                        if IsEntityAVehicle(e) then
						
                            local vehicleModel = GetEntityModel(e)
    
                            local vehDisplayName = GetDisplayNameFromVehicleModel(vehicleModel)
                            local vehicleLabelText = GetLabelText(vehDisplayName)
                            local vehicleName = vehicleLabelText == 'NULL' and vehDisplayName or vehicleLabelText
    
                            local speed = math.ceil(GetEntitySpeed(e) * 3.6)
                            local plate = GetVehicleNumberPlateText(e)
                            plate = plate:sub(1, 5).. " " ..plate:sub(6)
                            radar.front = string.format("%s - %s - %d km/h", vehicleName, plate, speed)
    
                            if lastSpeeds[1] ~= speed then
                                newValues = true
                            end
                            lastSpeeds[1] = speed
                        end

                        
                        local bcoordB = GetOffsetFromEntityInWorldCoords(veh, 0.0, -105.0, 0.0)
                        local rearcar = StartShapeTestCapsule(coordA, bcoordB, 3.0, 10, veh, 7)
                        local f, g, h, i, j = GetShapeTestResult(rearcar)
                        
                        if IsEntityAVehicle(j) then
                            local vehicleModel = GetEntityModel(j)

                            local vehDisplayName = GetDisplayNameFromVehicleModel(vehicleModel)
                            local vehicleLabelText = GetLabelText(vehDisplayName)
                            local vehicleName = vehicleLabelText == 'NULL' and vehDisplayName or vehicleLabelText

                            local speed = math.ceil(GetEntitySpeed(j) * 3.6)
                            local plate = GetVehicleNumberPlateText(j)
                            plate = plate:sub(1, 5).. " " ..plate:sub(6)
                            radar.back = string.format("%s - %s - %d km/h", vehicleName, plate, speed)

                            if lastSpeeds[2] ~= speed then
                                newValues = true
                            end
                            lastSpeeds[2] = speed
                        end

                        if newValues then
                            SendNUIMessage({interface = "pdradar", front = radar.front, back = radar.back})
                        end
                    end

                    if not IsPedInAnyVehicle(tempPed) then
                        radarOn = false
                        break
                    end

                    Citizen.Wait(100)
                end

                SendNUIMessage({interface = "pdradar", show = false})
            else
                radarOn = false
            end
        end)
    end
end)

RegisterCommand("togradar", function()
    if radarOn then
        radar.stop = not radar.stop
        SendNUIMessage({interface = "pdradar", stop = radar.stop})
    end
end)

RegisterKeyMapping("pdradar", "Radar politie", "keyboard", "NUMPAD5")

RegisterKeyMapping("togradar", "Pune radarul pe pauza", "keyboard", "NUMPAD8")