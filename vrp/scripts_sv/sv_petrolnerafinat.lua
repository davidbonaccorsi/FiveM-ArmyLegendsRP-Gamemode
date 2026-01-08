RegisterServerEvent("vl:cumpara_petrol_nerafinat", function()
    player = source
    local user_id = vRP.getUserId(player)

    vRP.prompt(player,"Petrol Nerafinat", "Cumpara petrol (5 RON / L)","", function(liters)
        liters = tonumber(liters)
        if liters < 0 then return end
        if type(liters) ~= "number" then return end

        TriggerClientEvent("vrp:progressBar", player, {
            duration = 4000,
            text = "Astepti imbutelierea petrolului🏴",
        })
        Citizen.Wait(4200)

        if vRP.tryPayment(user_id, liters * 5, true, "Petrol Nerafinat") or vRP.tryBankPayment(user_id, liters * 5, true, "Petrol Nerafinat") then
            vRP.giveItem(user_id, "petrol_nerafinat", liters, false, false, false, 'Petrol Nerafinat')
        end
    end)
end)


RegisterServerEvent("vl:fura_petrol", function()
    player = source
    local user_id = vRP.getUserId(player)
    local playerPed = GetPlayerPed(player)

    if #(GetEntityCoords(playerPed) - vector3(4284.845703125,2967.4372558594,-181.84521484375)) > 10 then
        return vRP.ban(user_id, "Aleluia ai luat muia :). [Event]: vl:fura_petrol", player, 0, false)
    end
    if vRP.getInventoryItemAmount(user_id, "scubakit") >= 1 then
        return vRP.ban(user_id, "Aleluia ai luat muia :). [Event]: vl:fura_petrol", player, 0, false)
    end

    local litri = math.random(200,300)

    FreezeEntityPosition(playerPed, true)

    TriggerClientEvent("vrp:progressBar", player, {
        duration = 90000,
        text = "Furi Petrol🏴",
    })
    Citizen.Wait(90000)

    FreezeEntityPosition(playerPed,false)

    vRP.giveItem(user_id, "petrol_nerafinat", litri, false, false, false, 'Petrol Nerafinat')
end)