local function calculatePercentage(percentage, number)
	return math.floor((number * percentage) / 100)
end

registerCallback('createIncident', function(player, data)
    local incidentPlayers = data.players

    if #incidentPlayers > 1 then
        for _, player in next, incidentPlayers do
            exports.mongodb:insertOne({
                collection = 'mdt_incidents',
                document = {
                    id = exports.mongodb:countSync({collection = 'mdt_incidents'}) + 1,
                    user_id = tonumber(player.id),
                    name = data.name,
                    description = data.description,
                    players = data.players,
                    cops = data.cops,
                    createdAt = data.createdAt,
                    vehicles = data.vehicles,
                    jail = data.jails
                }
            })
        end
    else
        exports.mongodb:insertOne({
            collection = 'mdt_incidents',
            document = {
                id = exports.mongodb:countSync({collection = 'mdt_incidents'}) + 1,
                user_id = tonumber(data.targetId),
                name = data.name,
                description = data.description,
                players = data.players,
                cops = data.cops,
                createdAt = data.createdAt,
                vehicles = data.vehicles,
                jail = data.jails
            }
        })
    end

    if #(data.jails) >= 1 then
        local jailTime = 0

        for _, jail in next, data.jails do
            jailTime += jail.time
        end

        local jailReduction = tonumber(data.jail_reduction)

        if jailReduction > 0 then
            jailTime = math.floor(jailTime - ((jailReduction / 100) * jailTime))
        end

        for _, player in next, incidentPlayers do
            local playerId = tonumber(player.id)

            if vRP.getUserVipRank(playerId) > 1 then
                vRP.setInPoliceJail(playerId, math.floor(calculatePercentage(50, jailTime)))
            else
                vRP.setInPoliceJail(playerId, jailTime)
            end
        end
    end

    return exports.mongodb:countSync({collection = 'mdt_incidents'})
end)

registerCallback('searchVehicleIncidents', function(player, user_id, vehicle)
    return exports.mongodb:findSync({
        collection = 'mdt_incidents',
        query = {
            ['vehicles.user_id'] = user_id,
            ['vehicles.vehicle'] = vehicle
        }
    })
end)

registerCallback('deleteIncident', function(player, id)
    exports.mongodb:deleteOne({
        collection = 'mdt_incidents',
        query = {id = id}
    })
    
    return true
end)