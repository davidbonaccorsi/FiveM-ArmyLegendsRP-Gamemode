
local fare <const> = 50

local chargingStations = {
    vector3(282.04919433594,-338.04656982422,44.920093536377),
}

local electricModels <const> = {
    -- lowercase
    ["ikx3f15022"] = true,
    ["taycan"] = true,
    ["al_smurd_gmchummer"] = true,
    ["models"] = true,
    ["teslax"] = true,
    ["twizy"] = true,
    ["serv_electricscooter"] = true
}

exports("getElectricModels", function()
    return electricModels
end)

for k, v in pairs(chargingStations) do
    local blip = AddBlipForCoord(v)
    SetBlipSprite(blip, 620)
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Incarcare electrica")
    EndTextCommandSetBlipName(blip)
end

local chargePoints = {
    [1] = {
        vector3(264.42, -331.46, 44.92),
        vector3(265.64, -328.07, 44.92),
        vector3(266.85, -324.69, 44.92),
        vector3(267.92, -321.72, 44.92),
        vector3(269.04, -318.62, 44.92),
        vector3(282.63, -330.86, 44.92),
        vector3(281.36, -334.39, 44.92),
        vector3(280.24, -337.5, 44.92),
        vector3(279.07, -340.74, 44.92),
        vector3(294.44, -350.32, 44.92),
        vector3(295.76, -346.65, 44.82),
        vector3(296.83, -343.68, 44.82),
        vector3(298.0, -340.44, 44.82),
        vector3(299.27, -336.91, 44.82),
        vector3(300.33, -333.94, 44.82),
        vector3(301.5, -330.7, 44.82),
    }
}

DecorRegister("electricFuel", 3)


function isModelElectric(model)
    if electricModels[model:lower()] then
        return true
    end
    return false -- GetDisplayNameFromVehicleModel(GetEntityModel(playerVehicle))
end

function getModelElectricFuel(veh)
    if veh and DecorExistOn(veh, "electricFuel") then
        return math.floor(DecorGetInt(veh, "electricFuel") or 100)
	end
    return 100
end


local refueling = false

function setModelElectricFuel(veh, fuel)
    if not fuel then return end

    DecorSetInt(veh, "electricFuel", math.floor(fuel))
end

AddEventHandler("vrp:onPlayerEnterVehicle", function(veh, isDriver)
    if not isDriver then return end

    if not DoesEntityExist(veh) then return end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(playerVehicle))
                        
    if not isModelElectric(model) then return end
    
    local fuelLevel = getModelElectricFuel(veh)

    setModelElectricFuel(veh, fuelLevel)

    while (playerVehicle == veh) and DoesEntityExist(veh) do
        ::retryLoop::
        if refueling then
            Citizen.Wait(1000)
            fuelLevel = getModelElectricFuel(veh)
            goto retryLoop
        end

        if GetIsVehicleEngineRunning(veh) then
            local rpm = GetVehicleCurrentRpm(veh)
            local speed = math.max(1, math.floor(GetEntitySpeed(veh) * 3.6))

            if fuelLevel >= 5 then
				if rpm > 0.7 then
					fuelLevel = fuelLevel - (rpm / (7 * (1.5-rpm))) * (1 + speed/300)
					Citizen.Wait(3000)
				elseif rpm > 0.6 then
					fuelLevel = fuelLevel - (rpm / (14 * (1.5-rpm))) * (1 + speed/300)
					Citizen.Wait(4000)
				elseif rpm > 0.5 then
					fuelLevel = fuelLevel - (rpm / (17 * (1.5-rpm))) * (1 + speed/300)
					Citizen.Wait(5000)
				elseif rpm > 0.4 then
					fuelLevel = fuelLevel - (rpm / (20 * (1.5-rpm))) * (1 + speed/300)
					Citizen.Wait(6000)
				elseif rpm > 0.3 then
					fuelLevel = fuelLevel - (rpm / (20 * (1.5-rpm))) * (1 + speed/500)
					Citizen.Wait(7000)
				elseif rpm > 0.2 then
					fuelLevel = fuelLevel - (rpm / (30 * (1.5-rpm))) * (1 + speed/500)
					Citizen.Wait(8000)
				else
					fuelLevel = fuelLevel - (rpm / (40 * (1.5-rpm))) * (1 + speed/500)
					Citizen.Wait(10000)
				end
			else
				fuelLevel = fuelLevel - (rpm / (10 * (1.5-rpm))) * (1 + speed/500)
				Citizen.Wait(2000)
			end

            setModelElectricFuel(veh, fuelLevel)

            if fuelLevel <= 2 then
                SetVehicleEngineOn(veh, false, false, true)
            elseif fuelLevel <= 10 then
                Citizen.CreateThread(function()
                    Citizen.Wait(math.random(math.floor(fuelLevel) * 1000, 15000))
                    SetVehicleEngineOn(veh, false, false, true)
                end)
            end
        end
        Wait(100)
    end
end)


Citizen.CreateThread(function()
    local input = false
        
    local function drawText(text, x, y, scale, r, g, b)
        SetTextFont(0)
        SetTextCentre(1)
        SetTextProportional(0)
        SetTextScale(scale, scale)
        SetTextDropShadow(30, 5, 5, 5, 255)
        SetTextEntry("STRING")
        SetTextColour(r, g, b, 255)
        AddTextComponentString(text)
        DrawText(x, y)
    end

    while true do
        Citizen.Wait(1000)

        for k, center in pairs(chargingStations) do
            local inRadius = (#(pedPos - center) <= 50.0)

            while inRadius and not refueling do

                for k, pos in pairs(chargePoints[k]) do
                    -- GetClosestObjectOfType(...): invalid prop

                    local dst = #(pedPos - pos)

                    if dst <= 15 then

                        local rgb = {93, 182, 229}

                        if dst <= 2 and not (playerVehicle == 0) then
                            rgb = {113, 203, 113}

                            local model = GetDisplayNameFromVehicleModel(GetEntityModel(playerVehicle))
                        
                            if not isModelElectric(model) then
                                rgb = {255, 0, 0}
                                goto skipCheck
                            end

             
                            drawText("Apasa ~b~H~w~ sa incarci masina pe care o conduci !~n~Pretul este de "..fare.."$ / 10 KW", 0.5, 0.85, 0.4, 255, 255, 255)
                            if IsControlJustPressed(0, 74) then 
                                local veh = GetPlayersLastVehicle()
                                
                                if not veh or (veh == 0) then
                                    TriggerEvent("vrp-hud:notify", "Ai nevoie de o masina electrica pentru a folosi incarcatorul !", "error")
                                    goto skipRefuel
                                end

                                local fuel = getModelElectricFuel(veh)
                                if not fuel then goto skipRefuel end

                                local max = math.max(0, math.floor(100 - fuel))

                                if max < 1 then
                                    TriggerEvent("vrp-hud:notify", "Vehiculul are destula energie electrica.", "error")
                                    goto skipRefuel
                                end

                                refueling = true


                                Citizen.CreateThread(function()
                                    while refueling do
                                        Citizen.Wait(100)
                                        if (fuel >= 100) or (max <= 0) then break end

                                        local p = promise.new()
                                        triggerCallback("canPayElectricFuel", function(ok)
                                            if not ok then
                                                p:resolve(false)
                                                return
                                            end
                                            FreezeEntityPosition(veh, true)
                                            SetVehicleEngineOn(veh, false, true, true)

                                            local untilTime = GetGameTimer() + 10000
                                            FreezeEntityPosition(veh, true)
                                            Citizen.CreateThread(function()
                                                while GetGameTimer() < untilTime do
                                                    fuel = math.min(100, fuel + 1)
                                                    max = math.max(0, max - 1)

                                                    if (fuel >= 100) or (max <= 0) then break end
                                                    Citizen.Wait(1000)
                                                end
                                            end)
                                            local stop = false
                                            while GetGameTimer() < untilTime do
                                                if (fuel >= 100) or (max <= 0) then break end

                                                drawText("Apasa ~r~U~w~ sa opresti alimentarea cu energie !~n~~HC_4~"..fuel.."/100 KW", 0.5, 0.85, 0.4, 255, 255, 255)

                                                if IsControlJustReleased(0, 303) then
                                                    stop = true
                                                    p:resolve(false)
                                                    break
                                                end
                                                Citizen.Wait(1)
                                            end
                                            if stop then return end
                                            p:resolve(true)
                                        end, fare, "Electric Charging")
                                        
                                        if not Citizen.Await(p) then break end
                                    end
                                    FreezeEntityPosition(veh, false)

                                    refueling = false
                                    setModelElectricFuel(veh, fuel)
                                end)

                                break
                                ::skipRefuel::
                            end
                        end
                        ::skipCheck::

                        DrawMarker(36, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, rgb[1], rgb[2], rgb[3], 100, false, false, false, true)
                    end

                end

                inRadius = (#(pedPos - center) <= 50.0)
                Citizen.Wait(1)
            end

            if input then
                TriggerEvent("vrp-hud:showBind", false)
                input = false
            end
        end

    end
end)
