registerCallback('searchFine', function(player, query)
    local data = exports.mongodb:findMultiple({
        collection = 'mdt_fines',
        limit = 10,
        query = {
            {
                name = {
                    ['$regex'] = string.format('^%s', query),
                    ['$options'] = 'i'
                },
            }, 
            
            {
                code = query
            }
        },

        required = false,
    })

    return data
end)

registerCallback('createFine', function(player, fine)
    local user_id = vRP.getUserId(player)

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:insertOne({
        collection = 'mdt_fines',
        document = {
            id = exports.mongodb:countSync({collection = 'mdt_fines'}) + 1,
            code = fine.code,
            name = fine.name,
            amount = fine.amount
        }
    })

    return exports.mongodb:countSync({collection = 'mdt_fines'})
end)

registerCallback('deleteFine', function(player, id)
    local user_id = vRP.getUserId(player)

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:deleteOne({
        collection = 'mdt_fines',
        query = {
            id = id
        }
    })

    return true
end)

registerCallback('updateFine', function(player, data)
    local user_id = vRP.getUserId(player)

    if not data then return end;

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:updateOne({
        collection = 'mdt_fines',
        query = {id = data.id},
        
        update = {
            ['$set'] = {
                name = data.name,
                amount = data.amount
            }
        }
    })
end)