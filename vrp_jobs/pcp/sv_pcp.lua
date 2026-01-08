
local maxDelivery = math.random(5, 8)

local pipeCoords = {
    {2215.3532714844,5579.8276367188,53.953926086426,139.0},
    {2218.0180664062,5579.6049804688,53.97486114502,135.0},
    {2220.0969238281,5579.1079101562,53.905132293701,90.0},
    {2222.4519042969,5579.2387695312,53.920616149902,170.0},
    {2226.6591796875,5578.822265625,53.908180236816,107.0},
    {2229.7578125,5578.5634765625,53.971485137939,136.0},
    {2232.9919433594,5578.669921875,54.107639312744,132.0},
    {2215.1206054688,5577.7270507812,53.821968078613,151.0},
    {2217.138671875,5577.7119140625,53.838317871094,136.0},
    {2219.5891113281,5577.4365234375,53.847682952881,118.0},
    {2221.5480957031,5577.2495117188,53.846099853516,125.0},
    {2224.8776855469,5577.095703125,53.845634460449,160.0},
    {2227.2270507812,5576.72265625,53.870628356934,297.0},
    {2229.6789550781,5576.5395507812,53.936973571777,333.0},
    {2232.1262207031,5576.0849609375,54.002361297607,311.0},
    {2235.1652832031,5576.2846679688,54.045936584473,160.0},
    {2237.7399902344,5576.2846679688,54.021961212158,324.0},
    {2238.5109863281,5573.982421875,53.856922149658,331.0},
    {2234.8645019531,5574.1723632812,53.96248626709,343.0},
    {2231.1103515625,5574.1689453125,53.92195892334,107.0},
}

vRP.defInventoryItem("drug_piperidine", "Piperidina", "Folosit pentru a produce droguri", false, 0.15)
vRP.defInventoryItem("drug_dust", "Amestec ilegal", "Folosit pentru a produce droguri", false, 0.2)
vRP.defInventoryItem("zipbagcoca", "Punga de plastic", "Folosit pentru a produce droguri", false, 0.05)

vRP.defInventoryItem("pcp", "PCP", "Vinde pentru a face bani", false, 0.80)

AddEventHandler("jobs:onPlayerPaid", function(user_id)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de PCP")
    if job then
        local xpAmm = math.random(1, 5)
        vRP.giveXp(user_id, xpAmm, false)
        vRPclient.notify(vRP.getUserSource(user_id), {"Ai acumulat "..xpAmm.." XP"})       
    end
end)

registerCallback("getPCPToDelivery", function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de PCP")
    
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

registerCallback("gatherPiperine", function(player, plantId)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de PCP")
    
    if job and lastJob[user_id] then
        if lastJob[user_id].gatheringPipe then
            if lastJob[user_id].gatheringPipe[plantId] then
                lastJob[user_id].gatheringPipe[plantId] = nil
                
                if not next(lastJob[user_id].gatheringPipe) then
                    local amount = math.random(2, 4)
                    if vRP.canCarryItem(user_id, "drug_piperidine", amount) then
                        vRPclient.notify(player, {"Ai cules plantele si ai primit "..amount.." Piperidina"})
                        vRP.giveItem(user_id, "drug_piperidine", amount, false, false, false, 'Traficant de PCP')

                        return true
                    end
                    return false
                end

                return true
            end
        end

        return false
    end
end)


RegisterServerEvent("work-pcptrafficker:requestPipeCoords", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if player and user_id then
        local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de PCP")
        if job then

            local generated, amm = {}, 0
            local max = 5 -- 10 ?

            ::generatePos::
            math.randomseed(GetGameTimer() * player)
            local pick = math.random(1, #pipeCoords)
            if generated[pick] then
                Citizen.Wait(10)
                goto generatePos
            end
            
            generated[pick] = pipeCoords[pick]
            amm = amm + 1

            if (amm + 1) <= max then goto generatePos end


            if lastJob[user_id] then
                lastJob[user_id].gatheringPipe = generated
            end

            TriggerClientEvent("work-pcptrafficker:getPipeCoords", player, generated)
        else
            vRPclient.notify(player, {"Nu esti un Traficant de PCP !", "error"})
        end
    end
end)

local dustRecipe <const> = {
    {"water", 6},
    {"drug_piperidine", 2},
}

local grantedToCombine = {}

AddEventHandler("vRP:playerLeave", function(user_id, player)
    if grantedToCombine[player] then
        grantedToCombine[player] = nil
    end
end)

RegisterServerEvent("work-pcptrafficker:combineAllDust", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if player and user_id then
        if not grantedToCombine[player] then
            return
        end

        vRP.giveItem(user_id, "drug_dust", 1, false, false, false, 'Traficant de PCP')
        grantedToCombine[player] = nil
    end
end)

registerCallback("canCombinePCPDust", function(player)
    local user_id = vRP.getUserId(player)

    if user_id and player then
        if not vRP.canCarryItem(user_id, "drug_dust", 1) then
            vRPclient.notify(player, {"Nu exista spatiu in inventar.", "error"})
            return
        end
    
        local ok = true
        for k, v in pairs(dustRecipe) do
            if vRP.getInventoryItemAmount(user_id, v[1]) < v[2] then
                ok = false
                break
            end
        end
    
        if not ok then
            vRPclient.notify(player, {"Nu ai itemele necesare pentru combinare.\n\nReteta:\n- 6 Apa\n- 2 Piperidina", "error"})
            return false
        end
    
        for k, v in pairs(dustRecipe) do
            vRP.removeItem(user_id, v[1], v[2])
        end
    
        grantedToCombine[player] = true
    
        return true
    end
end)

registerCallback('useChemSetPcp', function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Traficant de PCP")

    if not job then
        return 'Nu esti un Traficant de PCP!'
    end

    if not vRP.canCarryItem(user_id, "pcp", 1) then
        return 'Nu ai destul spatiu in inventar!.'
    end 

    if vRP.removeItem(user_id, 'drug_dust', 1) then
        if math.random(1, 5) == 1 then
            return 'O nu! Setul de chimie tocmai mi-a explodat si am pierdut Amestecul ilegal'
        end

        vRP.giveItem(user_id, "pcp", amm, false, false, false, 'Traficant de PCP')
        return 'Ai produs PCP cu succes!'
    end

    return 'Iti lipsesc ingredientele necesare'
end)