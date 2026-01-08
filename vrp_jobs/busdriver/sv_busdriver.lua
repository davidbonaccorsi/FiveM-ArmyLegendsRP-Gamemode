local outBus = {}

RegisterServerEvent("jobs:setBusObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    outBus[user_id] = netid

end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if outBus[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(outBus[user_id])

        if DoesEntityExist(vehicle) then
            local x, y, z = table.unpack(GetEntityCoords(vehicle))
            exports["vrp_jobs"]:setLastJobTblValue(user_id, "vehpos", {x, y, z})
        
            DeleteEntity(vehicle)
        end

        outBus[user_id] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if outBus[user_id] then
        local vehicle = NetworkGetEntityFromNetworkId(outBus[user_id])

        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        
        outBus[user_id] = nil
    end
end)
