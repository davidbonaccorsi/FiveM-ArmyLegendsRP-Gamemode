
local cfg = module("cfg/weapdealer")

RegisterServerEvent("vrp-weapdealer:tryBuy")
AddEventHandler("vrp-weapdealer:tryBuy", function(itemTbl, page)
    local player = source
    local user_id = vRP.getUserId(player)
    local group = vRP.getUserFaction(user_id) or "user"

    local theFaction = vRP.getFaction(group)

    if (vRP.getFactionType(group) == "Mafie") and theFaction.weapons then
        local item = itemTbl.weapon --[["weapon_"]]

        -- if page > 1 then
        --     item = "ammo_"
        -- end

        if itemTbl and tonumber(itemTbl.amount) > 0 then
            local price = itemTbl.price
            -- if page > 1 and itemTbl.ammoprice then
            --     price = itemTbl.ammoprice
            -- end
            
            -- item = item..itemTbl.weapon

            if vRP.canCarryItem(user_id, item, tonumber(itemTbl.amount)) and vRP.tryPayment(user_id, price*tonumber(itemTbl.amount), true, "Weapon Dealer") then
                vRP.giveItem(user_id, item, tonumber(itemTbl.amount), false, false, false, 'Mafia Market')
            end
        end
    else
        vRPclient.notify(player, {"Nu detii pachetul de arme.", "error"})
    end
end)


local function build_client_points(user_id, player)
    local x,y,z = table.unpack(cfg.position)
    -- if cfg.blipid then
    --     vRPclient.addBlip(player, {"vRP:weapDealer", x, y, z, cfg.blipid, cfg.blipcolor, "Magazin (Weapon Dealer)", 0.8})
    -- end

    local weapon_dealer = function(player,area)
        local user_id = vRP.getUserId(player)

        local group = vRP.getUserFaction(user_id) -- exports.vrp:getUserGroup(user_id, "Weapon Dealer")
        if not (vRP.getFactionType(group) == "Mafie") or not (vRP.getFaction(group).weapons) then
            vRPclient.notify(player, {"Nu detii pachetul de arme.", "error"})
            return
        end
        
        local name = GetPlayerName(player).." ("..user_id..")"
        TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "weapDealer", event = "build", name = name, money = vRP.getMoney(user_id), faction = group})
    end

    vRP.setArea(player, "vRP:weapDealer", x, y, z, 15.0, {
        key = "E",
        text = "Magazin de arme",
        minDst = 1
    }, {
        type = 27,
        x = 0.501,
        y = 0.501,
        z = 0.5001,
        color = cfg.iconColor or {255, 255, 255, 200},
        coords = vec3(x,y,z) - vec3(0.0, 0.0, 0.9)
    }, weapon_dealer, function() end)
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        Citizen.Wait(2500)
        build_client_points(user_id, player)
        TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "weapDealer", event = "setWeapons", weapons = cfg.weapons})
    end
end)
