local cfg = module('cfg/gym')

local activeSubscriptions = {}

function vRP.getUserStrength(user_id)
    local gymData = vRP.requestUData(user_id, 'gymData')
    if gymData then
        return gymData.xp or 0
    end
    return 0
end

function vRP.getUserSpaceFromStrength(user_id)
    local max = 0
    local userStrength = vRP.getUserStrength(user_id)
    for k, v in pairs(cfg.kgPerStrength) do
      if k <= userStrength and k > max then
        max = k
      end
    end
    return cfg.kgPerStrength[max]
end

function tvRP.canUseGym()
    local player = source
    local user_id = vRP.getUserId(player)
    if (activeSubscriptions[user_id] or 0) > os.time() then
        return true
    end
    return false 
end


local function calculatePercentage(percentage, number)
	return (number * percentage) / 100
end

RegisterServerEvent('vRP:updatePlayerGym', function()
    local player = source
    local user_id = vRP.getUserId(player)

    math.randomseed(os.time() * user_id)
    local randomGain = math.random(25, 50)

    local vipRank = vRP.getUserVipRank(user_id) or 0
    if vipRank > 0 then
        randomGain += math.floor(calculatePercentage(((vipRank == 1) and 25 or 50), randomGain))
    end

    if vRP.getUserSpaceFromStrength(user_id) >= 25 then
        exports.vrp:achieve(user_id, 'fitnessEasy', 1)
    end

    vRP.getUData(user_id, 'gymData', function(data)
        if data then
            data.xp += randomGain
            -- data.lastTime = os.time()
            data.lastTime = os.time() + daysToSeconds(3)
            vRP.setUData(user_id, "gymData" ,data)
        else
            vRP.setUData(user_id, 'gymData', {
                xp = randomGain,
                lastTime = os.time() + daysToSeconds(3)
            })
        end

        vRP.createLog(user_id, {state = "increase", xp = data and data.xp or randomGain}, "Gym")
    end)
end)

registerCallback('buyGymSubscription', function(player)
    local user_id = vRP.getUserId(player)

    if activeSubscriptions[user_id] then
        return 'Ai deja un abonament activ la sala! Te pot ajuta cu altceva?'
    end

    if vRP.tryPayment(user_id,250,false,"Gym") then
        activeSubscriptions[user_id] = os.time() + 60 * 60
        return 'Ti-ai achizitionat abonament pentru 60 de minute!'        
    end

    return 'Nu ai destui bani la tine pentru a plati!'
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, spawn)
    if spawn then
        Citizen.Wait(5000)
        vRP.getUData(user_id, 'gymData', function(data)
            if data then
                if (tonumber(data.lastTime) or 0) <= os.time() then
                    if (data.xp or 0) <= 0 then return end;
                    local loss = math.floor(data.xp * 25 / 100)
                    data.xp -= loss
                    data.lastTime = os.time() + daysToSeconds(3)
                    vRP.setUData(user_id, "gymData", data)
                    vRP.createLog(user_id, {state = "loss", xp = loss}, "Gym")
                    vRPclient.notify(player, {"Nu ai mai trecut de mult pe sala, forma ta fizica a scazut cu 25%", 'info'})
                end
            end
        end)
    end
end)

AddEventHandler('vRP:playerLeave', function(user_id, player)
    activeSubscriptions[user_id] = nil
end)