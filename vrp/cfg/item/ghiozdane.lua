local items = {}

items["ghiozdanMare"] = {
    name = "Ghiozdan Mare",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    category = 'backpacks',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        if vRP.hasBag(user_id) then
            -- if not tvRP.canUnequipBag() then return tvRP.notify('Nu poti sa iti dai ghiozdanul jos pentru ca ai iteme in el.', 'error') end
            vRP.usersData[user_id].activeBag = nil
            TriggerClientEvent('vrp-inventory:updateBackpack', player, false)
        else
            vRP.usersData[user_id].activeBag = {
                space = 55,
                name = "Ghiozdan Mare",
            }
            TriggerClientEvent('vrp-inventory:updateBackpack', player, vRP.usersData[user_id].activeBag)
        end 
    end,
    isUnique = true,
    weight = 2.0,
}

items["ghiozdanMediu"] = {
    name = "Ghiozdan Mediu",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    category = 'backpacks',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        if vRP.hasBag(user_id) then
            vRP.usersData[user_id].activeBag = nil
            TriggerClientEvent('vrp-inventory:updateBackpack', player, false)
        else
            vRP.usersData[user_id].activeBag = {
                space = 35,
                name = "Ghiozdan Mediu",
            }
            TriggerClientEvent('vrp-inventory:updateBackpack', player, vRP.usersData[user_id].activeBag)
        end 
    end,
    isUnique = true,
    weight = 2.0,
}

items["ghiozdanMic"] = {
    name = "Ghiozdan Mic",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    category = 'backpacks',
    useItem = function(player, slot)
        local user_id = vRP.getUserId(player)
        if vRP.hasBag(user_id) then
            print('has bag')
            vRP.usersData[user_id].activeBag = nil
            TriggerClientEvent('vrp-inventory:updateBackpack', player, false)
        else

            vRP.usersData[user_id].activeBag = {
                space = 15,
                name = "Ghiozdan Mic",
            }
            TriggerClientEvent('vrp-inventory:updateBackpack', player, vRP.usersData[user_id].activeBag)
        end 
    end,
    isUnique = true,
    weight = 2.0,
}

return items