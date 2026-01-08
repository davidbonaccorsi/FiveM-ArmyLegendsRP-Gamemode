
local maxDelivery = math.random(5, 8)


vRP.defInventoryItem("jar", "Borcan", "Folosit pentru a produce droguri", false, 0.15)
vRP.defInventoryItem("drug_opmixture", "Amestec de opium", "Folosit pentru a produce droguri", false, 0.2)
vRP.defInventoryItem("drug_opiumseeds", "Seminte de opium", "Folosit pentru a produce droguri", false, 0.05)

vRP.defInventoryItem("opium", "Opium", "Vinde pentru a face bani", false, 0.80)

AddEventHandler("jobs:onPlayerPaid", function(user_id)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de opium")
    if job then
        local xpAmm = math.random(1, 5)
        vRP.giveXp(user_id, xpAmm, false)
        vRPclient.notify(vRP.getUserSource(user_id), {"Ai acumulat "..xpAmm.." XP"})       
    end
end)

registerCallback("getOpiumToDelivery", function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de opium")
    
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

registerCallback("gatherOpiumPlant", function(player, plantId)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de opium")
    
    if job and lastJob[user_id] then
        if lastJob[user_id].plants then
            if lastJob[user_id].plants[plantId] then

                if not lastJob[user_id].plants[plantId].completed then
                    vRPclient.notify(player, {"Planta este inca in curs de crestere.", "error"})
                    return
                end

                local amount = math.random(1, 3)
                if vRP.canCarryItem(user_id, "drug_opiumseeds", amount) then
                    vRPclient.notify(player, {"Ai cules planta si ai primit "..amount.." Seminte de opium"})
                    vRP.giveItem(user_id, "drug_opiumseeds", amount, false, false, false, 'Traficant de opium')

                    return true
                end
                return false
            end
        end

        return false
    end
end)

local mixtureRecipe <const> = {
    {"drug_opiumseeds", 10},
    {"water", 6},
}

registerCallback("combineOpiumSeeds", function(player)
    local user_id = vRP.getUserId(player)

    if user_id and player then
        if not vRP.canCarryItem(user_id, "drug_opmixture", 1) then
            vRPclient.notify(player, {"Nu exista spatiu in inventar.", "error"})
            return
        end
    
        local ok = true
        for k, v in pairs(mixtureRecipe) do
            if vRP.getInventoryItemAmount(user_id, v[1]) < v[2] then
                ok = false
                break
            end
        end
    
        if not ok then
            vRPclient.notify(player, {"Nu ai itemele necesare pentru combinare.\n\nReteta:\n- 6 Apa\n- 10 Seminte de opium", "error"})
            return false
        end
    
        for k, v in pairs(mixtureRecipe) do
            vRP.removeItem(user_id, v[1], v[2])
        end

        Citizen.CreateThread(function()
            Citizen.Wait(10000)
            vRP.giveItem(user_id, "drug_opmixture", 1, false, false, false, 'Traficant de opium')
        end)
        
        return true
    end
end)

local packRecipe <const> = {
    {"jar", 1},
    {"drug_opmixture", 1},
}

registerCallback("packOpiumMixture", function(player)
    local user_id = vRP.getUserId(player)

    if user_id and player then
        
        local ok = true
        for k, v in pairs(packRecipe) do
            if vRP.getInventoryItemAmount(user_id, v[1]) < v[2] then
                ok = false
                break
            end
        end
        
        if not ok then
            vRPclient.notify(player, {"Nu ai itemele necesare pentru impachetare.\n\nReteta:\n- 1 Borcan\n- 1 Amestec de opium", "error"})
            return false
        end
    
        for k, v in pairs(packRecipe) do
            vRP.removeItem(user_id, v[1], v[2])
        end

        Citizen.CreateThread(function()
            Citizen.Wait(5000)
            vRP.giveItem(user_id, "opium", 1, false, false, false, 'Traficant de opium')
        end)

        return true
    end
end)
