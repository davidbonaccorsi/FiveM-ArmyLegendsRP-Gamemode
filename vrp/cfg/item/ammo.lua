local items = {}

items["ammo_9mm"] = {
    name = "Gloante 9MM",
    description = "Gloante de calibru 9MM.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_762"] = {
    name = "Gloante 7.62MM",
    description = "Gloante de calibru 7.62MM.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_556"] = {
    name = "Gloante 5.56MM",
    description = "Gloante de calibru 5.56MM.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_45acp"] = {
    name = "Gloante .45ACP",
    description = "Gloante de calibru .45ACP.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

-- Ammo PD

items["ammo_9mm_pd"] = {
    name = "Gloante 9MM",
    description = "Gloante de calibru 9MM PD.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_762_pd"] = {
    name = "Gloante 7.62MM",
    description = "Gloante de calibru 7.62MM PD.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_556_pd"] = {
    name = "Gloante 5.56MM",
    description = "Gloante de calibru 5.56MM PD.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_45acp_pd"] = {
    name = "Gloante .45ACP",
    description = "Gloante de calibru .45ACP PD.",
    category = 'ammo',
    useItem = function() end,
    weight = 0.01,
}

items["ammo_222rem"] = {
    name = "Gloante 222REM",
    description = "Gloante de calibru 222 Rem folosite la vanatoare",
    category = "ammo",
    useItem = function() end,
    weight = 0.01
}

-- [CUTII DE GLOANTE]

items['ammobox_9mm'] = {
    name = 'Cutie Gloante 9MM',
    description = 'Cutie cu 50x Gloante de calibru 9MM',
    category = 'ammo',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        local inventory = vRP.getUserInventory(user_id)

        if inventory[slot] and inventory[slot].item == 'ammobox_9mm' then
            if vRP.canCarryItem(user_id, 'ammobox_9mm', 50) then
                inventory[slot] = nil
                vRP.giveItem(user_id, 'ammobox_9mm', 50, false, false, false, 'Ammo Box')
            end
        end
    end,
    isUnique = true,
    weight = 0.5,
}

items['ammobox_762'] = {
    name = 'Cutie Gloante 7.62MM',
    description = 'Cutie cu 50x Gloante de calibru 7.62MM',
    category = 'ammo',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        local inventory = vRP.getUserInventory(user_id)

        if inventory[slot] and inventory[slot].item == 'ammobox_762' then
            if vRP.canCarryItem(user_id, 'ammobox_762', 50) then
                inventory[slot] = nil
                vRP.giveItem(user_id, 'ammobox_762', 50, false, false, false, 'Ammo Box')
            end
        end
    end,
    isUnique = true,
    weight = 0.5,
}

items['ammobox_556'] = {
    name = 'Cutie Gloante 5.56MM',
    description = 'Cutie cu 50x Gloante de calibru 5.56MM',
    category = 'ammo',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        local inventory = vRP.getUserInventory(user_id)

        if inventory[slot] and inventory[slot].item == 'ammobox_556' then
            if vRP.canCarryItem(user_id, 'ammobox_556', 50) then
                inventory[slot] = nil
                vRP.giveItem(user_id, 'ammobox_556', 50, false, false, false, 'Ammo Box')
            end
        end
    end,
    isUnique = true,
    weight = 0.5,
}

items['ammobox_45acp'] = {
    name = 'Cutie Gloante 45ACP',
    description = 'Cutie cu 50x Gloante de calibru 45ACP',
    category = 'ammo',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        local inventory = vRP.getUserInventory(user_id)

        if inventory[slot] and inventory[slot].item == 'ammobox_45acp' then
            if vRP.canCarryItem(user_id, 'ammo_45acp', 50) then
                inventory[slot] = nil
                vRP.giveItem(user_id, 'ammo_45acp', 50, false, false, false, 'Ammo Box')
            end
        end
    end,
    isUnique = true,
    weight = 0.5,
}

return items