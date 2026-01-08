
local allFish <const> = {
    ['arapaima'] = {
        name = "Arapaima",
        price = 15000,
        chance = 5,
        kg = {5, 25},
    }, 
    ['somonmare'] = {
        name = "Somon",
        price = 3500,
        chance = 8,
        kg = {5, 15},
    }, 
    ['salaumare'] = {
        name = "Salau",
        price = 3250,
        chance = 10,
        kg = {3, 10}
    }, 
    ['aravana'] = {
        name = "Aravana",
        price = 3000,
        chance = 20,
        kg = {1, 5}
    }, 
    ['stiucamare'] = {
        name = "Stiuca",
        price = 2500,
        chance = 40,
        kg = {1, 7}
    }, 
    ['biban_de_nil'] = {
        name = "Biban de Nil",
        price = 2750,
        chance = 50,
        kg = {3, 5}
    }, 
    ['crapmare'] = {
        name = "Crap",
        price = 2500,
        chance = 60,
        kg = {3, 10}
    }, 
    ['anghila_electrica'] = {
        name = "Anghila Electrica",
        price = 2000,
        chance = 70,
        kg = {1, 5}
    }, 
    ['rosioaramare'] = {
        name = "Rosioara Mare",
        price = 2000,
        chance = 75,
        kg = {1, 5}
    }, 
    ['bocanc'] = {
        name = "Bocanc",
        price = 200,
        chance = 90,
        kg = {1, 5}
    }, 
    ['platicamare'] = {
        name = "Platica",
        price = 1500,
        chance = 100,
        kg = {1, 5}
    }
}

local fishKeys = {}

Citizen.CreateThread(function()
    for fish in pairs(allFish) do
        table.insert(fishKeys, fish)
    end
end)

local fishingRods <const> = {'undita_3', 'undita_2', 'undita_1'}

Citizen.CreateThread(function()
    vRP.defInventoryItem("momeala", "Momeala de pescuit", "", false, 0.5)
    
    for item, data in pairs(allFish) do
        vRP.defInventoryItem(item, data.name, "Un peste exotic", false, 1.0, 'fish', true)
    end
end)

local function getRandExoticFish()
    ::retryPick::
    math.randomseed(os.time() * GetGameTimer())
    local r = math.random(1, 100)
    local rnd = math.random(1, #fishKeys)
    local fish = fishKeys[rnd]

    if r <= allFish[fish].chance then
        math.randomseed(os.time() * GetGameTimer())
        return {item = fish, name = allFish[fish].name, weight = math.random(allFish[fish].kg[1], allFish[fish].kg[2])}
    end
    goto retryPick
end

local maxFishAmount = 10
local catchFishCooldown = {}

registerCallback("catchFish", function(player, rod)
    local user_id = vRP.getUserId(player)
    if user_id then

        if catchFishCooldown[user_id] and (catchFishCooldown[user_id] or 0) <= os.time() then
            catchFishCooldown[user_id] = nil

            local exoticFish = getRandExoticFish()
            local itemId = exoticFish.item
            local fishWeight = exoticFish.weight

            if vRP.canCarryItem(user_id, itemId, 1, fishWeight) then
                if exoticFish.name ~= "Bocanc" then
                    if not vRP.damageItem(user_id, rod, 10) then
                        return
                    end
                    
                    if vRP.giveItem(user_id, itemId, 1, false, {weight = fishWeight}, false, false, 'Fisher Job') then
                        exports.vrp:achieve(user_id, 'fisherEasy', 1)

                        vRPclient.notify(player, {'Ai prins un '..exoticFish.name..' de '..fishWeight..' kg', 'info'})
                    end
                else
                    vRP.giveItem(user_id, itemId, 1, false, false, false, 'Fisher Job')
                    vRPclient.notify(player, {'Ai gasit un '..exoticFish.name, 'info'})
                end
            else
                vRPclient.sendInfo(player, {"Galeata este plina cu peste"})
                vRPclient.subtitle(player, {"Pentru a vinde pestele du-te la orice magazin"})
            end
        end
    end
end)

registerCallback('hasRod', function(player)
    local user_id = vRP.getUserId(player)

    for _, rod in pairs(fishingRods) do
        if vRP.hasItem(user_id, rod) then
            return rod
        end
    end

    return false
end)

registerCallback("hasItemAmount", function(player, item, amm, take)
    local user_id = vRP.getUserId(player)
    if user_id then

        local itmAmount = vRP.getInventoryItemAmount(user_id, item)
        if item == "momeala" then
            catchFishCooldown[user_id] = os.time() + 3
        end

        if take then
            return vRP.removeItem(user_id, item, amm)
        end
        return (itmAmount >= amm)
    end
    
    return false
end)

registerCallback("cautaMomeala", function(player)
    local user_id = vRP.getUserId(player)

    local job = exports["vrp_jobs"]:hasJob(user_id, "Pescar")
    if not job then return end

    math.randomseed(os.time() * GetGameTimer() * user_id)
    local sansa = math.random(1, 6)

    if sansa <= 3 then
        return vRP.giveItem(user_id, "momeala", sansa, false, false, false, 'Fisher Job') and true, sansa
    end
end)

local loadPrice = 300
RegisterServerEvent("work-fisher:buyLoad", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if player and user_id then
        local job = exports["vrp_jobs"]:hasJob(user_id, "Pescar")
        if job then
            vRP.prompt(player, "Pescar", "Cata momeala vrei sa cumperi? <br><br>Pret momeala: $"..loadPrice.."/bucata", false, function(amm)
                amm = tonumber(amm)

                if amm then
                    if vRP.canCarryItem(user_id, "momeala", amm) then
                        if vRP.tryFullPayment(user_id, math.floor(loadPrice*amm), false, false, "Cayo Store") then
                            vRP.giveItem(user_id, "momeala", amm, false, false, false, 'Magazin Momeala')
                        else
                            vRPclient.notify(player, {"Nu ai destui bani !", "error"})
                        end
                    else
                        vRPclient.notify(player, {"Buzunarele sunt pline cu momeala !", "error"})
                    end
                end
            end)
        else
            vRPclient.notify(player, {"Nu esti un Pescar !", "error"})
        end
    end
end)

registerCallback('buyLoadFisher', function(player)
    local user_id = vRP.getUserId(player)
    local job = exports["vrp_jobs"]:hasJob(user_id, "Pescar")
    if not job then
        return 'Nu esti un Pescar!'
    end

    local amount = promise.new()
    vRP.prompt(player, "Pescar", "Cata momeala vrei sa cumperi? <br><br>Pret momeala: $"..loadPrice.."/bucata", false, function(amm)
        amount:resolve(tonumber(amm))
    end, true)
    local amount = Citizen.Await(amount)

    if not amount then
        return 'Nu ai introdus o cantitate!'
    end

    if vRP.canCarryItem(user_id, 'momeala', amount) then
        if vRP.tryFullPayment(user_id, math.floor(loadPrice*amount), false, false, "Cayo Store") then
            vRP.giveItem(user_id, "momeala", amount, false, false, false, 'Magazin Momeala')
            return 'Ai cumparat '..amount..' momeala! Te mai pot ajuta cu altceva?'
        else
            return 'Nu ai destui bani!'
        end
    end
end)

RegisterServerEvent('vrp_fisher:sellFish', function()
    local player = source
    local user_id = vRP.getUserId(player)
    
    local job = exports["vrp_jobs"]:hasJob(user_id, "Pescar")
    if not job then return end

    local choices = {}
    local userFish = vRP.getItemsByType(user_id, "fish")
  
    for _, data in pairs(userFish) do
        local price = allFish[data.item].price * tonumber(data.weight)

        table.insert(choices, {data.label.." - $"..price, {data.item, data.label, data.amount, price, data.weight}})
    end

    if next(choices) then
        table.insert(choices, {'Vinde tot pestele', 'allFish'})

        vRP.selectorMenu(player, "Vinde pestele", choices, function(fish)
            if not fish then return end

            if fish == 'allFish' then
                for _, data in pairs(choices) do
                    if type(data[2]) == 'table' then
                        local item, name, amount, totPrice, weight = table.unpack(data[2])

                        if vRP.removeItem(user_id, item, amount, {weight = weight}) then
                            if amount > 1 then
                                name = name.." x"..amount
                                totPrice = totPrice * amount
                            end
                            vRP.giveMoney(user_id, totPrice, "Fisher - "..name)
                        end
                    end
                end
            else
                local item, name, amount, totPrice, weight = table.unpack(fish)
    
                if vRP.removeItem(user_id, item, amount, {weight = weight}) then
                    vRP.giveMoney(user_id, totPrice, "Fisher - "..name)
                end
            end
        end)
    end
end)