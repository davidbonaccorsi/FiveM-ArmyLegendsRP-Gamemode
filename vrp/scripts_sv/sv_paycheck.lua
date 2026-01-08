
local cfg = {
	jobPaycheck = 1500,

	vippaycheck = { -- [vipLevel] = paycheck
		[1] = 15000,
		[2] = 30000,
	},

	vipDiamondTax = 0.5, -- vip2 plateste doar 70% din impozit

	discordPaycheck = 3500,

	houseInteriors = {
		['nice'] = 7500,
        ['trevor'] = 7500,
        ['lester'] = 7500,
        ['mansion'] = 12500,
        ['kinda_nice'] = 10000,

        ['app1'] = 12500,
        ['app2'] = 12500,
        ['app3'] = 12500,

        ['sh1'] = 15000,
        ['sh2'] = 15000,
        ['sh3'] = 15000
	},

	paydayDuration = 3600 -- secunde
}

local sleeping = {}

RegisterServerEvent("housing:startSleeping")
AddEventHandler("housing:startSleeping", function()
	local player = source
	sleeping[player] = os.time()
end)

RegisterServerEvent("housing:stopSleeping")
AddEventHandler("housing:stopSleeping", function()
	local player = source
	sleeping[player] = nil
end)

function vRP.isUserSleeping(player)
	return sleeping[player] or false
end


local VIPMISSING = "https://discord.com/api/webhooks/1251911007539040317/EYC3XY6ydSUy437O5l6_G3fjSw3fhpUKUrsgBBdNDKoOMqn9rIbLa5vLP_5BHWu_sr6F"
local function giveSalary(user_id)
	local player = vRP.getUserSource(user_id)
	if player ~= nil and user_id then

		if not vRP.isInAdminJail(user_id) then
			local factionPayday = 0
			local jobPayday = 0
			local theFaction = ""

			local gainXp = math.random(1, 5)
			
			if vRP.hasUserFaction(user_id) then
				local theFaction = vRP.getUserFaction(user_id) or ""
				local theRank = vRP.getFactionRank(user_id) or ""
				local thePay = vRP.getFactionRankSalary(theFaction, theRank) or 0

				local fType = vRP.getFactionType(theFaction)

				if fType ~= "Mafie" and fType ~= "Gang" then
					gainXp = gainXp + math.random(10, 25)
				end

				if thePay > 0 then
					factionPayday = thePay
				end
			end
			local userJob = exports["vrp_jobs"]:hasJob(user_id)

			if userJob then
				jobPayday = cfg.jobPaycheck
			end

			local level = vRP.getLevel(user_id)
			
			jobPayday = math.floor(jobPayday + (((level/3)*jobPayday)/50))
			factionPayday = math.floor(factionPayday + (((level/3)*factionPayday)/50))

			local vipLvl = vRP.getUserVipRank(user_id) or 0
		
			if not sleeping[player] or (sleeping[player] and os.time() - sleeping[player] < 600) then

				if factionPayday > 0 or jobPayday > 0 then
					vRP.giveBankMoney(user_id, factionPayday + jobPayday, "Payday")
				end
				
				vRPclient.notify(player, {"Ai primit payday $"..vRP.formatMoney(jobPayday + factionPayday)})
				vRP.giveXp(user_id, gainXp)

				
				if vipLvl > 0 then
					local vmoney = cfg.vippaycheck[vipLvl] or 0
					vRP.giveBankMoney(user_id, vmoney, "Vip Payday")
					vRPclient.notify(player, {"VIP Payday: "..vRP.formatMoney(vmoney)})

					if not exports.vrp:IsRolePresent(player, 1248614631962837073) and vipLvl == 1 then
						PerformHttpRequest(VIPMISSING, function(err, text, headers) end, 'POST', json.encode({
							username = "VIP MISSING", 
							content = "||@1213941926169149471 @1213941432214102046|| ["..GetPlayerName(player).."]["..user_id.."] Acestui player ii lipseste gradul de Prime 1 pe discord."
						}), { ['Content-Type'] = 'application/json' })
					end

					if not exports.vrp:IsRolePresent(player, 1248614654997958719) and vipLvl == 2 then
						PerformHttpRequest(VIPMISSING, function(err, text, headers) end, 'POST', json.encode({
							username = "VIP MISSING", 
							content = "||@1213941926169149471 @1213941432214102046|| ["..GetPlayerName(player).."]["..user_id.."] Acestui player ii lipseste gradul de Prime Platinum pe discord."
						}), { ['Content-Type'] = 'application/json' })
					end
				end

				
				if vRP.usersData[user_id].bonusDiscord then
					vRP.giveBankMoney(user_id, cfg.discordPaycheck, "Discord Activity Bonus")
					vRPclient.notify(player, {"Discord Activity bonus: "..vRP.formatMoney(cfg.discordPaycheck)})
				end

				if vRP.getUserHoursPlayed(user_id) > 100 then

					getUserVehTax(user_id, function(totalTax)

						if vipLvl == 2 then
							totalTax = math.ceil(totalTax * cfg.vipDiamondTax)
						end

						if vRP.tryFullPayment(user_id, totalTax, false, true, "Intretinere auto") then
							vRPclient.notify(player, {"Intretinere Auto: -$"..vRP.formatMoney(totalTax)})
						else
							local totalMoney = math.ceil(vRP.getMoney(user_id) + vRP.getBankMoney(user_id))
							if vRP.tryFullPayment(user_id, totalMoney, false, true, "Intretinere auto") then
								vRPclient.notify(player, {"Intretinere Auto: -$"..vRP.formatMoney(totalTax)})
							end
						end
					end)

					local houseCount, userHouses = exports['playerhousing']:getUserHouses(user_id)

					if houseCount > 0 then

						local houseTaxPrice = 0

						local msg = "Impozit Case"

						for houseId, data in pairs(userHouses) do
							houseTaxPrice = houseTaxPrice + (cfg.houseInteriors[data.class] or 0)

							local showPrice = (cfg.houseInteriors[data.class] or 0)
							if vipLvl == 2 then
								showPrice = math.ceil(showPrice * cfg.vipDiamondTax)
							end
							msg = msg.."\nCasa cu NR. "..houseId..": $"..vRP.formatMoney(showPrice)
						end

						if vipLvl == 2 then
							-- vip2 plateste doar 70% din impozit
							houseTaxPrice = math.ceil(houseTaxPrice * cfg.vipDiamondTax)
						end

						if vRP.tryFullPayment(user_id, houseTaxPrice, false, true, "Taxa case") then
							vRPclient.notify(player, {msg})
						else
							local totalMoney = math.ceil(vRP.getMoney(user_id) + vRP.getBankMoney(user_id))
							if vRP.tryFullPayment(user_id, totalMoney, false, true, "Taxa case") then
								vRPclient.notify(player, {msg})
							end
						end

					end
				else
					vRPclient.notify(player, {"Esti scutit de impozite deoarece ai sub 100 de ore jucate"})
				end
			else

				if factionPayday > 0 or jobPayday > 0 then
					local sleepPayday = math.floor((factionPayday + jobPayday)*0.1)
					vRP.giveBankMoney(user_id, sleepPayday, "Payday")
					vRPclient.notify(player, {"Ai primit payday $"..vRP.formatMoney(sleepPayday)})
				end

				if vRP.usersData[user_id].bonusDiscord then
					vRP.giveBankMoney(user_id, cfg.discordPaycheck, "Discord Activity Bonus")
					vRPclient.notify(player, {"Discord Activity bonus: "..vRP.formatMoney(cfg.discordPaycheck)})
				end

				vRP.giveXp(user_id, 1)

				if vipLvl > 0 then
					local vmoney = math.floor((cfg.vippaycheck[vipLvl] or 0) * 0.1)
					vRP.giveBankMoney(user_id, vmoney, "Vip Payday")
					vRPclient.notify(player, {"VIP Payday: "..vRP.formatMoney(vmoney)})
				end

			end

			if vRP.getUserAdminLevel(user_id) > 0 then
				local user = vRP.getUser(user_id)
				local smoney = math.random(100,500) * (user.paydayTk or 0)

				if smoney > 0 then
					vRPclient.msg(player, {"^1Staff Payday: ^2$"..vRP.formatMoney(smoney)})
					vRP.giveBankMoney(user_id, smoney, "Staff Payday")
					user.paydayTk = 0
				end
			end

		else
			vRPclient.notify(player, {"Esti in Admin Jail si nu ai primit payday-ul!"})
		end
	end
end

local thePaydayTime = os.time() + cfg.paydayDuration

function paydayCheck()

	Citizen.CreateThread(function()
		SetTimeout(5000, paydayCheck)
	end)
	

	if os.time() >= thePaydayTime then
		thePaydayTime = os.time() + cfg.paydayDuration
		Citizen.CreateThread(function()
			local users = vRP.getUsers()
			for user_id, player in pairs(users) do
				giveSalary(user_id)
				Citizen.Wait(150)
			end
		end)
		TriggerEvent("vRP:onPayday")
	end
end

paydayCheck()

RegisterCommand("setpayday", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 5 then
		local durr = 60
		if args[1] then durr = tonumber(args[1]) end

		thePaydayTime = os.time() + durr

		vRPclient.sendInfo(player, {"Ai setat urmatorul payday in "..durr.." secunde"})
	else
		vRPclient.noAccess(player)
	end
end)

RegisterCommand("getpayday", function(player)
	local granted = (player == 0)
	if not granted then
		local user_id = vRP.getUserId(player)
		granted = vRP.getUserAdminLevel(user_id) >= 5
	end

	if granted then
		local remainingSec = thePaydayTime - os.time()
		if player == 0 then
			print("PayDay remaining time: "..math.floor(remainingSec / 60).." minutes "..(remainingSec % 60).." seconds")
		else
			vRPclient.msg(player, {"^5Paycheck: ^7There are ^5"..math.floor(remainingSec / 60).." minutes "..(remainingSec % 60).." seconds^7 remaining until payday."})
		end
	else
		vRPclient.noAccess(player)
	end
end)