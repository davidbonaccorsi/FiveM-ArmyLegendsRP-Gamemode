local cfg = module('cfg/fuelstation')
DecorRegister("customFuel", 1)

local electricModels = exports.vrp:getElectricModels()

AddEventHandler('vrp:onPlayerEnterVehicle', function(veh, isDriver)
    local lastDamage = 0.0

    while (playerVehicle == veh) do
        local vehicle = GetVehiclePedIsIn(tempPed, false)
        local shakeRate = GetEntitySpeed(veh) / 250.0 -- 250.0 Normal Shake / 100.0 High Shake / 50.0 Maksimum Shake
        local curHealth = GetVehicleBodyHealth(veh)
        
        if curHealth < lastDamage then
            ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", shakeRate)
        end

        lastDamage = curHealth
        Wait(100)
    end
end)

AddEventHandler('vrp:onPlayerEnterVehicle', function(veh, isDriver)
    if not isDriver then return end

    local fuelLevel = DecorExistOn(veh, 'customFuel') and DecorGetFloat(veh, 'customFuel') or 100.0
    local isInVehicle = veh

    while (playerVehicle == veh) do
        if not DoesEntityExist(isInVehicle) or not isInVehicle then
            break
        end

        if GetIsVehicleEngineRunning(isInVehicle) then
            local rpm = GetVehicleCurrentRpm(isInVehicle)
            local speed = math.max(1, math.floor(GetEntitySpeed(isInVehicle) * 3.6))

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

            SetVehicleFuelLevel(isInVehicle, fuelLevel + 0.0)
            DecorSetFloat(isInVehicle, 'customFuel', fuelLevel + 0.0)

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

local function getFuelstation(coords)
    for gasId, data in pairs(cfg.gasStations) do
        if #(data.coords - coords) <= 30 then
            return gasId
        end
    end
end

local keyActive = {}
Citizen.CreateThread(function()

    for id, pos in pairs(cfg.gasStations) do
        local blip = AddBlipForCoord(pos.coords)
        SetBlipSprite(blip, 361)
		SetBlipScale(blip, 0.6)
		SetBlipColour(blip, 64)
		SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, 180)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Benzinarie")
		EndTextCommandSetBlipName(blip)
    end

    while true do
        local ticks = 1500
        local vehicle = GetPlayersLastVehicle(tempPed)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(vehCoords - pedPos)
        
        if (playerVehicle == 0) and dist <= 6.0 then
            
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            if isModelElectric(model) then goto skipLoop end

            for index, pumpModel in pairs(cfg.thePumps) do
                local closestPump = GetClosestObjectOfType(pedPos, 1.5, pumpModel, false, false)
    
                if closestPump ~= 0 then
                    ticks = 1
                    
                    local coords = GetEntityCoords(closestPump)
                    local distance = #(GetEntityCoords(PlayerPedId()) - coords)
                    DrawMarker(41, coords[1] + 1.0, coords[2],coords[3] + 1.0, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.35, 194, 80, 80, 150, true, true, false, true)

                    if not keyActive[index] then
                        keyActive[index] = true
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = 'Alimenteaza vehiculul'})
                    end
    
                    if IsControlJustReleased(0, 51) then                        
                        if not tvRP.isInComa() then
                            local gasId = getFuelstation(coords)

                            keyActive[index] = false
                            TriggerEvent("vrp-hud:showBind", false)
                            TriggerEvent("vrp-hud:updateMap", false)
                            TriggerEvent("vrp-hud:setComponentDisplay", {
                                serverHud = false,
                                minimapHud = false,
                                bottomRightHud = false,
                                chat = false,
                            })

                            triggerCallback('getFuelStationData', function(fuelPrice, fuelLevel, userMoney)
                                SendNUIMessage({
                                    interface = 'fuelStation',
                                    data = {
                                        menu = 'fuel-pump',
                                        vehFuel = tonumber(100 - GetVehicleFuelLevel(vehicle)),
                                        fuelPrice = fuelPrice,
                                        fuelStock = fuelLevel,
                                        userMoney = userMoney,
                                        stationId = gasId,
                                    },
                                })
                            end, gasId)
                        end
                    end
                else
                    if keyActive[index] then
                        keyActive[index] = false
                        TriggerEvent("vrp-hud:showBind", false)
                    end
                end
            end
        else
            for index, _ in pairs(cfg.thePumps) do
                if keyActive[index] then
                    keyActive[index] = false
                    TriggerEvent("vrp-hud:showBind", false)
                end
            end
        end
        ::skipLoop::
        Wait(ticks)
    end
end)

Citizen.CreateThread(function()
	for index, data in pairs(cfg.gasStations) do
        if data.business then
            tvRP.setArea("vRP:"..index ,data.business[1], data.business[2], data.business[3], 15,
            {key = 'E', text='Meniu Benzinarie', minDst = 1},
            {
				type = 29,
				x = 0.501,
				y = 0.501,
				z = 0.5001,
                color = {185, 230, 185, 200},
                coords = data.business
            },
            function()
                TriggerServerEvent('vrp-fuelstation:businessMenu', index)
            end)
        end
	end
end)

RegisterNUICallback("fuelVehicle", function(data, cb)
    triggerCallback('canPayFuel', function(canFuel)
        if not canFuel then
            return tvRP.notify("Nu ai destui bani pentru a plati, incearca alta metoda de plata!", "error")
        end

        Citizen.CreateThread(function()
            SetCurrentPedWeapon(tempPed, -1569615261, true) -- weapon_unarmed
            RequestAnimDict("timetable@gardener@filling_can")
    
            while not HasAnimDictLoaded("timetable@gardener@filling_can") do
                Citizen.Wait(1)
            end
    
            TaskPlayAnim(tempPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
        end)

        local vehicle = GetPlayersLastVehicle(tempPed)
        local fuel = parseInt(GetVehicleFuelLevel(vehicle))
        local amount = fuel + tonumber(data[2])
    
        FreezeEntityPosition(tempPed, true)
        FreezeEntityPosition(vehicle, false)
    
        while tonumber(fuel) <= amount do
            if tonumber(fuel) >= 100 then
                break
            end
    
            fuel += 2
            if fuel > 100 then
                fuel = 100
            end
            Citizen.Wait(1100)
        end
        
        Citizen.Wait(100)
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
        DecorSetFloat(vehicle, 'customFuel', fuel + 0.0)
        FreezeEntityPosition(tempPed, false)
        ClearPedTasks(PlayerPedId())

    end, data[1], data[2], data[3])
    cb(true)
end)

RegisterNUICallback("fuelStation:buyProduct", function(data, cb)
    TriggerServerEvent("vRP:buyFuelStationProduct", data[1], data[2])
    cb('ok')
end)

RegisterNUICallback('fuelStation:sellGasStation', function(data, cb)
    TriggerServerEvent('vrp-fuelstation:sellStation', data[1])
    cb('ok')
end)

RegisterNUICallback("fuelStation:addFuel", function(data, cb)
    TriggerServerEvent("vrp-fuelstation:addFuel", data[1])
    cb('ok')
end)

RegisterNUICallback('fuelStation:updatePrice', function(data, cb)
    TriggerServerEvent("vrp-fuelstation:updatePrice", data[1], data[2])
    cb('ok')
end)

RegisterNUICallback("fuelStation:withdrawBalance", function(data, cb)
    TriggerServerEvent("vrp-fuelstation:withdrawBalance", data[1])
    cb('ok')
end)

RegisterNetEvent("vRP:useCanistra", function()
    if tvRP.isInComa() then
        return
    end

    local vehicle = tvRP.getVehicleInDirection(GetEntityCoords(tempPed, 1), GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 2.0, 0.0))
    if (DoesEntityExist(vehicle)) then
        local fuel = tonumber(GetVehicleFuelLevel(vehicle))
        local amount = (100 - fuel) + fuel

        FreezeEntityPosition(tempPed, true)
        FreezeEntityPosition(vehicle, false)
        
        local animDict = "weapon@w_sp_jerrycan"
        local animName = "fire"
        
        RequestModel(GetHashKey("prop_ld_jerrycan_01"))
        while not HasModelLoaded(GetHashKey("prop_ld_jerrycan_01")) do
            Citizen.Wait(1)
        end

        ClearPedSecondaryTask(tempPed)
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(1)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(tempPed, 0.0, 0.0, -5.0)
        local canObj = CreateObject(GetHashKey("prop_ld_jerrycan_01"), plyCoords, 1, 0, 0)

        TaskPlayAnim(tempPed, animDict, animName, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
        AttachEntityToEntity(canObj, tempPed, GetPedBoneIndex(tempPed, 28422), 0.09, 0.0, 0.0, 0.0, 270.0, 0.0, 1, 1, 0, 1, 0, 1)
        
        if amount > 100 then amount = 100 end

        while tonumber(fuel) <= amount do
            if tonumber(fuel) >= 100 then
                break
            end

            fuel += 1
            Citizen.Wait(1100)
        end

        Citizen.Wait(100)
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
        DecorSetFloat(vehicle, 'customFuel', fuel + 0.0)
        ClearPedSecondaryTask(tempPed)
        DeleteEntity(canObj)

        FreezeEntityPosition(tempPed, false)
    end
end)