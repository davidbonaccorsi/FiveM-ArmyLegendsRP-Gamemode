
local outCaddy = {}

RegisterServerEvent("jobs:setCaddyObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    outCaddy[user_id] = netid
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if outCaddy[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(outCaddy[user_id])

        if DoesEntityExist(vehicle) then
            local x, y, z = table.unpack(GetEntityCoords(vehicle))
            exports["vrp_jobs"]:setLastJobTblValue(user_id, "vehpos", {x, y, z})

            DeleteEntity(vehicle)
        end

        outCaddy[user_id] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if outCaddy[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(outCaddy[user_id])
        
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end

        outCaddy[user_id] = nil
    end
end)
