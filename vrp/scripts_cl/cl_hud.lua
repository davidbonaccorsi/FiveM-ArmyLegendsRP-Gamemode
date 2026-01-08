
RegisterNetEvent("vrp:onPlayerEnterVehicle")
RegisterNetEvent("vrp:onPlayerLeaveVehicle")
RegisterNetEvent("vrp-hud:updateMap")

AddEventHandler("onPlayerTalkingStatusChanged", function(state)
    SendNUIMessage({
        action = "colorizeMicrophone",
        talking = state
    })
end)

local sent = false
AddEventHandler("gameEventTriggered", function(name, args)    
    if name == "CEventNetworkPlayerEnteredVehicle" then 
        Wait(1500)
        if not (args[2] == playerVehicle) then return end

        local inVeh = playerVehicle ~= 0
        local veh = playerVehicle
        local isDriver = (GetPedInVehicleSeat(veh, -1) == tempPed) or false
        local plate = GetVehicleNumberPlateText(veh)
        local nid = NetworkGetNetworkIdFromEntity(veh)
        if not sent then
            TriggerEvent("vrp:onPlayerEnterVehicle", veh, isDriver)
            sent = true
        end
        if isDriver then
            TriggerServerEvent("vrp:onPlayerEnterVehicle", nid, plate)
            SetPedCanBeDraggedOut(tempPed, false)
        end

        Citizen.CreateThread(function()
            while isDriver do
                if playerVehicle == 0 then break end
                
                local carSpeed = math.ceil(GetEntitySpeed(playerVehicle) * 3.6)
                local carOdometer = string.format("%.2f", (DecorGetFloat(playerVehicle, "veh_km") or 0) / 1000)
                
                
                local model = GetDisplayNameFromVehicleModel(GetEntityModel(playerVehicle))
                
                local electric = isModelElectric(model)
                local fuel = electric and getModelElectricFuel(playerVehicle) or (string.format("%.1f", DecorExistOn(playerVehicle, 'customFuel') and DecorGetFloat(playerVehicle, 'customFuel') or GetVehicleFuelLevel(playerVehicle)))

                SendNUIMessage({
                    interface = "setSpeedoValue",
                    speed = carSpeed,
                    tank = fuel,
                    electric = electric,
                    rpm = GetVehicleCurrentRpm(playerVehicle),
                    odometer = carOdometer,
                    seatbelt = carBelt,
                    class = GetVehicleClass(playerVehicle),
                    show = true,
                })
            
                Wait(1000)
            end
			TriggerEvent("vrp:onPlayerLeaveVehicle", veh)
			if isDriver then
				TriggerServerEvent("vrp:onPlayerLeaveVehicle", nid, plate)
			end
            sent = false
            SendNUIMessage({interface = "setSpeedoValue", show = false })
        end)
    end
end)

AddEventHandler("getOnlinePly", function(amm)
    SendNUIMessage({
        interface = "setHudPlayers",
        players = amm,
    })
end)



local function getMinimapAnchor()
    SetScriptGfxAlign(string.byte("L"), string.byte("B"))

    local topX, topY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.1888888))
    ResetScriptGfxAlign()

    local width, height = GetActiveScreenResolution()
    return {width*topX, height*topY}
end

RegisterNUICallback("hud:getMinimapAnchor", function(data, cb)
    local anchor = getMinimapAnchor()

    -- return left, top
    cb(anchor)
end)

Citizen.CreateThread(function()
    RegisterNetEvent("vrp-hud:setComponentDisplay")
    local active, hudStates = true, {}

    exports("getHudState", function(component)
        return hudStates[component]
    end)

    exports("isMapActive", function()
        return active
    end)
    RegisterNetEvent("vrp-hud:updateMap")
    AddEventHandler("vrp-hud:updateMap", function(tog)
        active = tog

        DisplayRadar(active)
    end)


    RegisterNUICallback("hud:resetAllDisplay", function(data, cb)
        TriggerEvent("vrp-hud:setComponentDisplay", "resetAll")
        cb("ok")
    end)

    AddEventHandler("vrp-hud:setComponentDisplay", function(componentsTbl)
        if type(componentsTbl) == "string" and componentsTbl == "resetAll" then
            componentsTbl = {}
            for component, state in pairs(hudStates) do
                componentsTbl[component] = true
            end
        end

        Citizen.Wait(100)
        for component, tog in pairs(componentsTbl) do
            hudStates[component] = tog

            SendNUIMessage({
                action = "setComponentDisplay",
                component = component,
                tog = tog
            })
        end
    end)

    TriggerEvent("vrp-hud:updateMap", active)
end)


AddEventHandler("pma-voice:setTalkingMode", function(theLevel)
    SendNUIMessage({
        interface = "setVoiceLevel",
        lvl = theLevel,
    })
end)

AddEventHandler("onPlayerTalkingStatusChanged", function(tog)
    SendNUIMessage({
        interface = "setVoiceState",
        tog = tog
    })
end)

local bank, cash, coins = 0, 0, 0
RegisterNetEvent("vrp-hud:updateMoney", function(newCash, newBank, newCoins)
    bank, cash = newBank, newCash
    coins = newCoins

    SendNUIMessage({interface = "setHudMoney", cash = cash})
end)

exports("getCashMoney", function()
    return cash
end)

RegisterNetEvent("vrp-hud:updateUid", function(id)
    SendNUIMessage({
        interface = "setHudId",
        id = id,
    })
end)

RegisterNetEvent("vrp-hud:showMoneyFlow", function(amount, type)
    SendNUIMessage({
        interface = "moneyFlow",
        type = type,
        amount = amount
    })
end)

RegisterNetEvent("vrp-hud:sendApiError", function(...)
    local args = {...}
    exports.vrp:runjs("serverHud.sendError('"..table.unpack(args).."')")
end)

RegisterNetEvent("vrp-hud:sendApiInfo", function(...)
    local args = {...}
    exports.vrp:runjs("serverHud.sendInfo('"..table.unpack(args).."')")
end)


Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)
        
        local var1, var2 = GetStreetNameAtCoord(pedPos.x, pedPos.y, pedPos.z)
        local street = GetStreetNameFromHashKey(var1)
        local district = GetStreetNameFromHashKey(var2)

        if street:len() < 2 then
            street = "Necunoscuta"
        elseif district:len() < 2 then
            district = "Necunoscuta"
        end

        SendNUIMessage({
            interface = "locationDisplay",
            data = {
                district = district,
                street = street,
            }
        })
    end
end)


local compass = false

RegisterCommand("compass", function()

    compass = not compass

    if compass then
        SendNUIMessage({ act = "interface", target = "compass", event = "show" })
    
        Citizen.CreateThread(function()
            local lastHeading = 1

            Citizen.CreateThread(function()
                while compass do

                    local var1, var2 = GetStreetNameAtCoord(pedPos.x, pedPos.y, pedPos.z)
                    local street = GetStreetNameFromHashKey(var1)
                    local district = GetStreetNameFromHashKey(var2)

                    if street:len() < 2 then
                        street = "Necunoscuta"
                    elseif district:len() < 2 then
                        district = "Necunoscuta"
                    end

					SendNUIMessage({
                        act = "interface",
                        target = "compass",
                        event = "update",
                        data = {
                            district = district,
                            street = street,
                        }
                    })

                    Citizen.Wait(500)
                end
            end)

			while compass do
				local camRot = GetGameplayCamRot(0)
				local heading = tostring(math.floor(360.0 - ((camRot.z + 360.0) % 360.0)))
				if heading == '360' then heading = '0' end
				if heading ~= lastHeading then
					SendNUIMessage({
                        act = "interface",
                        target = "compass",
                        event = "update",
                        data = {heading = tonumber(heading)}
                    })
					Citizen.Wait(2)
				end
				lastHeading = heading
				Citizen.Wait(10)
			end
        end)
    else
        SendNUIMessage({ act = "interface", target = "compass", event = "hide" })
    end
end)