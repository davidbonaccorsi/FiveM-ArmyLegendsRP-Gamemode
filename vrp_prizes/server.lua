local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vrp_prizes")

local spinPrice = 45000
local dmdPrice = 10

local carModel = "18performante"
local bikeModels = {"20r1"}

local superCars = {
	["shotaro"] = {70, "Shotaro"}
}

local userVehs = {}
local uVehs = {}

local function hasVeh(user_id, veh)
	if uVehs[user_id] then
		for _, v in pairs(uVehs[user_id]) do
			if v.vehicle == veh then
				return true
			end
		end
	end
	return false
end

local function canWinAtLeastASuperVeh(user_id)
	for veh, data in pairs(superCars) do
		if not hasVeh(user_id, veh) then
			return true
		end
	end
	return false
end


local function hasLuck(chance) -- percent%
    if chance >= 1 then
        return (math.random(1, 100) <= chance)
    elseif chance >= 0.1 and chance < 1.0 then
        return (math.random(1, 1000) <= (chance*10))
    else
        return (math.random(1, 10000) <= (chance*100))
    end
end

local scroollTime = 11700

local function setVipForOneWeek(user_id, vipLevel, days)
	local player = vRP.getUserSource(user_id)
	vRP.setUserVip(user_id, vipLevel)
	local expireTime = os.time() + (days *24*60*60)
	exports.vrp:updateUser(user_id, 'userVip', {
		expireTime = expireTime,
		vip = vipLevel,
	})
	vRP.createLog(user_id, {win = "VIP"..vipLevel.." - "..days.." days", name = GetPlayerName(player)}, "LuckyRoulette")
end

local function setGradeOneWeek(user_id, grade, days)
	local player = vRP.getUserSource(user_id)
	local expireTime = os.time() + (days *24*60*60)
	vRP.addUserGroup(user_id, grade, expireTime)
	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
		["$set"] = {
			["userGrades."..grade] = {grade = grade, expireTime = expireTime, time = os.time()}
		}
	}})
	vRP.createLog(user_id, {win = "Grade '"..grade.."' - "..days.." days", name = GetPlayerName(player)}, "LuckyRoulette")
end


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
end

local winTable = {
	--{"Prize Name", Sansa%, runOnWin(user_id)}
	{"VIP1", 15, function(user_id)
		if not vRP.isUserVip({user_id}) then
			Citizen.CreateThread(function()
				local days = math.random(5, 14)
				setVipForOneWeek(user_id, 1, days)
				Wait(scroollTime)
				TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "winSimple", 0.5)
				vRPclient.subtitle(vRP.getUserSource({user_id}), {
	    			"~b~Felicitari~w~: Ai castigat ~b~Prime ~w~ "..days.." zile!"
	    		})
	    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3Prime ^7 pentru "..days.." zile")
			end)			
			return true
		end
		return false
	end}, 
	{"VIP2", 9, function(user_id)
		if not vRP.isUserVip({user_id}) then
			Citizen.CreateThread(function()
				local days = math.random(5, 14)
				setVipForOneWeek(user_id, 2, days)
				Wait(scroollTime)
				TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "winSimple", 0.5)
				vRPclient.subtitle(vRP.getUserSource({user_id}), {
	    			"~b~Felicitari~w~: Ai castigat ~b~Prime Platinum ~w~ "..days.." zile!"
	    		})
	    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3Prime Platinum ^7 pentru "..days.." zile")
			end)			
			return true
		end
		return false
	end}, 
    {"Money1", 100, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "cashBing", 0.7)
    		local baniCastigati = math.random(15000, 20000)
    		vRP.giveMoney({user_id, baniCastigati, "Lucky Roulette"})
    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
    			"~g~Felicitari~w~: Ai castigat ~g~"..vRP.formatMoney({baniCastigati}).."~w~ !"
    		})
    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^2"..vRP.formatMoney({baniCastigati}).."$")
    	end)
    	return true
    end}, 
    {"Money2", 20, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "cashBing", 0.7)
    		local baniCastigatRuleta = math.random(40000, 150000)
    		vRP.giveMoney({user_id, baniCastigatRuleta, "Lucky Roulette"})
    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
    			"~g~Felicitari~w~: Ai castigat ~g~"..vRP.formatMoney({baniCastigatRuleta}).."~w~ !"
    		})
    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^2"..vRP.formatMoney({baniCastigatRuleta}).."$")
    	end)
    	return true
    end},
    {"Xenon", 8, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "winSimple", 0.5)
    		vRP.giveItem(user_id, 'premium_xenon', 1, false, false, false, 'Lucky Roulette')
    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
    			"~b~Felicitari~w~: Ai castigat un ~b~Xenon Premium ~w~!"
    		})
    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat un ^9Xenon ^7Premium")
    	end)
    	return true
    end},
    -- {"WeaponDealer", 4, function(user_id)
    -- 	if not vRP.hasPermission({user_id, "weapon.dealer"}) and not vRP.isUserPolitist({user_id}) and not vRP.isUserInFaction({user_id, "Smurd"}) then
	--     	Citizen.CreateThread(function()
	--     		Wait(scroollTime)
	--     		setGradeOneWeek(user_id, "Weapon Dealer", 2)
	--     		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "winSimple", 0.5)
	--     		vRPclient.subtitle(vRP.getUserSource({user_id}), {
	--     			"~b~Felicitari~w~: Ai castigat gradul de ~b~Weapon Dealer ~w~ pentru 2 zile !"
	--     		})
	--     		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3Weapon Dealer ^7pentru 2 zile")
	--     	end)
	--     	return true
	--     end
	--     return false
    -- end},
    {"Motocicleta", 0.05, function(user_id)
     	if not userVehs[user_id][2] then
     		userVehs[user_id][2] = true
		 	Citizen.CreateThread(function()
	     		Wait(scroollTime)
	     		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "horn1", 0.5)
	     		local bikeModel = bikeModels[math.random(1, #bikeModels)]
	     		local veh_name, _ = vRP.checkVehicleName(bikeModel)
	     		winVehicle(user_id, bikeModel, veh_name, "ds") -- aici se pune boat daca e barca
	     		vRPclient.subtitle(vRP.getUserSource({user_id}), {
	     			"~b~Felicitari~w~: Ai castigat o motocicleta: ~b~"..veh_name.." ~w~!"
	     		})
	     		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3Motocicleta "..veh_name)
	     	end)
	     	return true
		 end
		 return false
    end},
    {"Masina", 0.08, function(user_id)
		if not userVehs[user_id][1] then
			userVehs[user_id][1] = true
			Citizen.CreateThread(function()
	    		Wait(scroollTime)
	    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "horn2", 0.5)
	    		local veh_name, _ = vRP.checkVehicleName(carModel)
	    		winVehicle(user_id, carModel, veh_name)
	    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
	    			"~b~Felicitari~w~: Ai castigat o masina ~b~Limited Edition ~w~!"
	    		})
	    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat o masina limited edition ^1"..veh_name)
	    	end)
	    	return true
		end
		return false
    end},

    {"permisArma", 7, function(user_id)
    	if not vRP.hasPermission(user_id, "permis.arma") and not vRP.isUserPolitist(user_id) then
    		Citizen.CreateThread(function()
	    		Wait(scroollTime)
	    		local days = math.random(3, 10)
	    		setGradeOneWeek(user_id, "Permis Port Arma", days)
	    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "winSimple", 0.5)
	    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
	    			"~b~Felicitari~w~: Ai castigat ~b~Permis Port Arma ~w~ pentru "..days.." zile !"
	    		})
	    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3Permis Port Arma ^7pentru "..days.." zile")
	    	end)
    		return true
    	end
    	return false
    end},
	
    {"Coin", 4, function(user_id)
    	Citizen.CreateThread(function()
    		Wait(scroollTime)
    		TriggerClientEvent("vrp:playSound", vRP.getUserSource({user_id}), "horn2", 0.5)
    		local dmd = math.random(5, 10)
    		vRP.giveCoins({user_id, dmd, false, "Ruleta"})
    		vRPclient.subtitle(vRP.getUserSource({user_id}), {
    			"~b~Felicitari~w~: Ai castigat ~b~"..dmd.." Legend Coins ~w~!"
    		})
    		TriggerClientEvent("chatMessage", -1, "^3Lucky Roulette^7: "..GetPlayerName(vRP.getUserSource({user_id})).." a castigat ^3"..dmd.." Legend Coins")
    	end)
    	return true
    end}
}

local function daysToSecconds(days)
	return days*24*60*60
end

local function hasValueInArray (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

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

local function addOnePaymentLog(withDmd)
	local key = "prizes:moneyTimes"
	if withDmd then
		key = "prizes:dmdTimes"
	end

	exports.mongodb:updateOne({collection = "sData", query = {dkey = key}, update = {['$inc'] = {dvalue = 1}}})
end

RegisterServerEvent("prizes:doPayment")
AddEventHandler("prizes:doPayment", function(withDmd)
	local player = source
	local user_id = vRP.getUserId({player})
	if user_id then

		local payment = false

		if withDmd then
			payment = vRP.tryCoinsPayment({user_id, dmdPrice, "Ruleta", true})
		else
			payment = vRP.tryPayment({user_id, spinPrice, true, "Ruleta"})
		end

		if payment then

			addOnePaymentLog(withDmd)
			
			for _, win in pairs(winTable) do
				local hasChance = win[2]
				if withDmd then
					hasChance = hasChance + (hasChance * 0.3)
				end
				
				-- Definim un Array cu castigurile ce vor avea sanse injumatatite la jucatorii noi (sub 300 de ore jucate)
				local lowerChancesForNewcomers = {'Motocicleta', 'Masina'}
				
				-- Verificam daca castigul se afla in Array-ul definit mai sus
				if hasValueInArray(lowerChancesForNewcomers, win[1]) then
					-- Preluam Userul din Baza de Date
					-- Daca Userul are sub 300 de ore jucate, atunci sansele sale vor fi injumatatite
					exports.mongodb:findOne({collection = "users", query = {id = user_id}, options = {projection = {_id = 0, hoursPlayed = 1}}}, function(success, result)
						if result[1] then
							if (result[1]['hoursPlayed'] or 0) < 300 then
								hasChance = hasChance/2
							end
						end
					end)
				end
				
				if hasLuck(hasChance) then
					if win[3](user_id) then
						TriggerClientEvent("prizes:winSomething", player, win[1])
						if win[1] ~= "Coin" then
							vRP.createLog({user_id, {win = win[1], winner = GetPlayerName(player)}, "LuckyRoulette"})
						end
					end
				end
			end
		else
			vRPclient.notify(player, {"Nu ai destui bani la tine"})
			TriggerClientEvent("prizes:noMoney", player)
		end
	else
		vRPclient.notify(player, {"Ruleta este in mentenanta"})
	end
end)

local function initPlayer(player) -- blipid 617
	TriggerClientEvent("prizes:setPrice", player, vRP.formatMoney({spinPrice}), dmdPrice)

	local user_id = vRP.getUserId({player})

	local k = 0
	while not user_id do
		k = k + 1
		user_id = vRP.getUserId({player})
		if k >= 10 then
			DropPlayer(player, "A aparut o problema la autentificare !")
			break
		end
		Wait(1000)
	end
	if user_id then
		userVehs[user_id] = {}
		exports.mongodb:count({collection = "userVehicles", query = {id = user_id, vehicle = carModel}}, function(success, result)
			if result > 0 then
				userVehs[user_id][1] = true
			else
				userVehs[user_id][1] = false
			end
		end)
		userVehs[user_id][2] = false
		for _, bikeModel in pairs(bikeModels) do
			exports.mongodb:count({collection = "userVehicles", query = {id = user_id, vehicle = bikeModel}}, function(success, result)
				if result > 0 then
					userVehs[user_id][2] = true
				end
			end)
		end
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		initPlayer(player)

		vRPclient.addBlip(player, {"vRP:prizes", -1828.1492919922,-1192.7012939453,14.308885574341, 617, 26, "Lucky Roulette", 0.6})
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	userVehs[user_id] = nil
end)

AddEventHandler("onResourceStart", function(res)
	if GetCurrentResourceName() == res then
		Wait(1000)
		local users = vRP.getUsers({})
		for user_id, player in pairs(users) do
			initPlayer(player)
		end
	end
end)
