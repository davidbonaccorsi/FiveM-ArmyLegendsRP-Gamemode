
--[[
    new positions:
    -2039.5588378906,-370.74340820312,48.106136322021 - default spawn
    -1563.2001953125,-1320.2095947266,0.66492760181427 - boats spawn
]]


local cfg, camera, vehicle, menuActive, testDrive = {}, nil, 0, false, false

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    cfg = GlobalState["dealership_cfg"]
end)

local dealershipLocation = vec3(-33.440937042236,-1097.279296875,27.274379730225)
local sellerLocation = vec3(-31.256063461304,-1097.8092041016,27.274377822876)
local possibleSpawns = {
    barci = {-825.15069580078,-1520.1862792969,1.5287020206451},
    avioane = {-1379.0897216797,-3240.7109375,13.94483089447},
    elicoptere = {-1379.0897216797,-3240.7109375,13.94483089447},
    camioane = {1169.7462158203,-3293.9167480469,5.9023199081421,61.46661},
    remorci = {-231.70372009277,-2484.939453125,6.0013980865479,160.0},
    dube = {815.60162353516,-3194.67578125,5.900812625885,61.46661},
    cayo = {4442.8525390625,-4468.6303710938,4.3284411430359},
}

local categCams = {
    -- {category, {playerPos, pointPos}}
    default = {{-2041.4372558594,-370.83056640625,48.956912994385}, {-2036.7170410156,-367.86849975586,48.106227874756}},
    barci = {{-810.31, -1515.43, 3.17}, {-825.15069580078,-1520.1862792969,1.5287020206451}},
    avioane = {{-1367.0500488281,-3219.4340820313,18.683557510376}, {-1379.0897216797,-3240.7109375,13.94483089447}},
    elicoptere = {{-1367.0500488281,-3219.4340820313,18.683557510376}, {-1379.0897216797,-3240.7109375,13.94483089447}},
    camioane = {{1157.3056640625,-3292.9658203125,10.112668991089}, {1169.7462158203,-3293.9167480469,5.9023199081421}},
    remorci = {{-250.03268432617,-2484.3474121094,11.18252658844}, {-231.70372009277,-2484.939453125,6.0013980865479}},
    dube = {{807.98822021484,-3194.5632324219,8.3959770202637}, {815.60162353516,-3194.67578125,5.900812625885}},
    cayo = {{4446.5297851563,-4478.55859375,4.326117515564}, {4440.2866210938,-4460.99609375,4.3283472061157}},
}

exports("isInDealership", function()
    if menuActive then
        return true
    end

    return false
end)

RegisterNUICallback("dealership:getVehiclesList", function(data, cb)
    cb(cfg.vehicles[data[1]] or {})
end)

exports("isInTestDrive", function()
    if testDrive then
        return true
    end
    return false
end)


local camera = 0
local function createPreviewCamera(playerPos, pointPos)

    DoScreenFadeOut(1000)
    Citizen.Wait(1000)

    local ground = Citizen.InvokeNative(0xC906A7DAB05C8D2B, playerPos[1], playerPos[2], playerPos[3], Citizen.PointerValueFloat(), 0)

    FreezeEntityPosition(tempPed, true)
    tvRP.teleport(playerPos[1], playerPos[2], playerPos[3])
    SetEntityHeading(tempPed, playerPos[4] or 0.0)
    SetEntityVisible(tempPed, false)

    if not DoesCamExist(camera) then
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end
    SetCamRot(camera, vec3(-5.0, 0.0, 161.3), true)
    SetCamCoord(camera, playerPos[1], playerPos[2], playerPos[3])
    PointCamAtCoord(camera, pointPos[1], pointPos[2], pointPos[3])
    RenderScriptCams(true, false, 2500.0, true, true)

    DoScreenFadeIn(1000)
    TriggerEvent("vrp:interfaceFocus", true)
    Citizen.Wait(1000)

    if not menuActive then
        SendNUIMessage({interface = "dealership", data = {money = exports.vrp:getCashMoney(), name = GetPlayerName(PlayerId())}})
    end

end

RegisterNUICallback("dealership:exit", function(data, cb)
    TriggerEvent("vrp:interfaceFocus", false)

    DoScreenFadeOut(500)
    local x, y, z = -49.17552947998,-1108.4447021484,26.670251846313
    tvRP.teleport(x,y,z) -- dealershipLocation.x, dealershipLocation.y, dealershipLocation.z
    FreezeEntityPosition(tempPed, false)
    SetEntityVisible(tempPed, true)

    Citizen.Wait(1000)
    DoScreenFadeIn(1000)

    RenderScriptCams(false, false, 1.0, true, true)
    DestroyAllCams(true)

    menuActive = false

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    TriggerEvent("vrp-hud:updateMap", true)
    TriggerEvent("vrp-hud:setComponentDisplay", {
        serverHud = true,
        minimapHud = true,
        bottomRightHud = true,
        chat = true,
    })


    cb("ok")

end)

Citizen.CreateThread(function()

    tvRP.spawnNpc("dealership", {
        position = sellerLocation,
        rotation = 70,
        freeze = true,
        scenario = {anim = {dict = "anim@amb@nightclub@lazlow@ig1_vip@", name = "clubvip_base_laz"}},
        minDist = 3.5,
        
        model = "ig_miguelmadrazo",
        name = "Miguel Madrazo",
        ["function"] = function()
            TriggerEvent("vrp-hud:updateMap", false)
            TriggerEvent("vrp-hud:setComponentDisplay", {
                serverHud = false,
                minimapHud = false,
                bottomRightHud = false,
                chat = false,
            })

            createPreviewCamera(categCams["default"][1], categCams["default"][2])

            menuActive = true
        end
    })
    tvRP.addBlip("vRP:dealership", dealershipLocation.x, dealershipLocation.y, dealershipLocation.z, 810, 17, "Reprezentanta Auto", 0.5)
end)

local colors = {
    {57, 54, 53},
    {255, 255, 255},
    {230, 46, 45},
    {241, 145, 47},
    {64, 73, 227},
    {201, 49, 226},
    {232, 213, 43},
    {66, 200, 42},
    {50, 184, 215},
    {216, 55, 130},
}

local spawning, color = false, 2

RegisterNUICallback("dealership:isSpawning", function(data, cb)
    cb(spawning)
end)


RegisterNUICallback("dealership:spawn", function(data, cb)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    local top = {speed = 4, acceleration = 5, braking = 4, control = 4, trunk = 30}

    if spawning ~= false then return cb(false) end
    spawning = data[1]
    local i, hash = 0, GetHashKey(data[1])

    while not HasModelLoaded(hash) and i < 1000 do
        if i % 50 == 0 then
            RequestModel(hash)
        end
        Citizen.Wait(1)
        i = i+1
    end
    spawning = false

    if not menuActive then
        return
    end

    local spawnPoint = possibleSpawns[data[2]] or {-2036.7170410156,-367.86849975586,48.106227874756}
    vehicle = CreateVehicle(hash, spawnPoint[1], spawnPoint[2], spawnPoint[3] + 1.0, (spawnPoint[4] or 90.46661), false, false)
    
    local camConfig = categCams[data[2]] or categCams["default"]
    if camera and (camera == true or #(GetCamCoord(camera) - vec3(camConfig[1][1], camConfig[1][2], camConfig[1][3])) > 2.0) then
        createPreviewCamera(camConfig[1], camConfig[2])
    end
    
    local r,g,b = table.unpack(colors[color])
    SetVehicleCustomPrimaryColour(vehicle, r, g, b)
    SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)
    SetVehicleDirtLevel(vehicle, 0.0)

    NetworkFadeInEntity(vehicle, 0)

    vRPserver.getModelMaxTrunkSpace({data[1]}, function(trunk)
        top.speed = math.ceil(GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
        top.trunk = trunk

        triggerCallback("getDealershipStock", function(stock)
            top.stock = stock or 0
            cb(top)
        end, data[1])
    end)
end)

RegisterNUICallback("dealership:setColor", function(data, cb)

    if DoesEntityExist(vehicle) then
        local r,g,b = table.unpack(colors[data[1]])
        SetVehicleCustomPrimaryColour(vehicle, r, g, b)
        SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)

        color = data[1]
    end

    cb("ok")
end)

RegisterNUICallback("dealership:buy", function(data, cb)
    TriggerServerEvent("vrp-dealership:purchaseModel", data)

    cb("ok")
end)



local function degToRad(deg)
    return (deg * math.pi) / 180.0
end

local function rotationToDirection(rotation)
    local z = degToRad(rotation.z)
    local x = degToRad(rotation.x)
    local num = math.abs(math.cos(x))

    return vector3((-math.sin(z) * num),math.cos(z) * num,math.sin(x))
end

local function w2s(position)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)
    if not onScreen then
        return nil
    end
    return vector3((_x - 0.5) * 2,(_y - 0.5) * 2,0.0)
end

function processCoordinates(x, y)
    local screenX, screenY = GetActiveScreenResolution()
    local relativeX = 1 - (x / screenX) * 1.0 * 2
    local relativeY = 1 - (y / screenY) * 1.0 * 2

    if relativeX > 0.0 then
        relativeX = -relativeX;
    else
        relativeX = math.abs(relativeX)
    end

    if relativeY > 0.0 then
        relativeY = -relativeY
    else
        relativeY = math.abs(relativeY)
    end

    return { x = relativeX, y = relativeY }
end

local function s2w(camPos, relX, relY,cam)
    local camRot = GetCamRot(cam,2)
    local camForward = rotationToDirection(camRot)
    local rotUp = ( camRot + vector3(10.0,0.0,0.0) )
    local rotDown = ( camRot + vector3(-10.0,0.0,0.0) )
    local rotLeft = ( camRot + vector3(0.0,0.0,-10.0) )
    local rotRight = ( camRot + vector3(0.0,0.0,10.0) )

    local camRight = (rotationToDirection(rotRight) - rotationToDirection(rotLeft))
    local camUp = (rotationToDirection(rotUp)- rotationToDirection(rotDown))

    local rollRad = -degToRad(camRot.y)
    local camRightRoll = ((camRight* math.cos(rollRad))- (camUp* math.sin(rollRad)))
    local camUpRoll = ((camRight* math.sin(rollRad))+ (camUp* math.cos(rollRad)))

    local point3D = (((camPos+ (camForward* 10.0))+camRightRoll)+camUpRoll)

    local point2D = w2s(point3D)

    if point2D == nil then
        return (camPos +  (camForward* 10.0))
    end

    local point3DZero = (camPos+ (camForward* 10.0))
    local point2DZero = w2s(point3DZero)

    if point2DZero == nil then
        return (camPos+ (camForward* 10.0))
    end

    local eps = 0.001
    if math.abs(point2D.x - point2DZero.x) < eps or math.abs(point2D.y - point2DZero.y) < eps then
        return (camPos + (camForward* 10.0))
    end

    local scaleX = (relX - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (relY - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = (((camPos+ (camForward* 10.0))+ (camRightRoll* scaleX))+ (camUpRoll* scaleY))

    return point3Dret
end

local function screenToWorld(flags, cam)
    local x, y = GetNuiCursorPosition()

    local absoluteX = x
    local absoluteY = y

    local camPos = GetGameplayCamCoord()
    camPos = GetCamCoord(cam)
    local processedCoords = processCoordinates(absoluteX, absoluteY)
    local target = s2w(camPos, processedCoords.x, processedCoords.y,cam)

    local dir = (target-camPos)
    local from = (camPos+(dir* 0.05))
    local to = (camPos+(dir* 300))

    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, flags, ignore, 0)
    local a, b, c, d, e = GetShapeTestResult(ray)
    return b, c, e, to
end
  
local function GetEntityMouseOn(cam)
    local hit,endCoords,entityHit,_ = screenToWorld(2,cam)
    return hit,endCoords,entityHit
end

local lastX, rotatingDown = false, false
RegisterNUICallback("dealership:rotateDown", function(data, cb)

	rotatingDown = true
	local heading = GetEntityHeading(vehicle)
	lastX = GetNuiCursorPosition()
	local x = lastX

	Citizen.CreateThread(function()
		while rotatingDown do
			x = GetNuiCursorPosition()
			local diff = (x - lastX) * 0.3
			local newHeading = heading + diff

			if newHeading and (heading ~= newHeading) then
				SetEntityHeading(vehicle, newHeading + 0.0)
				heading = newHeading
			end
			lastX = x
            Citizen.Wait(1)
		end
	end)


	cb("ok")
end)

RegisterNUICallback("dealership:rotateUp", function(data, cb)
	rotatingDown = false
	cb("ok")
end)



local vehicle = false
RegisterNUICallback("dealership:testDrive", function(data, cb)
    local model, category = data[1], data[2]
    Citizen.Wait(500)

    local spawnPoint = possibleSpawns[category] or {-63.828220367432,-1132.0690917969,25.831851959229}
	if not vehicle or not DoesEntityExist(vehicle) then
		local i, mhash = 0, GetHashKey(model)

		while not HasModelLoaded(mhash) and i < 1000 do
			if i % 50 == 0 then
				RequestModel(mhash)
			end
			Citizen.Wait(1)
			i = i+1
		end

        local rgb = table.unpack(colors[color])

		vehicle = CreateVehicle(mhash, spawnPoint[1], spawnPoint[2], spawnPoint[3], 180.0, false, false)
		SetVehicleMaxSpeed(vehicle, 0.0)
		NetworkFadeInEntity(vehicle, 0)
		SetVehicleOnGroundProperly(vehicle)
		SetEntityInvincible(vehicle, true)
		FreezeEntityPosition(vehicle, true)
		SetVehicleDirtLevel(vehicle, 0.0)
		SetVehicleCustomPrimaryColour(vehicle, r, g, b)
		SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)
        SetVehicleNumberPlateText(vehicle, "AUTOTEST")

	end


	if DoesEntityExist(vehicle) then

		testDrive = true

		DoScreenFadeOut(700)
		Citizen.Wait(800)

		SetEntityVisible(tempPed, true)
		ClearFocus()
		RenderScriptCams(false, false, 0, true, false)
		DestroyAllCams(true)
		menuActive = false

		SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
		Citizen.Wait(100)
		FreezeEntityPosition(vehicle, false)
		SetEntityCoords(vehicle, spawnPoint[1], spawnPoint[2], spawnPoint[3])
		SetEntityHeading(vehicle, 90.0)
        TriggerServerEvent("vrp:setRoutingBucket", "user_id")

		Citizen.Wait(1000)
		DoScreenFadeIn(1000)

		local untilTime = GetGameTimer() + 60000

        TriggerEvent("vrp-hud:showBind", {key = "F", text = "Opreste testarea"})
		SendNUIMessage({interface = "testdrive", event = "show", model = cfg.vehicles[category][model].name})

		while GetGameTimer() < untilTime do
			Citizen.Wait(1)

			DisableControlAction(0, 75)

			if IsDisabledControlJustPressed(0, 75) then
				break
			end

		end

        TriggerEvent("vrp-hud:showBind", false)
        SendNUIMessage({interface = "testdrive", event = "hide"})

		DoScreenFadeOut(700, true)
		Citizen.Wait(800)
        local x, y, z = -49.17552947998,-1108.4447021484,26.670251846313
		tvRP.teleport(x,y,z) -- dealershipLocation.x, dealershipLocation.y, dealershipLocation.z
        TriggerServerEvent("vrp:setRoutingBucket", 0)

		DeleteEntity(vehicle)
        vehicle = nil
        
		Citizen.Wait(1000)
		DoScreenFadeIn(1000, true)

		testDrive = false
	end

    cb("ok")
end)
