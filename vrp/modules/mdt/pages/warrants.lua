registerCallback('searchCazier', function(player, user_id, noLimit)
    local user_id = tonumber(user_id)

    local data = exports.mongodb:findSync({
        collection = 'mdt_caziere',
        limit = not noLimit and 12,
        query = {user_id = user_id}
    })

    return data or {}
end)

RegisterServerEvent('police:clearWarrants', function(total)
    local player = source
    local user_id = vRP.getUserId(player)

    local price = 50000 * (total or 0)

    if price > 0 then
        if vRP.tryPayment(user_id, price, false, "Police Warrants") then
            exports.mongodb:delete({collection = "mdt_caziere", query = {user_id = user_id}}, function(success)
                if success then
                    vRPclient.notify(player, {"Ti-ai platit toate cazierele."})
                    exports.vrp:achieve(user_id, "CazierEasy", 1)
                end
            end)
        else
            vRPclient.notify(player, {"Nu iti permiti sa iti platesti cazierele.", "error"})
        end
    end
end)

registerCallback('createWarrant', function(player, warrant)
    if #warrant.players > 1 then
        for k, v in pairs(warrant.players) do
            exports.mongodb:insertOne({
                collection = 'mdt_caziere',
                document = {
                    id = exports.mongodb:countSync({collection = 'mdt_caziere'}) + 1,
                    userData = v.userIdentity,
                    reason = warrant.reason,
                    user_id = v.id,
                    createdAt = warrant.createdAt,
                    description = warrant.description,
                }
            })
        end
    else
        exports.mongodb:insertOne({
            collection = 'mdt_caziere',
            document = {
                id = exports.mongodb:countSync({collection = 'mdt_caziere'}) + 1,
                reason = warrant.reason,
                userData = warrant.userIdentity,
                user_id = warrant.target,
                createdAt = warrant.createdAt,
                description = warrant.description,
            }
        })
    end

    return true
end)

registerCallback('deleteWarrant', function(player, id)
    exports.mongodb:deleteOne({
        collection = 'mdt_caziere',
        query = {id = id}
    })

    return id
end)