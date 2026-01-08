registerCallback('searchSuggestedPlayers', function(player, query)
    if tonumber(query) then
        query = tonumber(query)
        return exports.mongodb:findSync({collection = 'users',query = {id = query}})
    end

    local data = exports.mongodb:findMultiple({
        collection = 'users',
        limit = 5,
        query = {
            {
                id = tostring(query),
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

        required = false
    })

    return data
end)

registerCallback('searchSuggestedCops', function(player, query)
    if tonumber(query) then
        query = tonumber(query)
        return exports.mongodb:findSync({collection = 'users',query = {id = query, ['userFaction.faction'] = 'Politie'}})
    end

    local data = exports.mongodb:findMultiple({
        collection = 'users',
        limit = 10,
        query = {
            {
                id = query
            }, 
            
            {
                ["userIdentity.firstname"] = {
                    ["$regex"] = string.format('^%s', query),
                    ['$options'] = 'i'
                }
            }, 
            
            {
                ["userIdentity.name"] = {
                    ["$regex"] = string.format('^%s', query),
                    ['$options'] = 'i'
                }
            }
        },

        required = {
            {['userFaction.faction'] = 'Politie'}
        }
    })

    return data;
end)

registerCallback('searchSuggestedVehicles', function(player, query)
    local data = exports.mongodb:findSync({
        collection = 'userVehicles',
        limit = 10,
        query = {
            ['carPlate'] = {
                ['$regex'] = string.format('^%s', query),
                ['$options'] = 'i'
            }
        }
    }) or {}

    if next(data) then
        local identity = vRP.getIdentity(data[1].user_id)
        return map(function(value) 
            return concat(value, {
                owner = identity['firstname'].." "..identity['name'].."",
                carnumber = data[1].carPlate,
                user_id = data[1].user_id
            })
        end, data)
    end
end)

registerCallback('searchSuggstedCharges', function(player, query)
    return exports.mongodb:findSync({
        collection = 'mdt_jail',
        query = {
            name = {
                ['$regex'] = string.format('^%s', query),
                ['$options'] = 'i'
            }
        }
    })
end)

registerCallback('searchSuggestedFines', function(player, query)
    local data = exports.mongodb:findMultiple({
        collection = 'mdt_fines',
        limit = 10,
        query = {
            {
                code = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                },
            },
            
            {
                name = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                }
            }
        },

        required = false,
    })
    
    return data
end)