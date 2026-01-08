
local cooldownBetweenSearch = {}

local allItems <const> = {
    {item = "phone", chance = 5},
    {item = "tacos", chance = 15},
    {item = "shaorma", chance = 10},
    {item = "sandvis", chance = 10},
    {item = "conserva", chance = 95, price = 100},
    {item = "petdeplastic", chance = 95, price = 100},
    {item = "rat", chance = 90},
}


RegisterServerEvent("vrp_reciclare:sellItems", function()
    local player = source
    local user_id = vRP.getUserId(player)

    Citizen.Wait(200)
    local choices = {}
    for id, itmdata in pairs(allItems) do
        if not itmdata.price then goto skipItem end

        local item = itmdata.item
        local ammount = vRP.getInventoryItemAmount(user_id, item)
        if ammount > 0 then
            local totPrice = ammount * itmdata.price
            local itmName = vRP.getItemName(item)
            table.insert(choices, {itmName.." - $"..totPrice, {item, itmName, ammount, totPrice}})
        end
        ::skipItem::
    end

    if not next(choices) then
        vRPclient.notify(player, {"Nu ai iteme reciclabile pentru mine !", "error"})
        return
    end

    vRP.selectorMenu(player, "Recicleaza gunoaie", choices, function(fish)
        if fish then
            local item, itmName, ammount, totPrice = table.unpack(fish)
            if vRP.removeItem(user_id, item, ammount) then
                vRP.giveMoney(user_id, totPrice, "Reciclare - "..itmName)
            end
        end
    end)
end)


local function getRandLoot()
    ::retryPick::
    Citizen.Wait(1)
    math.randomseed(os.time() * GetGameTimer())
    local rnd = math.random(1, 100)
    local i = math.random(1, #allItems)

    if rnd <= allItems[i].chance then
        return allItems[i]
    end
    goto retryPick
end

registerCallback("searchTrash", function(player)
    local user_id = vRP.getUserId(player)

    if (cooldownBetweenSearch[user_id] or 0) > os.time() then return end

    local pick = getRandLoot()
    
    if not pick or (pick.item == "rat") then
        return false
    end
    cooldownBetweenSearch[user_id] = os.time() + 10

    if vRP.canCarryItem(user_id, pick.item, 1, 0) then
        vRP.giveItem(user_id, pick.item, 1, false, false, false, 'Trash')
    end
    return true
end)
