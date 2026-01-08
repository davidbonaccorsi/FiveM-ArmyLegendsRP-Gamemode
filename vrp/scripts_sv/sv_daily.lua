local cfg = module('cfg/daily')

registerCallback('openDaily', function(player)
    local user_id = vRP.getUserId(player)

    return {
        dailyRewards = cfg.dailyRewards,
        dailyData = vRP.usersData[user_id].dailyData or {},
    }
end)

registerCallback('collectDaily', function(player)
    local user_id = vRP.getUserId(player)
    local dailyData = vRP.usersData[user_id].dailyData

    if dailyData.lastClaim < os.time() then
        dailyData.lastClaim = os.time() + 86400
        dailyData.collectedDays = dailyData.collectedDays + 1

        if cfg.dailyRewards[dailyData.collectedDays] then
            cfg.dailyRewards[dailyData.collectedDays].rewardPlayer(user_id)
        end

        exports.mongodb:updateOne({collection = 'users', query = {id = user_id}, update = {['$set'] = {dailyData = dailyData}}})
    end

    return {
        dailyRewards = cfg.dailyRewards,
        dailyData = vRP.usersData[user_id].dailyData or {},
    }
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, first_spawn, data)
    if not first_spawn then
        return
    end

    if not vRP.usersData[user_id].dailyData then
        vRP.usersData[user_id].dailyData = {
            lastClaim = 0,
            collectedDays = 1,
        }

        exports.mongodb:updateOne({collection = 'users', query = {id = user_id}, update = {['$set'] = {dailyData = vRP.usersData[user_id].dailyData}}})
    end
end)