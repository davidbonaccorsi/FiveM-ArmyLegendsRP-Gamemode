local cfg_vehicles = module("cfg/vehicles")
local cfg = module("cfg/garages")

DecorRegister("veh_user_id", 3)
DecorRegister("veh_vtype", 3)
DecorRegister("veh_model", 3)
DecorRegister("veh_km", 1)
DecorRegister("veh_job", 2)

local vehicles = {}
local veh_models = {}
local cachedHash = {}

local check_interval = 15 -- seconds
local update_interval = 30 -- seconds
local repair_cost = 1000

local function enumVehicles()
  local vehs = {}
  local it, veh = FindFirstVehicle()
  if veh then table.insert(vehs, veh) end
  local ok
  repeat
    ok, veh = FindNextVehicle(it)
    if ok and veh then table.insert(vehs, veh) end
  until not ok
  EndFindVehicle(it)

  return vehs
end

local function setVehicleState(veh, state)
	if state.condition then
		if state.condition.health then
			SetEntityHealth(veh, state.condition.health + 0.0)
		end

		if state.condition.engine_health then
			SetVehicleEngineHealth(veh, state.condition.engine_health + 0.0)
		end
		
		if state.condition.body_health then
			SetVehicleBodyHealth(veh, state.condition.body_health + 0.0)
		end

		if state.condition.petrol_tank_health then
			SetVehiclePetrolTankHealth(veh, state.condition.petrol_tank_health + 0.0)
		end

		if state.condition.km then
			DecorSetFloat(veh, "veh_km", tonumber(state.condition.km) + 0.0)
		else
			DecorSetFloat(veh, "veh_km", 0.0)
		end

		if state.condition.dirt_level then
			SetVehicleDirtLevel(veh, state.condition.dirt_level)
		end

		if state.condition.windows then
			for i, window_state in pairs(state.condition.windows) do
				if not window_state then
					SmashVehicleWindow(veh, tonumber(i))
				end
			end
		end

		if state.condition.tyres then
			for i, tyre_state in pairs(state.condition.tyres) do
				if tyre_state < 2 then
					SetVehicleTyreBurst(veh, tonumber(i), (tyre_state == 1), 1000.01)
				end
			end
		end

		if state.condition.doors then
			for i, door_state in pairs(state.condition.doors) do
				if not door_state then
					SetVehicleDoorBroken(veh, tonumber(i), true)
				end
			end
		end

		if state.condition.fuel_level then
			local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))

			if isModelElectric(model) then
				setModelElectricFuel(veh, tonumber(state.condition.fuel_level))
			else    
			    DecorSetFloat(veh, 'customFuel', tonumber(state.condition.fuel_level) + 0.0)
			    SetVehicleFuelLevel(veh, tonumber(state.condition.fuel_level) + 0.0)
			end
		end
	end

	if state.locked ~= nil then
		if state.locked then -- lock
			SetVehicleDoorsLocked(veh, 2)
			SetVehicleDoorsLockedForAllPlayers(veh, true)
		else -- unlock
			SetVehicleDoorsLockedForAllPlayers(veh, false)
			SetVehicleDoorsLocked(veh, 1)
			SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
		end
	end
end

-- [GARAGE FUNCTIONS]

exports("checkVehicle", function(veh)
	if veh and DecorExistOn(veh, "veh_user_id") then
		local model = cachedHash[GetEntityModel(veh)]
		if model then
		  	return DecorGetInt(veh, "veh_user_id"), model
		end
	end
end)

function tvRP.getVehicleState(vname)
	local veh = vehicles[vname]

	if not veh then return end

	local state = {
		customization = getVehicleCustomization(veh[2]),
		condition = {
			health = GetEntityHealth(veh[2]),
			engine_health = GetVehicleEngineHealth(veh[2]),
			body_health = GetVehicleBodyHealth(veh[2]),
			petrol_tank_health = GetVehiclePetrolTankHealth(veh[2]),
			dirt_level = GetVehicleDirtLevel(veh[2]),
			km = DecorGetFloat(veh[2], "veh_km"),
			fuel_level = isModelElectric(vname) and getModelElectricFuel(veh[2]) or math.ceil(GetVehicleFuelLevel(veh[2])),
		},
		vehData = {
			engine = math.floor(((GetVehicleModelEstimatedMaxSpeed(GetHashKey(vname)) or 0.0) / 10 ) + ((GetVehicleModelAcceleration(GetHashKey(vname)) or 0.0) * 10)) / 2,
			braking = GetVehicleModelMaxBraking(GetHashKey(vname)) or 0.0
		}
	}

	state.condition.windows = {}
	for i = 0, 7 do
		state.condition.windows[i] = IsVehicleWindowIntact(veh[2], i)
	end

	state.condition.tyres = {}
	for i = 0, 7 do
		local tyre_state = 2 -- 2: fine, 1: burst, 0: completely burst
		if IsVehicleTyreBurst(veh[2], i, true) then
			tyre_state = 0
		elseif IsVehicleTyreBurst(veh[2], i, false) then
			tyre_state = 1
		end

		state.condition.tyres[i] = tyre_state
	end

	state.condition.doors = {}
	for i = 0, 5 do
		state.condition.doors[i] = not IsVehicleDoorDamaged(veh[2], i)
	end

	state.locked = (GetVehicleDoorLockStatus(veh[2]) >= 2)

	return state
end

function tvRP.setPremiumXenon(veh, color)
	if IsEntityAVehicle(veh) then
		ToggleVehicleMod(veh, 22, true)
		Citizen.InvokeNative(0xE41033B25D003A07, veh, color)
	end
end

function tvRP.getNearestVehicles(radius)
	local pedPos = GetEntityCoords(PlayerPedId())
	local vehs = {}
	local handle, vehicle = FindFirstVehicle()
	local finished = false

	repeat
		if DoesEntityExist(vehicle) then
			local dst = #(GetEntityCoords(vehicle) - pedPos)

			if dst < radius then
				table.insert(vehs, NetworkGetNetworkIdFromEntity(vehicle))
			end
		end
		finished, vehicle = FindNextVehicle(handle)
	until not finished
	EndFindVehicle(handle)

	return vehs
end

function tvRP.isMyVehicleUsed(vname)
	local vehicle = vehicles[vname]
	if vehicle and (GetPedInVehicleSeat(vehicle[2], -1) == 0) then
		return false
	end
	return true
end 

function tvRP.getNearestVehicle(radius, retNetworkId)
	local ped = GetPlayerPed(-1)
	if IsPedSittingInAnyVehicle(ped) then
		if retNetworkId then
			return NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(ped, true))
		else
			return GetVehiclePedIsIn(ped, true)
		end
	else
		local pedPos = GetEntityCoords(ped)
		local veh = GetClosestVehicle(pedPos, radius+0.0001, 0, 7)

		if veh ~= 0 then
			if retNetworkId then
				return NetworkGetNetworkIdFromEntity(veh)
			else
				return veh
			end
		else
			local handle, vehicle = FindFirstVehicle()
			local finished = false
			local minPos = radius + 1

			repeat
				if DoesEntityExist(vehicle) then
					local dst = #(GetEntityCoords(vehicle) - pedPos)

					if dst < radius and dst < minPos then
						minPos, veh = dst, vehicle
					end
				end
				finished, vehicle = FindNextVehicle(handle)
			until not finished
			EndFindVehicle(handle)

			if veh ~= 0 then
				if retNetworkId then
					return NetworkGetNetworkIdFromEntity(veh)
				else
					return veh
				end
			else
				return 0
			end
		end
	end
end


function tvRP.tryOwnNearestVehicle(radius)
    local veh = tvRP.getNearestVehicle(radius)
    if veh then
        local veh_uid, vname = exports.vrp:checkVehicle(veh)
        if veh_uid and tonumber(veh_uid) == tonumber(exports.vrp:getMyUserId()) then
            if vehicles[vname] ~= veh then
                vehicles[vname] = veh
            end
        end
    end
end

function tvRP.isPlayerInAnyVehicle(eject)
	local ped = PlayerPedId()
	if IsPedSittingInAnyVehicle(ped) then
		if eject then
			TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, true), 16)
		end
		return true
	end

	return false
end

function tvRP.isInOwnedCar(name)
    local vehicle = vehicles[name]
    if vehicle then
        if playerVehicle ~= 0 then
            if vehicle[2] == playerVehicle then
                return true
            end
        end
    end

    return false
end

function tvRP.getVehicleAtPosition(startVector)
  local foundVehs = EnumerateEntitiesWithinDistance(GetGamePool("CVehicle"), startVector, 5.0)
  
  if #foundVehs > 0 then
    return foundVehs
  end

  return false
end

function tvRP.getNearestOwnedVehicle(radius)
	local nearestVehs = tvRP.getNearestVehicles(20.0)

    local pedPos = GetEntityCoords(PlayerPedId())
	local user_id = tonumber(Player(GetPlayerServerId(tempPlayer)).state.user_id)

	for i in pairs(nearestVehs) do
		local veh = NetworkGetEntityFromNetworkId(nearestVehs[i])
		local cid, model = exports.vrp:checkVehicle(veh)
		
		if (cid == user_id) and model then
			local vehDst = #(pedPos - GetEntityCoords(veh))
			if vehDst <= radius + 0.0 and model then
				if not vehicles[model] then
					vehicles[model] = {model, veh}
				end
				vehicles[model][2] = veh

				return model
			end
		end
	end

	return false
end

function tvRP.getAnyOwnedVehiclePosition()
	for k,v in pairs(vehicles) do
		if IsEntityAVehicle(v[2]) then
			local x,y,z = table.unpack(GetEntityCoords(v[2],true))
			return true,x,y,z
		end
	end

	return false,0,0,0
end

function tvRP.getPersonalVehicle()
	for _, data in pairs(vehicles) do
		if IsEntityAVehicle(data[2]) then
			return data[2]
		end
	end

	return false
end

-- return x,y,z
function tvRP.getOwnedVehiclePosition(vname)
	local vehicle = vehicles[vname]
	local x,y,z = 0,0,0

	if vehicle then
		x,y,z = table.unpack(GetEntityCoords(vehicle[2],true))
	end

	return x,y,z
end

-- return ok, vehicule network id
function tvRP.getOwnedVehicleId(vname)
	local vehicle = vehicles[vname]
	if vehicle then
		return true, NetworkGetNetworkIdFromEntity(vehicle[2])
	else
		return false, 0
	end
end

-- eject the ped from the vehicle
function tvRP.ejectVehicle()
	local ped = GetPlayerPed(-1)
	if IsPedSittingInAnyVehicle(ped) then
		local veh = GetVehiclePedIsIn(ped,false)
		TaskLeaveVehicle(ped, veh, 4160)
	end
end

function tvRP.fixNearestVeh(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function tvRP.replaceNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    if GetEntitySpeed(veh)*3.6 < 10 then
      SetVehicleOnGroundProperly(veh)
    else
      tvRP.notify("Vehiculul trebuie sa stea pe loc!", "error")
    end
  end
end

function tvRP.getRepairCost(model, state)
	local vehicle = vehicles[model]
	local price = 0

	if vehicle then
		local vehHealth = (GetVehicleBodyHealth(vehicle[2]) / 10) -- 0 - 100
		local engine_health = (state.condition.engine_health / 10) -- 0 - 100
		local petrol_tank_health = (state.condition.petrol_tank_health / 10) -- 0 - 100
		local dmg = 0

		if vehHealth <= 0 then
			vehHealth = 0
		end
		if engine_health <= 0 then
			engine_health = 0
		end
		if petrol_tank_health <= 0 then
			petrol_tank_health = 0
		end

		while dmg + vehHealth + engine_health + petrol_tank_health < 300 do
			dmg = dmg + 1
			Citizen.Wait(0)
		end

		if dmg > 0 then
			price = math.floor((repair_cost / 100) * dmg) -- percententage based on vehHealth
		end
	end

	return price
end

function tvRP.repairVehicle(model)
	local vehicle = vehicles[model]

	if vehicle then
		local veh = vehicle[2]
		local fuel

		local electric = isModelElectric(model)

		if electric then
			fuel = getModelElectricFuel(veh)
		else
			fuel = GetVehicleFuelLevel(veh)
		end

		FreezeEntityPosition(veh, true)
		TriggerEvent("vrp:progressBar", {
			duration = 5000,
			text = "Iti este reparata masina..",
		})
		Citizen.Wait(5000)

		SetVehicleFixed(veh)
		if electric then
			setModelElectricFuel(veh, fuel)
		else
			SetVehicleFuelLevel(veh, fuel)
		end
		FreezeEntityPosition(veh, false)
		return true
	end
end

function tvRP.isInAnyCar()
	return (IsPedInAnyVehicle(PlayerPedId(), true) or false)
end

-- [GARAGE THREADS]

local isInVehicle = false
local oldpos = 0;
local vehicle_odometer = false
AddEventHandler('vrp:onPlayerLeaveVehicle', function()
    isInVehicle = false
	vehicle_odometer = false
end)

AddEventHandler('vrp:onPlayerEnterVehicle', function(veh, isDriver)
	if not isDriver then
		return
	end
	isInVehicle = true
	
	while isInVehicle do
		if vehicle_odometer then
			if IsVehicleOnAllWheels(veh) then
				local coords = GetEntityCoords(veh)
				if oldpos ~= nil then
					local dist = #(coords - oldpos)
					vehicle_odometer = vehicle_odometer + dist
					DecorSetFloat(veh, "veh_km", vehicle_odometer)
				end
				oldpos = coords
			end
		else
			vehicle_odometer = DecorGetFloat(veh, "veh_km") or 0
		end
		Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(update_interval * 1000)

		local states = {}
		for model, veh in pairs(vehicles) do
			if IsEntityAVehicle(veh[2]) then
				local state = tvRP.getVehicleState(model)
				
				states[model] = state
			end 
		end

		TriggerServerEvent("vrp-garages:saveStates", states)
	end 
end)

Citizen.CreateThread(function()
    Wait(5000)
    for model in pairs(cfg_vehicles) do
        local hash = GetHashKey(model)
        if hash then
            cachedHash[hash] = model
        end
    end
end)

Citizen.CreateThread(function()
	for i, garage in pairs(cfg.garages) do
		if not cfg.garage_types[garage[1]] then goto skipGarage end

		local data = cfg.garage_types[garage[1]]._config
		if not data then goto skipGarage end
		
		local coords = garage[2]

		if data.blipid and not garage.hidden then
			tvRP.addBlip("vRP:garage"..i, coords[1], coords[2], coords[3], data.blipid, data.blipcolor, "Garaj ("..garage[1]..")", 0.5)
		end
       
		tvRP.setArea("vRP:garage_"..i, coords[1], coords[2], coords[3], 15,
        {key = 'E', text = data.text or "Acceseaza garajul"},
        {
			type = 25,
			x = 1.6,
			y = 1.6,
			z = 0.25,
			color = data.iconColor or {255, 255, 255, 150},
			coords = {coords[1], coords[2], coords[3] - 0.9},
        },
        function()
			if data.faction and not (data.faction == LocalPlayer.state.faction) then
				return tvRP.notify('Nu poti accesa acest garaj!', 'error')
			end

			TriggerServerEvent("vrp-garages:openGarage", garage[1])
        end)

		::skipGarage::
	end
end) 

Citizen.CreateThread(function()
	local user_id = tonumber(Player(GetPlayerServerId(tempPlayer)).state.user_id)
	while true do
		for model, veh in pairs(vehicles) do
			if not DoesEntityExist(veh[2]) or not IsEntityAVehicle(veh[2]) then
				vehicles[model] = nil
			end
		end
		for _, veh in ipairs(enumVehicles()) do
			local cid, model = exports.vrp:checkVehicle(veh)
			if (cid == user_id) then
				if model and not vehicles[model] then
					vehicles[model] = {model, veh}
				end
			end
		end
		Citizen.Wait(check_interval * 1000)
	end
end)

function tvRP.loadVehicle(veh)
	local p = promise.new()
	local vehHash = joaat(veh)

	Citizen.CreateThread(function()
		local timer = GetGameTimer() + 10000

        RequestModel(vehHash)
		
		while not HasModelLoaded(vehHash) do
			Citizen.Wait(16)

			if GetGameTimer() > timer then return p:resolve(false) end
		end

		p:resolve(vehHash)
	end)

	return Citizen.Await(p)
end

exports('loadVehicle', tvRP.loadVehicle)

function tvRP.despawnGarageVehicle(vname,max_range)
	local vehicle = vehicles[vname]
		if vehicle then
			SetVehicleHasBeenOwnedByPlayer(vehicle[2],false)
			Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[2], false, true) -- set not as mission entity
			SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[2]))
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[2]))

			if DoesEntityExist(vehicle[2]) then
				tvRP.notify("A aparut o problema la despawnarea masinii.", "error")
				return false
			else
				vehicles[vname] = nil
				return true
			end
		end
	return false
end


function getVehicleCustomization(veh)
	local custom = {}
  
	custom.colours = {GetVehicleColours(veh)}
	custom.extra_colours = {GetVehicleExtraColours(veh)}
	custom.plate_index = GetVehicleNumberPlateTextIndex(veh)
	custom.wheel_type = GetVehicleWheelType(veh)
	custom.window_tint = GetVehicleWindowTint(veh)
	custom.livery = GetVehicleLivery(veh)

	custom.xenon = GetVehicleXenonLightsColor(veh)

	print(IsVehicleNeonLightEnabled(veh, 2))

	if IsVehicleNeonLightEnabled(veh, 2) then
	    custom.neonColor = table.pack(GetVehicleNeonLightsColour(veh))

		print(json.encode(custom.neonColor))
	end
  
	if IsVehicleExtraTurnedOn(veh, 1) then
	    custom.extra1 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 2) then
	    custom.extra2 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 3) then
	    custom.extra3 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 4) then
	    custom.extra4 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 5) then
	    custom.extra5 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 6) then
	    custom.extra6 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 7) then
	    custom.extra7 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 8) then
	    custom.extra8 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 9) then
	    custom.extra9 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 10) then
	    custom.extra10 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 11) then
	    custom.extra11 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 12) then
	    custom.extra12 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 13) then
	    custom.extra13 = true
	end
  
	if IsVehicleExtraTurnedOn(veh, 14) then
	    custom.extra14 = true
	end
  
	custom.tyre_smoke_color = {GetVehicleTyreSmokeColor(veh)}
  
	custom.mods = {}
	
	for i = 0, 49 do
	    custom.mods[i] = GetVehicleMod(veh, i)
	end
	
	custom.variation = GetVehicleModVariation(veh, 23)
  
	custom.turbo_enabled = IsToggleModOn(veh, 18)
	custom.smoke_enabled = IsToggleModOn(veh, 20)
  
	custom.culoarer, custom.culoareg, custom.culoareb = GetVehicleCustomPrimaryColour(veh)
	custom.culoaresr, custom.culoaresg, custom.culoaresb = GetVehicleCustomSecondaryColour(veh)
  
	return custom
end
  
function setVehicleCustomization(veh, custom)
	SetVehicleModKit(veh, 0)
  
	if custom.colours then
		SetVehicleColours(veh, table.unpack(custom.colours))
	end
  
	if custom.culoarer then
	    SetVehicleCustomPrimaryColour(veh, custom.culoarer, custom.culoareg, custom.culoareb)
	end
  
	if custom.culoaresr then
	    SetVehicleCustomSecondaryColour(veh, custom.culoaresr, custom.culoaresg, custom.culoaresb)
	end
  
	if custom.extra_colours then
	    SetVehicleExtraColours(veh, table.unpack(custom.extra_colours))
	end
  
	if custom.plate_index then
	    SetVehicleNumberPlateTextIndex(veh, custom.plate_index)
	end
  
	if custom.wheel_type then
	    SetVehicleWheelType(veh, custom.wheel_type)
	end
  
	if custom.window_tint then
	    SetVehicleWindowTint(veh, custom.window_tint)
	end
  
	if custom.livery then
	    SetVehicleLivery(veh, custom.livery)
	end
  
	if custom.extra1 then
	    SetVehicleExtra(veh, 1, 0)
	end
  
	if custom.extra2 then
	    SetVehicleExtra(veh, 2, 0)
	end
  
	if custom.extra3 then
	    SetVehicleExtra(veh, 3, 0)
	end
  
	if custom.extra4 then
     	SetVehicleExtra(veh, 4, 0)
	end
  
	if custom.extra5 then
	    SetVehicleExtra(veh, 5, 0)
	end
  
	if custom.extra6 then
	    SetVehicleExtra(veh, 6, 0)
	end
  
	if custom.extra7 then
	    SetVehicleExtra(veh, 7, 0)
	end
  
	if custom.extra8 then
	    SetVehicleExtra(veh, 8, 0)
	end
  
	if custom.extra9 then
	    SetVehicleExtra(veh, 9, 0)
	end
  
	if custom.extra10 then
	    SetVehicleExtra(veh, 10, 0)
	end
  
	if custom.extra11 then
	    SetVehicleExtra(veh, 11, 0)
	end
  
	if custom.extra12 then
	    SetVehicleExtra(veh, 12, 0)
	end
  
	if custom.extra13 then
	    SetVehicleExtra(veh, 13, 0)
	end
  
	if custom.extra14 then
	    SetVehicleExtra(veh, 14, 0)
	end
  
	if custom.tyre_smoke_color then
	    SetVehicleTyreSmokeColor(veh, table.unpack(custom.tyre_smoke_color))
	end

	if custom.xenon then
		tvRP.setPremiumXenon(veh, custom.xenon)
	end

	if custom.neonColor then
		local r, g, b = table.unpack(custom.neonColor)

		for i = 0, 3 do
			SetVehicleNeonLightEnabled(veh, i, true)
		end

		SetVehicleNeonLightsColour(veh, r, g, b)
	end
  
	if custom.mods then
	    for i, mod in pairs(custom.mods) do
	    	local status = false

	    	if tonumber(i) == 23 and custom.variation == 1 then
	    	    status = true
	    	end

	    	SetVehicleMod(veh, tonumber(i), mod, status)
	    end
	end
  
	if custom.turbo_enabled ~= nil then
	    ToggleVehicleMod(veh, 18, custom.turbo_enabled)
	end
  
	if custom.smoke_enabled ~= nil then
	    ToggleVehicleMod(veh, 20, custom.smoke_enabled)
	end
end

local performanceModIndices = {11,12,13,16}
function performanceUpgradeVehicle(vehicle)
    local max
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        for _, modType in ipairs(performanceModIndices) do
            max = GetNumVehicleMods(vehicle, modType) - 1
            SetVehicleMod(vehicle, modType, max, false)
        end
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
    end
end
  
-- [EVENTS]

RegisterNUICallback("garages:spawn", function(data, cb)
	TriggerEvent("vrp:interfaceFocus", false)

	if IsPedInAnyVehicle(tempPed) then
		return TriggerEvent('vrp-hud:notify', 'Nu poti scoate nimic din garaj cat timp esti intr-un vehicul', 'error')
	end

	triggerCallback('vehicleData', function(data)
		if not data then return end

		if vehicles[data.model] and vehicles[data.model][2] then
			if DoesEntityExist(vehicles[data.model][2]) and not (GetPedInVehicleSeat(veh, 0) ~= 0) then
				DeleteEntity(vehicles[data.model][2])
			end
		end

		local vehHash = exports.vrp:loadVehicle(data.model)

		if not HasModelLoaded(vehHash) then
			return tvRP.notify('Nu ti-am putut incarca vehiculul!', 'error')
		end

		if not cachedHash[vehHash] then
			cachedHash[vehHash] = data.model
		end

		local pedCoords = GetEntityCoords(tempPed)

		local nveh = CreateVehicle(vehHash, pedCoords, GetEntityHeading(tempPed), true)

		NetworkFadeInEntity(nveh, 0)
		SetVehicleNumberPlateText(nveh, data.carPlate)

		SetPedIntoVehicle(tempPed, nveh, -1)
		SetVehicleOnGroundProperly(nveh)

		SetEntityInvincible(nveh, false)
		DecorSetInt(nveh, "veh_user_id", tonumber(data.user_id))

		if cfg.defaultTunning[data.model] then
			if cfg.defaultTunning[data.model].tunning then
				performanceUpgradeVehicle(nveh)
			end

			if cfg.defaultTunning[data.model].windows_tint then
				SetVehicleWindowTint(nveh, 1)
			end
		end

		if data.customization then
			setVehicleCustomization(nveh, data.customization)
		end
		
		vehicles[data.model] = {data.model, nveh}
	
		if data.state then
			setVehicleState(nveh, data.state)
		else
			if isModelElectric(data.model) then
				setModelElectricFuel(nveh, 100)
			else
				SetVehicleFuelLevel(nveh, 100.0)
				DecorSetFloat(nveh, 'customFuel', 100.0)
			end
		end

	end, data[1], data[3])

	cb("ok")
end)

RegisterNUICallback("garages:despawn", function(data, cb)
	TriggerServerEvent("vrp-garages:despawn", data[1])
	cb("ok")
end)

-- veh actions

local findingDoor, allDoors = false, {
	{"seat_dside_f", -1},
	{"seat_pside_f", 0},
	{"seat_dside_r", 1},
	{"seat_pside_r", 2}
}
  
RegisterCommand("getnextdoortoenter", function()
	if findingDoor or playerVehicle ~= 0 then
	  return
	end
  
	local vehicle = tvRP.getVehicleInFront()
	if vehicle then
	  findingDoor = true
	  local nDistances = {}
	  local pCds = GetEntityCoords(tempPed)
	  
	  for _, theDoor in pairs(allDoors) do
		local doorBone = GetEntityBoneIndexByName(vehicle, theDoor[1])
		local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
		local dist = #(doorPos - pCds)
  
		table.insert(nDistances, dist)
	  end
  
	  local doorIndx, minIndx = 1, nDistances[1]
	  for newDoor, newIndx in ipairs(nDistances) do
		if nDistances[newDoor] < minIndx then
		  doorIndx, minIndx = newDoor, newIndx
		end
	  end
	  
	  TaskEnterVehicle(tempPed, vehicle, -1, allDoors[doorIndx][2], 1.0, 1, 0)
	  findingDoor = false
	end
end)
  
RegisterKeyMapping("getnextdoortoenter", "Nu schimba!!", "keyboard", "F")


function tvRP.vc_toggleLock(vname)
	local vehicle = vehicles[vname]
	if vehicle then

		local veh = vehicle[2]
		local locked = GetVehicleDoorLockStatus(veh) >= 2

		Citizen.CreateThread(function()
			if locked then
				SetVehicleDoorsLockedForAllPlayers(veh, false)
				SetVehicleDoorsLocked(veh,1)
				SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
				PlayVehicleDoorOpenSound(veh, 0)
				StartVehicleHorn(veh, 500, "NORMAL", -1)
				Citizen.Wait(300)
				tvRP.notify("Vehiculul a fost descuiat.", "success")
			else
				PlayVehicleDoorCloseSound(veh, 1)
				SetVehicleDoorsLocked(veh,2)
				Player(veh, 1)
				SetVehicleDoorsLockedForAllPlayers(veh, true)
				Citizen.Wait(300)
				tvRP.notify("Vehiculul a fost incuiat.", "info")
				StartVehicleHorn(veh, 500, "NORMAL", -1)
			end
		end)
		
		local dict = "anim@mp_player_intmenu@key_fob@"
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end

		if not IsPedInAnyVehicle(PlayerPedId(), true) then
			TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
		end
		
		SetVehicleLights(veh, 2)
		Citizen.Wait(150)
		SetVehicleLights(veh, 0)		
		Citizen.Wait(150)
		SetVehicleLights(veh, 2)
		Citizen.Wait(150)
		SetVehicleLights(veh, 0)
	end
end

RegisterCommand("togCarLockState", function()
	if tvRP.isHandcuffed(true) then return end
  
	local theCar = tvRP.getNearestOwnedVehicle(10)
	if theCar then
		tvRP.vc_toggleLock(theCar)
	end
end)
  
RegisterKeyMapping("togCarLockState", "Incuie/descuie un vehicul personal", "keyboard", "F3")