local robberyData = {}

registerCallback("atm:canRob", function(player, atm, vehId)
    local user_id = vRP.getUserId(player)
    local veh = NetworkGetEntityFromNetworkId(vehId)

    if not DoesEntityExist(veh) then return end

    if parseInt(robberyData[user_id]?.cooldown) > os.time() then
        return false, "Ai cooldown, poti da jaf in "..math.floor((robberyCooldown[user_id] - os.time()) / 60).." minute."
    end

    if not vRP.removeItem(user_id, "rope", 1) then 
        return false, "Ai nevoie de sfoara pentru a putea incepe jaful." 
    end

    robberyData[user_id] = {
        cooldown = os.time() + 1800,
        entities = {
            entity = atm,
            robberyVeh = vehId
        }
    }

    return robberyData[user_id].entities
end)

registerCallback("atm:collectMoney", function(player, entity)
    local user_id = vRP.getUserId(player)

    math.randomseed(os.time() * GetGameTimer() * user_id)
    
    local amount = math.random(5000, 10000)
    local data = robberyData[user_id]?.entities or {}

    if not (data.entity == entity) then return end

    vRP.giveMoney(user_id, amount, 'ATM Robbery')
    data = nil

    return true
end)