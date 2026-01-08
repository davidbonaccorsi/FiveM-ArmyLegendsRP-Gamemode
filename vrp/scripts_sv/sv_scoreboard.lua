
local playerList = {}

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        Citizen.Wait(5000)
        local faction = vRP.getUserFaction(user_id)
        if faction == "user" then
            faction = "Fara factiune"
        end

        playerList[user_id] = {uid = user_id, faction = faction, name = GetPlayerName(player)}
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if playerList[user_id] then
        playerList[user_id] = nil
    end
end)

exports("setScoreboardTblVal", function(user_id, key, val)
    if playerList[user_id] then
        playerList[user_id][key] = val
        return true
    end
    return false
end)

RegisterServerEvent("scoreboard:show", function()
    local player = source
    local user_id = vRP.getUserId(player)
    local faction = vRP.getUserFaction(user_id)

    if faction == "user" then
        faction = "Civil"
    end

    vRP.getWarnsNum(user_id, function(warnsNr)

        local data = {
            name = GetPlayerName(player),
            user_id = user_id,
            faction = faction,
            warns = warnsNr,
            playerList = playerList,
        }

        data.sessionTime = ("%dh %dm"):format(vRP.getUserHoursPlayedInThisSession(user_id, 1))
        data.hoursPlayed = vRP.getUserHoursPlayed(user_id)
    
        TriggerClientEvent("scoreboard:togShow", player, data)
    end)
end)