registerCallback('searchJail', function(player, query)
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

registerCallback('createJail', function(player, jail)
    local user_id = vRP.getUserId(player)

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:insertOne({
        collection = 'mdt_jail',
        document = {
            id = exports.mongodb:countSync({collection = 'mdt_jail'}) + 1,
            name = jail.name,
            time = jail.time
        }
    })

    return exports.mongodb:countSync({collection = 'mdt_jail'})
end)

registerCallback('deleteJail', function(player, id)
    local user_id = vRP.getUserId(player)

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:deleteOne({
        collection = 'mdt_jail',
        query = {
            id = id
        }
    })

    return id
end)

registerCallback('updateJail', function(player, data)
    local user_id = vRP.getUserId(player)

    if not vRP.isFactionLeader(user_id, 'Politie') then
        return false
    end

    exports.mongodb:updateOne({
        collection = 'mdt_jail',
        query = {
            id = data.id
        },
        update = {
            ['$set'] = {
                name = data.name,
                time = data.time
            }
        }
    })

    return data.id
end)