
local huntPos, huntRadius = {-1464.5980224609,4573.728515625,42.793586730957}, 250.0

local animalTypes <const> = {
    -- {model, chance, drops: {itemid, name, weight, price}}
	{model = "a_c_panther", chance = 10, drops = {
        ["panther_fangs"] = {"Colti de pantera", 1.0, 100},
        ["panther_fur"] = {"Blana de pantera", 1.0, 100},
    }},
	{model = "a_c_rabbit_01", chance = 40, drops = {
        ["rabbit_fur"] = {"Blana de iepure", 1.0, 100},
        ["rabbit_meat"] = {"Carne de iepure", 1.0, 100},
        ["rabbit_paw"] = {"Laba de iepure", 1.0, 100},
    }},
	{model = "a_c_chickenhawk", chance = 50, drops = {
        ["hawk_claw"] = {"Gheara de soim", 1.0, 100},
        ["hawk_feathers"] = {"Pene de soim", 1.0, 100},
    }}, 
	{model = "a_c_cormorant", chance = 50, drops = {
        ["cormorant_feathers"] = {"Pene de cormoran", 1.0, 100},
        ["cormorant_meat"] = {"Carne de cormoran", 1.0, 100},
    }},
	{model = "a_c_crow", chance = 50},
	{model = "a_c_deer", chance = 90, drops = {
        ["deer_fur"] = {"Blana de caprioara", 1.0, 100},
        ["deer_meat"] = {"Carne de caprioara", 1.0, 100},
        ["deer_antlers"] = {"Coarne de caprioara", 1.0, 100},
    }},
	{model = "a_c_boar", chance = 50, drops = {
        ["boar_fur"] = {"Blana de mistret", 1.0, 100},
        ["boar_meat"] = {"Carne de mistret", 1.0, 100},
        ["boar_fangs"] = {"Colti de mistret", 1.0, 100},
    }},
}

local dropPrices = {} -- auto filled from the loop below

for key, animal in pairs(animalTypes) do
    if not animal.drops then
        goto continue
    end

    for id, itmdata in pairs(animal.drops) do
        vRP.defInventoryItem(id, itmdata[1], "Obtinut de la vanatoare", false, itmdata[2])

        if itmdata[3] then
            dropPrices[id] = {name = itmdata[1], price = itmdata[3]}
        end
    end
    
    ::continue::
end

local function getAnimalByModel(model)
    for k, v in pairs(animalTypes) do
        if v.model == model then
            return v
        end
    end
    return false
end

local bulletGroups <const> = {
    [453432689] = true,
    [1593441988] = true,
    [584646201] = true,
    [-1716589765] = true,
    [324215364] = true,
    [736523883] = true,
    [-270015777] = true,
    [-1074790547] = true,
    [-2084633992] = true,
    [-1357824103] = true,
    [-1660422300] = true,
    [2144741730] = true,
    [487013001] = true,
    [2017895192] = true,
    [-494615257] = true,
    [-1654528753] = true,
    [100416529] = true,
    [205991906] = true,
    [1119849093] = true,
    [-1466123874] = true,
}


local noRelationAnimals <const> = {
    ["a_c_panther"] = true,
}
local noWanderAnimals <const> = {}

local trackedAnimals = {}
local firstSpawns = {}

RegisterServerEvent("work-forester:initPlayer", function()
    local player = source
    
    if not firstSpawns[player] then
        firstSpawns[player] = true
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
    if firstSpawns[player] then
        firstSpawns[player] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    local player = vRP.getUserSource(user_id)
    if firstSpawns[player] then
        firstSpawns[player] = nil
    end
end)

local function pickAnimalSpawn()
    local angle, rnd = math.rad(math.random(0, 360)), math.random() * huntRadius
    local x = huntPos[1] + rnd * math.cos(angle)
    local y = huntPos[2] + rnd * math.sin(angle)
    local z = huntPos[3]
    return vector3(x, y, z)
end

local function initAnimals(player)
    firstSpawns[player] = nil
    for i=1, #trackedAnimals do

        local animal = trackedAnimals[i]

        if animal then
            TriggerClientEvent("work-hunter:handleAnimal", player, animal.nid, not noRelationAnimals[animal.model], not noWanderAnimals[animal.model])
            Citizen.Wait(100)
        end
    end
end

RegisterServerEvent("work-hunter:enterForest", function()
    local player = source
    local user_id = vRP.getUserId(player)

    local job = exports["vrp_jobs"]:hasJob(user_id, "Vanator")
    if job then
        if not firstSpawns[player] then
            return
        end
        initAnimals(player)
    end
end)


local function getRandAnimal()
    ::retryPick::
    Citizen.Wait(1)
    math.randomseed(os.time() * GetGameTimer())
    local rnd = math.random(1, 100)
    local i = math.random(1, #animalTypes)

    if rnd <= animalTypes[i].chance then
        return animalTypes[i]
    end
    goto retryPick
end

Citizen.CreateThread(function()
    while true do

        if #trackedAnimals < 30 then
            local max = math.min(30 - #trackedAnimals, 15)
            
            for i = 1, max do
                local pos = pickAnimalSpawn()
                local animal = getRandAnimal()
                local hash = GetHashKey(animal.model)
                
                local ped = CreatePed(0, hash, pos, 0.0, true, true)
                -- FreezeEntityPosition(ped, true)
                -- Citizen.CreateThread(function()
                --     Citizen.Wait(2500)
                    
                --     if DoesEntityExist(ped) then
                --         FreezeEntityPosition(ped, false)
                --     end
                -- end)
                Citizen.Wait(1000)

                local nid = NetworkGetNetworkIdFromEntity(ped)

                table.insert(trackedAnimals, {nid = nid, entity = ped, model = animal.model, pos = pos})
                -- newAnimals[nid] = {relationship = (noTouchedAnwimals[hash] and false or true)}
                TriggerClientEvent("work-hunter:handleAnimal", -1, nid, not noRelationAnimals[animal.model], not noWanderAnimals[animal.model])
            end
        end

        Citizen.Wait(60000 * 1) -- 60.000 * 1 = 1 min
    end
end)

RegisterServerEvent("work-hunter:sacrificeAnimal", function(nid, death)
    local player = source
    local user_id = vRP.getUserId(player)
    
    local job = exports["vrp_jobs"]:hasJob(user_id, "Vanator")
    if job then
        
        local animal
        for k, v in pairs(trackedAnimals) do
            if v.nid == nid then
                animal = v
                if DoesEntityExist(v.entity) then 
                    DeleteEntity(v.entity)
                end
                table.remove(trackedAnimals, k)
                break
            end
        end
        
        if not animal or not bulletGroups[death] then
            if not bulletGroups[death] then
                print("[vrp_hunter] Death cause missing in bullet list: "..death)
            end

            TriggerClientEvent("work-hunter:deleteAnimal", player)
            return
        end


        if animal.model == "a_c_crow" then
            vRPclient.notify(player, {"Animalul este prea slab.", "error"})
            return
        end
        
        local animal = getAnimalByModel(animal.model) or {}
        
        for k, v in pairs(animal.drops or {}) do
            if vRP.canCarryItem(user_id, k, 1) then
                vRP.giveItem(user_id, k, 1, false, false, false, 'Hunter')
                vRPclient.notify(player, {"Ai obtinut "..v[1]})
            else
                vRPclient.notify(player, {"Nu poti cara "..v[1]})
            end
        end

        exports.vrp:achieve(user_id, "huntingEasy", 1)
    end
end)

registerCallback('sellDropsHunter', function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Vanator")

    if not job then
        return 'Nu esti un Vanator !'
    end

    local choices = {}

    for item, itmdata in pairs(dropPrices) do
        local amount = vRP.getInventoryItemAmount(user_id, item)
        if amount > 0 then
            local totPrice = amount * itmdata.price
            local itmName = itmdata.name
            
            table.insert(choices, {itmName.." - $"..totPrice, {item, itmName, amount, totPrice}})
        end
    end

    if not next(choices) then
        return 'Nu ai nimic de vandut! Te pot ajuta cu altceva?'
    end

    local reply = promise.new()
    vRP.selectorMenu(player, "Vinde materiale vanate", choices, function(drop)
        if not drop then
            return reply:resolve('Te pot ajuta cu altceva?')
        end

        local item, itmName, amount, totPrice = table.unpack(drop)
        if vRP.removeItem(user_id, item, amount) then
            vRP.giveMoney(user_id, totPrice, "Vanator - "..itmName)
        end
        
        reply:resolve('Ai primit '..totPrice..'$ pentru '..amount..' '..itmName..'! Te mai pot ajuta cu altceva?')
    end, true)
    
    return Citizen.Await(reply)
end)

local musketPrice, ammoPrice <const> = 10000, 10 * 100
RegisterServerEvent("work-hunter:getMusket", function()
    local player = source
    local user_id = vRP.getUserId(player)
    
    local job = exports["vrp_jobs"]:hasJob(user_id, "Vanator")
    if not job then
        vRPclient.notify(player, {"Nu esti un Vanator !", "error"})
        return
    end

    local choices = {
        {"Musket - $"..musketPrice, {"weapon_musket", 1, musketPrice}},
        {"Gloante (100) - $"..ammoPrice, {"ammo_222rem", 100, ammoPrice}},
    }

    if next(choices) then
        vRP.selectorMenu(player, "Magazin Vanator", choices, function(choose)
            if choose then
                local item, amount, totPrice = table.unpack(choose)
                if vRP.canCarryItem(user_id, item, amount) then                    
                    if vRP.tryFullPayment(user_id, totPrice, false, false, "Vanator - Musket") then
                        local itmName = vRP.getItemName(item)
                        vRP.giveItem(user_id, item, amount, false, false, false, 'Magazin Hunter')
                    else
                        vRPclient.notify(player, {"Nu iti permiti sa cumperi !", "error"})
                    end
                end
            end
        end)
    end
end)

local resName = GetCurrentResourceName()
AddEventHandler("onResourceStop", function(res)
    if res == resName then
        for k, animal in pairs(trackedAnimals) do
            if DoesEntityExist(animal.entity) then
                DeleteEntity(animal.entity)
            end
        end
        trackedAnimals = {}
    end
end)
