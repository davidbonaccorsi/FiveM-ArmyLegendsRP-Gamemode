
local startingPos = vector3(-1514.3322753906, 1512.4349365234, 115.28856658936)
local storePos = vector3(-1512.9309082031, 1517.0408935547, 115.28856658936)

local userRod

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 317)
    SetBlipColour(blip, 36)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Pescar")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("FisherStarter", {
        position = startingPos,
        rotation = 70,
        model = "a_m_m_malibu_01",
        freeze = true,
        minDist = 2.5,
        name = "Andrei Pescarul",
        ["function"] = function()
            SendNUIMessage({job = "fisher", group = inJob})
        end
    })

	table.insert(allJobPeds, "FisherStarter")

	local pedId = vRP.spawnNpc("FisherStore", {
		position = storePos,
		rotation = 65,
		model = "ig_helmsmanpavel",
		freeze = true,
		minDist = 2,
		name = "Marius Negustorul",
		buttons = {
			{text = "Pescaria este prea departe si vreau sa cumpar momeala de la tine", response = function()
				local reply = promise.new()
				triggerCallback('buyLoadFisher', function(res)
					reply:resolve(res)
				end)

				return Citizen.Await(reply)
			end},
		}
	})

	table.insert(allJobPeds, "FisherStore")

	local blip = AddBlipForCoord(storePos)
    SetBlipSprite(blip, 59)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Magazin (Pescar)")
    EndTextCommandSetBlipName(blip)
end)

local gameFinish
RegisterNUICallback("fisher:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local objs = {}

local function PlayAnim(ped,base,sub,nr,time) 
	Citizen.CreateThread(function() 
		RequestAnimDict(base) 
		while not HasAnimDictLoaded(base) do 
			Citizen.Wait(1) 
		end
		if IsEntityPlayingAnim(ped, base, sub, 3) then
			ClearPedSecondaryTask(ped) 
		else 
			for i = 1,nr do 
				TaskPlayAnim(ped, base, sub, 8.0, -8, -1, 16, 0, 0, 0, 0) 
				Citizen.Wait(time) 
			end 
		end 
	end) 
end

local function AttachEntityToPed(prop,bone_ID,x,y,z,RotX,RotY,RotZ)
	local ped = PlayerPedId()
	BoneID = GetPedBoneIndex(ped, bone_ID)
	obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	vX,vY,vZ = table.unpack(GetEntityCoords(ped))
	xRot, yRot, zRot = table.unpack(GetEntityRotation(ped,2))
	AttachEntityToEntity(obj, ped, BoneID, x,y,z, RotX,RotY,RotZ,  false, false, false, false, 2, true)
	return obj
end

local goingFishing = false

local function startFishing()
	if not goingFishing then
		goingFishing = true
		local rodObj = AttachEntityToPed('prop_fishing_rod_01',60309, 0,0,0, 0,0,0)
		FreezeEntityPosition(PlayerPedId(), true)
		
		local function stopFishing()
			Citizen.CreateThread(function()
				StopAnimTask(PlayerPedId(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
				Citizen.Wait(100)
				DeleteEntity(rodObj)
				FreezeEntityPosition(PlayerPedId(), false)
			end)
		end

		local catching, canCatch = true, true
		while catching do
			local time = 3300
			TaskStandStill(PlayerPedId(), time+7000)
			PlayAnim(PlayerPedId(), 'amb@world_human_stand_fishing@base', 'base', 1,0)

			Citizen.Wait(time)
			if canCatch then
				if math.random(1, 10) <= 9 then
					canCatch = false
					SendNUIMessage({job = "fishgame"})
					gameFinish = function(ok)

						if ok == true then
							triggerCallback("catchFish", function()
								if math.random(1, 10) == 1 then
									vRP.notify("Din pacate ti s-a rupt o momeala", "error")
									triggerCallback("hasItemAmount", function() end, "momeala", 1, true)
								end
								stopFishing()
							end, userRod)
						elseif not ok then
							vRP.notify("Pestele a scapat !", "error")
							triggerCallback("hasItemAmount", function() end, "momeala", 1, true)
							stopFishing()
						end
						catching = false
					end
				else
					stopFishing()
					vRP.notify('Nu ai prins nimic!')
					catching = false
				end
			end
		end

		goingFishing = false
	else
		vRP.sendInfo("Deja pescuiesti")
	end
end

local jobActive

local pos = vector2(-1514.250, 1524.785)
local pos2 = vector2(-1520.187, 1502.285)

AddEventHandler("jobs:onJobSet", function(job)
    Citizen.Wait(500)
    jobActive = (inJob == "Pescar")

	local inputActive = false

	Citizen.CreateThread(function()
	    while jobActive do

			if goingFishing then
				Citizen.Wait(2000)
			else
				local ped = PlayerPedId()
				local pedCoords = GetEntityCoords(ped)

				local x, y, z = table.unpack(pedCoords)
	
				while (x <= pos.x and x >= pos2.x) and (y <= pos.y and y >= pos2.y) and z <= 113 do
					if not inputActive then
						inputActive = true
						TriggerEvent("vrp-hud:showBind", {key = "E", text = "Incepe sa pescuiesti"})
					end
	
					if IsControlJustPressed(0, 38) then
						triggerCallback('hasRod', function(hasRod)
							if not hasRod then
								FreezeEntityPosition(PlayerPedId(), false)
								ClearPedTasks(PlayerPedId())

								return vRP.notify('Ai nevoie de o undita pentru a incepe sa pescuiesti!', 'error')
							end
	
							userRod = hasRod
							triggerCallback("hasItemAmount", function(ok)
								if ok then
									SetEntityCoords(ped, x, y, z - 1.0)
									Citizen.Wait(200)

									startFishing()
								elseif ok ~= "full" then
									vRP.subtitle("Ai nevoie de niste ~r~momeala~w~ pentru a putea sa pescuiesti")
								end
							end, "momeala", 1)
						end)
	
						Citizen.Wait(2000)
	
						break
					end
	
					Citizen.Wait(1)
	
					pedCoords = GetEntityCoords(ped)
					x, y, z = table.unpack(pedCoords)
				end
	
				if inputActive then
					inputActive = TriggerEvent("vrp-hud:showBind")
				end
			end

			Citizen.Wait(1024)
	    end
	end)
end)

local resName = GetCurrentResourceName()
AddEventHandler("onResourceStop", function(res)
    if res == resName then
        for _, object in pairs(objs) do
            DeleteEntity(object)
        end

        objs = {}
    end
end)

