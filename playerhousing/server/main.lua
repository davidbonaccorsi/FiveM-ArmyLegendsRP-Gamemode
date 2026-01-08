local housing = playerhousing
housing.__VERSION = "1.00"

local houseBigData = {}

function housing:Awake()
	exports.mongodb:find({collection = "houses", query = {}}, function(success, data)
		local houseData = Houses
		for k,v in pairs(houseData) do
			local match = table.find(data,"id",k)
			if match then
				houseData[k].owner = match.owner
				local wardrobePos = false
				if match.wardrobe then
					local w = json.decode(match.wardrobe)
					if w and w.x then
						wardrobePos = vector3(w.x,w.y,w.z)
					end
				end

				local chestPos = false
				if match.chest then
					local w = json.decode(match.chest)
					if w and w.x then
						chestPos = vector3(w.x,w.y,w.z)
					end
				end

				local garagePos = false
				if match.garage then
					local w = json.decode(match.garage)
					if w and w.x then
						garagePos = vector3(w.x,w.y,w.z)
					end
				end

				local furniture = {}
				if match.furniture then
					local f = json.decode((match.furniture or {}))
					if f and type(f) == "table" then
						for k,v in pairs(f) do
							local p = v.pos
							local r = v.rot
							if r.x then
								table.insert(furniture,{pos = vector3(p.x,p.y,p.z), rot = vector3(r.x,r.y,r.z), model = v.model})
							end
						end
					end
				end

				houseBigData[k] = {
					furniture = furniture,
					wardrobe = wardrobePos,
					chest = chestPos
				}

				houseData[k].Garage = garagePos
				if match.price then
					houseData[k].Price = tonumber(match.price)
				end

				if match.rentPrice then
					houseData[k].rentPrice = match.rentPrice
					houseData[k].rentPriceStr = vRP.formatMoney(match.rentPrice)
				end

				if match.class then
					houseData[k].Class = match.class
				end

				if match.nextPay then
					houseData[k].nextPay = match.nextPay
				end
			else
				houseData[k].furniture = {}
			end
			houseData[k].PriceStr = vRP.formatMoney(tonumber(houseData[k].Price))
			houseData[k].id = k
		end
		self.HouseData = houseData
		self.Started = true
	end)
end

function getUserHouses(user_id)

	local userHouses, count = {}, 0

	for houseId, data in pairs(housing.HouseData) do
		if data.owner == tostring(user_id) then
			count = count + 1
			userHouses[houseId] = {class = data.Class, price = data.Price}
		end
	end

	return count, userHouses

end

exports("getUserHouses", getUserHouses)

RegisterCommand("sethouseprice", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 4 then
		if args[1] and args[2] then
			local houseId = tonumber(args[1])
			local newprice = tonumber(args[2])
			if houseId and newprice then
				exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {["$set"] = {price = newprice}}})
				vRPclient.sendInfo(player, {"Ai setat noul pret !"})
			else
				vRPclient.sendError(player, {"Valoare invalida"})
			end
		else
			vRPclient.sendSyntax(player, {"/sethouseprice <house-id> <price>"})
		end
	else
		vRPclient.noAccess(player)
	end
end)

function housing:BuyHouse(source, houseId, free)
	local user_id = vRP.getUserId(source)

	if not free and not self.HouseData[houseId].Premium then
		vRPclient.notify(source, {"Casele se pot obtine doar prin licitatii.", "error", "Case"})
		return
	end

	exports.mongodb:count({collection = "houses", query = {owner = tostring(user_id)}}, function(success, ownedHouses)
		local max, vipRank = 3, vRP.getUserVipRank(tonumber(user_id))
		if vipRank > 0 then max = 6 end
	
		if ownedHouses < max then

			if self.HouseData[houseId] and (not self.HouseData[houseId].owner or self.HouseData[houseId].owner ~= "")then
				local canPay = free or false
				if not canPay then
					if self.HouseData[houseId].Premium then
						canPay = vRP.tryCoinsPayment(user_id, self.HouseData[houseId].Price, "Buy House")
					else
						canPay = vRP.tryFullPayment(user_id, self.HouseData[houseId].Price, false, false, "Buy House")
					end
				end

				if canPay then
					vRP.createLog(user_id, {house = houseId, price = self.HouseData[houseId].Price, from = "Server", player = GetPlayerName(source)}, "HouseBuy")
					self.HouseData[houseId].owner = tostring(user_id)

					TriggerClientEvent('playerhousing:SyncHouse', -1, self.HouseData[houseId])

					local aHouse = {
						id = houseId,
						owner = tostring(user_id),
						price = tonumber(self.HouseData[houseId].Price),
						furniture = json.encode({})
					}

					if self.HouseData[houseId].Premium then
						aHouse.nextPay = os.time() + daysToSeconds(30)
					end

					exports.mongodb:insertOne({collection = "houses", document = aHouse})
					exports.vrp:achieve(user_id, "homeEasy", 1)
				else
					vRPclient.notify(source, {"Nu iti permiti aceasta casa.", "error"})
				end
			end

		else
			vRPclient.notify(source, {"Ai deja "..max.." case detinute", "error"})
		end
	end)
end

exports("giveHousingAuction", function(user_id, houseId)

	if housing.HouseData[houseId].owner then
		exports.mongodb:deleteOne({collection = "houses", query = {id = houseId}})
		housing.HouseData[houseId].owner = nil
		TriggerClientEvent("playerhousing:SyncHouse", -1, housing.HouseData[houseId])
	end

	housing:BuyHouse(user_id, houseId, true)
end)


function housing:tryNextPayment(user_id, source)

	local housesCount, ownedHouses = getUserHouses(user_id)

	for houseId, h in pairs(ownedHouses or {}) do
		if self.HouseData[houseId] and self.HouseData[houseId].Premium then
			if (self.HouseData[houseId].nextPay or 0) > os.time() then
				goto skipHouse
			end

			local totalPrice = math.ceil(self.HouseData[houseId].Price * 0.50)
			if vRP.tryCoinsPayment(user_id, totalPrice, "Buy House") then
				local nextPay = os.time() + daysToSeconds(30)

				self.HouseData[houseId].nextPay = nextPay
				exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {
					["$set"] = {nextPay = nextPay}
				}})

				vRPclient.notify(source, {"Ai platit intretinerea pentru casa cu nr. "..houseId.."\nData de expirare: "..os.date("%d/%m/%Y %H:%M", self.HouseData[houseId].nextPay), "info", "Housing"})
			else
				vRPclient.notify(source, {"Nu iti permiti sa platesti intretinerea la casa cu nr. "..houseId.." iar aceasta ti-a fost scoasa !", "error"})
				exports.mongodb:deleteOne({collection = "houses", query = {id = houseId}})
				self.HouseData[houseId].owner = nil
				TriggerClientEvent("playerhousing:LeaveHouse", source)
				TriggerClientEvent("playerhousing:SyncHouse", -1, self.HouseData[houseId])
			end
		end
		::skipHouse::
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		Citizen.Wait(5000)
		housing:tryNextPayment(user_id, player)
	end
end)


function housing:SetWardrobe(source,house,pos)
	houseBigData[house].wardrobe = {x=pos.x, y=pos.y, z=pos.z}
	TriggerClientEvent('playerhousing:SyncHouse', -1, self.HouseData[house])
	local tPos = {x=pos.x,y=pos.y,z=pos.z}

	exports.mongodb:updateOne({collection = "houses", query = {id = house}, update = {['$set'] = {
		wardrobe = json.encode(tPos)
	}}})
end

function housing:SetChest(source,house,pos)
	houseBigData[house].chest = {x=pos.x, y=pos.y, z=pos.z}
	TriggerClientEvent('playerhousing:SyncHouse', -1, self.HouseData[house])
	local tPos = {x=pos.x,y=pos.y,z=pos.z}

	exports.mongodb:updateOne({collection = "houses", query = {id = house}, update = {['$set'] = {
		chest = json.encode(tPos)
	}}})
end

function housing:SetGarage(source,house,pos)
	self.HouseData[house].Garage = {x=pos.x, y=pos.y, z=pos.z}
	TriggerClientEvent('playerhousing:SyncHouse', -1, self.HouseData[house])
	local tPos = {x=pos.x,y=pos.y,z=pos.z}

	exports.mongodb:updateOne({collection = "houses", query = {id = house}, update = {['$set'] = {
		garage = json.encode(tPos)
	}}})
end


local userKeys, userRents = {}, {}

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
	if first_spawn then
		vRP.getUData(user_id, "vRPhousing:keys", function(preKeyData)
			local keyData = json.decode(preKeyData) or {}
			if keyData and keyData[1] then
				userKeys[player] = keyData
			else
				userKeys[player] = {}
			end

			vRP.getUData(user_id, "vRPhousing:rents", function(preRentData)
				local rentData = json.decode(preRentData) or {}
				if rentData and rentData[1] then
					userRents[player] = rentData
				else
					userRents[player] = {}
				end

				for index, data in pairs(userRents[player]) do
					if os.time() > data.expire then
						userRents[player][index] = nil
						vRP.setUData(user_id, "vRPhousing:rents", json.encode(userRents[player]))
					end
				end

				TriggerClientEvent('vrp-housing:startDone', player, userKeys[player], userRents[player])
			end)
		end)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	userKeys[player] = nil
	userRents[player] = nil
end)

function housing:GiveKeys(target,id)
	local user_id = vRP.getUserId(target)
	if user_id then
		local newData = { house = id }
		table.insert(userKeys[target], newData)
		vRP.setUData(user_id, "vRPhousing:keys", json.encode(userKeys[target]))
		TriggerClientEvent('playerhousing:GiveKey', target, id)
	end
end

function housing:TakeKeys(target,id)
	local user_id = vRP.getUserId(target)

	for indx, v in pairs(userKeys[target]) do
		if v.house == id then
			table.remove(userKeys[target], indx)
		end
	end
	
	vRP.setUData(user_id, "vRPhousing:keys", json.encode(userKeys[target]))
	TriggerClientEvent('playerhousing:TakeKey', target, id)
end

function housing:updateHouse(player, houseId)
	SetPlayerRoutingBucket(player, houseId % 40 + 10)
	TriggerClientEvent('playerhousing:SyncHouse', player, self.HouseData[houseId])
end

function housing:getHouseData()
	return self.HouseData
end

function housing:initPlayer(player)
	while not self.Started do Citizen.Wait(50) end
	local someData = self.HouseData
	
	for k, v in pairs(someData) do
		if type(v) == "table" then
			TriggerClientEvent('playerhousing:SyncHouse', player, v)
		end
	end
end

local function updateFurniture(houseId)

	local frns = {}

	for k, v in pairs(houseBigData[houseId].furniture) do
		local obj = {
			model = tostring(v.model),
			pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
			rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z}
		}

		table.insert(frns, obj)
	end

	exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$set'] = {
		furniture = json.encode(frns)
	}}})

	TriggerClientEvent('playerhousing:SyncHouse', -1, housing.HouseData[houseId])
end

function housing:buyObject(player, houseId, item, pos, rot)
	local user_id = vRP.getUserId(player)


	if vRP.tryPayment(user_id, tonumber(item.price), false, "Housing Furniture") then

		local obj = {
			model = tostring(item.object),
			pos = {x = pos.x, y = pos.y, z = pos.z},
			rot = {x = rot.x, y = rot.y, z = rot.z}
		}

		if self.HouseData[houseId] then
			table.insert(houseBigData[houseId].furniture, obj)

			updateFurniture(houseId)
		end
	end
end

function housing:editObject(player, houseId, item, pos, rot)
	local user_id = vRP.getUserId(player)

	local furn = houseBigData[houseId].furniture

	for k, v in pairs(furn) do
		if v.model == tostring(item.object) then

			furn[k] = {
				model = tostring(item.object),
				pos = {x = pos.x, y = pos.y, z = pos.z},
				rot = {x = rot.x, y = rot.y, z = rot.z}
			}

			updateFurniture(houseId)
			break
		end
	end
end

function housing:deleteObject(player, houseId, data)
	local user_id = vRP.getUserId(player)

	for k, v in pairs(houseBigData[houseId].furniture) do
		if GetHashKey(v.model) == data.object then
			table.remove(houseBigData[houseId].furniture, k)
			vRP.giveMoney(user_id, tonumber(data.sellPrice), "Housing")
			updateFurniture(houseId)
			break
		end
	end
end

function housing:knockOnDoor(player, ownerId, houseId)
	local user_id = vRP.getUserId(player)
	local ownerSrc = vRP.getUserSource(ownerId)
	TriggerClientEvent('playerhousing:PlayerKnocked', ownerSrc, user_id, houseId)
end

RegisterNetEvent('playerhousing:getHouseData')
AddEventHandler('playerhousing:getHouseData', function(cb) cb(housing:getHouseData()) end)

RegisterNetEvent('playerhousing:BuyHouse')
AddEventHandler('playerhousing:BuyHouse', function(houseId) housing:BuyHouse(source, houseId) end)

RegisterNetEvent('playerhousing:SetWardrobe')
AddEventHandler('playerhousing:SetWardrobe', function(id,tPos) housing:SetWardrobe(source,id,tPos) end)

RegisterNetEvent('playerhousing:SetChest')
AddEventHandler('playerhousing:SetChest', function(id,tPos) housing:SetChest(source,id,tPos) end)

RegisterNetEvent('vrp-housing:setGaragePos')
AddEventHandler('vrp-housing:setGaragePos', function(id,tPos) housing:SetGarage(source,id,tPos) end)

RegisterNetEvent('playerhousing:GiveKeys')
AddEventHandler('playerhousing:GiveKeys', function(targetSrc, houseId) housing:GiveKeys(targetSrc, houseId) end)

RegisterNetEvent('playerhousing:TakeKeys')
AddEventHandler('playerhousing:TakeKeys', function(targetSrc, houseId) housing:TakeKeys(targetSrc, houseId) end)

RegisterServerEvent('playerhousing:Enter')
AddEventHandler('playerhousing:Enter', function(houseId) housing:updateHouse(source, houseId) end)

RegisterServerEvent('playerhousing:Start')
AddEventHandler('playerhousing:Start', function(forAll) housing:initPlayer(source, forAll) end)

RegisterServerEvent('furni:PlaceFurniture')
AddEventHandler('furni:PlaceFurniture', function(houseId, item, pos, rot) housing:buyObject(source, houseId, item, pos, rot) end)

RegisterServerEvent('furni:ReplaceFurniture')
AddEventHandler('furni:ReplaceFurniture', function(houseId, item, pos, rot) housing:editObject(source, houseId, item, pos, rot) end)

RegisterServerEvent('furni:DeleteFurniture')
AddEventHandler('furni:DeleteFurniture', function(houseId, data) housing:deleteObject(source, houseId, data) end)

RegisterServerEvent('playerhousing:KnockOnDoorX')
AddEventHandler('playerhousing:KnockOnDoorX', function(ownerId, houseId) housing:knockOnDoor(source, ownerId, houseId) end)

RegisterServerEvent("vrp-housing:tryToRent", function(houseId)
	local player = source
	local user_id = vRP.getUserId(player)
	local hData = housing.HouseData[houseId]

	if hData then

		local hasAccess = (tostring(hData.owner) == tostring(user_id)) or false

		if not hasAccess then

			if hData.rentPrice then

				if vRP.tryPayment(user_id, hData.rentPrice, true, "House Rent") then

					local eTime = os.time() + 604800
					table.insert(userRents[player], { house = houseId, expire = eTime, formated = os.date("%d %b", eTime) })
					vRP.setUData(user_id, "vRPhousing:rents", json.encode(userRents[player]))
					TriggerClientEvent("vrp-housing:updateRents", player, userRents[player])

					housing.HouseData[houseId].rentMoney = (housing.HouseData[houseId].rentMoney or 0) + math.floor(hData.rentPrice * 0.75)
					exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$inc'] = {rentPrice = math.floor(hData.rentPrice * 0.75)}}})

				end

			else
				vRPclient.notify(player, {"Aceasta casa nu este data in chirie"})
			end

		else
			vRPclient.notify(player, {"Nu poti sa iti inchirezi singur casa"})
		end

	end
end)

RegisterServerEvent("vrp-housing:tryUseGarage", function(houseId)
	local player = source
	local user_id = vRP.getUserId(player)
	local hData = housing.HouseData[houseId]
	if hData then

		local hasAccess = (tostring(hData.owner) == tostring(user_id)) or false

		if not hasAccess then
			for _, d in pairs(userKeys[player]) do
				if d.house == houseId then
					hasAccess = true
					break
				end
			end

			if hasAccess then
				vRP.openGarage(user_id, player, hData.GarageType or "Personal")
			else

				for _, d in pairs(userRents[player]) do
					if d.house == houseId then
						hasAccess = true
						break
					end
				end

				if hasAccess then
					vRP.openGarage(user_id, player, hData.GarageType or "Personal")
				else
					vRPclient.notify(player, {"Nu detii acest garaj", "error"})
				end
			end
		else
			vRP.openGarage(user_id, player, hData.GarageType or "Personal")
		end
	end
end)

RegisterServerEvent("playerhousing:Leave")
AddEventHandler("playerhousing:Leave", function()
	local player = source
	SetPlayerRoutingBucket(player, 0)
end)

function svRP.getHouseBigData(houseId)
	if not houseBigData[houseId] then
		houseBigData[houseId] = {
			furniture = {},
			wardrobe = false,
			chest = false
		}
	end
	return houseBigData[houseId]
end


function svRP.getKeys()
	local player = source
	local keys = userKeys[player] or {}
	return keys
end

function svRP.getRents()
	local player = source
	local rents = userRents[player] or {}
	return rents
end

function svRP.getMyId()
	return vRP.getUserId(source)
end

function svRP.hasMoney(amount)
	local user_id = vRP.getUserId(source)

	return vRP.getMoney(user_id) >= tonumber(amount)
end

local teleportCooldown = {}

function svRP.teleportInsideHouse(user_id, houseId)
	if (teleportCooldown[user_id] or 0) < os.time() then
		teleportCooldown[user_id] = os.time() + 10
		local player = vRP.getUserSource(user_id)
		if player then
			vRPclient.getPosition(player, {}, function(x, y, z)
				local pos = vector4(x, y, z, 69.0)
				TriggerClientEvent('playerhousing:EnterHouse', player, pos, housing.HouseData[houseId])
			end)
		end
	else
		vRPclient.notify(source, {"Jucatorul este in curs de teleportare"})
	end
end

RegisterServerEvent("vrp-housing:enterWarderobe", function()
	local player = source
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then

		local menu = {name = "Garderoba", css = {top = "75px", header_color = "rgba(0,255,125,0.75)"}}

		vRP.getUData(user_id, "vRP:home:wardrobe", function(data)
			local sets = json.decode(data)
			if sets == nil then
				sets = {}
			end

			menu["# Salveaza #"] = {function(player, choice)
				vRP.prompt(player, "Save outfit", "Numele Outfit-ului", false, function(setname)
					if not setname then return end
					setname = sanitizeString(setname, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789()[]-+", true)
					if string.len(setname) > 0 and string.len(setname) < 50 then
						vRPclient.getClothes(player, {}, function(custom)
							sets[setname] = custom
							vRP.setUData(user_id, "vRP:home:wardrobe", json.encode(sets))
							vRP.closeMenu(player)
						end)
					else
						vRPclient.notify(player, {"Nume invalid"})
					end
				end)
			end, '<i class="fa-solid fa-clothes-hanger"></i>'}

			menu["# Reseteaza Tot #"] = {function(player, choice)
				vRP.closeMenu(player)
				vRP.request(player, "Esti sigur ca vrei sa-ti stergi toate tinutele ?", false, function(player, ok)
					if ok then
						vRP.setUData(user_id, "vRP:home:wardrobe", json.encode({}))
					end
				end)
			end, '<i class="fa-solid fa-trash-can-list"></i>'}

			local choose_set = function(player, choice)
				local custom = sets[choice]
				if custom ~= nil then
					vRPclient.setClothes(player, {custom})
					Citizen.Wait(500)
					TriggerClientEvent("raid:saveCurrentPed", player)
				end
			end

			for k, v in pairs(sets) do
				menu[k] = {choose_set, ""}
			end

			vRP.openMenu(player, menu)
		end)
	end
end)

function svRP.getUserSuperData()
	local player = source
	local theJobName = "Somer"

	local user_id = vRP.getUserId(player)

	if vRP.isUserPolitist(user_id) then
		theJobName = "Politie"
	end

	local userSuperData = {
		identifier = user_id,
		job = {name = theJobName}
	}

	return userSuperData
end

function svRP.openHouseChest(houseId)
	local player = source
	local user_id = vRP.getUserId(player)
	local hData = housing.HouseData[houseId]
	if hData then
		if tostring(hData.owner) == tostring(user_id) then
			vRP.openChest(player, "houseChest:"..houseId, 200, "Cufar casa: "..houseId)
		else
			vRPclient.notify(player, {"Doar proprietarul casei are cheia de la cufar", "error"})
		end
	end
end

function svRP.openHouseMenu(houseId)
	local player = source
	local user_id = vRP.getUserId(player)
	local hData = housing.HouseData[houseId]
	if hData then
		if tostring(hData.owner) == tostring(user_id) then
			local menu = {
				name = "Meniu Casa",
				css={top = "75px", header_color="rgba(226, 87, 36, 0.75)"}
			}

			menu["Ofera Cheile"] = {function(player)
				vRP.closeMenu(player)
				TriggerClientEvent("vrp-housing:GiveKeys", player)
			end, '<i class="fa-duotone fa-key"></i>'}
			menu["Confisca Cheile"] = {function(player)
				vRP.closeMenu(player)
				TriggerClientEvent("vrp-housing:TakeKeys", player)
			end, '<i class="fa-duotone fa-house-person-return"></i>'}

			menu["Seteaza Garderoba"] = {function(player)
				vRP.closeMenu(player)
				vRPclient.notify(player, {"Apasa E unde vrei sa-ti pui Garderoba"})
				TriggerClientEvent("vrp-housing:setGarderoba", player)
			end, '<i class="fa-solid fa-clothes-hanger"></i>'}
			menu["Seteaza pozitie Cufar"] = {function(player)
				vRP.closeMenu(player)
				vRPclient.notify(player, {"Apasa E unde vrei sa-ti pui Cufarul"})
				TriggerClientEvent("vrp-housing:setChest", player)
			end, '<i class="fa-solid fa-treasure-chest"></i>'}


			menu["Reseteaza Cheile"] = {function(player)
				vRP.closeMenu(player)
				
				exports.mongodb:find({collection = "users", query = {["uData.vRPhousing:keys"] = { ['$regex'] = '"house":'..houseId }}, options = {projection = {_id = 0, id = 1, ["uData.vRPhousing:keys"] = 1}}}, function(success, results)
					for _, data in pairs(results) do		
						local value = json.decode(data.uData['vRPhousing:keys']) or {}

						for index, obj in pairs(value) do
							if obj.house == houseId then
								value[index] = nil
							end
						end
		
						local target_src = vRP.getUserSource(data.id)
						if not target_src then
							exports.mongodb:updateOne({collection = "users", query = {id = data.id}, update = {
								['$set'] = {['uData.vRPhousing:keys'] = json.encode(value)}
							}})
						else
							vRP.setUData(data.id, "vRPhousing:keys", json.encode(value))
						end

					end
				end)
			end, '<i class="fa-regular fa-shield-keyhole"></i>'}

			menu["Reseteaza Mobilierul"] = {function(player)
				vRP.closeMenu(player)
				
				vRP.request(player, "Esti sigur ca doresti sa resetezi tot mobilierul din casa ?", false, function(player, ok)
					if ok then
						houseBigData[houseId].furniture = {}
						exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$unset'] = {furniture = 1}}})
						vRPclient.notify(player, {"Ai resetat tot mobilierul din casa."})
						TriggerClientEvent("playerhousing:LeaveHouse", player)
					end
				end)
			end, '<i class="fa-solid fa-trash-can-list"></i>'}

			if hData.rentPrice then
				menu["Opreste Rent"] = {function(player)
					vRP.closeMenu(player)
					
					housing.HouseData[houseId].rentPrice = nil
					housing.HouseData[houseId].rentPriceStr = nil
					exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$unset'] = {rentPrice = 1}}})

					vRPclient.notify(player, {"Ai oprit inchirierea casei tale."})
					TriggerClientEvent("playerhousing:SyncHouse", -1, housing.HouseData[houseId])
				end, '<i class="fa-duotone fa-house-circle-xmark"></i>'}

				menu["Retrage Bani"] = {function(player)
					vRP.closeMenu(player)
					if (hData.rentMoney or 0) >= 1 then

						local backupMoney = hData.rentMoney
						housing.HouseData[houseId].rentMoney = 0
						exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$set'] = {rentMoney = 0}}}, function(success)
							vRP.giveMoney(user_id, backupMoney, "Rent #"..houseId)
						end)

					end
				end, '<i class="fa-solid fa-coin"></i>', "Retrage banii obtinuti din chirii.<br/>Bani Stransi: <font color='green'>$"..(hData.rentMoney or 0).."</font>"}
			else
				menu["Porneste Rent"] = {function(player)
					vRP.closeMenu(player)
					
					vRP.prompt(player, "Rent house", "Pret / 7 zile", false, function(priceStr)
						if not priceStr then return end
						local price = math.abs(math.floor(tonumber(priceStr) or 0))

						if price then
							housing.HouseData[houseId].rentPrice = price
							housing.HouseData[houseId].rentPriceStr = vRP.formatMoney(price)
							exports.mongodb:updateOne({collection = "houses", query = {id = houseId}, update = {['$set'] = {rentPrice = price}}})

							vRPclient.notify(player, {"Ai pornit inchirierea casei tale cu pretul de $"..vRP.formatMoney(price).." pe 7 zile."})
							TriggerClientEvent("playerhousing:SyncHouse", -1, housing.HouseData[houseId])
						else
							vRPclient.notify(player, {"Valoare invalida"})
						end
					end)
				end, '<i class="fa-duotone fa-house-building"></i>'}
			end


			if not housing.HouseData[houseId].Premium then
				menu["Vinde Casa"] = {function(player)
					local submenu = {
						name = "Vinde Casa",
						css = {top = "75px", header_color="rgba(226, 87, 36, 0.75)"}
					}

					local sellPrice = math.floor(hData.Price*0.4)
					submenu["La Stat"] = {function(player)
						vRP.closeMenu(player)
						vRP.request(player, "Esti sigur ca doresti sa-ti vinzi casa cu "..sellPrice.."$", false, function(player, ok)
							if ok then
								exports.mongodb:deleteOne({collection = "houses", query = {id = houseId}}, function(success, result)
									if success then
										vRPclient.notify(player, {"Ti-ai vandut casa pe "..vRP.formatMoney(sellPrice).."$"})
										housing.HouseData[houseId].owner = nil
										TriggerClientEvent("playerhousing:LeaveHouse", player)
										TriggerClientEvent("playerhousing:SyncHouse", -1, housing.HouseData[houseId])

										vRP.createLog(user_id, {house = houseId, price = sellPrice, from = "Server", player = GetPlayerName(player)}, "HouseSell")									

										vRP.giveMoney(user_id, sellPrice, "Sell House State")
									end
								end)
							end
						end)
					end, '<i class="fa-solid fa-landmark-flag"></i>', "<font color='red'>(!)</font> Mobilierul va fii aruncat la groapa de gunoi<br/>Primesti: <font color='green'>"..vRP.formatMoney(sellPrice).."$</font>"}

					submenu["La Un Jucator"] = {function(player)
						vRP.closeMenu(player)
						vRPclient.getNearestPlayer(player, {15}, function(target_src)
							if target_src then
								local target_id = vRP.getUserId(target_src)
								if target_id then
									local target_str = tostring(target_id)
									exports.mongodb:count({collection = "houses", query = {owner = tostring(target_id)}}, function(success, ownedHouses)
										local max, vipRank = 3, vRP.getUserVipRank(tonumber(target_id))
										if vipRank > 0 then max = 6 end

										if ownedHouses < max then
											vRP.prompt(player, "Vanzare casa", "Pret vanzare: ", false, function(sellPrice)
												sellPrice = tonumber(sellPrice)
												if sellPrice then
													vRP.request(target_src, "Doreste si cumperi casa cu $" .. sellPrice .. " ?", false, function(target_src, ok)
														if ok then
															if vRP.tryPayment(target_id, sellPrice, false, "House Buy") then
																exports.mongodb:updateOne({collection = "houses",
																	query = {
																		id = houseId,
																		owner = tostring(user_id)
																	},
																	update = {
																		["$set"] = {owner = tostring(target_id)}
																	}
																}, function(success, result)
																	if success then
																		TriggerClientEvent("playerhousing:LeaveHouse", player)
																		TriggerClientEvent("playerhousing:LeaveHouse", target_src)

																		housing.HouseData[houseId].owner = target_str

																		TriggerClientEvent("playerhousing:SyncHouse", -1, housing.HouseData[houseId])

																		vRPclient.notify(player,{"Ti-ai vandut casa pe " ..vRP.formatMoney(sellPrice).."$"})
																		vRP.giveMoney(user_id, sellPrice, "Sell House TP")

																		vRP.createLog(target_id, {house = houseId, price = sellPrice, from = GetPlayerName(player)..' ['..user_id..']', player = GetPlayerName(target_src)}, "HouseBuy")
																		vRP.createLog(user_id, {house = houseId, price = sellPrice, from = GetPlayerName(target_src)..' ['..target_id..']', player = GetPlayerName(player)}, "HouseSell")									
																	end
																end)
															else
																vRPclient.notify(player, {"Jucatorul nu are destui bani la el", "error"})
																vRPclient.notify(target_src, {"Nu ai destui bani la tine", "error"})
															end
														end
													end)
												end
											end)
										else
											vRPclient.notify(player, {"Jucatorul are deja "..max.." case detinute", "error"})
										end
									end)
								end

							end
						end)
					end, '<i class="fa-duotone fa-person"></i>'}

					exports.mongodb:count({collection = "houses", query = {id = houseId, owner = tostring(user_id)}}, function(success, hasHouse)
						if hasHouse > 0 then
							vRP.openMenu(player, submenu)
						else
							vRPclient.notify(player, {"Nu mai detii aceasta casa", "error"})
						end
					end)
				end, '<i class="fa-solid fa-house-person-leave"></i>'}
			end

			vRP.openMenu(player, menu)
		else
			vRPclient.notify(player, {"Doar proprietarul casei poate accesa meniul", "error"})
		end
	end
end

Citizen.CreateThread(function()
	Citizen.Wait(5000)

	housing:Awake()
end)