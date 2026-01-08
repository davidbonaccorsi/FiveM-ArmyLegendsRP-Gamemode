local lang = vRP.lang

local flowLimit = 5000

local playerMoney = {}

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

-- load config
local cfg = module("cfg/money")

local function calculatePercentage(percentage, number)
	return math.floor((number * percentage) / 100)
end

-- API

-- get money
-- cbreturn nil if error
function vRP.getMoney(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	
	if tmp and tmp.userMoney then
		return tmp.userMoney.wallet
	else
		return 0
	end
end

-- set xzCoins
function vRP.setCoins(user_id,value)
	local playerMoney = vRP.usersData[user_id].userMoney

	if(playerMoney)then
		playerMoney.coins = value
	end

	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userMoney.coins'] = value}}})

	-- update client display
	local source = vRP.getUserSource(user_id)
	if source then
  		TriggerClientEvent("vrp-hud:updateMoney", source, vRP.getMoney(user_id), vRP.getBankMoney(user_id), value)
	end
end

function vRP.tryCoinsPayment(user_id, amount, from, notify)
	local coins = tonumber(vRP.getCoins(user_id))
	local player = vRP.getUserSource(user_id)
	if tonumber(amount) <= coins and tonumber(amount) > 0 then
		vRP.setCoins(user_id, coins-amount)

		vRP.createLog(user_id, {name = GetPlayerName(player), amount = amount, from = from}, "LegendCoinsPayment")

		if notify then
			vRPclient.notify(player, {"Ai platit "..amount.." Coins", "success"})
		end
		return true
	end

	if notify then
		vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai "..amount.." Coins", "error"})
	end
	return false
end


-- get xzCoins
-- cbreturn nil if error
function vRP.getCoins(user_id)
	local playerMoney = vRP.usersData[user_id].userMoney

	if(playerMoney)then
		return playerMoney.coins
	else
		return 0
	end
end

function vRP.getXZCoins(user_id)
	return vRP.getCoins(user_id)
end

function vRP.getDiamonds(user_id)
	return vRP.getCoins(user_id)
end

-- set money
function vRP.setMoney(user_id, value)
	if tonumber(value) >= 0 then
		local playerMoney = vRP.usersData[user_id].userMoney
		if(playerMoney)then
			playerMoney.wallet = value
		end
		if tonumber(value) > 5000000 then
			if vRP.getUserHoursPlayed(user_id) < 25 then
				if not vRP.hasGroup(user_id, "sponsors") then
					vRP.ban(user_id, "Tentativa de money exploit", false, 0)
				end
			end
		end
		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userMoney.wallet'] = tonumber(value)}}})
	end

	-- update client display
	local source = vRP.getUserSource(user_id)
	if source then
		TriggerClientEvent("vrp-hud:updateMoney", source, value, vRP.getBankMoney(user_id), vRP.getCoins(user_id))
	end
end


function vRP.getTransferLimit(user_id)
		if vRP.getUserHoursPlayed(user_id) < 10 then
			return 5000
		end
		return 500000
end

-- try a payment
-- return true or false (debited if true)
function vRP.tryPayment(user_id,amount,notify,from)
	if amount then
		if amount == 0 then return true end
		amount = math.floor(amount)
		local money = vRP.getMoney(user_id)
		if (money >= amount) and (amount >= 0) then
			vRP.setMoney(user_id,money-amount)
			--if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Ai platit ~g~$"..amount}) end
			TriggerClientEvent('vrp-hud:showMoneyFlow', vRP.getUserSource(user_id), amount, '-')
			if from then
				vRP.createLog(user_id, {amount = amount, from = from, method = "cash"}, "MoneyPayment")
				vRP.flowMoney({user_id = user_id,wallet = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id), type = "give", into = "cash", time = os.time(), amount = amount, from = from})
			end
			return true
		else
			if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai $"..vRP.formatMoney(amount), "error"}) end
			return false
		end
	end
end

function vRP.tryBankPayment(user_id,amount,notify,from,bankruptToo)
	if amount then
		if amount == 0 then return true end
		amount = math.floor(amount)
		local money = vRP.getBankMoney(user_id)
		if bankruptToo or ((money >= amount) and (amount >= 0)) then
			vRP.setBankMoney(user_id,money-amount)
			--if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Ai platit ~g~$"..amount}) end
			TriggerClientEvent('vrp-hud:showMoneyFlow', vRP.getUserSource(user_id), amount, '-')
			if from then
				vRP.createLog(user_id, {amount = amount, from = from, method = "bank"}, "MoneyPayment")
				vRP.flowMoney({user_id = user_id,wallet = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id), type = "give", into = "bank", time = os.time(), amount = amount, from = from})
			end
			return true
		else
			if notify then vRPclient.notify(vRP.getUserSource(user_id), {"Nu ai $"..vRP.formatMoney(amount), "error"}) end
			return false
		end
	end
end

local flowStack = {}

-- give money
function vRP.giveMoney(user_id,amount,from)
	local money = vRP.getMoney(user_id)
	if (tonumber(amount) or 0) < 0 then amount = 0 end

	amount = math.floor(tonumber(amount))
	
	vRP.setMoney(user_id,money+amount)

	if from then
		vRP.createLog(user_id, {amount = amount, from = from}, "MoneyReward")
		vRP.flowMoney({user_id = user_id,wallet = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id), type = "receive", into = "cash", time = os.time(), amount = amount, from = from})
	end
	TriggerClientEvent('vrp-hud:showMoneyFlow', vRP.getUserSource(user_id), amount, '+')
end

function vRP.giveJobMoney(user_id, amount, from, xp)
	local boost = vRP.giveJobBoostMoney(user_id, amount) or 0
	if boost > 0 then
		amount = amount + boost
	end

	vRP.giveMoney(user_id, amount, "Job "..from)
	local xpAmm = xp or math.random(1, 3)
	vRP.giveXp(user_id, xpAmm, false)
	vRPclient.notify(vRP.getUserSource(user_id), {"Ai primit $"..vRP.formatMoney(amount).."\nAi acumulat "..xpAmm.." XP"})
	
	vRP.createLog(user_id, {amount = amount, from = from, name = GetPlayerName(vRP.getUserSource(user_id))}, "JobEarnings")
	vRP.createLog(user_id, {amount = amount, from = "Job "..from}, "MoneyReward")

end

-- give xzCoins
function vRP.giveCoins(user_id, amount, notif, from)
	local xzCoins = vRP.getCoins(user_id)
	if notif then
		vRPclient.notify(vRP.getUserSource(user_id), {"Ai primit "..amount.." Coins"})
	end
	vRP.setCoins(user_id,xzCoins+amount)
	vRP.createLog(user_id, {amount = amount, from = from}, "LegendsCoinsReward")
end

-- get bank money
function vRP.getBankMoney(user_id)
	local tmp = vRP.getUserTmpTable(user_id)
	
	if tmp and tmp.userMoney then
		return tmp.userMoney.bank
	else
		return 0
	end
end

-- set bank money
function vRP.setBankMoney(user_id,value)
	if (tonumber(value) or 0) >= 0 then
		local playerMoney = vRP.usersData[user_id].userMoney
		if(playerMoney)then
			playerMoney.bank = value
		end
		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userMoney.bank'] = parseInt(value)}}})
		local source = vRP.getUserSource(user_id)
	    if source then
	    	TriggerClientEvent("vrp-hud:updateMoney", source, vRP.getMoney(user_id), value, vRP.getCoins(user_id))
	    end
	end
end

function vRP.flowMoney(tbl)
	table.insert(flowStack, tbl)
	if #flowStack >= 10 then
		exports.mongodb:insert({collection = "cashFlow", documents = flowStack})
		flowStack = {}
	end 
end

-- give bank money
function vRP.giveBankMoney(user_id,amount,from)
	if amount > 0 then

		amount = math.floor(amount)

		local money = vRP.getBankMoney(user_id)
		vRP.setBankMoney(user_id,money+amount)

		if from then
			vRP.createLog(user_id, {amount = amount, from = from}, "MoneyReward")
			vRP.flowMoney({user_id = user_id, type = "receive", wallet = vRP.getMoney(user_id), bank = vRP.getBankMoney(user_id),into = "bank", time = os.time(), amount = amount, from = from})
		end
	end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function vRP.tryWithdraw(user_id,amount,tax)
	local money = vRP.getBankMoney(user_id)
	if amount > 0 and money >= amount then
		vRP.tryBankPayment(user_id,amount,false,'Extragere Bancara')

		if tax then
			local reduce = calculatePercentage(10, amount)
			local vipRank = vRP.getUserVipRank(user_id)
	
			if vipRank > 1 then
				reduce = calculatePercentage(5, amount)	
			end

			amount = math.floor(amount - reduce)
		end
		vRP.giveMoney(user_id,amount, 'Extragere Bancara')
		return true
	else
		return false
	end
end

-- try a deposit
-- return true or false (deposited if true)
function vRP.tryDeposit(user_id,amount)
	if amount > 0 and vRP.tryPayment(user_id,amount,false,'Depozit Bancar') then
		vRP.giveBankMoney(user_id,amount,'Depozit Bancar')
		return true
	else
		return false
	end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function vRP.tryFullPayment(user_id, amount, notify, reversed, from)
	if amount then
		if not reversed then
			local money = vRP.getMoney(user_id)
			if money >= amount and (amount >= 0) then -- enough, simple payment
				return vRP.tryPayment(user_id, amount, notify, "Full Payment ("..from..")")
			else  -- not enough, withdraw -> payment
				if vRP.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
					return vRP.tryPayment(user_id, amount, notify, "Full Payment ("..from..")")
				end
			end
		else
			local money = vRP.getBankMoney(user_id)
			if money >= amount and (amount >= 0) then -- enough, simple payment
				return vRP.tryBankPayment(user_id, amount, notify, "Full Payment ("..from..")")
			else  -- not enough, withdraw -> payment
				if vRP.tryDeposit(user_id, amount-money) then -- withdraw to complete amount
					return vRP.tryBankPayment(user_id, amount, notify, "Full Payment ("..from..")")
				end
			end
		end
	end

	return false
end

registerCallback("canFullPay", function(player, ...)
	local user_id = vRP.getUserId(player)
	return vRP.tryFullPayment(user_id, ...)
end)


function vRP.tryMurdarPayment(user_id, amount, from)
	local murdari = vRP.getInventoryItemAmount(user_id, "dirty_money")
	if murdari >= amount then
		return vRP.removeItem(user_id, 'dirty_money', amount)
	elseif murdari > 0 then
		vRP.removeItem(user_id, 'dirty_money', murdari)
		return vRP.tryFullPayment(user_id, amount-murdari, false, false, "Murdar Payment ("..from..")")
	else
		return vRP.tryFullPayment(user_id, amount, false, false, "Murdar Payment ("..from..")")
	end

	return false
end

AddEventHandler("vRP:playerJoin",function(user_id, source, name, dbdata)
	if not dbdata.userMoney then
		vRP.usersData[user_id].userMoney = {bank = cfg.open_bank, wallet = cfg.open_wallet, coins = cfg.open_xzCoins}
		exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {
			['$set'] = {
				['userMoney.wallet'] = cfg.open_wallet,
				['userMoney.bank'] = cfg.open_bank,
				['userMoney.coins'] = cfg.open_xzCoins
			}
		}})
	end
end)


-- money hud
AddEventHandler("vRP:playerSpawn", function(user_id, source)
	Citizen.Wait(5500)
	TriggerClientEvent("vrp-hud:updateMoney", source, vRP.getMoney(user_id), vRP.getBankMoney(user_id), vRP.getCoins(user_id))
end)

-- add player give money to main menu
vRP.registerActionsMenuBuilder("nearply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  	local choices = {}

	  	choices["Ofera bani"] = {function()
			vRPclient.getNearestPlayer(player, {2}, function(nPlayer)
				if nPlayer then
					vRP.prompt(player, "GIVE MONEY", false, false, function(amount)
						amount = tonumber(amount)
	
						if amount then
							local nUser = vRP.getUserId(nPlayer)
							
							if nUser then
								if vRP.tryPayment(user_id, amount, true, "Player ("..GetPlayerName(nPlayer)..")") then
									if vRP.isPossibleMoneyCheat(user_id, amount) then
										return vRP.ban(user_id,'Money Exploit Detected [vRP:gMaxMoney]',false,0)
									end
	
									vRP.giveMoney(nUser, amount, "Player ("..GetPlayerName(player)..")");
									
									
									vRPclient.notify(nPlayer, {"Ai primit $"..vRP.formatMoney(amount)})
									vRPclient.notify(player, {"Ai oferit $"..vRP.formatMoney(amount)})
								end
							end
						end
					end)
				else
					vRPclient.notify(player, {"Niciun jucator in preajma!", "error"})
				end
			end)
		end, "pay.svg"}
  
		add(choices)
	end
end)

registerCallback('canPay', function(player, amount, loc)
	local user_id = vRP.getUserId(player)

	if vRP.tryPayment(user_id, amount, false, loc or "Unknown") then
		if loc == 'Frizerie' or loc == 'Tattoo Shop' then
		    exports.vrp:achieve(user_id, loc, 1)
		end

		return true
	end
end)

function vRP.isPossibleMoneyCheat(user_id, value)
	if tonumber(value) > 5000000 then
		if vRP.getUserHoursPlayed(user_id) < 25 then
			if not vRP.hasGroup(user_id, "sponsors") then
				return true
			end
		end
	end
	return false
end

function tvRP.tryPayment(amount)
	local amm = tonumber(amount)

	if amm then
		local player = source
		local user_id = vRP.getUserId(player)

		if vRP.getMoney(user_id) - amm >= 0 then
			return vRP.tryPayment(user_id, amm)
		end
	end
	return false
end

function tvRP.getMoney()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		return vRP.getMoney(user_id)
	end
	return 0
end

function tvRP.getBankMoney()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		return vRP.getBankMoney(user_id)
	end
	return 0
end

function tvRP.getCoins()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id then
		return vRP.getCoins(user_id)
	end
	return 0
end