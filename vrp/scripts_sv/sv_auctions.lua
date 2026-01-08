local activeAuction = false
local inAuction = {}

local function calculatePercentage(percentage, number)
	return math.floor((number * percentage) / 100)
end

exports("getActiveAuction", function()
    return activeAuction 
end)

function vRP.createAuction(data)
    if activeAuction then
        return false
    end

    activeAuction = data
    TriggerClientEvent("vrp-hud:hint", -1, "Tocmmai a inceput o licitatie!", "Licitatie activa", "fa-sharp fa-solid fa-gavel")
    Citizen.CreateThread(function()
        while activeAuction and activeAuction.time > os.time() do
            Citizen.Wait(1000)
        end

        if activeAuction and activeAuction.lastBidder then
            local user_id = activeAuction.lastBidder.id
            local player = vRP.getUserSource(user_id)

            if activeAuction.type == 'house' then
                local houseId = activeAuction.houseNumber and tonumber(activeAuction.houseNumber)
                exports['playerhousing']:giveHousingAuction(user_id, houseId)
            elseif activeAuction.type == 'market' then
                local market = activeAuction.market and tonumber(activeAuction.market)
                exports['vrp']:setMarketOwner(user_id, market)
            elseif activeAuction.type == 'gas' then
                local gasId = activeAuction.gasId and tonumber(activeAuction.gasId)
                exports['vrp']:setGasOwner(user_id, gasId)
            end
        end

        activeAuction = false
        inAuction = {}
    end)
end

RegisterServerEvent('vrp-auctions:closeAuction', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if not activeAuction then
        return
    end

    if inAuction[user_id] then
        inAuction[user_id] = nil
    end

    activeAuction.activePlayers = table.len(inAuction)
    TriggerClientEvent('vrp:sendNuiMessage', -1, {
        interface = 'auctions',
        action = 'update-players',
        players = activeAuction.activePlayers
    })
end)

RegisterServerEvent('vrp-auctions:tryToJoin', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if not activeAuction then
        return
    end

    if activeAuction and activeAuction.time < os.time() then
        return vRPclient.notify(player, {"Licitatile s-au terminat!", 'error'})
    end

    inAuction[user_id] = true;

    activeAuction.activePlayers = table.len(inAuction)
    TriggerClientEvent('vrp:sendNuiMessage', player, {
        interface = 'auctions',
        action = 'open',
        data = activeAuction
    })

    TriggerClientEvent('vrp:sendNuiMessage', -1, {
        interface = 'auctions',
        action = 'update-players',
        players = activeAuction.activePlayers
    })
end)

RegisterServerEvent('vrp-auctions:bid', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if not activeAuction then
        return
    end

    if activeAuction and activeAuction.time < os.time() then
        return vRPclient.notify(player, {"Licitatile s-au terminat!", 'error'})
    end

    if activeAuction.lastBidder and activeAuction.lastBidder.id == user_id then
        return
    end
    local bid = math.floor(activeAuction.lastBidder and activeAuction.lastBidder.bid + calculatePercentage(50, activeAuction.lastBidder.bid) or activeAuction.startPrice)

    if not vRP.tryBankPayment(user_id, tonumber(bid), false, 'Auctions') then
        return vRPclient.notify(player, {"Nu ai suficienti bani!", 'error'})
    end

    if activeAuction.lastBidder and activeAuction.lastBidder.id then
        local player = vRP.getUserSource(parseInt(activeAuction.lastBidder.id))
        if player then
            vRP.giveBankMoney(activeAuction.lastBidder.id, tonumber(activeAuction.lastBidder.bid), 'Auction')
        else
            exports.mongodb:updateOne({
                collection = 'users',
                query = {
                    user_id = activeAuction.lastBidder.id
                },
                update = {
                    ["$inc"] = {
                        ['userMoney.bank'] = activeAuction.lastBidder.bid
                    }
                }
            })
        end
    end

    if not activeAuction.bids then
        activeAuction.bids = {}
    end

    table.insert(activeAuction.bids, {
        id = user_id,
        name = GetPlayerName(player),
        bid = bid,
    })

    activeAuction.lastBidder = {
        id = user_id,
        name = GetPlayerName(player),
        bid = bid,
        time = os.time()
    }

    activeAuction.activePlayers = table.len(inAuction)
    TriggerClientEvent('vrp:sendNuiMessage', -1, {
        interface = 'auctions',
        action = 'update',
        data = activeAuction
    })
end)

AddEventHandler('vRP:playerLeave', function(player, user_id)
    if inAuction[user_id] and activeAuction then
        inAuction[user_id] = nil

        activeAuction.activePlayers = table.len(inAuction)
        TriggerClientEvent('vrp:sendNuiMessage', -1, {
            interface = 'auctions',
            action = 'update-players',
            players = activeAuction.activePlayers
        })
    end
end)