local activeCalls = {}

RegisterServerEvent("vrp-phone:callService")
AddEventHandler("vrp-phone:callService", function(service)
    local player = source
    local user_id = vRP.getUserId(player)

    if service == "ambulance" then

        if not activeCalls[user_id] then

            
            vRP.selectorMenu(player, 'Selecteaza o conditie', { -- call conditions
                {'Conditie de viata critica', 'Conditie de viata critica'},
                {'In stare fizica buna', 'In stare fizica buna'},
                {'Inghetand in apa', 'Inghetand in apa'},
                {'Ranit pe un munte', 'Ranit pe un munte'}
            }, function(condition)
                
                if condition then
                    activeCalls[user_id] = {
                        user_id = user_id,
                        player = player,
                        name = exports.vrp:getRoleplayName(user_id, true),
                        position = GetEntityCoords(GetPlayerPed(player)),
                        condition = condition,
                    }
                end

                Citizen.Wait(100)
                if activeCalls[user_id] then
                    vRP.doFactionFunction("Smurd", function(member)
                        TriggerClientEvent("vrp:sendNuiMessage", member, {interface = "emsCallsAlert"})
                    end)
                end

            end)
        else
            vRPclient.notify(player, {"Ai deja un apel in asteptare.", "error"})
        end
    end
end)

RegisterServerEvent("ems:takeCall", function(target_id)
    local player = source
    local user_id = vRP.getUserId(player)

    if vRP.isUserInFaction(user_id, "Smurd") then
        if activeCalls[target_id] then
            TriggerClientEvent("ems:startCall", player, activeCalls[target_id].player, activeCalls[target_id].position, 51, 6)
            
            local target_src = vRP.getUserSource(target_id)
            if target_src then
                vRPclient.notify(target_src, {"Un echipaj medical se indreapta catre tine.", "error"})

                vRPclient.notify(player, {"Te indrepti catre un apel.\n\nSolicitant: "..exports.vrp:getRoleplayName(target_id).."\nConditie: "..activeCalls[target_id].condition, "info", "Apel preluat", 10000})
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

    if vRP.isUserInFaction(user_id, "Smurd") then
        TriggerClientEvent("ems:showCallsMenu", player, {
            interface = "emsCalls",
            calls = activeCalls,
        })
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if activeCalls[user_id] then
        activeCalls[user_id] = nil
    end
end)
