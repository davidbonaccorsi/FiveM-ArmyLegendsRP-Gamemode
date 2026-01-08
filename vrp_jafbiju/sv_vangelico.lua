local Tunnel = module("vrp", "lib/Tunnel")

local vRP = exports.vrp:link()
local vRPclient = Tunnel.getInterface("vRP", "vrp_biju")

local allWins = {
    {
        item = 'colier_diamante',
        name = "Colier cu Diamante",
        price = 75000,
        chance = 2
    }, {
        item = 'poseta_diamante',
        name = "Poseta cu Diamante",
        price = 3500,
        chance = 15
    }, {
        item = 'cercei_diamante',
        name = "Cercei cu diamante",
        price = 3250,
        chance = 25
    }, {
        item = 'bratare_diamante',
        name = "Bratara cu diamante",
        price = 3000,
        chance = 40
    }, {
        item = 'diadema_diamante',
        name = "Diadema cu diamante",
        price = 2500,
        chance = 60
    }, {
        item = 'inel_diamante',
        name = "Inel cu diamante",
        price = 2750,
        chance = 90
    }
}

local maxChance = 0


for id, itmdata in pairs(allWins) do
    if itmdata.chance > maxChance then
        maxChance = itmdata.chance
    end -- get max chance

    vRP.defInventoryItem(itmdata.item, itmdata.name, "Un obiect furat de la bijuterie", false, 0.5)
end

local function getRandWinItem()
    math.randomseed(os.time())
    local r = math.random(1, maxChance)

    for id, itmdata in pairs(allWins) do
        if r <= itmdata.chance then
            return {id = id,name = itmdata.name}
        end
    end
end

local lastRobbery
local activeRobbery = false
local robSecret = {}

local minCops = 8
local minLevel = 7

RegisterServerEvent("vrp-biju:startRobbing")
AddEventHandler("vrp-biju:startRobbing", function()
	local player = source
	local user_id = vRP.getUserId(player)

	if (lastRobbery or 0) <= os.time() then

        local cops = 0
        vRP.doFactionFunction("Politie", function(src)
            cops = cops + 1
        end)

        if cops >= minCops then
            if vRP.hasLevel(user_id, minLevel) then

                lastRobbery = os.time() + 1800 -- 30 minute cooldown
                activeRobbery = true

                TriggerClientEvent("vrp-biju:setState", -1, false)

                local newSecret = math.random(1, user_id) + ((os.time() % 60) + 1)
                robSecret[user_id] = newSecret

                TriggerClientEvent("vrp-biju:sendCoords", player, {newSecret})

                TriggerEvent("vrp-wanted:addWanted", 3, "Jaf la Bijuterii")
                
                return vRP.doFactionFunction("Politie", function(src)
                    vRPclient.subtitle(src, {"Magazinul de bijuterii este ~r~JEFUIT~w~ chiar acum !", 5})
                end)
            end
        else
            vRPclient.notify(player, {"Trebuie sa fie minim "..minCops.." politisti online pentru a jefuii bijuteria", "error"})
        end
    else
        vRPclient.notify(player, {"Trebuie sa mai astepti "..(lastRobbery - os.time()).." (de) secunde inainte de a jefuii iar bijuteria!", "error"})
    end
end)

RegisterServerEvent("vrp-biju:cancelRob")
AddEventHandler("vrp-biju:cancelRob", function()
	local player = source
	local user_id = vRP.getUserId(player)

	robSecret[user_id] = nil
    playerWins[user_id] = nil
	activeRobbery = false
	TriggerClientEvent("vrp-biju:setState", -1, not activeRobbery)
end)

local playerWins = {}
RegisterServerEvent("vrp-biju:tryToRob", function(cpData)
    local player = source
	local user_id = vRP.getUserId(player)

    if not robSecret[user_id] or (robSecret[user_id] ~= cpData[1]) then
		DropPlayer(player, "[AntiCheat] Injection detected")
    else

        local wins, max = {}, math.random(3, 5)
        for i=1, max do
            local win = getRandWinItem()
            table.insert(wins, win)
            Citizen.Wait(100)
        end
        
        playerWins[user_id] = wins
        TriggerClientEvent("vrp-biju:robSuccess", player, wins)
    end
end)

RegisterServerEvent("vrp-biju:robCoords")
AddEventHandler("vrp-biju:robCoords", function(cpData)
	local player = source
	local user_id = vRP.getUserId(player)

	if not robSecret[user_id] or (robSecret[user_id] ~= cpData[1]) then
		DropPlayer(player, "[AntiCheat] Injection detected")
    else

        for k, theWin in pairs(playerWins[user_id] or {}) do
            local amt = 1
            local win = "biju_"..theWin.name
            
            if vRP.canCarryItem(user_id, win, amt) then
                vRP.giveItem(user_id, win, amt, false, false, false, 'Vangelico Rob')
            else
                vRPclient.notify(player, {"Nu ai destul spatiu pentru a cara "..theWin.name, "error"})
            end
        end
        playerWins[user_id] = nil
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source)
	TriggerClientEvent("vrp-biju:setState", source, not activeRobbery)
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if robSecret[user_id] then
		robSecret[user_id] = nil
	end
    if playerWins[user_id] then
        playerWins[user_id] = nil
    end
end)

RegisterServerEvent("vrp_vangelico:sellJews")
AddEventHandler("vrp_vangelico:sellJews", function()
    local player = source
    local user_id = vRP.getUserId(player)
	vRP.buildActionsMenu("robseller", {user_id = user_id, player = player}, function(menu)
		menu.onclose = function(player) end

		menu['Vinde bijuterii'] = {function()
            Citizen.Wait(500)
            local choices = {}
            for id, itmdata in pairs(allWins) do
                local item = "biju_" ..itmdata.name
                local ammount = vRP.getInventoryItemAmount(user_id, item)
                if ammount > 0 then
                    local totPrice = ammount * itmdata.price
                    local itmName = itmdata.name
                    table.insert(choices, {itmName.." - $"..totPrice, {item, itmName, ammount, totPrice}})
                end
            end
    
            if next(choices) then
                vRP.selectorMenu(player, "Vinde bijuterii", choices, function(fish)
                    if fish then
                        local item, itmName, ammount, totPrice = table.unpack(fish)
                        if vRP.removeItem(user_id, item, amount) then
                            vRP.giveMoney(user_id, totPrice, "Vangelico Rob - "..itmName)
                        end
                    end
                end)
            else
                vRPclient.notify(player, {"Nu ai bijuterii sa imi vinzi.", "error"})
            end
        end, "diamond.svg"}

		if menu then
			vRP.openActionsMenu(player, menu)
		end
	end)
end)