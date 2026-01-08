registerCallback('searchOfficers', function()
    local cops = vRP.getOnlineUsersByFaction('Politie')
    local data = {}

    for user_id, source in next, cops do
        local identity = vRP.getIdentity(user_id)

        table.insert(data, {
            user_id = user_id,
            firstname = identity.firstname,
            lastname = identity.name,
            rank = vRP.getFactionRank(user_id)
        })
    end

    return data
end)

registerCallback('searchOfficer', function(player, query)
    if type(query) == 'number' then
        return exports.mongodb:findSync({
            collection = 'users',
            limit = 10,
            query = {
                id = query
            }
        })
    end

    local data = exports.mongodb:findMultiple({
        collection = 'users',
        limit = 10,
        query = {
            {
                id = query,
            }, 
            
            {
                ['userIdentity.firstname'] = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                },
            }, 
            
            {
                ['userIdentity.name'] = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                }
            }
        },

        required = {{['userFaction.faction'] = 'Politie'}},
    })

    return data
end)