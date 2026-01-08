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

local planeObject = nil

Citizen.CreateThread(function()
	local planeCoords = vec3(4453.96, -4480.30, 4.23)

	local blip = AddBlipForCoord(planeCoords)
	SetBlipSprite(blip, 577)
	SetBlipColour(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Inchiriere Deltaplan")
	EndTextCommandSetBlipName(blip)

	Citizen.Wait(1000)

	while true do
		if planeObject then
			Citizen.Wait(5000)
		else
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)

			if not IsPedSittingInAnyVehicle(ped) then 
				local dst = #(pedCoords - planeCoords)
				while dst <= 10 do
					DrawText3D(planeCoords.x, planeCoords.y, planeCoords.z + .4, "Inchiriere Deltaplan", 1.0, 0, {255, 255, 255})
					DrawMarker(7, planeCoords.x, planeCoords.y, planeCoords.z, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 245, 203, 66, 200, 0, 0, 0, 1)

					if dst <= 1 then
						drawText("Apasa ~g~E~w~ pentru a inchiria un Deltaplan !~n~$~g~5.000", 0.5, 0.85, 0.4, 255, 255, 255)

						if IsControlJustPressed(0, 38) then
							TriggerServerEvent("cayo:rentDelta")
							break
						end
					end

					Citizen.Wait(1)

					pedCoords = GetEntityCoords(ped)
					dst = #(pedCoords - planeCoords)
				end
			end

			Citizen.Wait(1024)
		end
	end
end)

RegisterNetEvent("cayo:spawnDelta")
AddEventHandler("cayo:spawnDelta", function(data)
	if DoesEntityExist(planeObject) then
		return
	end

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

		planeObject = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.pos[4], true, false)
		NetworkFadeInEntity(planeObject,0)
		SetVehicleFuelLevel(planeObject, 100.0)
		SetVehicleOnGroundProperly(planeObject)
		SetEntityInvincible(planeObject,false)
		Citizen.InvokeNative(0xAD738C3085FE7E11, planeObject, true, true) -- set as mission entity
		SetVehicleHasBeenOwnedByPlayer(planeObject, true)
		local ped = PlayerPedId()
		SetPedIntoVehicle(ped, planeObject, -1)

		TriggerServerEvent("cayo:setPlaneObj", NetworkGetNetworkIdFromEntity(planeObject))

		local planeBlip = AddBlipForEntity(planeObject)
		SetBlipSprite(planeBlip, 577)
		SetBlipDisplay(planeBlip, 10)
		SetBlipColour(planeBlip, 81)

		BeginTextCommandSetBlipName("STRING")
	    AddTextComponentString("Deltaplan")
	    EndTextCommandSetBlipName(planeBlip)

	    local area = {5017.1059570313, -5111.4536132813, 160.53521728516, 1800.0}

	    local blip = AddBlipForRadius(area[1], area[2], area[3], area[4])
		SetBlipColour(blip, 1)
		SetBlipAlpha(blip, 50)
		SetBlipFlashes(blip, true)

		Citizen.CreateThread(function()
			local untilTime = GetGameTimer() + 15000

			while GetGameTimer() < untilTime do
				drawText("Nu este permisa navigarea cu Deltaplanul in afara permiterului marcat", 0.5, 0.85, 0.4, 255, 255, 255)
				Citizen.Wait(1)
			end
			RemoveBlip(blip)
		end)

		Citizen.Wait(5000)

		Citizen.CreateThread(function()
			SetVehicleDoorsLocked(planeObject, 2)
			local locked = true

			while planeObject do

				if IsControlJustPressed(0, 303) then -- U
					if locked then
						SetVehicleDoorsLocked(planeObject, 1)

						local untilTime = GetGameTimer() + 2000
						while GetGameTimer() < untilTime do
							drawText("Deblocat", 0.5, 0.85, 0.4, 69, 214, 56)
							Citizen.Wait(1)
						end
					else
						SetVehicleDoorsLocked(planeObject, 2)

						local untilTime = GetGameTimer() + 2000
						while GetGameTimer() < untilTime do
							drawText("Blocat", 0.5, 0.85, 0.4, 214, 39, 30)
							Citizen.Wait(1)
						end
					end
					locked = not locked
				end

				Citizen.Wait(1)
			end
		end)

	    Citizen.CreateThread(function()
	    	while DoesEntityExist(planeObject) do
	    		ped = PlayerPedId()
	    		if GetVehicleEngineHealth(planeObject) > 300.0 then
		    		if GetDistanceBetweenCoords(GetEntityCoords(ped), area[1], area[2], area[3], false) > area[4] then

		    			SetVehicleEngineHealth(planeObject, 250.0)

		    			local untilTime = GetGameTimer() + 15000

						while GetGameTimer() < untilTime do

							if math.floor((untilTime - GetGameTimer()) / 1000) % 2 == 0 then
								drawText("Nu este permisa navigarea cu Deltaplanul in afara permiterului marcat", 0.5, 0.85, 0.4, 255, 255, 255)
							end
							Citizen.Wait(1)
						end

		    		end
		    	end
	    		Citizen.Wait(1500)
	    	end

	    	RemoveBlip(planeBlip)
	    	planeObject = nil
	    	TriggerServerEvent("cayo:setPlaneObj", 0, true)
	    end)
	end
end)

-- local rentedObject = nil

-- Citizen.CreateThread(function()
-- 	local ped = PlayerPedId()
-- 	local rentedCoords = {4519.69, -4514.18, 4.51}

-- 	local blip = AddBlipForCoord(rentedCoords[1], rentedCoords[2], rentedCoords[3])
-- 	SetBlipSprite(blip, 811)
-- 	SetBlipColour(blip, 71)
-- 	SetBlipAsShortRange(blip, true)

-- 	BeginTextCommandSetBlipName("STRING")
-- 	AddTextComponentString("Inchiriere Vehicul")
-- 	EndTextCommandSetBlipName(blip)

-- 	Citizen.Wait(1000)

-- 	while true do
-- 		Citizen.Wait(1500)
-- 		if rentedObject then
-- 			Citizen.Wait(5000)
-- 		else
-- 			ped = PlayerPedId()
-- 			if not IsPedSittingInAnyVehicle(ped) then 
-- 				local dst = GetDistanceBetweenCoords(GetEntityCoords(ped), rentedCoords[1], rentedCoords[2], rentedCoords[3], false)
-- 				while dst <= 10 do

-- 					DrawText3D(rentedCoords[1], rentedCoords[2], rentedCoords[3]+0.4, "Inchiriere Vehicul", 1.0, 0, {255, 255, 255})
-- 					DrawMarker(36, rentedCoords[1], rentedCoords[2], rentedCoords[3], 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 245, 203, 66, 200, 0, 0, 0, 1)

-- 					if dst <= 1 then
-- 						drawText("Apasa ~g~E~w~ pentru a inchiria un un vehicul !", 0.5, 0.85, 0.4, 255, 255, 255)
-- 						if IsControlJustPressed(0, 38) then
-- 							TriggerServerEvent("cayo:rentVeh")
-- 							break
-- 						end
-- 					end

-- 					Citizen.Wait(1)
-- 					dst = GetDistanceBetweenCoords(GetEntityCoords(ped), rentedCoords[1], rentedCoords[2], rentedCoords[3], false)
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- RegisterNetEvent("cayo:spawnRentedVeh")
-- AddEventHandler("cayo:spawnRentedVeh", function(data)
-- 	if DoesEntityExist(rentedObject) then
-- 		return
-- 	end

-- 	if not (data.hash and data.pos) then
-- 		return
-- 	end

-- 	local i = 0
-- 	while not HasModelLoaded(data.hash) and i < 1000 do
-- 		RequestModel(data.hash)
-- 		Citizen.Wait(10)
-- 		i = i+1
-- 	end

-- 	if HasModelLoaded(data.hash) then

-- 		rentedObject = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.pos[4], true, false)
-- 		TriggerServerEvent("LegacyFuel:UpdateServerFuelTable", NetworkGetNetworkIdFromEntity(rentedObject), 100.0)
-- 		NetworkFadeInEntity(rentedObject,0)
-- 		SetVehicleFuelLevel(rentedObject, 100.0)
-- 		SetVehicleOnGroundProperly(rentedObject)
-- 		SetEntityInvincible(rentedObject,false)
-- 		Citizen.InvokeNative(0xAD738C3085FE7E11, rentedObject, true, true) -- set as mission entity
-- 		SetVehicleHasBeenOwnedByPlayer(rentedObject, true)
-- 		local ped = PlayerPedId()
-- 		SetPedIntoVehicle(ped, rentedObject, -1)

-- 		TriggerServerEvent("cayo:setPlaneObj", NetworkGetNetworkIdFromEntity(rentedObject))

-- 		local vehBlip = AddBlipForEntity(rentedObject)
-- 		SetBlipSprite(vehBlip, 532)
-- 		SetBlipDisplay(vehBlip, 10)
-- 		SetBlipColour(vehBlip, 28)

-- 		BeginTextCommandSetBlipName("STRING")
-- 	    AddTextComponentString("Vehicul")
-- 	    EndTextCommandSetBlipName(vehBlip)

-- 	    local area = {5017.1059570313, -5111.4536132813, 160.53521728516, 1300.0}

-- 		Citizen.CreateThread(function()
-- 			local untilTime = GetGameTimer() + 15000

-- 			while GetGameTimer() < untilTime do
-- 				drawText("Nu este permisa iesirea din permietrul insulei cu vehiculul", 0.5, 0.85, 0.4, 255, 255, 255)
-- 				Citizen.Wait(1)
-- 			end
-- 		end)

-- 		Citizen.Wait(5000)

-- 	    Citizen.CreateThread(function()

-- 			Citizen.CreateThread(function()
-- 				SetVehicleDoorsLocked(rentedObject, 2)
-- 				local locked = true

-- 				while rentedObject do

-- 					if IsControlJustPressed(0, 303) then -- U
-- 						if locked then
-- 							SetVehicleDoorsLocked(rentedObject, 1)

-- 							local untilTime = GetGameTimer() + 2000
-- 							while GetGameTimer() < untilTime do
-- 								drawText("Deblocat", 0.5, 0.85, 0.4, 69, 214, 56)
-- 								Citizen.Wait(1)
-- 							end
-- 						else
-- 							SetVehicleDoorsLocked(rentedObject, 2)

-- 							local untilTime = GetGameTimer() + 2000
-- 							while GetGameTimer() < untilTime do
-- 								drawText("Blocat", 0.5, 0.85, 0.4, 214, 39, 30)
-- 								Citizen.Wait(1)
-- 							end
-- 						end
-- 						locked = not locked
-- 					end

-- 					Citizen.Wait(1)
-- 				end
-- 			end)

-- 	    	while DoesEntityExist(rentedObject) do
-- 	    		ped = PlayerPedId()
-- 	    		if GetVehicleEngineHealth(rentedObject) > 300.0 then
-- 		    		if GetDistanceBetweenCoords(GetEntityCoords(ped), area[1], area[2], area[3], false) > area[4] then

-- 		    			SetVehicleEngineHealth(rentedObject, 250.0)

-- 		    			local untilTime = GetGameTimer() + 15000

-- 						while GetGameTimer() < untilTime do

-- 							if math.floor((untilTime - GetGameTimer()) / 1000) % 2 == 0 then
-- 								drawText("Nu este permisa iesirea din permietrul insulei cu vehiculul", 0.5, 0.85, 0.4, 255, 255, 255)
-- 							end
-- 							Citizen.Wait(1)
-- 						end

-- 		    		end
-- 		    	end
-- 	    		Citizen.Wait(1500)
-- 	    	end

-- 	    	RemoveBlip(vehBlip)
-- 	    	rentedObject = nil
-- 	    	TriggerServerEvent("cayo:setPlaneObj", 0, true)
-- 	    end)
-- 	end
-- end)
