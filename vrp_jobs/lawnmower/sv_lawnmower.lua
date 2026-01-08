
local lawnmowers = {}
local rocks = {}

RegisterServerEvent("jobs:setMowerObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    
    if DoesEntityExist(vehicle) then
        lawnmowers[user_id] = vehicle
    end
end)

RegisterServerEvent("work-lawnmower:getRock", function(rocksOfSlot)
    local player = source
    local user_id = vRP.getUserId(player)

    if (rocks[user_id] or 0) + 1 <= #rocksOfSlot then
        rocks[user_id] = (rocks[user_id] or 0) + 1
    else
        vRPclient.notify(player, {"Ai adunat prea multe pietre din aceasta zona.", "error"}) 
    end
end)

AddEventHandler("jobs:onPlayerPaid", function(user_id)
    if rocks[user_id] then
        local player = vRP.getUserSource(user_id)
        local gainXp = tonumber(rocks[user_id])
        
        vRP.giveXp(user_id, gainXp)

        rocks[user_id] = nil
        vRPclient.notify(player, {"Ai primit "..gainXp.." XP pentru piatra adunata."})
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if lawnmowers[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(netid)

        if lawnmowers[user_id] and DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end

    lawnmowers[user_id] = nil
    
    if rocks[user_id] then
        rocks[user_id] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if lawnmowers[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        
        lawnmowers[user_id] = nil
        rocks[user_id] = nil
    end
end)
