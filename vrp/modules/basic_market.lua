local markets = {}
local market_items = {}

local cfg = module("cfg/markets")
local market_types = cfg.market_types

local function isInTable(item, tbl)
	for _, value in pairs(tbl) do
		if value == item then
			return true
		end
	end
end

local function getMarketData(id)
	return markets[id]
end

exports("getMarketData", getMarketData)

exports("getUserMarketsCount", function(user_id)
	local i = 0

	for _, data in pairs(markets) do
		if data.owner and (data.owner == user_id) then
			i += 1
		end
	end

	return i
end)

exports('setMarketOwner', function(user_id, bizId)
	local market = getMarketData(bizId)

	if market then
		markets[bizId].owner = user_id;
		market.owner = user_id

		exports.mongodb:updateOne({
			collection = "markets",
			query = { id = bizId },
			update = {
				["$set"] = { owner = user_id, expireTime = os.time() + (86400 * 30) }
			}
		})
	end

	TriggerEvent("vrp-markets:setOwnerPhoneNr")
end)

local stockOrders = {}
local minStock = 100

Citizen.CreateThread(function()
	Citizen.Wait(31000)

	function getCorrectMarketOrder(bizId, items)
		local market = getMarketData(bizId)

		local order = {}
		local reward = 1

		if market then
			for item, data in pairs(items) do
				local itemName = vRP.getItemName(item)

				if itemName then
					order[item] = {
						label = itemName,
						amount = type(data) == "table" and data.amount or tonumber(data)
					}

					reward += market_items[market.type][item].biz_price
				end
			end
		end

		return { order = order, biz = bizId, reward = reward }
	end

	exports.mongodb:find({ collection = "market_orders" }, function(success, result)
		if not result then return end

		for _, data in pairs(result) do
			stockOrders[data.biz] = getCorrectMarketOrder(data.biz, data.order or {})
		end
	end)
end)

exports("getMarketStockOrders", function()
	return stockOrders
end)

exports("getMarketOrder", function(bizId)
	return stockOrders[bizId]
end)

exports("setMarketProvider", function(bizId, worker)
	if stockOrders[bizId] then
		stockOrders[bizId].worker = worker

		return true
	end
end)

exports("getMarketLoad", function(bizId)
	local loadCount = 0

	if stockOrders[bizId] then
		for _ in pairs(stockOrders[bizId].order or {}) do
			loadCount += 1
		end

		stockOrders[bizId].load = loadCount
	end

	return loadCount
end)


RegisterServerEvent("vrp-markets:setOwnerPhoneNr", function()
	if not markets then return 0 end;
	for _, data in pairs(markets) do
		if data.owner then
			local userIdentity = vRP.getIdentity(data.owner)
			if not userIdentity then return 0 end;
			markets[data.id].phoneNr = userIdentity.phone or 0;
			markets[data.id].ownerName = userIdentity.name .. " " .. userIdentity.firstname
		end
	end
	GlobalState.markets = markets
end)

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	exports.mongodb:find({ collection = "markets" }, function(success, result)
		if not result then return end
		for _, data in pairs(result) do
			markets[data.id] = data
			local time = os.time();
			if (data.owner and data.expireTime and time > data.expireTime) then
				exports.mongodb:update({
					collection = "markets",
					query = { owner = data.owner },
					update = {
						["$unset"] = { owner = 1, expireTime = 1 }
					}
				})
				markets[data.id].owner = nil;
			end

			if not data.owner or (data.owner and data.owner == 0) then
				if data.stocks then
					for item, amount in pairs(data.stocks) do
						markets[data.id].stocks[item] = 99
					end
				end
			end
		end
	end)

	RegisterCommand("tptomarket", function(player, args)
		local user_id = vRP.getUserId(player)

		if vRP.getUserAdminLevel(user_id) < 4 then
			vRPclient.noAccess(player)
			return
		end

		if not args[1] then
			vRPclient.sendSyntax(player, { "/tptomarket <marketId>" })
		end;
		local market = getMarketData(tonumber(args[1]))

		if not market then
			vRPclient.notify(player, { "Magazin inexistent.", "error" })
			return
		end

		vRPclient.teleport(player, { market.x, market.y, market.z })
	end)

	RegisterCommand("markets", function(player, args)
		local user_id = vRP.getUserId(player)
		if not user_id then return 0 end;

		if vRP.getUserAdminLevel(user_id) < 5 then
			vRPclient.noAccess(player)
			return
		end
		local marketMsg = "";
		for marketId, data in pairs(markets) do
			local marketStatus = "^2"
			local marketID = data.id
			if not data then
				marketStatus = "^2"
			elseif (data and data.owner and data.owner ~= 0) then
				marketStatus = "^1"
			end
			marketMsg = marketMsg .. marketStatus .. marketID .. "^0 | "
		end
		TriggerClientEvent("chatMessage", player, "^1System:^0 Marketuri disponibile pentru licitatii:\n " .. marketMsg)
	end)

	Citizen.Wait(15000)
	for mType, items in pairs(market_types) do
		local categories = {}

		market_items[mType] = {}

		for item, data in pairs(items) do
			if type(data) == "table" and item ~= "_config" then
				local itemName = vRP.getItemName(item)

				local price, category = table.unpack(data)

				if itemName then
					-- if itemName == "Unknown" then print('Unknown -> ',item) end;
					market_items[mType][item] = {
						label = itemName,
						price = price,
						biz_price = math.ceil(price * .9),
						category = category,
						stock = minStock
					}

					if not isInTable(category, categories) then
						table.insert(categories, category)
					end
				end
			end
		end

		table.sort(categories, function(a, b)
			return string.upper(a) < string.upper(b)
		end)

		items._config.categories = categories
	end
	GlobalState.markets = markets

	TriggerEvent("vrp-markets:setOwnerPhoneNr")
end)

local function isMarketOwner(bizId, user_id)
	local market = getMarketData(bizId) or {}

	return market.owner and (market.owner == user_id)
end

local function isMarketOwned(bizId, user_id)
	local market = getMarketData(bizId) or {}

	return market.owner or 0;
end
local function getMarketsOwned(user_id)
	local count = 0;
	for k, v in pairs(markets) do
		if v.owner and v.owner == user_id then
			count = count + 1;
		end
	end
	return count;
end
exports("getMarketsOwned", getMarketsOwned)
exports("isMarketOwner", isMarketOwner)
exports("isMarketOwned", isMarketOwned)
RegisterServerEvent("vrp-markets:openMarket", function(id)
	local player = source
	local user_id = vRP.getUserId(player)

	local marketData = getMarketData(id)
	if not marketData then return end

	local faction = vRP.getUserFaction(user_id)

	local marketCfg = market_types[marketData.type]?._config

	if marketCfg.fType and not (vRP.getFactionType(faction) == marketCfg.fType) then
		vRPclient.notify(player, { "Nu poti deschide acest magazin.", "error" })
		return
	end

	local data = {
		id = id,
		gtype = marketData.type,
		items = market_items[marketData.type],
		stock = marketData.stocks,
		bizPos = marketData.bizPos,
		categories = marketCfg.categories,
		money = vRP.getMoney(user_id),
		name = exports.vrp:getRoleplayName(user_id)
	}

	TriggerClientEvent("vrp:sendNuiMessage", player, { interface = "market", data = data })
end)

RegisterServerEvent('vrp-markets:openMarketBiz', function(id)
	local player = source
	local user_id = vRP.getUserId(player)
	local marketData = getMarketData(id)
	if not marketData then return end
	if not isMarketOwner(id, user_id) then
		return vRPclient.notify(player, { "Nu esti detinatorul acestui magazin!", "error" })
	end

	local data = {
		bizid = id,
		items = market_items[marketData.type],
		profit = marketData.profit
	}

	TriggerClientEvent("vrp:sendNuiMessage", player, { interface = "marketBiz", data = data })
end)

function vRP.getItemPrice(item, marketType)
	local items = market_types[marketType]
	if not items then return end

	for itemId, data in next, items do
		if itemId == item then
			return true, math.max(data[1], 0)
		end
	end

	return false, 0
end

RegisterServerEvent("vrp-markets:orderStock", function(bizId, item, amount)
	local player = source
	local user_id = vRP.getUserId(player)

	if parseInt(amount) <= 0 then return end

	if not isMarketOwner(bizId, user_id) then
		vRPclient.notify(player, { "Nu detii acest magazin.", "error" })
		return
	end

	local biz = getMarketData(bizId)

	if biz then
		local data = market_items[biz.type][item] or {}
		local price = data.biz_price

		if not price then
			vRPclient.notify(player, { "Acest item nu poate fi comandat.", "error" })
			return
		end

		if stockOrders[bizId] and stockOrders[bizId].worker then
			vRPclient.notify(player,
				{ "Ai deja o comanda activa, asteapta ca produsele comandate sa iti fie furnizate.", "error" })
			return
		end

		local cost = math.floor(tonumber(amount) * price) or 0

		if cost > 0 and vRP.tryFullPayment(user_id, cost, true, false, "Market Stock Order (" .. bizId .. ")") then
			if not stockOrders[bizId] then
				stockOrders[bizId] = { order = {} }
				exports.mongodb:insertOne({ collection = "market_orders", document = { biz = bizId } })
			end

			if not stockOrders[bizId].order[item] then
				stockOrders[bizId].order[item] = { amount = 0 }
			end

			stockOrders[bizId].order[item].amount = stockOrders[bizId].order[item].amount + tonumber(amount)
			exports.mongodb:updateOne({
				collection = "market_orders",
				query = { biz = bizId },
				update = {
					["$set"] = { ["order." .. item] = stockOrders[bizId].order[item].amount }
				}
			})

			Citizen.Wait(500)
			stockOrders[bizId] = getCorrectMarketOrder(bizId, stockOrders[bizId].order)

			Citizen.Wait(1500)
			TriggerClientEvent("vrp-hud:sendApiInfo", player, "Ai comandat " .. amount .. "x " .. data.label)
		else
			TriggerClientEvent("vrp-hud:sendApiError", player, "Nu ai destui bani pentru a plati comanda.")
		end
	end
end)

local function restockMarket(bizId)
	if not stockOrders[bizId] then
		return
	end

	local market = getMarketData(bizId)

	if market then
		if not stockOrders[bizId] or (not next(stockOrders[bizId].order or {})) then return end

		if not market.stocks then
			market.stocks = {}
		end

		for k, v in pairs(stockOrders[bizId].order) do
			market.stocks[k] = (market.stocks[k] or 0) + v.amount
		end

		stockOrders[bizId] = nil
		exports.mongodb:deleteOne({ collection = "market_orders", query = { biz = bizId } })
	end
end

exports("restockMarket", restockMarket)

RegisterServerEvent("vrp-markets:withdrawProfit", function(id)
	local player = source
	local user_id = vRP.getUserId(player)

	if not id or not isMarketOwner(id, user_id) then
		vRPclient.notify(player, { "Nu detii acest magazin.", "error" })
		return
	end

	local market = getMarketData(id) or {}

	if market.profit then
		if market.profit < 1 then
			vRPclient.notify(player, { "Nu ai facut profit.", "error" })
			return
		end

		vRP.giveMoney(user_id, tonumber(market.profit), "Market Withdraw")
		market.profit = 0
	end
end)

RegisterServerEvent("vrp-markets:buy", function(item, gtype, id)
	local player = source
	local user_id = vRP.getUserId(player)

	local market = getMarketData(id) or {}

	if market.stocks then
		if ((market.stocks[item]) or minStock) < 1 then
			return false
		end
	end

	if vRP.canCarryItem(user_id, item, 1) then
		local price = market_items[gtype][item].price
		if vRP.tryBankPayment(user_id, price, false, "Market Purchase") or vRP.tryPayment(user_id, price, false, "Market Purchase") then
			if vRP.items[item].category == 'food' then
				vRP.giveItem(user_id, item, 1, false, {
					expire = os.time() + (32 * 3600),
				}, false, "Market Purchase")
			else
				vRP.giveItem(user_id, item, 1, false, false, false, 'Market Purchase')
			end


			if item == "phone" then
				if not exports.vrp:hasCompletedBegginerQuest(user_id, 1) then
					exports.vrp:completeBegginerQuest(user_id, 1)
				end

				exports.vrp:achieve(user_id, 'DigitalDenEasy', 1)
			end

			if item == "laptop_h" then
				exports.vrp:achieve(user_id, 'LaptopEasy', 1)
			end

			TriggerClientEvent("vrp-hud:runjs", player, "markets.balance = " .. vRP.getMoney(user_id) .. ";")

			local item_name = vRP.getItemName(item)
			vRP.createLog(user_id,
				{
					amount = 1,
					item = item,
					item_name = item_name,
					name = GetPlayerName(player),
					price = price,
					ppi =
						price,
					gtype = gtype
				}, "MarketBuy")

			if id and market and market.bizPos then
				if not market.stocks then
					market.stocks = {}
				end

				local stock = (market.stocks[item] or minStock)
				market.stocks[item] = math.max(0, stock - 1)
				TriggerClientEvent("vrp:sendNuiMessage", player, {
					interface = "updateMarketData",
					stock = market.stocks[item],
					balance = vRP.getMoney(user_id),
					item = item,
				})

				-- pay business 180% ?
				local bizGet = math.ceil(1.80 * price)
				market.profit = (market.profit or 0) + bizGet
			end
		else
			vRPclient.notify(player, { 'Nu ai destui bani la tine pentru a plati', 'error' })
		end
	end
end)

RegisterServerEvent("vrp-markets:sellMarket", function(id)
	local player = source
	local user_id = vRP.getUserId(player)

	if not id or not isMarketOwner(id, user_id) then
		vRPclient.notify(player, { "Nu detii acest magazin.", "error" })
		return
	end

	local market = getMarketData(id) or {}
	if market.profit then
		vRPclient.getNearestPlayer(player, { 5 }, function(target)
			if not target then
				return vRPclient.notify(player, { 'Nu exista jucatori in apropiere!', 'error' })
			end
			local target_id = vRP.getUserId(target);
			if not target_id then
				return vRPclient.notify(player, { 'Nu exista jucatori in apropiere!', 'error' })
			end
			local isFriend = isPlayerFriend(user_id, target_id)

			vRP.request(player, "Doresti sa vinzi magazinul tau jucatorului " ..
				GetPlayerName(target) .. " (" .. target_id .. ") ?", false,
				function(_, ok)
					if ok then
						vRP.prompt(player, "Vinde Magazinul",
							"Introdu in caseta de mai jos pretul cerut pe magazin iar apoi apasa pe butonul de confirmare.",
							false,
							function(amount)
								if amount then
									amount = tonumber(amount)
									if not amount then return 0 end;
									amount = math.abs(amount)
									vRP.request(target,
										GetPlayerName(player) .. " (" ..
										user_id ..
										") doreste sa va vanda magazinul sau pentru suma de " .. amount ..
										"$ , acceptati?", false,
										function(_, ok2)
											if ok2 then
												if vRP.tryBankPayment(target_id, amount, true, "Cumparare Market", false) then
													vRP.giveBankMoney(user_id, amount, "Vanzare Market")
													exports['vrp']:setMarketOwner(user_id, id);
													vRPclient.notify(target,
														{ "Ati cumparat magazinul cu succes, acum sunteti proprietarul acestuia",
															"success" })
													vRPclient.notify(player,
														{ "Ati vandut magazinul cu succes, banii v au fost virati in contul bancar" })
												else
													vRPclient.notify(target, { "Nu aveti destui bani in banca", "error" })
													vRPclient.notify(player,
														{ "Persoana in cauza nu detine banii necesari in contul bancar",
															"error" })
												end
											else
												vRPclient.notify(player,
													{ 'Persoana in cauza a refuzat cererea dvs', 'error' })
											end
										end)
								end
							end)
					end
				end)
		end)
	end
end)

-- save stocks on server restart
AddEventHandler("onServerRestarting", function()
	for _, data in pairs(markets) do
		if data.stocks then
			exports.mongodb:updateOne({
				collection = "markets",
				query = { id = data.id },
				update = {
					["$set"] = {
						stocks = data.stocks,
						profit = data.profit
					}
				}
			})
		end
	end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(5000)
		for k, v in pairs(markets) do
			if v.owner and v.owner == user_id then
				markets[k].expireTime = os.time() + (86400 * 30)
				exports.mongodb:updateOne({
					collection = "markets",
					query = { owner = v.owner },
					update = {
						["$set"] = { expireTime = os.time() + (86400 * 30) }
					}
				})
			end
		end
	end
end)
