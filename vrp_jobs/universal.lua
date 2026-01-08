
local Tunnel = module("lib/Tunnel")

vRP = exports.vrp:link()
vRPclient = Tunnel.getInterface("vRP", "vrp_jobs")

local cfg = {
    jobs = {
        ["Taietor de iarba"] = {
            start = "work-lawnmower:startJob",
            money = {500, 800},
            xp = 2
        },
        ["Sofer de autobuz"] = {
            start = "work-busdriver:startJob",
            money = {1500, 2000},
            xp = 4,
            minLvl = 2
        },
        ["Curatator de strazi"] = {
            start = "work-streetsweeper:startJob",
            money = {2350, 2650},
            xp = 5,
            minLvl = 4
        },
        ["Culegator de portocale"] = {
            start = "work-orangepicker:startJob",
            money = {3500, 4500},
            xp = 7,
            minLvl = 10
        },
        ["Constructor"] = {
            start = "work-builder:startJob",
            money = {4000, 5000},
            xp = 10,
            minLvl = 25
        },
        ["Traficant de iarba"] = {
            start = "work-weedtrafficker:startJob",
            money = {5500, 6500},
            dirty = true,
            xp = 5,
            minLvl = 30
        },
        ["Traficant de PCP"] = {
            start = "work-pcptrafficker:startJob",
            money = {7500, 8500},
            dirty = true,
            xp = 5,
            minLvl = 60
        },
        ["Traficant de opium"] = {
            start = "work-opiumtrafficker:startJob",
            money = {8500, 9500},
            dirty = true,
            xp = 10,
            minLvl = 90
        },
        ["Hacker"] = {
            start = "work-hacker:startJob",
            money = {10000, 14000},
            dirty = true,
            xp = 10,
            minLvl = 120 -- trece si in index.html la clasa min-level ( valabil pt fiecare )
        },
	    ["Cercetator maritim"] = {
	        dirty = true,
	        minLvl = 45,
	    }
    }
}

local resName = GetCurrentResourceName()

function registerCallback(cbName, cb)
    RegisterServerEvent(resName..":s_callback:"..cbName, function(...)
        local player = source
        if cb and player then
            local result = table.pack(cb(player, ...))
            TriggerClientEvent(resName..":c_callback:"..cbName, player, table.unpack(result))
        end
    end)
end


local playerJobs = {}
local playerSecrets = {}

lastJob = {}

exports("setJob", function(user_id, job)
    local player = vRP.getUserSource(user_id)
    playerJobs[user_id] = job
    TriggerClientEvent("jobs:onJobSet", player, playerJobs[user_id])
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        executeMission(user_id)
    end)

    exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
        ["$set"] = {job = job}
    }})
end)

exports("getJob", function(user_id)
    return playerJobs[user_id]
end)

exports("hasJob", function(user_id, job)

    if not (playerJobs[user_id] == "Somer") then
        if job and not (playerJobs[user_id] == job) then
            return false
        end

        return true
    end
  
    return false
end)

function doInJobPlayersFunction(job, cb)
    for k, plyJob in pairs(playerJobs) do
        if plyJob == job then
            cb(vRP.getUserSource(k))
        end
    end
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
    if first_spawn then
        playerJobs[user_id] = dbdata.job or "Somer"

        TriggerClientEvent("jobs:onJobSet", player, playerJobs[user_id])

        if dbdata.lastJob then
            TriggerClientEvent("jobs:setLastJob", player, playerJobs[user_id], dbdata.lastJob)
        end
        lastJob[user_id] = dbdata.lastJob or {}

        Citizen.Wait(10000)
        executeMission(user_id)
    end
end)

AddEventHandler("onResourceStart", function(res)
    if res == resName then
        local users = vRP.getUsers()
        for user_id, src in pairs(users) do
            playerJobs[user_id] = "Somer"
        end
    end
end)

RegisterServerEvent("jobs:getGroup", function(group)
    local player = source
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id)
    local level = vRP.getLevel(user_id)

    if not job then
        if cfg.jobs[group] and cfg.jobs[group].minLvl and level < cfg.jobs[group].minLvl then
            vRPclient.notify(player, {"Ai nevoie de nivel "..cfg.jobs[group].minLvl.." pentru a te angaja!", "error"})
            return
        end

        exports["vrp_jobs"]:setJob(user_id, group)
        TriggerClientEvent("jobs:showNewGroup", player, group)
        lastJob[user_id] = {}

        Citizen.SetTimeout(5000, function()
            if not exports.vrp:hasCompletedBegginerQuest(user_id, 3) then
                exports.vrp:completeBegginerQuest(user_id, 3)
            end
        end)
    else
        vRPclient.notify(player, {"Ai deja un job: "..playerJobs[user_id]})
    end
end)

RegisterServerEvent("jobs:getFired", function()
    local player = source
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id)

    if job then
        exports["vrp_jobs"]:setJob(user_id, "Somer")
        TriggerClientEvent("jobs:onJustFired", player)

        if lastJob[user_id] then
            lastJob[user_id] = false
            TriggerClientEvent("jobs:setLastJob", player, playerJobs[user_id], {})
        end

        TriggerEvent("jobs:onPlayerFired", user_id)

        vRPclient.notify(player, {"Ti-ai dat demisia cu succes!"})
    else
        vRPclient.notify(player, {"Nu ai un job."})
    end
end)

function hasMission(user_id)
    return playerSecrets[user_id]
end

exports("hasMission", user_id)

RegisterServerEvent("jobs:updateLastJob", function(jobTbl)
    local player = source
    local user_id = vRP.getUserId(player)

    if player and playerJobs[user_id] then
        lastJob[user_id] = jobTbl
    end
end)

exports("setLastJobTblValue", function(user_id, key, value)
    if lastJob[user_id] and type(lastJob[user_id]) == "table" then
        lastJob[user_id][key] = value
    end
end)

function executeMission(user_id)
    local player = vRP.getUserSource(user_id)
    local job = playerJobs[user_id]

    local jobData = cfg.jobs[job] or {}

    if player and jobData.start then
        local newRnd = math.random(1, math.max(GetNumPlayerIndices(), 1) * os.time())

        while newRnd == playerSecrets[user_id] do
            newRnd = math.random(1, math.max(GetNumPlayerIndices(), 1) * os.time())
        end

        playerSecrets[user_id] = newRnd
        TriggerClientEvent(jobData.start, player, {playerSecrets[user_id]})
    end
end

registerCallback("getPaid", function(player, cpData, multiply)
    local user_id = vRP.getUserId(player)
    local job = playerJobs[user_id]

    if job and job ~= "Somer" and playerSecrets[user_id] then
        if playerSecrets[user_id] == cpData[1] then
            local amount = cfg.jobs[job].money

            if type(amount) == "table" then
                local min, max = table.unpack(amount)
                amount = math.random(min, max)
            end

            if type(amount) == "number" and amount > 0 then
                local level = vRP.getLevel(user_id)
                if level > 1 then
                    amount = math.floor(amount + (((level/3)*amount)/50))
                end

                if multiply then
                    amount = math.floor(tonumber(amount) * tonumber(multiply))
                end

                if vRP.getUserVipRank(user_id) == 1 then
                    amount = math.floor(5/100*tonumber(amount))
                end

                if vRP.getUserVipRank(user_id) == 2 then
                    amount = math.floor(15/100*tonumber(amount))
                end

                if cfg.jobs[job].dirty then
                    vRP.giveItem(user_id, "dirty_money", amount)
                    exports.vrp:achieve(user_id, "ilegalEasy", 1)
                else
                    vRP.giveJobMoney(user_id, amount, job, cfg.jobs[job].xp)
                end
                
                TriggerEvent("jobs:onPlayerPaid", user_id)
                exports.vrp:achieve(user_id, job, 1)
            end
            playerSecrets[user_id] = nil
            Citizen.CreateThread(function()
                Citizen.Wait(5000)
                executeMission(user_id)
            end)
        end
    end
    return true
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    Citizen.Wait(1000)
    if lastJob[user_id] ~= nil then
        local update = {}
        if type(lastJob[user_id]) == "table" and next(lastJob[user_id]) then
            update["$set"] = {lastJob = lastJob[user_id]}
        else
            update["$unset"] = {lastJob = 1}
        end
        
        exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = update})
        Citizen.Wait(500)
        lastJob[user_id] = nil
    end

    playerJobs[user_id] = nil
end)
