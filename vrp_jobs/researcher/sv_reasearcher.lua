
local allLoots = {
    -- {id = "wooden_plank", name = "Bucata Lemn", weight = 0.2, chance = 90},
    {id = "metal_fragmentat", name = "Metal Fragmentat", weight = 0.3, chance = 50},
    {id = "suruburi", name = "Suruburi", weight = 1.0, chance = 70},
    {id = "otel", name = "Bucata otel", weight = 1.0, chance = 30},
    {id = "prafdepusca", name = "Pachet Praf de Pusca", weight = 1.0, chance = 30},
    {id = "scubakit", name = "Scuba Kit", weight = 10.0, chance = 5},
    {id = "colier_diamante", name = "Colier cu Diamante", weight = 3.0, chance = 5},
    {id = "ammobox_9mm", name = "Cutie Gloante 9MM", weight = 0.5, chance = 2},
    {id = "weapon_de", name = "Desert Eagle", weight = 0.5, chance = 1},
}

for id, loot in pairs(allLoots) do
    if not loot.weapons then goto onlyOneItem end
    for k, v in pairs(loot.weapons) do
        vRP.defInventoryItem("research_" ..loot.id.."|"..v.weapon, v.name.." "..loot.name, "Gasit in apele adanci ale oceanului", false, v.weight or loot.weight)
    end
    goto skip

    ::onlyOneItem::
    vRP.defInventoryItem("research_" ..loot.id, loot.name, "Gasit in apele adanci ale oceanului", false, loot.weight)
    ::skip::
end

local scubaTank = {}
exports("getScubaTankState", function(player)
    return scubaTank[player]
end)

vRP.defInventoryItem("scubakit", "Scuba Kit", "Folosit pentru explorarea oceanului", function(player)
    if not scubaTank[player] then
        scubaTank[player] = true
    else
        local p = promise.new()
        
        vRP.request(player, "Esti sigur ca vrei sa dai jos Scuba Kit?", false, function(_, ok)
            p:resolve(ok)
        end)

        if Citizen.Await(p) then
            scubaTank[player] = nil
        end
    end

    TriggerClientEvent("work-researcher:useScuba", player, scubaTank[player])
end, 0.5)

AddEventHandler("vRP:playerLeave", function(user_id, player)
    if scubaTank[player] then
        scubaTank[player] = nil
    end
end)


local inOcean = {}

RegisterServerEvent("work-researcher:enterOcean", function()
    local player = source
    local user_id = vRP.getUserId(player)

    local job = exports["vrp_jobs"]:hasJob(user_id, "Cercetator maritim")
    if job then
        inOcean[player] = true
    end
end)

RegisterServerEvent("work-researcher:leaveOcean", function()
    local player = source

    if inOcean[player] then
        inOcean[player] = nil
    end
end)

local scubaKitPrice <const> = 10000

registerCallback("work-researcher:getScubaKit", function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Cercetator maritim")

    if not job then
        return "Nu esti un Cercetator maritim!"
    end

    if not vRP.canCarryItem(user_id, "scubakit", 1) then
        return "Nu ai destul spatiu in inventar!"
    end

    if not vRP.tryPayment(user_id, scubaKitPrice, false, "Cercetator maritim") then
        return "Nu ai destui bani!"
    end

    exports.vrp:achieve(user_id, "diversetEasy", 1)

    vRP.giveItem(user_id, "scubakit", 1, false, false, false, 'Magazin Scuba Kit')
end)

local function getRandLoot()
    ::retryPick::
    Citizen.Wait(1)
    math.randomseed(os.time() * GetGameTimer())
    local rnd = math.random(1, 100)
    local i = math.random(1, #allLoots)

    if rnd <= allLoots[i].chance then
        return allLoots[i]
    end
    goto retryPick
end

registerCallback("gatherOceanLoot", function(player, plantId)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Cercetator maritim")
    
    if job and lastJob[user_id] then
        if lastJob[user_id].loot then
            if lastJob[user_id].loot[plantId] then

                local pick = getRandLoot()
                if not pick then
                    vRPclient.notify(player, {"Nu ai gasit nimic.", "error"})
                    return true
                end

                local amount = 1
                if pick.amount then
                    amount = math.random(pick.amount[1], pick.amount[2])
                end

                if vRP.canCarryItem(user_id, "research_"..pick.id, amount) then
                    vRPclient.notify(player, {"Ai deschis cutia si ai gasit "..amount.." "..pick.name})
                    vRP.giveItem(user_id, "research_"..pick.id, amount, false, false, false, 'Cercetator maritim')
                    
                    return true
                end

                return false
            end
        end

        return false
    end
end)
