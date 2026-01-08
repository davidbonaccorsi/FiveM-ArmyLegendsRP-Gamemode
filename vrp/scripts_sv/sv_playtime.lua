
local readyFlips = {}
local collectFlips = {}

local finishVehicle = {"bmws", "BMW S1000 RR Limited"}

local function addOneVehicleLog()
	local key = "prizes:paydayWins"

	exports.mongodb:updateOne({collection = "sData", query = {dkey = key}, update = {['$inc'] = {dvalue = 1}}})
end

Citizen.CreateThread(function()
    local reset = false
    while true do
        local hour = tonumber(os.date("%H"))

        if hour == 0 then
            if not reset then
                reset = true
                readyFlips = {}
                collectFlips = {}

                TriggerClientEvent("vrp:sendNuiMessage", -1, {interface = "playtimeFlips", event = "readyToFlip", hide = true})
            end
        elseif reset then
            reset = false
        end
        Citizen.Wait(10000)
    end
end)

local function checkFlip(user_id, player)
    if readyFlips[user_id] and not collectFlips[user_id] then
        TriggerClientEvent("vrp:sendNuiMessage", player, {
            interface = "playtimeFlips",
            event = "readyToFlip"
        })
    end
end

AddEventHandler("vRP:onPayday", function()
    local users = vRP.getUsers()
    for k, v in pairs(users) do
        if not readyFlips[k] then
            readyFlips[k] = true
            checkFlip(k, v)
            Citizen.Wait(10)
        end
    end
end)

local function hasLuck(chance) -- percent%
    if chance >= 1 then
        return (math.random(1, 100) <= chance)
    elseif chance >= 0.1 and chance < 1.0 then
        return (math.random(1, 1000) <= (chance*10))
    else
        return (math.random(1, 10000) <= (chance*100))
    end
end


local scroollTime = 0

local winTable = {
	--{"Prize Name", "Prize Title", Sansa%, runOnWin(user_id)}
    {"Money1", "Bani", 100, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("sound:play", vRP.getUserSource(user_id), "cashBing", 0.7)
    		local monii = math.random(10000, 15000)
    		vRP.giveMoney(user_id, monii, "PaycheckFlips")
    		vRPclient.subtitle(vRP.getUserSource(user_id), {
    			"~g~Felicitari~w~: Ai castigat ~g~"..vRP.formatMoney(monii).."~w~ !"
    		})
    	end)
    	return true
    end}, 
    {"Money2", "Bani", 20, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("sound:play", vRP.getUserSource(user_id), "cashBing", 0.7)
    		local monii = math.random(50000, 75000)
    		vRP.giveMoney(user_id, monii, "PaycheckFlips")
    		vRPclient.subtitle(vRP.getUserSource(user_id), {
    			"~g~Felicitari~w~: Ai castigat ~g~"..vRP.formatMoney(monii).."~w~ !"
    		})
    	end)
    	return true
    end},

    {"Coin", "Legend Coins", 2, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("sound:play", vRP.getUserSource(user_id), "horn2", 0.5)
    		local dmd = math.random(2, 5)
    		vRP.giveCoins(user_id, dmd, false, "PaycheckFlips")
    		vRPclient.subtitle(vRP.getUserSource(user_id), {
    			"~g~Felicitari~w~: Ai castigat ~b~"..dmd.." Legend Coins ~w~!"
    		})
    	end)
    	return true
    end},

	{"Xenon", "Xenon Premium", 1, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("sound:play", vRP.getUserSource(user_id), "winSimple", 0.5)
    		vRP.giveInventoryItem(user_id, "premium_xenon", 1, false)
    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
    			"~b~Felicitari~w~: Ai castigat un ~b~Xenon Premium ~w~!"
    		})
    	end)
    	return true
    end}
}

Citizen.CreateThread(function()
	local function swapObj(tbl, i, j)
		local ax = tbl[i]
		tbl[i] = tbl[j]
		tbl[j] = ax
	end

	for i=1, #winTable-1 do
		for j=i+1, #winTable do
			if winTable[i][2] > winTable[j][2] then
				swapObj(winTable, i, j)
			end
		end
	end
end)

RegisterServerEvent("vrp-playtimef:getReminder", function()
    local player = source
    local user_id = vRP.getUserId(player)
    local user = vRP.getUser(user_id)

    if user_id and user then
        TriggerClientEvent("vrp:sendNuiMessage", player, {
            interface = "playtimeFlips",
            event = "reminder",
            flips = user.cardFlips or 0,
        })
    end
end)


local function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.mongodb:count({collection = "userVehicles", query = {carPlate = plate_number}}, function(success, result)
	  task({result})
	end)
end

local function winVehicle(user_id, vehicle, title, veh_type)
	if not veh_type then
		veh_type = "ds"
	end

	
	local carPlate = "RX00ERR"
	local function search()
		carPlate = vRP.generatePlateNumber()
	
		getIdentifierByPlateNumber(carPlate, function(onePlate)
			if not onePlate or onePlate ~= 0 then
				search()
			end
		end)
	end
	search()
	
	local newVehicle = {
		user_id = user_id,
		vehicle = vehicle,
		vtype = veh_type,
		name = title,
		carPlate = carPlate,
		state = 1,
	}

	exports.mongodb:insertOne({collection = "userVehicles", document = newVehicle})
	vRP.addCacheVehicle(user_id, newVehicle)
    addOneVehicleLog()

    Citizen.CreateThread(function()
        Citizen.Wait(3000)
        TriggerClientEvent("sound:play", vRP.getUserSource(user_id), "horn1", 0.5)
        vRPclient.subtitle(vRP.getUserSource(user_id), {
            "~b~Felicitari~w~: Ai castigat un vehicul ~b~Limited Edition ~w~!"
        })
    end)
end

RegisterCommand("paydayrolls", function(player, args)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) >= 5 then
		vRP.getSData("prizes:paydayWins", function(carTimes)
            local vehicle, title, veh_type = table.unpack(finishVehicle)
			vRPclient.msg(player, {
				"^6Payday Flips^7: "..title.." - ^1"..(carTimes or 0).." owners"
			})
		end)
	else
		vRPclient.noAccess(player)
	end
end)

RegisterServerEvent("vrp-playtimef:winSomething", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if readyFlips[user_id] and not collectFlips[user_id] then
		for _, win in pairs(winTable) do
			local hasChance = win[3]
			
			if hasLuck(hasChance) then
				if win[4](user_id) then
                    TriggerClientEvent("vrp:sendNuiMessage", player, {
                        interface = "playtimeFlips",
                        event = "winSomething",
                        win = win[1],
                        title = win[2]
                    })

					if win[1] ~= "Coin" then
						vRP.createLog(user_id, {win = win[1], name = GetPlayerName(player)}, "PaycheckFlips")
					end

                    local user = vRP.getUser(user_id)
                    user.cardFlips = (user.cardFlips or 0) + 1
                    
                    if user.cardFlips >= 60 then
                        local vehicle, title, veh_type = table.unpack(finishVehicle)

                        if not exports.vrp:isUserOwningVehicle(user_id, vehicle) then
                            winVehicle(user_id, vehicle, title, veh_type)
						else
							vRP.createLog(user_id, {win = win[1], name = GetPlayerName(player)}, "PaycheckFlipsCARERROR")
						end
                        user.cardFlips = 0
                    end
                    vRP.updateUser(user_id, "cardFlips", user.cardFlips)
					break
				end
			end
		end

        collectFlips[user_id] = true
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn, dbdata)
    if first_spawn then
        checkFlip(user_id, player)
    end
end)
