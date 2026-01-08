
if true then return end

local boomboxSkip = {}

RegisterServerEvent("vrp-boombox:trySetMusic", function()
    local player = source
    local user_id = vRP.getUserId(player)

    vRP.prompt(player, "Boombox", "Link melodie (doar de pe Youtube):", false, function(song)
        if not song then return end

        TriggerClientEvent("vrp-boombox:playSound", -1, song)
    end)
end)
