local achievements = module('cfg/achievements')

RegisterServerEvent("vrp-achievements:openMenu", function()
    local player = source
    local user_id = vRP.getUserId(player)

    TriggerClientEvent("vrp:sendNuiMessage", player, {
        interface = "achievements",
        username = GetPlayerName(player),
        achievements = achievements,
        userAchievements = vRP.usersData[user_id].userAchievements or {}
    })
end)

exports('hasCompleteAchieve', function(user_id, task)
    if not vRP.usersData[user_id].userAchievements then
        vRP.usersData[user_id].userAchievements = {}
    end

    if vRP.usersData[user_id].userAchievements[task] then
        return vRP.usersData[user_id].userAchievements[task].completed
    end

    return false
end)

exports('achieve', function(user_id, task, progress)
    if not vRP.usersData[user_id].userAchievements then
        vRP.usersData[user_id].userAchievements = {}
    end

    local userAchievements = vRP.usersData[user_id].userAchievements

    if achievements and achievements[task] then
        if not userAchievements[task] then
            userAchievements[task] = {
                progress = progress,
                completed = false
            }
        end

        if userAchievements[task].completed then return end

        userAchievements[task].progress += progress
        if userAchievements[task].progress >= achievements[task].task then
            userAchievements[task].completed = true
            vRP.giveMoney(user_id, achievements[task].reward, 'Achivement Reward: '..achievements[task].name)
            vRP.updateUser(user_id, 'userAchievements', userAchievements)

            local player = vRP.getUserSource(user_id)
            TriggerClientEvent("vrp:sendNuiMessage", player, {
                interface = "achievementNotify",
                complete = true,
                task =  achievements[task].task,
                progress = userAchievements[task].progress,
                text = achievements[task].desc,
                title = achievements[task].name
            })
        else
            local player = vRP.getUserSource(user_id)
            TriggerClientEvent("vrp:sendNuiMessage", player, {
                interface = "achievementNotify",
                complete = false,
                task =  achievements[task].task,
                progress = userAchievements[task].progress,
                text = achievements[task].desc,
                title = achievements[task].name
            })
        end
    end
end)