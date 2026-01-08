local cfg = module("cfg/bunker")
local bunkersData, ownedBunkers, inBunkerPlayers = {}, {}, {}

Citizen.CreateThread(function()
    Wait(5000)
    exports.mongodb:find({collection = "bunkers"}, function(success, result)
        for index, data in pairs(result) do
            if not bunkersData[data.bunkerLocation] then
                bunkersData[data.bunkerLocation] = {}
            end

            ownedBunkers[data.owner] = data
            table.insert(bunkersData[data.bunkerLocation], data)
        end

        Wait(500)

        for bunker, i in pairs(bunkersData) do
            for index, data in pairs(bunkersData[bunker]) do
                if data.bunkerExpire <= os.time() then
                    bunkersData[bunker].blocked = true
                    exports.mongodb:updateOne({collection = 'bunkers', query = {bunker = data.bunker}, update = {["$set"] = {blocked = true}}})
                end
            end
        end
    end)
end)

function daysUntilExpiration(expireDate)
    local currentDate = os.time()
    local days = math.floor((expireDate - currentDate) / 86400)
    return days
end

registerCallback('getBunkerData', function(player, bunker)
    local user_id = vRP.getUserId(player)

    return {bunkerData = bunkersData[bunker], ownedBunker = ownedBunkers[user_id], owned = ownedBunkers[user_id] and ownedBunkers[user_id].bunkerLocation == bunker, id = user_id}
end)

registerCallback("getCraftingData", function(player, craftLocation)
    local user_id = vRP.getUserId(player)
    local inventory = vRP.getUserInventory(user_id)
    local items = {}

    for slot, data in pairs(inventory) do
        if data.amount > 0 then
            items[data.item] = (items[data.item] or 0) + data.amount
        end
    end

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
       if ownedBunkers[user_id] and ownedBunkers[user_id].bunkerData and ownedBunkers[user_id].bunkerData[craftLocation] then
            return {bought = true, bunkerData = ownedBunkers[user_id].bunkerData[craftLocation], userItems = items}
       else
            return {bought = false}
       end
    end
    return false
end)

registerCallback('tryCompletBunkerNecesary', function(player, craftLocation)
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        if ownedBunkers[user_id] and ownedBunkers[user_id].bunkerData and ownedBunkers[user_id].bunkerData[craftLocation] then
            -- Check Items
            for _, data in pairs(cfg.bunkerCraftings[craftLocation].need) do
                if vRP.getInventoryItemAmount(user_id, data.item) < data.amount then
                    return vRPclient.notify(player, {"Nu ai itemele necesare pentru a incepe sa craftezi!", 'error'})
                end
            end

            -- Take Items
            for _, data in pairs(cfg.bunkerCraftings[craftLocation].need) do
                vRP.removeItem(user_id, data.item, data.amount)
            end

            ownedBunkers[user_id].bunkerData[craftLocation].craftData = {
                finishTime = os.time() + cfg.bunkerCraftings[craftLocation].time * 60,
                item = cfg.bunkerCraftings[craftLocation].item,
                amount = cfg.bunkerCraftings[craftLocation].amount
            }

            exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerData = ownedBunkers[user_id].bunkerData}}})

            return {bunkerData = ownedBunkers[user_id].bunkerData[craftLocation].craftData, craftingMinutes = cfg.bunkerCraftings[craftLocation].time}
        else
            vRPclient.notify(player, {"Nu ai cumparat aceasta masa de crafting!", 'error'})
        end
    end

    return false
end)

registerCallback('getBunkerMenuData', function(player)
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        return {bunkerData = ownedBunkers[user_id].bunkerData, bunkerMissions = ownedBunkers[user_id].bunkerMissions, bunkerExpire = ownedBunkers[user_id].bunkerExpire}
    end

    return false
end)

local function generateRandomString(length)
    local chars = {}
    for i = 1, length do
        chars[i] = string.char(math.random(97, 122))
    end
    return table.concat(chars)
end

local function generateUniqueIdentifier()
    local timestamp = os.time() 
    local randomString = generateRandomString(6)

    return "bunker_" .. tostring(timestamp) .. "_" .. randomString
end

RegisterServerEvent('vrp-bunker:tryCollectBunkerCrafted', function(craftLocation)
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        if ownedBunkers[user_id] and ownedBunkers[user_id].bunkerData and ownedBunkers[user_id].bunkerData[craftLocation] then
            if ownedBunkers[user_id].bunkerData[craftLocation].craftData and ownedBunkers[user_id].bunkerData[craftLocation].craftData['finishTime'] <= os.time() then

                local item = ownedBunkers[user_id].bunkerData[craftLocation].craftData.item
                local amount = ownedBunkers[user_id].bunkerData[craftLocation].craftData.amount
                vRP.giveItem(user_id, item, amount, false, false, false, 'Bunker Crafted')

                if item == "weapon_uzi" then
                    exports.vrp:achieve(user_id, "UziEasy", 1)
                end

                ownedBunkers[user_id].bunkerData[craftLocation].craftData = nil
                exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerData = ownedBunkers[user_id].bunkerData}}})
            else
                vRPclient.notify(player, {"Itemul inca se crafteaza, mai ai de asteptat!", 'error'})
            end
        end
    end
end)

-- bunk_int Cutsceene
RegisterServerEvent('vrp-bunker:buy', function(bunker)
    local player = source
    local user_id = vRP.getUserId(player)

    if bunkersData[bunker] and #bunkersData[bunker] > 19 then
        return vRPclient.notify(player, {"Acest buncar si-a atins capacitatea maxima!", 'error'})
    end
    
    if ownedBunkers[user_id] then
        return vRPclient.notify(player, {"Detii deja un buncar, nu poti avea mai mult de 1!", 'error'})
    end

    vRP.request(player, "Doresti sa cumperi un Buncar in aceasta locatie pentru suma de 5.000.000$?", false, function(_, ok)
        if ok then
            if vRP.tryPayment(user_id, 5000000) then
                local newBunker = {
                    bunker = generateUniqueIdentifier(),
                    owner = user_id,
                    username = GetPlayerName(player),
                    bunkerLocation = bunker,
                    bunkerExpire = os.time() + 30 * 24 * 60 * 60,
                    bunkerMissions = {
                        ['special-transport'] = os.time(),
                        ['steal-vehicles'] = os.time(),
                        ['drugs'] = os.time()
                    },
                    bunkerData = {}
                }

                TriggerClientEvent('vrp-bunker:buyAnim', player, newBunker.bunkerLocation)
                inBunkerPlayers[user_id] = {
                    bunker = newBunker.bunker,
                    bunkerLocation = newBunker.bunkerLocation,
                }
                SetPlayerRoutingBucket(player, user_id)
        
                if not bunkersData[bunker] then
                    bunkersData[bunker] = {}
                end
        
                table.insert(bunkersData[bunker], newBunker)
                ownedBunkers[user_id] = newBunker
                exports.mongodb:insertOne({collection = "bunkers", document = newBunker})
                
                vRPclient.notify(player, {"Ti-ai achizitionat cu success un buncar!", 'info'})
            else
                vRPclient.notify(player, {"Nu ai destui bani la tine!", 'error'})
            end
        end
    end)
end)

RegisterServerEvent('vrp-bunker:exit', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if inBunkerPlayers[user_id] then
        inBunkerPlayers[user_id] = nil
        SetPlayerRoutingBucket(player, 0)
    end
end)

RegisterServerEvent('vrp-bunker:sell', function(bunkerID)
    local player = source
    local user_id = vRP.getUserId(player)
    
    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == bunkerID then
        vRPclient.getNearestPlayer(player, {5}, function(targetSrc)
            if not targetSrc then
                return vRPclient.notify(player, {"Nu ai niciun jucator in apropiere!", "error"})
            end
            local target_id = vRP.getUserId(targetSrc)
            vRP.prompt(player,"VINDE BUNCARUL", "Introdu in caseta de mai jos pretul cerut pe buncar apoi apasa pe butonul de confirmare.", false, function(amount)
                amount = tonumber(amount)
                amount = math.abs(amount)

                if ownedBunkers[target_id] then
                    return vRPclient.notify(player, {"Jucatorul detine deja un buncar!", 'error'})
                end

                vRP.request(player, "Vrei sa vinzi buncarul pentru $"..amount.."?", false, function(_, ok)
                    if ok then
                        vRP.request(targetSrc, "Vrei sa cumperi buncarul pentru $"..amount.."?", false, function(_, ok)
                            if ok then
                                if vRP.tryPayment(target_id, amount) then
                                    vRP.giveMoney(user_id, amount, "Sell Bunker")
            
                                    ownedBunkers[target_id] = ownedBunkers[user_id]
                                    ownedBunkers[user_id] = nil
                                    ownedBunkers[target_id].owner = target_id
                                    ownedBunkers[target_id].username = GetPlayerName(targetSrc)

                                    exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[target_id].bunker}, update = {["$set"] = {owner = target_id, username = GetPlayerName(targetSrc)}}})

                                    for bunker, data in pairs(bunkersData[ownedBunkers[target_id].bunkerLocation]) do
                                        if data.bunker == ownedBunkers[target_id].bunker then
                                            data.owner = target_id
                                            data.username = GetPlayerName(targetSrc)
                                        end
                                    end
                                else
                                    vRPclient.notify(player, {"Nu ai destui bani la tine!", 'error'})
                                end
                            end
                        end)
                    end
                end)
            end)
        end)
    end
end)

RegisterServerEvent('vrp-bunker:enter', function(bunkerID)
    local player = source
    local user_id = vRP.getUserId(player)

    local function enter_bunker(player, virtual, bunker)
        TriggerClientEvent("vrp-bunker:enter", player, bunker)
        SetPlayerRoutingBucket(player, virtual)
    end

    if ownedBunkers[user_id] and (not bunkerID) then
        if ownedBunkers[user_id].blocked then
            vRP.request(player, 'Buncarul tau a fost trecut sub sechestru pentru neplata, doresti sa platesti 1000$ pentru a redobandi buncarul?', false, function(_, ok)
                if ok then
                    if vRP.tryPayment(user_id, 1000, true, 'Sechestru Buncar') then
                        ownedBunkers[user_id].bunkerExpire = os.time() + 1 * 24 * 60 * 60
                        ownedBunkers[user_id].blocked = false
                        exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerExpire = ownedBunkers[user_id].bunkerExpire, blocked = false}}})
                    end
                end
            end)
        else
            inBunkerPlayers[user_id] = {
                bunker = ownedBunkers[user_id].bunker,
                bunkerLocation = ownedBunkers[user_id].bunkerLocation
            }
            enter_bunker(player, user_id, ownedBunkers[user_id].bunkerLocation)
        end
    else
        for owner_id, data in pairs(ownedBunkers) do
            if data.bunker == bunkerID then

                if data.locked then
                    return vRPclient.notify(player, {"Proprietarul si-a blocat buncarul, nu poti intra!", 'error'})
                end

                local owner_src = vRP.getUserSource(owner_id) 
                if owner_src then
                    vRP.request(owner_src, GetPlayerName(player).." vrea sa intre la tine in buncar, ii permiti?", false, function(_, ok)
                        if ok then
                            inBunkerPlayers[user_id] = {
                                bunker = data.bunker,
                                bunkerLocation = data.bunkerLocation,
                            }
                            enter_bunker(player, owner_id, data.bunkerLocation)
                        else
                            vRPclient.notify(player, {"Proprietarul nu ti-a permis sa intri!", 'error'})
                        end
                    end)
                else
                    vRPclient.notify(player, {'Proprietarul nu este online!', 'error'})
                end
            end
        end
    end
end)

RegisterServerEvent('vrp-bunker:lock', function(bunkerId)
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == bunkerId then
        if ownedBunkers[user_id].locked then
            ownedBunkers[user_id].locked = false        
            vRPclient.notify(player, {"Ti-ai deblocat buncarul!", 'info'})
        else
            ownedBunkers[user_id].locked = true
            vRPclient.notify(player, {"Ti-ai blocat buncarul!", 'info'})
        end
    end
end)

RegisterServerEvent('vrp-bunker:buyLocation', function(location)
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        if ownedBunkers[user_id] and ownedBunkers[user_id].bunkerData then

            local name = cfg.bunkerCraftings[location].name
            local price = cfg.bunkerCraftings[location].price

            vRP.request(player, 'Esti sigur ca vrei sa cumperi '..name..' pentru suma de '..price..'$ ?', false, function(_, ok)
                if ok then
                    if vRP.tryPayment(user_id, price, false, 'Bunker Upgrade: '..name) then
                        ownedBunkers[user_id].bunkerData[location] = {
                            boughtTime = os.time()
                        }

                        exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerData = ownedBunkers[user_id].bunkerData}}})
                    end 
                end
            end)
        end
    end
end)

RegisterServerEvent('vrp-bunker:buyBunkerDays', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then

        if ownedBunkers[user_id].bunkerExpire and daysUntilExpiration(ownedBunkers[user_id].bunkerExpire) < 30 then
            local currentDays = daysUntilExpiration(ownedBunkers[user_id].bunkerExpire)

            vRP.prompt(player, "INTRETINERE BUNCAR", "Introdu in caseta de mai jos <span style='color: var(--prompt-yellow);'>numarul de zile pe care doresti sa il achizitionezi (1.000$ / zi)</span> apoi apasa pe butonul de confirmare.", false, function(days)
                if not days then
                    return
                end
                days = tonumber(days)

                if days > 0 then
                    local price = days * 1000

                    if (currentDays + days) > 30 then
                        vRPclient.notify(player, {"Nu poti cumpara mai mult de 30 de zile!", 'error'})
                        return
                    end

                    if vRP.tryPayment(user_id, price, false, 'Bunker Days: '..days) then
                        ownedBunkers[user_id].bunkerExpire = ownedBunkers[user_id].bunkerExpire + (days * 24 * 60 * 60)

                        exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerExpire = ownedBunkers[user_id].bunkerExpire}}})
                    end
                end
            end, false)
        else
            vRPclient.notify(player, {"Nu poti cumpara mai mult de 30 de zile!", 'error'})
        end
    end
end)

local activeBunkerMission = {}
RegisterServerEvent('vrp-bunker:startMission', function(mission)
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        if activeBunkerMission[user_id] then
            return vRPclient.notify(player, {"Ai deja o misiune activa!", 'error'})
        end

        if ownedBunkers[user_id] and ownedBunkers[user_id].bunkerMissions then
            if (ownedBunkers[user_id].bunkerMissions[mission] or 0) >= os.time() then
                return
            end

            if (mission == 'drugs') then
                ownedBunkers[user_id].bunkerMissions[mission] = os.time() + 6 * 60 * 60

                local missionData = cfg.stealDrugs[math.random(1, #cfg.stealDrugs)]
                missionData.missionType = 'drugs'
                activeBunkerMission[user_id] = missionData
                
                if inBunkerPlayers[user_id] then
                    inBunkerPlayers[user_id] = nil
                    SetPlayerRoutingBucket(player, 0)
                end

                TriggerClientEvent('vrp-bunker:steal-drugs', player, missionData.spawnLocation, missionData.dropLocation)
            elseif (mission == 'special-transport') then
                ownedBunkers[user_id].bunkerMissions[mission] = os.time() + 12 * 60 * 60

                local missionData = cfg.specialTransports[math.random(1, #cfg.specialTransports)]
                missionData.missionType = 'special-transport'
                activeBunkerMission[user_id] = missionData

                if inBunkerPlayers[user_id] then
                    inBunkerPlayers[user_id] = nil
                    SetPlayerRoutingBucket(player, 0)
                end
                
                Citizen.Wait(1000)
                TriggerClientEvent('vrp-bunker:transport-mission', player, missionData.dropLocation)
            else
                ownedBunkers[user_id].bunkerMissions[mission] = os.time() + 4 * 60 * 60

                math.randomseed(os.time() * user_id)
                local missionData = cfg.stealVehicle[math.random(1, #cfg.stealVehicle)]

                if inBunkerPlayers[user_id] then
                    inBunkerPlayers[user_id] = nil
                    SetPlayerRoutingBucket(player, 0)
                end

                Citizen.Wait(1000)
                TriggerClientEvent('vrp-bunker:stealVehicle', player, missionData.vehicle, missionData.spawnLocation, missionData.dropLocation)
                missionData.missionType = 'steal-vehicles'
                activeBunkerMission[user_id] = missionData
            end

            exports.mongodb:updateOne({collection = "bunkers", query = {bunker = ownedBunkers[user_id].bunker}, update = {["$set"] = {bunkerMissions = ownedBunkers[user_id].bunkerMissions}}})
        end
    end
end)

AddEventHandler('vRP:playerLeave', function(user_id, player)
    if activeBunkerMission[user_id] then
        activeBunkerMission[user_id] = nil
    end
end)

RegisterServerEvent('vrp-bunker:missionDone', function(passed)
    local player = source
    local user_id = vRP.getUserId(player)

    local missionData = activeBunkerMission[user_id]

    if missionData then        
        if not passed then
            vRPclient.notify(player, {'Misiune esuata.', 'error'})
        else
            math.randomseed(os.time() * GetGameTimer() * user_id)

            local reward = math.random(missionData.minReward, missionData.maxReward)
            vRP.giveMoney(user_id, reward, "Bunker Mission - "..missionData.missionType)
        end

        activeBunkerMission[user_id] = nil
    end
end)

RegisterServerEvent('vRP:bunkerChest', function()
    local player = source
    local user_id = vRP.getUserId(player)

    if ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker then
        vRP.openChest(player, 'bunker:'..inBunkerPlayers[user_id].bunker, 1200, 'Cufar Buncar', false)
    else
        vRPclient.notify(player, {"Doar proprietarul poate accesa cufar-ul!", 'error'})
    end
end)

registerCallback("tryOpenVehicle", function(player)
    local user_id = vRP.getUserId(player)
    local data = activeBunkerMission[user_id] or {}

    return data.missionType == "drugs" and vRP.removeItem(user_id, "lockpick", 1)
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, connect)
    if not connect then return end;

    if inBunkerPlayers[user_id] then
        if (ownedBunkers[user_id] and ownedBunkers[user_id].bunker == inBunkerPlayers[user_id].bunker) then
            TriggerClientEvent("vrp-bunker:enter", player, inBunkerPlayers[user_id].bunkerLocation)
            SetPlayerRoutingBucket(player, user_id)
        else
            local bunkerLocation = inBunkerPlayers[user_id].bunkerLocation
            local bunkerCoords = cfg.bunkers[bunkerLocation]
            
            SetEntityCoords(GetPlayerPed(player), bunkerCoords[1], bunkerCoords[2], bunkerCoords[3])
        end
    end 
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
    if inBunkerPlayers[user_id] then
        local bunkerLocation = inBunkerPlayers[user_id].bunkerLocation
        local bunkerCoords = cfg.bunkers[bunkerLocation]
        
        SetEntityCoords(GetPlayerPed(player), bunkerCoords[1], bunkerCoords[2], bunkerCoords[3])
        exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {userCoords = {x = bunkerCoords[1], y = bunkerCoords[2], z = bunkerCoords[3]}}}})
    end
end)