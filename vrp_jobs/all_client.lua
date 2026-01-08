vRP = exports.vrp:link()
local resName = GetCurrentResourceName()

RegisterNetEvent("jobs:setLastJob")

inJob = false
RegisterNetEvent("jobs:onJobSet", function(group)
	inJob = group

	if inJob == "Somer" then
		inJob = false
	end
end)

exports("getActiveJob", function()
	return inJob or false
end)

RegisterNetEvent("jobs:showNewGroup", function(group)
	SendNUIMessage({job = "newGroup", group = group})
end)

RegisterNUICallback("getGroup", function(data, cb)
	if data[1] then
		TriggerServerEvent("jobs:getGroup", data[1])
	end
	cb("ok")
end)

RegisterNetEvent("jobs:onJustFired")
RegisterNUICallback("getFired", function(data, cb)
	TriggerServerEvent("jobs:getFired")
	cb("ok")
end)

local function callback(cbName, cb, ...)
	TriggerServerEvent(resName..":s_callback:"..cbName, ...)
	return RegisterNetEvent(resName..":c_callback:"..cbName, function(...)
		cb(...)
	end)
end

function triggerCallback(cbName, cb, ...)
	local ev = false
	local f = function(...)
		if ev ~= false then
			RemoveEventHandler(ev)
		end
		cb(...)
	end
	ev = callback(cbName, f, ...)
	return ev
end

function getVehicleObject(data, cb)
	if not (data.hash and data.pos) then
		return
	end

	local i = 0
	while not HasModelLoaded(data.hash) and i < 1000 do
		RequestModel(data.hash)
		Citizen.Wait(10)
		i = i+1
	end

	if HasModelLoaded(data.hash) then

		local veh = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.h or 0.0, true, false)
		NetworkFadeInEntity(veh,0)
		SetVehicleFuelLevel(veh, 100.0)
		SetVehicleOnGroundProperly(veh)
		SetEntityInvincible(veh,false)
		SetEntityHeading(veh, data.h or 0.0)
		Citizen.InvokeNative(0xAD738C3085FE7E11, veh, true, true) -- set as mission entity
		SetVehicleHasBeenOwnedByPlayer(veh, true)
		if data.setinveh then
		    local ped = PlayerPedId()
		    SetPedIntoVehicle(ped, veh, -1)
		end

		cb(veh)
	end
end

RegisterNUICallback("setFocus", function(data, cb)
    SetNuiFocus(data[1], data[1])
	cb("ok")
end)

function rotToDir(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGameplayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = rotToDir(cameraRotation)
	local destination =
	{
 		x = cameraCoord.x + direction.x * distance,
 		y = cameraCoord.y + direction.y * distance,
 		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestSweptSphere(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 0.2, 339, PlayerPedId(), 4))
	return b, c, e
end

local boxAnim = false
exports("setBoxAnim", function(state, canRun, lockIdle)
	boxAnim = state
	if boxAnim then
		Citizen.CreateThread(function()
			RequestAnimDict("anim@heists@box_carry@")
			while not HasAnimDictLoaded("anim@heists@box_carry@") do
				Citizen.Wait(1)
			end
			local ped = PlayerPedId()

			Citizen.CreateThread(function()
				while boxAnim do
					if not canRun then
						DisableControlAction(0, 21, true)
					end
					DisableControlAction(0, 22, true)
					DisableControlAction(0, 55, true) 
					DisableControlAction(0, 23, true)
					DisableControlAction(0, 24, true)
					DisableControlAction(0, 25, true)
					DisableControlAction(0, 44, true)
					DisableControlAction(0, 140, true)
					Citizen.Wait(1)
				end
			end)

			while boxAnim do
				local neededAnim = "idle"

				if not lockIdle then
					if IsPedWalking(ped) then
						neededAnim = "walk"
					elseif IsPedRunning(ped) or IsPedSprinting(ped) then
						neededAnim = "run"
					end
				end

				if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", neededAnim, 3) then
					TaskPlayAnim(ped, "anim@heists@box_carry@", neededAnim, 8.0, 8.0, -1, 1 | 16 | 32, 0.0, 0, 0, 0)
				end

				Citizen.Wait(500)
				ped = PlayerPedId()
			end
			
			ClearPedTasksImmediately(ped)
		end)
	end
end)

RegisterCommand("subtitle", function(player, args)
	local msg = table.concat(args, " ", 1)

	if not args[1] then return false end
	
	vRP.subtitle(msg)
end)


allJobPeds = {}
AddEventHandler("onResourceStop", function(res)
	if res == resName then
		for _, ped in pairs(allJobPeds) do
			vRP.deleteNpc(ped)
		end

		allJobPeds = {}
	end
end)
