
local maxDelivery = math.random(5, 8)

local hackPositions = {
    {210.13958740234,201.10963439941,105.57251739502, "Pacific Bank"},
    {-723.85369873047,-913.18927001953,19.013891220093, "Weazel Market"},
    {295.17202758789,-591.30859375,43.247489929199, "Hospital"},
    {-1034.1788330078,-229.22189331055,39.01411819458, "Life Invader"},
    {428.57165527344,-962.08532714844,29.28885269165, "Police Station"},
    {-636.75122070312,-241.53012084961,38.105590820312, "Vangelico"},
    {-53.436599731445,-1117.2493896484,26.433847427368, "Dealership"},
    {1153.6840820312,-331.58865356445,68.873931884766, "Mirror Market"},
    {908.48736572266,-183.30476379395,74.203430175781, "Taxi"},
    {-1617.0708007812,-805.80212402344,10.098780632019, "Mechanic"},
    {-2959.9460449219,462.16204833984,15.219735145569, "Flecca Highway-L"},
    {-1824.560546875,781.11682128906,137.9881439209, "Canyon Market"},
}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k, v in pairs(hackPositions) do
        exports.vrp:addTpToJobSubch("Hacker", {"Zone: "..v[4], {v[1], v[2], v[3]}})
    end
end)

local inHack = {}

vRP.defInventoryItem("usbstick", "Stick USB", "Un spatiu de stocare a datelor", false, 0.80)
vRP.defInventoryItem("laptop_h", "Laptop", "Folosit pentru a fura date", function(player)
    local user_id = vRP.getUserId(player)

    local job = exports["vrp_jobs"]:hasJob(user_id, "Hacker")
    if job then

        if lastJob[user_id] and lastJob[user_id].zone then

            if not vRP.removeItem(user_id, 'usbstick') then
                vRPclient.notify(player, {"Nu ai un stick USB.", "error"})
                return
            end

            inHack[user_id] = true
            TriggerClientEvent("work-hacker:startMinigame", player)
            return
        end

        getHackZone(player, user_id, math.random(1, #hackPositions))
    else
        vRPclient.notify(player, {"Nu esti un Hacker !", "error"})
    end
end, 0.2)

AddEventHandler("vRP:playerLeave", function(user_id)
    if inHack[user_id] then
        inHack[user_id] = nil
    end
end)

function getHackZone(player, user_id, rnd)
    local zone = hackPositions[rnd]

    if zone then
        zone.radius = zone[5] or 100

        if lastJob[user_id] then
            lastJob[user_id].zone = zone
            lastJob[user_id].rnd = rnd
        end

        TriggerClientEvent("work-hacker:getHackZone", player, rnd, zone)
    end
end

vRP.defInventoryItem("fullusbstick", "Stick USB plin", "Vinde pentru a face bani", false, 0.80)

AddEventHandler("jobs:onPlayerPaid", function(user_id)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Hacker")
    if job then
        local xpAmm = math.random(1, 5)
        vRP.giveXp(user_id, xpAmm, false)
        vRPclient.notify(vRP.getUserSource(user_id), {"Ai acumulat "..xpAmm.." XP"})       
    end
end)

registerCallback("getUSBToDelivery", function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Hacker")
    
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

RegisterServerEvent("work-hacker:checkHack", function(outcome)
    local player = source
    local user_id = vRP.getUserId(player)

    if player and user_id then
        
        if not inHack[user_id] then
            return
        end

        inHack[user_id] = nil
        lastJob[user_id].zone = nil
        lastJob[user_id].rnd = nil
    
        if not outcome then
            vRPclient.notify(player, {"Nu ai reusit sa furi datele !", "error"})
            vRP.giveItem(user_id, "usbstick", 1)
            return
        end

        if vRP.canCarryItem(user_id, "fullusbstick", 1) then
            vRPclient.notify(player, {"Datele furate au fost transferate pe un stick USB."})
            vRP.giveItem(user_id, "fullusbstick", 1)
        end
    end
end)
