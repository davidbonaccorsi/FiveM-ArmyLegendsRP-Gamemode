

local planeObj = nil

local function drawText(text, x, y, scale, r, g, b)
	SetTextFont(0)
	SetTextCentre(1)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextDropShadow(30, 5, 5, 5, 255)
	SetTextEntry("STRING")
	SetTextColour(r, g, b, 255)
	AddTextComponentString(text)
	DrawText(x, y)
end

local passangers = 0

RegisterNetEvent("vrp-pilot:setPassangers")
AddEventHandler("vrp-pilot:setPassangers", function(amm)
	passangers = amm
	SendNUIMessage({job = "setPilotAmm", amm = passangers})
end)

RegisterNetEvent("vrp-pilot:spawnPlane")
AddEventHandler("vrp-pilot:spawnPlane", function(planeData, destination, arrivePos)

	if DoesEntityExist(planeObj) then
		return
	end

	local i = 0
	while not HasModelLoaded(planeData.hash) and i < 1000 do
		RequestModel(planeData.hash)
		Citizen.Wait(10)
		i = i+1
	end

	if HasModelLoaded(planeData.hash) then

		passangers = 0
		SendNUIMessage({job = "setPilotAmm", amm = passangers})

		DoScreenFadeOut(1000)
		Citizen.Wait(1500)

		planeObj = CreateVehicle(planeData.hash, planeData.pos[1], planeData.pos[2], planeData.pos[3]+0.5, planeData.pos[4], true, false)
		NetworkFadeInEntity(planeObj,0)
		SetVehicleFuelLevel(planeObj, 100.0)
		SetVehicleOnGroundProperly(planeObj)
		SetEntityInvincible(planeObj,false)
		SetPedIntoVehicle(PlayerPedId(), planeObj, -1)
		Citizen.InvokeNative(0xAD738C3085FE7E11, planeObj, true, true) -- set as mission entity
		SetVehicleHasBeenOwnedByPlayer(planeObj, true)
		SetVehicleDoorsLocked(planeObj, 2)

		TriggerServerEvent("vrp-pilot:setPlane", NetworkGetNetworkIdFromEntity(planeObj))

		Citizen.Wait(500)

		DoScreenFadeIn(500)

		Citizen.CreateThread(function()
			local ped = PlayerPedId()

			local destBlip = AddBlipForCoord(destination[1], destination[2], destination[3])
			SetBlipSprite(destBlip, 1)
			SetBlipColour(destBlip, 3)
			SetBlipDisplay(destBlip, 8)

			Citizen.CreateThread(function()
				SendNUIMessage({job = "setPilotShow", tog = true})
				while planeObj do
					DisableControlAction(0, 75, true)
					Citizen.Wait(1)
				end
				SendNUIMessage({job = "setPilotShow", tog = false})
			end)

			local finished = false
			local inAir = false

			Citizen.CreateThread(function()
				local untilTime = GetGameTimer() + 10000

				while GetGameTimer() < untilTime do
					drawText("Asteapta ~g~pasageri ~w~sau du-te la ~b~destinatie", 0.5, 0.85, 0.4, 255, 255, 255)
					Citizen.Wait(1)
				end
			end)

			while DoesEntityExist(planeObj) and GetVehicleEngineHealth(planeObj) > 300.0 and not finished do
				Citizen.Wait(1000)
				ped = PlayerPedId()

				local pedCoords = GetEntityCoords(ped)

				ClearGpsCustomRoute()
				StartGpsCustomRoute(9, true, true)
				AddPointToGpsCustomRoute(destination[1], destination[2], destination[3])
				AddPointToGpsCustomRoute(pedCoords)
				SetGpsCustomRouteRender(true, 10, 10)

				if not inAir and pedCoords.z > planeData.pos[3] + 5.0 then
					inAir = true
					TriggerServerEvent("vrp-pilot:planeTookOff")
					Citizen.CreateThread(function()
						local untilTime = GetGameTimer() + 5000
						local text = "Ai decolat cu ~g~"..passangers.." ~w~pasageri, un zbor minunat!"

						if passangers == 1 then
							text = "Ai decolat cu ~g~un ~w~pasager, un zbor placut!"
						elseif passangers == 0 then
							text = "Ai decolat ~r~fara ~w~pasageri, un zbor placut!"
						end

						while GetGameTimer() < untilTime do
							drawText(text, 0.5, 0.85, 0.4, 255, 255, 255)
							Citizen.Wait(1)
						end
					end)
				end

				local dst = GetDistanceBetweenCoords(pedCoords, destination[1], destination[2], destination[3], true)
				while dst <= 80.0 and DoesEntityExist(planeObj) and GetVehicleEngineHealth(planeObj) > 300.0 do
					ClearGpsCustomRoute()

					DrawMarker(1, destination[1], destination[2], destination[3]-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 15.0, 15.0, 0.6, 158, 225, 251, 200)
					if dst <= 10.0 then
						drawText("Apasa ~b~E~w~ pentru a termina zborul", 0.5, 0.85, 0.4, 255, 255, 255)
						if IsControlJustPressed(0, 38) then
							
							TriggerServerEvent("vrp-pilot:flightArrived")
							DoScreenFadeOut(1500)

							Citizen.Wait(2000)
							SetEntityCoords(ped, arrivePos[1], arrivePos[2], arrivePos[3])
							Citizen.Wait(2000)

							DoScreenFadeIn(1000)

							finished = true
							break

						end
					end

					Citizen.Wait(1)
					dst = GetDistanceBetweenCoords(GetEntityCoords(ped), destination[1], destination[2], destination[3], true)
				end

			end

			if DoesBlipExist(destBlip) then
				RemoveBlip(destBlip)
				ClearGpsCustomRoute()
			end

			if DoesEntityExist(planeObj) then
				Citizen.Wait(10000)
				DeleteVehicle(planeObj)
			end

			planeObj = nil

			if not finished then
				TriggerServerEvent("vrp-pilot:flightCanceled")
			end
		end)
	end

	SetModelAsNoLongerNeeded(planeData.hash)

end)

RegisterNetEvent("vrp-pilot:getInPlane")
AddEventHandler("vrp-pilot:getInPlane", function(networkId, seat)
	
	local ped = PlayerPedId()
	FreezeEntityPosition(ped, true)
	DoScreenFadeOut(1000)
	Citizen.Wait(2000)

	local obj = NetworkGetEntityFromNetworkId(networkId)
	if DoesEntityExist(obj) then
		SetPedIntoVehicle(ped, obj, seat)
		Citizen.Wait(500)
		DoScreenFadeIn(500)

		planeObj = true

		Citizen.CreateThread(function()
			while planeObj do
				DisableControlAction(0, 75, true)
				Citizen.Wait(1)
			end
		end)
	end
	FreezeEntityPosition(ped, false)
end)

RegisterNetEvent("vrp-pilot:flightDone")
AddEventHandler("vrp-pilot:flightDone", function(pos)
	DoScreenFadeOut(1000)
	Citizen.Wait(1200)
	SetEntityCoords(PlayerPedId(), pos[1], pos[2], pos[3])
	Citizen.Wait(300)
	DoScreenFadeIn(500)
	planeObj = nil
end)

local function DrawText3D(x,y,z, text, scl, font, colors) 

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(colors[1], colors[2], colors[3], 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local allJobCoords = {
	["Los Santos"] = vec4(-1065.9609375,-2811.6459960938,26.218276977539,150),
	["Grapeseed"] = vec4(2139.9816894531,4788.71484375,40.970268249512,120),
	["Cayo Perico"] = vec4(4427.7822265625,-4451.53125,7.2367177009583,25)
}

Citizen.CreateThread(function()
	local ped = PlayerPedId()

	Citizen.Wait(1000)

	for jobTitle, jobCoords in pairs(allJobCoords) do
		local jobBlip = AddBlipForCoord(jobCoords)
		SetBlipSprite(jobBlip, 423)
		SetBlipColour(jobBlip, 24)
		SetBlipAsShortRange(jobBlip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Pilot")
		EndTextCommandSetBlipName(jobBlip)
		SetBlipScale(jobBlip, 0.5)

		local pedId = vRP.spawnNpc("PilotStarter"..jobTitle, {
			position = jobCoords.xyz,
			rotation = jobCoords.w,
			model = "s_m_y_airworker",
			freeze = true,
			minDist = 2.5,        
			name = "Jean Pilotul",
			["function"] = function()
				TriggerServerEvent("vrp-pilot:startMission", jobTitle)
			end
		})
	
		table.insert(allJobPeds, "PilotStarter"..jobTitle)
	end

end)


local airPortCoords = {
	["Los Santos"] = vec3(-1062.5203857422,-2740.646484375,21.367887496948),
	["Grapeseed"] = vec3(2158.0610351563,4789.8149414063,41.11315536499),
	["Cayo Perico"] = vec3(4517.3481445313,-4548.330078125,4.1392951011658)
}

Citizen.CreateThread(function()
	Citizen.Wait(1000)

	for _, jobCoords in pairs(airPortCoords) do
		local jobBlip = AddBlipForCoord(jobCoords)
		SetBlipSprite(jobBlip, 423)
		SetBlipColour(jobBlip, 26)
		SetBlipAsShortRange(jobBlip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Aeroport")
		SetBlipScale(jobBlip, 0.5)
		EndTextCommandSetBlipName(jobBlip)
	end

	while true do
		if planeObj then
			Citizen.Wait(5000)
		else
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)

			if not IsPedSittingInAnyVehicle(ped) then
				for jobTitle, jobCoords in pairs(airPortCoords) do
					local dst = #(pedCoords - jobCoords)

					while dst <= 10 do
						DrawText3D(jobCoords.x, jobCoords.y, jobCoords.z + .4, "Aeroport", 1.0, 0, {255, 255, 255})
						DrawMarker(33, jobCoords.x, jobCoords.y, jobCoords.z, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 122, 195, 254, 200, 0, 0, 0, 1)

						if dst <= 1 then
							drawText("Apasa ~b~E~w~ pentru a lua avionul", 0.5, 0.85, 0.4, 255, 255, 255)
							if IsControlJustPressed(0, 38) then
								TriggerServerEvent("vrp-pilot:startFlight", jobTitle)
								break
							end
						end

						Citizen.Wait(1)

						pedCoords = GetEntityCoords(ped)
						dst = #(pedCoords - jobCoords)
					end
				end
			end

			Citizen.Wait(1024)
		end
	end

end)