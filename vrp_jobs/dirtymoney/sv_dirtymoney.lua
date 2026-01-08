local washTimes = 0
local washMoneyCooldown = false

RegisterServerEvent("jobs:washDirtyMoney", function()
    local player = source
    local user_id = vRP.getUserId(player)
    
    if (washMoneyCooldown or 0) <= os.time() then
        if vRP.removeItem(user_id, 'dirty_money', 10000) then
            washTimes = washTimes + 1
            
            vRP.giveMoney(user_id, 7500, "Dirty Wash")

            if washTimes % 100 == 0 then
                washMoneyCooldown = os.time() + 5000
            end
        else
            vRPclient.subtitle(player, {"Nu ai ~HC_25~bani murdari~w~ pentru a spala !", 1})
        end
    end
end)

registerCallback("canWashMoney", function(player)
    local user_id = vRP.getUserId(player)
    local theFaction = vRP.getUserFaction(user_id) or ""
    local fType = vRP.getFactionType(theFaction)

    if fType ~= "Mafie" and fType ~= "Gang" then
        return false, false
    end

    if (washMoneyCooldown or 0) <= os.time() then
        return true, true
    end
    return false, true, ((washMoneyCooldown or 0) - os.time())
end)