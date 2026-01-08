registerCallback('searchVehicle', function(player, query)
    local tempData = {}
    local data = exports.mongodb:findSync({
        collection = 'userVehicles',
        limit = 10,
        query = {
            ['carPlate'] = {
                ['$regex'] = string.format('^%s', query),
                ['$options'] = 'i'
            }
        }
    })

    if data then
        for k, v in pairs(data) do
            if v.vtype ~= "faction" then
                local identity = vRP.getIdentity(tonumber(v.user_id))
                tempData[#tempData + 1] = concat(v, {
                    owner = identity['firstname'].." "..identity['name'].."",
                    carnumber = v.carPlate,
                    user_id = v.user_id
                })
            end
        end
    end
    return tempData
end)

registerCallback('updateVehicle', function(player, user_id, model, description)
    exports.mongodb:updateOne({
        collection = 'userVehicles',
        query = {user_id = user_id, vehicle = model},
        update = {
            ['$set'] = {
                description = description
            }
        }
    })

    return true
end)

registerCallback('updateVehiclePhoto', function(player, user_id, model, description)
    exports.mongodb:updateOne({
        collection = 'userVehicles',
        query = {user_id = user_id, vehicle = model},
        update = {
            ['$set'] = {
                image = url
            }
        }
    })

    return true
end)
