registerCallback('searchCitizen', function(player, query)
    if tonumber(query) then
        return exports.mongodb:findSync({collection = 'users', query = {id = tonumber(query)}})
    end

    local data = exports.mongodb:findMultiple({
        collection = 'users',
        limit = 50,
        query = {
            {
                id = tostring(query),
            }, 
            
            {
                ['userIdentity.firstname'] = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                }
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

    return data or {}
end)

registerCallback('searchCitizenIncidents', function(player, id)
    local user_id = tonumber(id)
    
    if user_id then
        local data = exports.mongodb:findSync({collection = 'mdt_incidents', query = {user_id = user_id}})
        return data 
    end

    return {}
end)

registerCallback('searchCitizenVehicles', function(player, user_id)
    local tempData = {}
    local user_id = tonumber(user_id)
    
    local vehicles = exports.mongodb:findSync({
        collection = 'userVehicles',
        query = {
            user_id = user_id
        }
    })

    if vehicles then
        for _, data in next, vehicles do
            if data.vtype ~= "car" then
                local identity = vRP.getIdentity(data.user_id)
                
                tempData[#tempData + 1] = concat(data, {
                    owner = string.format('%s %s', identity.firstname, identity.name),
                    carnumber = data.carPlate,
                    user_id = data.user_id
                })
            end
        end
    end

    return tempData
end)

registerCallback('updateCitizenDescription', function(player, data)
    exports.mongodb:updateOne({
        collection = 'users',
        query = {id = data.id},

        update = {
            ['$set'] = {
                description = data.description
            }
        }
    })

    return true
end)

registerCallback('updatePhoto', function(player, user_id, url)
    exports.mongodb:updateOne({
        collection = 'users',
        query = {id = user_id},
        
        update = {
            ['$set'] = {
                image = url
            }
        }
    })

    return true
end)