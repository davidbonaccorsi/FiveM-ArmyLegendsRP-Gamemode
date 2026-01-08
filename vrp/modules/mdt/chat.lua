local chatMessages = {}

registerCallback('getMDTMessages', function()
    return chatMessages
end)

registerCallback('addMdtChatMessage', function(player, data)
    local user_id = vRP.getUserId(player)
    local identity = vRP.getIdentity(user_id)

    local message = {
        id = data.id,
        image = nil,
        phone = identity.phone,
        author = string.format('%s %s', identity.firstname, identity.name),
        rank = vRP.getFactionRank(user_id),
        content = data.content,
        createdAt = data.createdAt
    }

    table.insert(chatMessages, message)

    TriggerClientEvent('vRP:sendMdtNui', -1, {action = 'ADD_MESSAGE', args = message})
end)