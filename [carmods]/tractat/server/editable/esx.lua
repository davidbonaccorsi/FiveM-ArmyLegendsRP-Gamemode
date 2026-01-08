if Config.esxSettings.enabled then

    local Proxy = module("vrp", "lib/Proxy")
    local Tunnel = module("vrp", "lib/Tunnel")

    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP", "tractat")
    
    -- ESX.RegisterUsableItem(Config.items.towingRope, function(source)
    --     if Config.jobWhitelist.towing.enabled then
    --         if not IsPlayerJobWhitelisted(source, Config.jobWhitelist.towing.jobs) then
    --             return TriggerClientEvent('kq_towing:client:notify', source, L('~r~You may not use this item'))
    --         end
    --     end
    --     TriggerClientEvent('kq_towing:client:startRope', source, false, true)
    -- end)

    vRP.defInventoryItem({'funie', 'Funie', 'Funie cu care poti tracta vehicule', function(player)
        TriggerClientEvent('kq_towing:client:startRope', player, false, true)
	end, 0.01, 'funie', true})

    -- ESX.RegisterUsableItem(Config.items.winch, function(source)
    --     if Config.jobWhitelist.winch.enabled then
    --         if not IsPlayerJobWhitelisted(source, Config.jobWhitelist.winch.jobs) then
    --             return TriggerClientEvent('kq_towing:client:notify', source, L('~r~You may not use this item'))
    --         end
    --     end
    --     TriggerClientEvent('kq_towing:client:startRope', source, true, true)
    -- end)

    vRP.defInventoryItem({'coarba', 'Coarba', 'Ajuta la tractarea vehiculelor', function(player)
        TriggerClientEvent('kq_towing:client:startRope', player, true, true)
	end, 0.01, 'coarba', true})

    function RemovePlayerItem(player, item, amount)
        vRP.removeItem({vRP.getUserId(player), item, tonumber(amount)})
    end

    function AddPlayerItem(player, item, amount)
        vRP.giveItem({vRP.getUserId(player), item, tonumber(amount)})
    end
end
