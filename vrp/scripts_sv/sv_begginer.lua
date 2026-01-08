
local userQuest = {}
local allQuest = module("cfg/begginer_quests")


local function hasCompletedBegginerQuest(user_id, theQuest)
    for k, quest in pairs(userQuest[user_id]) do
        if quest == theQuest then
            return true
        end
    end

    return false
end

exports("hasCompletedBegginerQuest", hasCompletedBegginerQuest)

local function completeBegginerQuest(user_id, quest)
    table.insert(userQuest[user_id], quest)

    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
        ["$push"] = {beginnerQuest = quest}
    }})

    local player = vRP.getUserSource(user_id)
    if #userQuest[user_id] == #allQuest then
        vRP.giveMoney(user_id, allQuest.reward, "Beginner Quest")

        TriggerClientEvent("vrp-begginer:setQuest", player, false)
    else
        TriggerClientEvent("vrp-begginer:showCompleted", player, allQuest[quest].title)
        
        if #userQuest[user_id] < #allQuest then
            TriggerClientEvent("vrp-begginer:setQuest", player, userQuest[user_id], allQuest)
        end
    end
end

exports("completeBegginerQuest", completeBegginerQuest)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, extraData)
    if first_spawn then

        userQuest[user_id] = extraData.beginnerQuest or {}
        
        if #userQuest[user_id] < #allQuest then
            TriggerClientEvent("vrp-begginer:setQuest", player, userQuest[user_id], allQuest)
        end

    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player, isSpawned)
    if userQuest[user_id] and isSpawned then
        userQuest[user_id] = nil
    end
end)
