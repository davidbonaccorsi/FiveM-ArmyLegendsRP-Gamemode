
RegisterServerEvent("vrp-post:useLocker", function()
    local player = source
    local user_id = vRP.getUserId(player)

    local user = vRP.getUser(user_id)

    if user and user_id then
        
        local packages = user.postChest or {}
        if not next(packages) then
            TriggerClientEvent("vrp-hud:sendApiError", player, "Nu ai pachete disponibile in locker.")
            return
        end

        TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "postLocker", username = GetPlayerName(player), packages = packages})
    end
end)

RegisterServerEvent('vrp-post:pickupItem', function(slot, itemid)
    local player = source
    local user_id = vRP.getUserId(player)
    local postChest = vRP.usersData[user_id].postChest or {}

    if postChest and postChest[slot] and postChest[slot].item == itemid then
        local item = postChest[slot].item
        local amount = postChest[slot].amount
        local extraData = postChest[slot].extraData

        if vRP.canCarryItem(user_id, item, amount) then
            vRP.giveItem(user_id, itemid, amount, false, extraData or false, false, false, 'Post Office')
            table.remove(postChest, slot)
        end

        vRP.updateUser(user_id, "postChest", postChest)
    end
end)

exports('sendPostPackage', function(user_id, item, amount, extraData)
    if not vRP.usersData[user_id].postChest then
        vRP.usersData[user_id].postChest = {}
    end

    table.insert(vRP.usersData[user_id].postChest, {
        item = item,
        name = vRP.getItemName(item),
        amount = amount,
        extraData = extraData
    })

    local player = vRP.getUserSource(user_id)
    if player then
        TriggerClientEvent("vrp-post:notify", player)
    end
    vRP.updateUser(user_id, "postChest", vRP.usersData[user_id].postChest)
end)