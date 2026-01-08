
local resName = GetCurrentResourceName()

function registerCallback(cbName, cb, late)
    RegisterServerEvent("vrp_cbs:"..cbName, function(...)
        local player = source

        if cb and player then
            if late then
                TriggerLatentClientEvent("vrp_cbs:"..cbName, player, late, cb(player, ...))
                return
            end

            TriggerClientEvent("vrp_cbs:"..cbName, player, cb(player, ...))
        end
    end)
end
