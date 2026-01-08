Citizen.CreateThread(function()
    local input = Config.keybinds.toggle.input
    local pressedAt = nil

    while true do
        local sleep = 3000

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed) then
            local veh = GetVehiclePedIsIn(playerPed)

            -- Whether or not the ped is the driver
            if CanVehicleToggleEsp(veh) and GetPedInVehicleSeat(veh, -1) == playerPed then
                sleep = 200

                if IsControlPressed(0, input) or IsDisabledControlPressed(0, input) then
                    if pressedAt == nil then
                        pressedAt = GetGameTimer()
                    elseif pressedAt + 100 < GetGameTimer() then
                        sleep = 1
                        DisableControlAction(0, input)
                    end

                    if pressedAt + Config.keybinds.toggle.holdDuration < GetGameTimer() then
                        pressedAt = nil
                        local netId = NetworkGetNetworkIdFromEntity(veh)

                        if IsEspOff(veh) then
                            TriggerEvent("vrp-hud:notify", "Ai pornit ESP-ul!", "success")
                        else
                            TriggerEvent("vrp-hud:notify", "Ai oprit ESP-ul!", "success")
                        end

                        TriggerServerEvent('kq_tractioncontrol:server:toggleTraction', netId, not IsEspOff(veh))

                        Citizen.CreateThread(function()
                            local disableUntil = GetGameTimer() + 100
                            while GetGameTimer() < disableUntil do
                                Citizen.Wait(1)
                                DisableControlAction(0, input)
                            end
                        end)
                    end
                else
                    pressedAt = nil
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- This function is responsible for all the tooltips displayed on top right of the screen, you could
-- replace it with a custom notification etc.
function ShowTooltip(message)
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    EndTextCommandDisplayHelp(0, 0, 0, -1)
end

-- This function is responsible for drawing all the 3d texts ('Press [E] to ...' e.g)
function Draw3DText(coords, textInput)
    SetTextScale(Config.fontScale, Config.fontScale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentSubstringKeyboardDisplay(textInput)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function CanVehicleToggleEsp(vehicle)
    return UseCache('canVehUseEsp' .. vehicle, function()
        -- Blacklist
        local blacklist = Config.blacklist

        if blacklist.vehiclesEnabled then
            if ContainsVehicleModel(blacklist.vehicles, GetEntityModel(vehicle)) then
                return false
            end
        end

        if blacklist.classesEnabled then
            if Contains(blacklist.classes, GetVehicleClass(vehicle)) then
                return false
            end
        end

        -- Whitelist
        local whitelist = Config.whitelist

        if whitelist.vehiclesEnabled then
            if not ContainsVehicleModel(whitelist.vehicles, GetEntityModel(vehicle)) then
                return false
            end
        end

        if whitelist.classesEnabled then
            if not Contains(whitelist.classes, GetVehicleClass(vehicle)) then
                return false
            end
        end

        if TractionControlAlwaysOff(vehicle) then
            return false
        end

        return true
    end, 10000)
end

function TractionControlAlwaysOff(vehicle)
    return UseCache('tractionControlAlwaysOff' .. vehicle, function()
        local noTractionControl = Config.noTractionControl

        if noTractionControl.vehiclesEnabled then
            if ContainsVehicleModel(noTractionControl.vehicles, GetEntityModel(vehicle)) then
                return true
            end
        end

        if noTractionControl.classesEnabled then
            if Contains(noTractionControl.classes, GetVehicleClass(vehicle)) then
                return true
            end
        end

        return false
    end, 10000)
end

function Contains(tab, val)
    if not tab then
        return false
    end

    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function ContainsVehicleModel(tab, val)
    if not tab then
        return false
    end

    for index, value in ipairs(tab) do
        if GetHashKey(value) == val then
            return true
        end
    end

    return false
end

function ToggleTractionControl(vehicle, state)
    if vehicle == nil then
        vehicle = GetVehiclePedIsIn(PlayerPedId())
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if state == nil then
        state = not IsEspOff(vehicle)
    end

    TriggerServerEvent('kq_tractioncontrol:server:toggleTraction', netId, state)
end
exports('ToggleTractionControl', ToggleTractionControl)
