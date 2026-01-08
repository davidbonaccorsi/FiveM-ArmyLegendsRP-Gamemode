
local authLog = false

RegisterCommand("discordlog", function(player)
    if player ~= 0 then
        vRPclient.noAccess(player)
        return
    end

    authLog = not authLog
    print("[vRP] Discord Auth logging: "..(authLog and "^2YES^7" or "^1NO^7"))
end)

AddEventHandler("vrp:allowDiscord", function(data)
    if authLog then
        print("[vRP] Discord authentification: "..json.encode(data))
    end

    local user_id = parseInt(data.user_id)

    local source = vRP.getUserSource(user_id)
    if source then
        TriggerClientEvent("vrp:sendNuiMessage", source, {
            interface = 'discordLogin',
            action = 'update',
            data = data,
        })
    end
end)

-- AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, data)
--     if not first_spawn then return end

--     if not (data.discordData) then
--         TriggerClientEvent('vrp:sendNuiMessage', player, {
--             interface = 'discordLogin',
--             action = 'open',
--             user_id = user_id,
--         })
--     end
-- end)