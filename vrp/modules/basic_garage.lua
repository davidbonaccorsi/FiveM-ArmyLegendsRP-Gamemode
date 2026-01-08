
-- a basic garage implementation

local garages = {}
Citizen.CreateThread(function()
  Citizen.Wait(5000)
  exports.mongodb:find({collection = "garages"}, function(success, result)
    garages = result or {}
  end)
end)

local cfg = module("cfg/garages")
local cfg_inventory = module("cfg/inventory")
local cfg_vehicles = module("cfg/vehicles")
local vehicle_groups = cfg.garage_types

local characters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","X","Y","Z"}
local activeCooldowns = {}


local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end


function vRP.addCacheVehicle(user_id, vehicle)
	local user = vRP.getUser(user_id)
	if not user.userVehicles then
		user.userVehicles = {}
	end

	user.userVehicles[vehicle.vehicle] = vehicle
end

function vRP.removeCacheVehicle(user_id, vehicle)
	vRP.usersData[user_id].userVehicles[vehicle] = nil
end

function vRP.setVehicleData(user_id, vehicle, key, data)
	if not user_id or not vehicle or not key or not data then return end

	if tostring(data) ~= "off" and tostring(data) ~= '-1' then
		if vRP.usersData[user_id] and vRP.usersData[user_id].userVehicles and vRP.usersData[user_id].userVehicles[vehicle] then
			vRP.usersData[user_id].userVehicles[vehicle][key] = data
		end
		exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$set"] = {[key] = data}}})
	else
		if vRP.usersData[user_id] and vRP.usersData[user_id].userVehicles and vRP.usersData[user_id].userVehicles[vehicle] then
			vRP.usersData[user_id].userVehicles[vehicle][key] = nil
		end
		exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {["$unset"] = {[key] = 1}}})
	end
end

RegisterCommand("cleartrunk", function(player, args)
	local user_id = vRP.getUserId(player)
  
	if vRP.getUserAdminLevel(user_id) >= 4 then
		local target_id = tonumber(args[1])
		local vehicle = tostring(args[2])

		if target_id and vehicle then
			local target_src = vRP.getUserSource(target_id)
			vRP.setVehicleData(target_id, vehicle, "trunk", {})
			vRPclient.msg(player, {"^3Minunat! ^7I-ai resetat portbagajul jucatorului "..(target_src and GetPlayerName(target_src) or "ID "..target_id)})
		else
			vRPclient.sendSyntax(player, {"/cleartrunk <user_id>"})
		end
	end
end)

RegisterCommand("clearglovebox", function(player, args)
	local user_id = vRP.getUserId(player)
  
	if vRP.getUserAdminLevel(user_id) >= 4 then
		local target_id = tonumber(args[1])
		local vehicle = tostring(args[2])

		if target_id and vehicle then
			local target_src = vRP.getUserSource(target_id)
			vRP.setVehicleData(target_id, vehicle, "glovebox", {})
			vRPclient.msg(player, {"^3Minunat! ^7I-ai resetat torpedoul jucatorului "..(target_src and GetPlayerName(target_src) or "ID "..target_id)})
		else
			vRPclient.sendSyntax(player, {"/clearglovebox <user_id>"})
		end
	end
end)

function vRP.setVehicleMultipleData(user_id, vehicle, setTable, pushTable, unsetTable)
  
	local setQuery, pushQuery, unsetQuery = {}, {}, {}
	local updateQuery = {}
  
	if not userVehicles[user_id] then
	  userVehicles[user_id] = {}
	end
  
	if vRP.usersData[user_id].userVehicles[vehicle] then
  
	  if type(setTable) == "table" then
		for key, value in pairs(setTable) do
		  setQuery[key] = value
  
		  local keys = splitString(key, ".")
		  if #keys > 1 then
			if not vRP.usersData[user_id].userVehicles[vehicle][keys[1]] then
			  vRP.usersData[user_id].userVehicles[vehicle][keys[1]] = {}
			end
			vRP.usersData[user_id].userVehicles[vehicle][keys[1]][keys[2]] = value
		  else
			vRP.usersData[user_id].userVehicles[vehicle][key] = value
		  end
		end
  
		updateQuery['$set'] = setQuery
	  end
  
	  if type(unsetTable) == "table" then
		for key, v in pairs(unsetTable) do
		  unsetQuery[key] = 1
		  local keys = splitString(key, ".")
		  if #keys > 1 then
			vRP.usersData[user_id].userVehicles[vehicle][keys[1]][keys[2]] = nil
		  else
			vRP.usersData[user_id].userVehicles[vehicle][key] = nil
		  end
		end
  
		updateQuery['$unset'] = unsetQuery
	  end
  
	  if type(pushTable) == "table" then
		for bigKey, values in pairs(pushTable) do
		  pushQuery[bigKey] = values
		  if not vRP.usersData[user_id].userVehicles[vehicle][bigKey] then
			vRP.usersData[user_id].userVehicles[vehicle][bigKey] = {}
		  end
		  table.insert(vRP.usersData[user_id].userVehicles[vehicle][bigKey], values)
		end
		updateQuery['$push'] = pushQuery
	  end
  
	  exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = updateQuery})
	end
end

function vRP.getVehicleDataTable(user_id, vehicle)
	if not vRP.usersData[user_id].userVehicles then
		vRP.usersData[user_id].userVehicles = {}
	end

	return vRP.usersData[user_id].userVehicles[vehicle]
end


function vRP.getVehModelFromName(vehName, cbr)
	local task = Task(cbr)

	for model, vehs in pairs(cfg_vehicles) do
		if tostring(vehs[1]) == tostring(vehName) then
			task({tostring(model)})
			return
		end
	end

	task({})
end


function vRP.checkVehicleName(veh, vipCosts)
	if veh and cfg_vehicles then
		local v = cfg_vehicles[veh]
		if v then
			if (tonumber(v[2]) or 0) == 0 and vipCosts then
				v[2] = 3333333 -- Impozit premium cars
			end
			return v[1], tonumber(v[2])
		end

		return "INVALID (Model: "..veh..")", 0
	end

	return "INVALID", 0
end



exports("getUserVehiclesTbl", function(user_id)
	if vRP.usersData[user_id] and vRP.usersData[user_id].userVehicles then
		return vRP.usersData[user_id].userVehicles
	end

	return {}
end)

exports("getTotalVehicles", function(user_id)
	local total = 0
	for k in pairs(vRP.usersData[user_id].userVehicles or {}) do
		total = total + 1
	end

	return total
end)

exports("getTotalOutVehicles", function(user_id)
	local total = 0
	for k, veh in pairs(vRP.usersData[user_id].userVehicles or {}) do
		if veh.state == 2 then
			total = total + 1
		end
	end
	
	return total
end)

exports("isUserOwningVehicle", function(user_id, vehicle)
	if vRP.usersData[user_id].userVehicles[vehicle] then
		return true
	end

	return false
end)


function vRP.generatePlateNumber()
	local plate = "LS "
	for i=1, 2 do
	  plate = plate..math.random(1, 9)
	end
	for i=1, 3 do
	  plate = plate..characters[math.random(1, #characters)]
	end
	return plate
end

function vRP.updateCarPlate(user_id, vehicle, plate)
	if vRP.usersData[user_id].userVehicles[vehicle] then
		vRP.usersData[user_id].userVehicles[vehicle].carPlate = plate
		exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = vehicle}, update = {
			["$set"] = {carPlate = plate}
		}})
	end
end

function vRP.getVehicleType(user_id, vehicle)
	if vRP.usersData[user_id] and vRP.usersData[user_id].userVehicles then
		if vRP.usersData[user_id].userVehicles[vehicle] then
			return vRP.usersData[user_id].userVehicles[vehicle].vtype
		end
	end

	return false
end

function vRP.getPlayerVehLimit(user_id)
	if vRP.usersData[user_id] then
	  return tonumber(vRP.usersData[user_id].vehLim)
	end
	return 0
end
  
function vRP.setPlayerVehLimit(user_id, limit)
	exports.mongodb:updateOne({collection = "users", query = {id = user_id}, update = {['$set'] = {['userLimits.vehLim'] = limit}}})
	if vRP.usersData[user_id] then
		vRP.usersData[user_id].vehLim = tonumber(limit)
	end
end
  
AddEventHandler("vRP:playerJoin",function(user_id,source,name,extraData)
	if vRP.usersData[user_id] then
	  local limits = extraData.limits or {}
	  vRP.usersData[user_id].vehLim = limits.vehLim or 20
	end
end)

RegisterServerEvent("vrp-garages:saveStates", function(vehicles)
	local player = source
	local user_id = vRP.getUserId(player)

	for model, data in pairs(vehicles or {}) do
		if vRP.usersData[user_id].userVehicles[model] then
			vRP.usersData[user_id].userVehicles[model].vehStatus = data
		end
	end
end)

RegisterServerEvent('vrp-custom:getMoney', function()
    local player = source
    local user_id = vRP.getUserId(player)
    local money = math.floor(vRP.getBankMoney(user_id) + vRP.getMoney(user_id))
    
    TriggerClientEvent('vrp-custom:setMoney', player, money)
end)

RegisterServerEvent('vrp-custom:removeMoney', function(money)
    local player = source
    local user_id = vRP.getUserId(player)
    vRPclient.getNearestOwnedVehicle(player, {2}, function(vehicle)
		vRP.tryFullPayment(user_id, money, false, false, "Tunning ("..(vehicle or "unknown")..")")
    end)
end)

AddEventHandler("vRP:playerSpawn", function(user_id,source,first_spawn,dbdata)
	if first_spawn then
		Citizen.Wait(5500)

        local userVehicles = {}
        for i, data in pairs(dbdata.userVehicles or {}) do
			data._id = nil
			data.user_id = nil
            userVehicles[data.vehicle] = data
        end

		if vRP.usersData[user_id] then
        	vRP.usersData[user_id].userVehicles = userVehicles
		end
	end
end)

AddEventHandler('vRP:playerLeave', function(user_id, player, spawned)
	if not spawned then return end
	for model, data in pairs(vRP.usersData[user_id].userVehicles or {}) do
		exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = model}, update = {["$set"] = data}})
	end
end)

-- Impozit AUTO --
local feeTypes <const> = {
	["ds"] = true,
	["avion"] = true,
	["elicopter"] = true,
	["boat"] = true,
	["van"] = true,
	["truck"] = true,
	["trailer"] = true,
}

function getUserVehTax(user_id, cbr)
	local task = Task(cbr, {0})
	local totalTax = 0
	local theVehs = vRP.usersData[user_id].userVehicles[user_id] or {}
	for vname, tbl in pairs(theVehs) do
		if tbl and feeTypes[tbl.vtype or "ds"] then
			local vehModel = tostring(vname)
			local vehName, vehPrice = vRP.checkVehicleName(vehModel, true)
			local vehTax = math.ceil(vehPrice * 0.0015)
			totalTax = totalTax + vehTax
		end
	end
	task({math.ceil(totalTax)})
end

----- Impozit AUTO -----

exports("getUserVehiclesByGarage", function(user_id, gtype)
	local vehicles = {}
	local gcfg = vehicle_groups[gtype]._config
	local vtype = gcfg.vtype

	local user = vRP.getUser(user_id)

	local out, total = 0, 0

	if vtype == "car" then
		for k, vehicle in pairs(vehicle_groups[gtype]) do
			
			if k ~= "_config" then
				vehicles[k] = {
					name = vehicle[1],
					vehicle = k,
					vtype = vtype,
					carPlate = gcfg.vehPlate,
				}

				total = total + 1
			end
		end

	else

		for model, vehicle in pairs(user.userVehicles or {}) do
			if vehicle.vtype == vtype then
				vehicles[model] = vehicle
				
				if vehicle.state == 2 then
					out = out + 1
				end

				total = total + 1
			end
		end
	end

	return vehicles, total, out
end)




-- -- menu related

function vRP.openGarage(user_id, player, gtype)
	
	local vehicles, total, out = exports.vrp:getUserVehiclesByGarage(user_id, gtype)
	
	if total > 0 then
		local data = {
			out = out,
			vehicles = vehicles,
			gtype = gtype
		}


		TriggerClientEvent("vrp:sendNuiMessage", player, {interface = "garage", data = data})

	else
		vRPclient.notify(player, {"Nu ai vehicule in garaj.", "error"})
	end
end

RegisterServerEvent("vrp-garages:openGarage", function(gtype)
	local player = source
	local user_id = vRP.getUserId(player)

	vRP.openGarage(user_id, player, gtype)
end)

-- -- admin commands

RegisterCommand('givecar', function(player, args)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) >= 5 then
		local target_id = parseInt(args[1])
		local model = tostring(args[2])
		local vtype = tostring(args[3])

		if not target_id or not model then
			return
		end

		if not target_id or not model or not vtype then
			vRPclient.sendSyntax(player, {'/givecar <id> <model> <vtype>'})
			return
		end

		local carPlate = "RX00ERR"
		local function searchOne()
			carPlate = vRP.generatePlateNumber()
		
			getIdentifierByPlateNumber(carPlate, function(onePlate)
				if not onePlate or onePlate ~= 0 then
					searchOne()
				end
			end)
		end
		searchOne()

		local newVehicle = {
			user_id = target_id,
			vehicle = model,
			vtype = vtype,
			name = cfg_vehicles[vtype] and cfg_vehicles[vtype][model] or 'Necunoscut',
			carPlate = carPlate,
			trunk = {},
			glovebox = {},
			state = 1,
		}

		exports.mongodb:find({collection = "userVehicles"}, function(success, result)
			for k,v in pairs(result) do
				if result[1].user_id == target_id and result[1].vehicle == model then
					return
				end
			end
		end)

		exports.mongodb:insertOne({collection = "userVehicles", document = newVehicle})
		vRP.addCacheVehicle(target_id, newVehicle)
	end
end)

RegisterCommand("de", function(player)
	local ped = GetPlayerPed(player)
	local pedPos = GetEntityCoords(ped)
	local user_id = vRP.getUserId(player)
  
	if vRP.getUserAdminLevel(user_id) >= 1 then
  
		vRPclient.getNearestVehicle(player, {3.0, true}, function(vehNetworkId)
			if vehNetworkId then
				local vehicle = NetworkGetEntityFromNetworkId((vehNetworkId == 0) and GetVehiclePedIsIn(ped, false) or vehNetworkId)

				if DoesEntityExist(vehicle) then
					DeleteEntity(vehicle)
					vRPclient.notify(player, {"Vehiculul a fost sters.", "info"})
				else
			  		vRPclient.notify(player, {"Vehiculul nu poate fi sters.", "error"})
				end
			end
			
		end)
	else
		vRPclient.noAccess(player)  
	end
end)
  
RegisterCommand("dv", function(player)
	vRPclient.executeCommand(player, {"de"})
end)

RegisterCommand("fix", function(source)
	local user_id = vRP.getUserId(source)
	if vRP.getUserAdminLevel(user_id) >= 2 then
		TriggerClientEvent("vehicle:fix", source)
	else
		vRPclient.noAccess(source)
	end
end)

RegisterCommand("dearea", function(player, args)
	local user_id = vRP.getUserId(player)
	if vRP.getUserAdminLevel(user_id) >= 2 then
	  local radius = tonumber(args[1])
	  if radius and radius > 0 and radius <= 100 then

		vRPclient.getNearestVehicles(player, {radius}, function(nearestVehciles)
			local deletedEnts = 0
			for _, vehNetworkId in pairs(nearestVehciles) do
				if vehNetworkId and vehNetworkId ~= 0 then 
					local vehicle = NetworkGetEntityFromNetworkId(vehNetworkId)

					if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == 0 then
						DeleteEntity(vehicle)
						deletedEnts += 1
					end
				end
			end

			vRPclient.msg(player, {"^2Succes: ^7Ai sters in total ^1"..deletedEnts.." ^7(de) vehicule."})
		end)
	  else
		vRPclient.sendSyntax(player, {"/dearea <raza (1-100)>"})
	  end
	else
	  vRPclient.noAccess(player)
	end
end)
  
RegisterCommand("dvarea", function(player, args)
	vRPclient.executeCommand(player, {"dearea "..(args[1] or "")})
end)

-- -- client events

registerCallback('vehicleData', function(player, model, gtype)
	local user_id = vRP.getUserId(player)

	if vehicle_groups[gtype] and (vehicle_groups[gtype][model] or cfg_vehicles[model]) then
		local gcfg = vehicle_groups[gtype]._config

		if gcfg.vtype == "car" then
			local p = promise.new()

			if exports.vrp:isUserOwningVehicle(user_id, model) then
				p:resolve(vRP.getVehicleDataTable(user_id, model))
			else
				local vehicle = {user_id = user_id, vehicle = model, vtype = gcfg.vtype, name = vehicle_groups[gtype][model][1], carPlate = vRP.generatePlateNumber()}
				
				vRP.addCacheVehicle(user_id, vehicle)
				exports.mongodb:insertOne({collection = "userVehicles", document = vehicle})

				p:resolve(vehicle)
			end

			local vehTbl = Citizen.Await(p) or {}
			local state = vehTbl.vehStatus or {}

			return {vtype = gcfg.vtype, model = model, customization = state.customization or {}, state = {}, carPlate = vehTbl.carPlate or "RX00ERR", user_id = user_id}
		else

			local vehTbl = vRP.getVehicleDataTable(user_id, model)
			local out, max, vipRank = exports.vrp:getTotalOutVehicles(user_id), 3, vRP.getUserVipRank(user_id)

			if vipRank > 0 then
				max = (vipRank == 1) and 4 or 5
			end

			if (out < max) or vehTbl.state == 2 then
				local ok = promise.new()

				if vehTbl.state == 2 then
					vRP.request(player, "Vehiculul nu este parcat in garaj, vrei sa platesti o taxa de $"..cfg.already_out_tax.." pentru a il prelua?", false, function(_, pay)
						local canPay = (pay and vRP.tryPayment(user_id, cfg.already_out_tax, true, "Garage (Already Out)") or vRP.tryBankPayment(user_id, cfg.already_out_tax, true, "Garage (Already Out)"))
						
						ok:resolve(canPay)
					end)
				else
					ok:resolve(true)
				end

				if Citizen.Await(ok) then
					local state = vehTbl.vehStatus or {}

					vRP.setVehicleData(user_id, model, "state", 2)

					return {vtype = gcfg.vtype, model = model, customization = state.customization or {}, state = state, carPlate = vehTbl.carPlate or "RX00ERR", user_id = user_id}
				end
			else
				vRPclient.notify(player, {"Poti avea maxim 3 masini scoase afara din garaj.", "error"})
				return false;
			end
		end
	else
		vRPclient.notify(player, {"Masina spawnata este invalida.", "error"})
		return false;
	end

	return false;
end)

RegisterServerEvent("vrp-garages:despawn", function(gtype)
	local player = source
	local user_id = vRP.getUserId(player)

	vRPclient.getNearestOwnedVehicle(player, {5}, function(veh)
		if veh then
			local vtype = vRP.getVehicleType(user_id, veh)

			if vehicle_groups[gtype] then
				local gcfg = vehicle_groups[gtype]._config
				
				if gcfg.vtype == vtype then
					if gcfg.vtype ~= "car" then
						vRPclient.getVehicleState(player, {veh}, function(state)
							vRP.setVehicleData(user_id, veh, "vehStatus", state)
						end)
					end

					vRP.setVehicleData(user_id, veh, "state", 1)
					vRPclient.despawnGarageVehicle(player, {veh})
				else
					vRPclient.notify(player, {"Nu poti parca acest vehicul in garajul asta.", "error"})
				end
			end
		end
	end)
end)

-- -- actions

vRP.registerActionsMenuBuilder("basicply", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
	  	local choices = {}

		choices["Perchezitioneaza Vehicul"] = {function()
			vRPclient.getNearestPlayer(player, {2}, function(targetSrc)
				if not targetSrc then
					return vRPclient.notify(player, {"Nu ai niciun jucator in apropiere!", "error"})
				end

				vRPclient.getNearestOwnedVehicle(targetSrc, {10}, function(veh)
					if not veh then
						return vRPclient.notify(player, {"Jucatorul nu are o masina detinuta in apropiere!", "error"})
					end
					local target_id = vRP.getUserId(targetSrc)
					local vehicleData = vRP.getVehicleDataTable(target_id, veh)

					if vehicleData and vehicleData.trunkUsed then
						return vRPclient.notify(player, {"Portabajul este deja folosit de catre cineva!", "error"})
					end

					vRP.request(targetSrc, GetPlayerName(player).." vrea sa iti perchezitioneze masina. Accepti?", false, function(_, ok)
						if not ok then
							return vRPclient.notify(player, {"Jucatorul a refuzat perchezitia!", "error"})
						end
						local vehTrunk = vRP.getVehicleTrunk(target_id, veh)
						vehicleData.trunkUsed = true

						TriggerClientEvent('vrp-inventory:openChest', player, {
							name = 'Torpedou vehicul',
							type = 'trunk-player',
							chestData = {
								vehicle = veh,
								key = target_id,
							},
							maxWeight = cfg_inventory.chest_weights[veh] or 30,
							items = vehTrunk,
						 })
					end)
				end)
			end)
		end, "car.svg"}

		choices["Perchezitioneaza Torpedou"] = {function()
			vRPclient.getNearestPlayer(player, {2}, function(targetSrc)
				if not targetSrc then
					return vRPclient.notify(player, {"Nu ai niciun jucator in apropiere!", "error"})
				end

				vRPclient.getNearestOwnedVehicle(targetSrc, {10}, function(veh)
					if not veh then
						return vRPclient.notify(player, {"Jucatorul nu are o masina detinuta in apropiere!", "error"})
					end
					local target_id = vRP.getUserId(targetSrc)
					local vehicleData = vRP.getVehicleDataTable(target_id, veh)

					if vehicleData and vehicleData.gloveboxUsed then
						return vRPclient.notify(player, {"Torpedoul este deja folosit de catre cineva!", "error"})
					end

					vRP.request(targetSrc, GetPlayerName(player).." vrea sa iti perchezitioneze torpedoul. Accepti?", false, function(_, ok)
						if not ok then
							return vRPclient.notify(player, {"Jucatorul a refuzat perchezitia!", "error"})
						end
						local vehGlovebox = vRP.getVehicleGloveBox(target_id, veh)
						vehicleData.gloveboxUsed = true

						TriggerClientEvent('vrp-inventory:openChest', player, {
							name = 'Torpedou vehicul',
							type = 'glovebox-player',
							chestData = {
								vehicle = veh,
								key = target_id,
							},
							maxWeight = 5,
							items = vehGlovebox,
						 })
					end)
				end)
			end)
		end, "car.svg"}

		local ok = promise.new()
		vRPclient.getNearestOwnedVehicle(player, {10}, function(owned)
			ok:resolve(owned)
		end)

		if Citizen.Await(ok) then
			choices["Vinde vehicul"] = {function()
				vRPclient.getNearestOwnedVehicle(player, {10}, function(veh)
					if veh then
						vRPclient.getNearestPlayer(player, {2}, function(targetSrc)
							if targetSrc then
								local target_id = vRP.getUserId(targetSrc)
								local vehType = vRP.getVehicleType(user_id, veh)
	
								if not vehType then
									return vRPclient.notify(player, {"A aparut o eroare legat de vehicle type!", "error"})
								end
	
								if vehType == 'car' then
									vRPclient.notify(player, {"Nu poti vinde un vehicul de serviciu!", "error"})
								else
									vRP.prompt(player,"SELL VEHICLE", "Introdu in caseta de mai jos pretul cerut pe vehicul apoi apasa pe butonul de confirmare.", false, function(amount)
										amount = tonumber(amount)
										
										if amount and amount > 0 then
											
											if vRP.usersData[target_id].userVehicles[veh] then
												return vRPclient.notify(player, {"Acest jucator are deja acest vehicul!", "error"})
											end
				
											if vRP.usersData[user_id].userVehicles[veh].premium or vRP.usersData[user_id].userVehicles[veh].vip then
												return vRPclient.notify(player, {"Nu poti vinde vehiculele premium!", "error"})
											end
				
											vRP.request(player, "Vrei sa vinzi vehiculul pentru $"..amount.."?", false, function(_, ok)
												if ok then
													vRP.request(targetSrc, GetPlayerName(player).." vrea sa iti vanda "..cfg_vehicles[veh][1].." pentru $"..amount..". Accepti?", false, function(_, ok)
														if ok then
															if vRP.tryBankPayment(target_id, amount,false,"Buy Vehicle") or vRP.tryPayment(target_id, amount,false,"Buy Vehicle") then
																vRP.giveMoney(user_id,amount,"Sell Vehicle")
	
																exports.mongodb:updateOne({collection = "userVehicles", query = {user_id = user_id, vehicle = veh}, update = {["$set"] = {['user_id'] = target_id}}})
																vRP.usersData[target_id].userVehicles[veh] = deepcopy(vRP.usersData[user_id].userVehicles[veh])
																Citizen.Wait(500)
																vRP.usersData[user_id].userVehicles[veh] = nil
																vRPclient.despawnGarageVehicle(player, {veh})
																vRPclient.notify(player, {"Ai vandut vehiculul!", "success"})
																vRPclient.notify(targetSrc, {"Ai cumparat vehiculul!", "success"})
															else
																vRPclient.notify(targetSrc, {"Nu ai destui bani!", "error"})
																vRPclient.notify(player, {GetPlayerName(targetSrc).." nu are destui bani pentru a cumpara vehiculul!", "error"})
															end
														else
															vRPclient.notify(player, {"Jucatorul a refuzat oferta!", "error"})
														end
													end)
												end
											end)
										end
									end)
								end		
	
							else
								vRPclient.notify(player, {"Nu ai niciun jucator in apropiere!", "error"})
							end
						end)
					end
				end)
			end, "car.svg"}
		end
		add(choices)
	end
end)
