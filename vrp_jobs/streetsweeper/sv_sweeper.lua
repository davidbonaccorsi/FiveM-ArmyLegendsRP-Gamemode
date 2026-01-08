
local sweepers = {}

RegisterServerEvent("jobs:setSweeperObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    sweepers[user_id] = netid
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if sweepers[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(sweepers[user_id])

        if DoesEntityExist(vehicle) then
            local x, y, z = table.unpack(GetEntityCoords(vehicle))
            exports["vrp_jobs"]:setLastJobTblValue(user_id, "vehpos", {x, y, z})

            DeleteEntity(vehicle)
        end

        sweepers[user_id] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if sweepers[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(sweepers[user_id])

        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end

        sweepers[user_id] = nil
    end
end)
