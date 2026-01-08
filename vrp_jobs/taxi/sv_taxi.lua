local activeCalls, inCall = {}, {}

local taxiVehicles = {}

RegisterServerEvent("jobs:setTaxiObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    taxiVehicles[user_id] = netid
end)


AddEventHandler("vRP:playerLeave", function(user_id)
    if taxiVehicles[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(taxiVehicles[user_id])

        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end

    taxiVehicles[user_id] = nil
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if taxiVehicles[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(taxiVehicles[user_id])
        
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        taxiVehicles[user_id] = nil
    end
end)


RegisterServerEvent("vrp-phone:callService")
AddEventHandler("vrp-phone:callService", function(service)
    local player = source
    local user_id = vRP.getUserId(player)

    if service == "taxi" then

        if not activeCalls[user_id] then

            activeCalls[user_id] = {
                user_id = user_id,
                player = player,
                name = exports.vrp:getRoleplayName(user_id, true),
                position = GetEntityCoords(GetPlayerPed(player)),
            }

            Citizen.Wait(100)
            if activeCalls[user_id] then
                doInJobPlayersFunction("Taximetrist", function(member)
                    TriggerClientEvent("vrp:sendNuiMessage", member, {interface = "emsCallsAlert"})
                end)
            end
        else
            vRPclient.notify(player, {"Ai deja un apel in asteptare.", "error"})
        end
    end
end)

RegisterServerEvent("ems:takeCall", function(target_id)
    local player = source
    local user_id = vRP.getUserId(player)

    if exports["vrp_jobs"]:hasJob(user_id, "Taximetrist") then
        if activeCalls[target_id] then

            if not taxiVehicles[user_id] then
                vRPclient.notify(player, {"Nu ai un un vehicul de Taxi.", "error"})
                return
            end

            if inCall[user_id] then
                vRPclient.notify(player, {"Ai deja o cursa activa.", "error"})
                return
            end

            local target_src = vRP.getUserSource(target_id)
            if target_src then
                
                inCall[user_id] = {
                    user_id = user_id,
                    player = player,
                    target_src = target_src,
                    code = math.random(1111,9999),
                }
                
                TriggerClientEvent("ems:startCall", player, activeCalls[target_id].player, activeCalls[target_id].position, 379, 60)

                vRPclient.notify(target_src, {"Un taximetrist se indreapta catre tine.", "error"})

                vRPclient.notify(player, {"Te indrepti catre un apel.\n\nSolicitant: "..exports.vrp:getRoleplayName(target_id), "info", "Apel preluat", 10000})

                TriggerClientEvent("work-taxi:startTrackingTaxi", target_src, player, taxiVehicles[user_id], activeCalls[target_id].position, inCall[user_id].code)
            end

            activeCalls[target_id] = nil
        else
            vRPclient.notify(player, {"Solicitare invalida.", "error"})
        end
    end
end)

AddEventHandler("ems:openCallsMenu", function(player)
    local user_id = vRP.getUserId(player)
    -- --

    if exports["vrp_jobs"]:hasJob(user_id, "Taximetrist") then
        TriggerClientEvent("ems:showCallsMenu", player, {
            interface = "emsCalls",
            calls = activeCalls,
        })
    end
end)

RegisterServerEvent("work-taxi:updateFare", function(amount, playerNet, code)
    local user_id = vRP.getUserId(playerNet)
    if user_id then
        if inCall[user_id] and (inCall[user_id].code == tonumber(code)) then
            vRPclient.subtitle(playerNet, {"Total de plata: ~g~$"..vRP.formatMoney(amount), 5})
        end
    end
end)

RegisterServerEvent("work-taxi:payDriver", function(amount, playerNet, code)
    local player = source
    local user_id = vRP.getUserId(player)
    local target_id = vRP.getUserId(playerNet)

    if target_id then
        if inCall[target_id] and (inCall[target_id].code == tonumber(code)) then
            if vRP.tryFullPayment(user_id, amount, true, false, "Taxi Service ("..target_id..")") then
                vRP.giveMoney(target_id, amount)
            else
                vRPclient.notify(playerNet, {"Clientul nu are bani sa iti plateasca.", "error"})
            end

            exports.vrp:achieve(user_id, "TaxiEasy", 1)
        end

        inCall[target_id] = nil
    else
        vRPclient.notify(player, {"Nu poti plati acestui sofer.", "error"})
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if activeCalls[user_id] then
        activeCalls[user_id] = nil
    end

    if inCall[user_id] then
        TriggerClientEvent("work-taxi:cancelRoute", inCall[user_id].target_src)
        inCall[user_id] = nil
    end
end)
