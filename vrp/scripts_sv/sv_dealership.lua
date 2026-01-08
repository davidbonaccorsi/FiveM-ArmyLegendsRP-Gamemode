local cfg = module("cfg/dealership")
local vehicles = module("cfg/vehicles")

local restock_classes = {
	['class_super'] = 5,
	['class_highend'] = 15,
	['class_midrange'] = 50,
	['class_lowend'] = 10000,
	['lowriders'] = 30,
	['wanted'] = 5,
	['class_retro'] = 5,
	['dube'] = 10000,
	['remorci'] = 10000,
	['motoare'] = 500,
	['avioane'] = 3,
	['elicoptere'] = 20,
	['barci'] = 300,
	['cayo'] = 25,
}

GlobalState["dealership_cfg"] = {}

Citizen.CreateThread(function()


	-- load vehicles from garage config
	for k, v in pairs(vehicles) do

		if not v[2] or type(v[2]) == 'string' then
			--  print('Missing price for vehicle '..k..' in cfg/vehicles.lua')
			return
		end 

		if v[2] and (v[2] >= 0) and v[3] then

			if not cfg.vehicles[v[3]] then
				cfg.vehicles[v[3]] = {}
			end

			cfg.vehicles[v[3]][k] = {
				name = v[1],
				price = v[2]
			}
		end
	end
	GlobalState["dealership_cfg"] = cfg
end)

function getIdentifierByPlateNumber(plate_number, cbr)
	local task = Task(cbr, {0}, 2000)
  
	exports.mongodb:count({collection = "userVehicles", query = {["carPlate"] = plate_number}}, function(success, result)
	  task({result})
	end)
end

local vehicleStock = {}

RegisterCommand('restockvehs', function(player)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) > 6 then
		for model, data in pairs(vehicles) do
			if restock_classes[data[3]] then

				if vehicleStock[model] then
					vehicleStock[model] += restock_classes[data[3]]
					exports.mongodb:updateOne({collection = "dealershipStocks", query = {model = model}, update = {['$inc'] = {stock = restock_classes[data[3]]}}})
				else
					vehicleStock[model] = restock_classes[data[3]]
					exports.mongodb:insertOne({collection = "dealershipStocks", document = {
						model = model,
						stock = restock_classes[data[3]]
					}})
				end
			end
		end

		TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 Dealershipul a fost suplimentat cu stock la toate categoriile disponibile!")
	else
		vRPclient.noAccess(player)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(5000)

	exports.mongodb:find({collection = "dealershipStocks", query = {}}, function(success, results)
		for k, res in pairs(results) do
			vehicleStock[res.model] = res.stock or 0
		end
	end)
end)

registerCallback("getDealershipStock", function(player, model)
	return vehicleStock[model] or 0
end)

RegisterServerEvent("vrp-dealership:purchaseModel", function(data)
	local model, category = data[1], data[2]
	local player = source
	local user_id = vRP.getUserId(player)

	if model and category then
		local vtype = cfg.vehicle_types[category] or "ds"
		local vehicle = cfg.vehicles[category][model]

		if vehicle then

			if not vehicleStock[model] or (vehicleStock[model] < 1) then
				vRPclient.notify(player, {"Nu mai exista masini de acest tip in stock.", "error"})
				return
			end

			if exports.vrp:isUserOwningVehicle(user_id, model) then
				return vRPclient.notify(source, {"Detii deja aceast vehicul intr-un garaj.", "error"})
			end
		
			if vRP.tryBankPayment(user_id, vehicle.price, true, "Dealership Purchase") then
				vRPclient.notify(source, {"Ai achizitionat "..vehicle.name, "info"})

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
					user_id = user_id,
					vehicle = model,
					vtype = vtype,
					name = vehicle.name,
					carPlate = carPlate,
					trunk = {},
					glovebox = {},
					state = 1,
				}

				if vtype == 'van' then
					exports.vrp:achieve(user_id, 'vanEasy', 1)
				end

				if not exports.vrp:hasCompletedBegginerQuest(user_id, 4) then
					exports.vrp:completeBegginerQuest(user_id, 4)
				end
				exports.vrp:achieve(user_id, 'DealershipEasy', 1)
				
				exports.mongodb:insertOne({collection = "userVehicles", document = newVehicle})
				vRP.addCacheVehicle(user_id, newVehicle)

				vRP.createLog(user_id, {price = vehicle.price, vehicle = model, vehicle_name = vehicle.name, plate = carPlate, name = GetPlayerName(player)}, "DealershipPurchase")

				vehicleStock[model] = math.max(0, (vehicleStock[model] or 0) - 1)
				exports.mongodb:updateOne({collection = "dealershipStocks", query = {model = model}, update = {
					["$inc"] = {stock = -1}
				}})

			else
				vRPclient.notify(player, {"Nu ai bani pentru a cumpara masina.", "error"})
			end
		end
	
	end
end)



RegisterCommand("addvehstocks", function(player, args)
	local user_id = vRP.getUserId(player)

	if vRP.getUserAdminLevel(user_id) > 5 then
		local addType = args[1]

		local stocks = tonumber(args[2])
		if not stocks then addType = "stocksInvalid" end

		if addType == "model" then
			local allVehs = GlobalState["dealership_cfg"].vehicles

			local model = args[3]

			if model and model:len() > 1 then


				local vehTitle
				for category, vehs in pairs(allVehs) do
					for index, vehData in pairs(vehs) do
						if index == model then
							vehTitle = vehData.name
							break
						end
					end
				end

				if vehTitle then

					exports.mongodb:updateOne({collection = "dealershipStocks", query = {model = model}, update = {['$inc'] = {stock = stocks}}})
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")

					Citizen.Wait(180000) -- 3 min

					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")


					Citizen.Wait(90000) -- 1.5 min

					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde Dealershipul va fi suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")

					Citizen.Wait(30000) -- 30 sec

					TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 Dealershipul a fost suplimentat cu ^1"..stocks.."^7 vehicule marca "..vehTitle..".")
					vehicleStock[model] = (vehicleStock[model] or 0) + stocks

				else
					vRPclient.sendError(player, {"Model invalid"})
				end

			else
				vRPclient.sendSytax(player, {"/addvehstocks <type> <stocksNr> <model-masina>"})
			end


		elseif addType == "all" then
			exports.mongodb:update({collection = "dealershipStocks", query = {}, update = {['$inc'] = {stock = stocks}}})

			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 5 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")

			Citizen.Wait(180000) -- 3 min

			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 2 minute ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")


			Citizen.Wait(90000) -- 1.5 min

			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 In 30 de secunde ^1TOT ^7Dealershipul va fi suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")

			-- Citizen.Wait(30000) -- 30 sec

			TriggerClientEvent("chatMessage", -1, "^9[ANUNT]^7 ^1TOT ^7Dealershipul a fost suplimentat cu ^1"..stocks.."^7 masini de fiecare model.")
			for index, v in pairs(vehicleStock) do
				vehicleStock[index] = (vehicleStock[index] or 0) + stocks
			end
		else
			vRPclient.sendSyntax(player, {"/addvehstocks <type> <stocksNr> [extra]"})
			vRPclient.msg(player, {"^1Add Types^7: model, all"})
		end
	else
		vRPclient.noAccess(player)
	end
end)

-- AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
--     if first_spawn then
-- 		if #(GetEntityCoords(source) - vector3(-2041.4372558594,-370.83056640625,48.956912994385)) <= 20 then
-- 			tvRP.teleport(user_id,-33.440937042236,-1097.279296875,27.274379730225)
-- 		end
-- 	end
-- end)

local playerLoaded = {}
AddEventHandler("vRPcli:playerSpawned", function()
    local player = source
	local user_id = vRP.getUserId(player)
    
    if not playerLoaded[player] then
		if #(GetEntityCoords(GetPlayerPed(player)) - vector3(-2041.4372558594,-370.83056640625,48.956912994385)) <= 20 then
			tvRP.teleport(user_id,-33.440937042236,-1097.279296875,27.274379730225)
		end
      	playerLoaded[player] = true
    end
end)