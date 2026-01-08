local playerWanted = {}

function vRP.addWanted(user_id, amount, reason)
    if not playerWanted[user_id] then
        playerWanted[user_id] = {}
    end

    local currentWantedCount = #playerWanted[user_id]
    if currentWantedCount >= 5 then
        return
    end

    local remainingSlots = 5 - currentWantedCount
    local numToAdd = math.min(amount, remainingSlots)

    for i = 1, numToAdd do
        table.insert(playerWanted[user_id], {
            reason = reason,
            time = 1800,
        })
    end

    updatePlayerWanted(user_id)
end

function vRP.removeWanted(user_id)
    if playerWanted[user_id] then
        playerWanted[user_id] = nil
    end

    updatePlayerWanted(user_id)
end

function updatePlayerWanted(user_id)
    local player = vRP.getUserSource(user_id)
    
    if player then
        vRP.updateUser(user_id, 'playerWanted', playerWanted[user_id])

        TriggerClientEvent('vrp:sendNuiMessage', player, {
            interface = 'setHudWanted',
            wanted = #playerWanted[user_id]
        })
        TriggerClientEvent('vrp-wanted:updatePlayers', -1, player, playerWanted[user_id])
    end
end

local function task_wanted_check()
    for user_id, data in pairs(playerWanted) do
        if #data >= 1 then
            local latest_record = data[#data]
            if latest_record then
                latest_record.time = latest_record.time - 10
    
                if latest_record.time <= 0 then
                    table.remove(data, #data)
                    updatePlayerWanted(user_id)
                end
            end
        end
    end
    SetTimeout(1000 * 10, task_wanted_check)
end task_wanted_check()

AddEventHandler('vRP:playerSpawn', function(user_id, player, spawn, data)
    if not spawn then return end;

    if not playerWanted[user_id] then
        playerWanted[user_id] = data.playerWanted or {}
    end

    if vRP.isUserPolitist(user_id) then
        for user_id, data in pairs(playerWanted) do
            local player_src = vRP.getUserSource(user_id)
            if player_src then
                TriggerClientEvent('vrp-wanted:updatePlayers', player, player_src, data)
            end
        end
    end
    
    updatePlayerWanted(user_id)
end)

AddEventHandler('vRP:playerLeave', function(user_id, player, spawned)
    if not spawned then return end;

    if playerWanted[user_id] then
        vRP.updateUser(user_id, 'playerWanted', playerWanted[user_id])
        TriggerClientEvent('vrp-wanted:updatePlayers', -1, player, false)
    end
end)

RegisterServerEvent('vrp-wanted:addWanted')
AddEventHandler("vrp-wanted:addWanted", function(amount, reason)
    local player = source;
    local user_id = vRP.getUserId(player)

    vRP.addWanted(user_id, amount, reason)
end)

RegisterCommand('setwanted', function(player, args)
    local user_id = vRP.getUserId(player)
    local wantedLevel = parseInt(args[1])

    if (vRP.getUserAdminLevel(user_id) <= 4) then
        return
    end

    if (wantedLevel <= 0) then
        return
    end
    
    vRP.addWanted(user_id, wantedLevel, 'test')
end)