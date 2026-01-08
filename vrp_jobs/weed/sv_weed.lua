
local maxDelivery = math.random(5, 8)

vRP.defInventoryItem("drug_cansativa", "Cannabis Sativa", "Folosit pentru a produce droguri", false, 0.15)
vRP.defInventoryItem("drug_seeds", "Seminte", "Plantate pentru a produce droguri", function(player)
    TriggerClientEvent("work-weedtrafficker:plantSeed", player)
end, 0.25)

vRP.defInventoryItem("weed", "Marijuana", "Vinde pentru a face bani", false, 0.80)

AddEventHandler("jobs:onPlayerPaid", function(user_id)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de iarba")
    if job then
        local xpAmm = math.random(1, 5)
        vRP.giveXp(user_id, xpAmm, false)

        vRPclient.notify(vRP.getUserSource(user_id), {"Ai acumulat "..xpAmm.." XP"})       
    end
end)

registerCallback("getWeedToDelivery", function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de iarba")
    
    if job then
        local lastRnd
        if lastJob[user_id] then
            lastRnd = lastJob[user_id].amount
        end

        local newRnd = math.random(1, maxDelivery)
		while newRnd == lastRnd do
			newRnd = math.random(1, maxDelivery)
		end

        return newRnd
    end
end)

registerCallback("gatherWeedPlant", function(player, plantId)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de iarba")
    
    if job and lastJob[user_id] then
        if lastJob[user_id].plants then
            if lastJob[user_id].plants[plantId] then
                local amount = math.random(1, 3)

                if vRP.canCarryItem(user_id, "drug_cansativa", amount) then
                    vRPclient.notify(player, {"Ai cules planta si ai primit "..amount.." Cannabis Sativa"})
                    vRP.giveItem(user_id, "drug_cansativa", amount, false, false, false, 'Traficant de iarba')

                    return true
                end

                return false
            end
        end

        return false
    end
end)

local loadPrice = 50
registerCallback('buySeeds', function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de iarba")

    if not job then
        return 'Nu esti un Traficant de iarba!'
    end

    local amount = promise.new()
    vRP.prompt(player, "Traficant de iarba", "Cate seminte vrei sa cumperi? <br><br>Pret seminte: $"..loadPrice.."/bucata", false, function(amm)
        amount:resolve(tonumber(amm))
    end, true)
    local amount = Citizen.Await(amount)

    if amount then
        if not vRP.canCarryItem(user_id, "drug_seeds", amount) then
            return 'Nu ai destul spatiu in inventar !'
        end

        if vRP.tryFullPayment(user_id, math.floor(loadPrice*amount), false, false, "Weed Store") then
            vRP.giveItem(user_id, "drug_seeds", amount, false, false, false, 'Traficant de iarba')
        end
    end

    return 'Nu ai destui bani!'
end)

registerCallback('useChemSetWeed', function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de iarba")

    if not job then
        return 'Nu esti un Traficant de iarba!'
    end

    if not vRP.canCarryItem(user_id, "weed", 1) then
        return 'Nu ai destul spatiu in inventar !'
    end

    if vRP.removeItem(user_id, 'drug_cansativa', 1) then
        if math.random(1, 5) == 1 then
            return 'O nu! Setul de chimie tocmai mi-a explodat si am pierdut Cannabis Sativa'
        end

        vRP.giveItem(user_id, "weed", 1, false, false, false, 'Traficant de iarba')
        return 'Ai folosit setul de chimie si ai primit Marijuana'
    end
end)
