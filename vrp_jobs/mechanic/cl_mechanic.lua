
local startingPos = vector3(-1579.1485595703,-838.80755615234,10.026169776917)

local garagePos = vector3(-1593.6020507812,-825.80737304688,9.9761629104614)

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

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 446)
    SetBlipColour(blip, 16)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mecanic")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("MechanicStarter", {
        position = startingPos,
        rotation = 121,
        model = "s_m_m_autoshop_02",
        freeze = true,
        minDist = 2.5,        
        name = "Virgil Mecanicul",
        ["function"] = function()
            SendNUIMessage({job = "mechanic", group = inJob})
        end
    })

    table.insert(allJobPeds, "MechanicStarter")

end)

local blips, objs = {}, {}

local jobActive
local truckObject
AddEventHandler("jobs:onJobSet", function(job)
    Citizen.Wait(500)
    jobActive = (inJob == "Mecanic")

    if not jobActive then
        for k, object in pairs(objs) do
            DeleteEntity(object)
        end
        objs = {}

        if next(blips) then
            for k, blip in pairs(blips) do
                RemoveBlip(blip)
            end
            blips = {}
        end
    else
        local blip = AddBlipForCoord(garagePos)
        SetBlipSprite(blip, 317)
        SetBlipColour(blip, 31)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.6)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garaj (Mecanic)")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)
    end

    Citizen.CreateThread(function()
        while jobActive do
            local ped = PlayerPedId()
            local pedPos = GetEntityCoords(ped)

            local dst = #(pedPos - garagePos)
            
            while dst <= 10 and jobActive do

                
				DrawText3D(garagePos[1], garagePos[2], garagePos[3]+0.4, "Autovehicul tractari", 1.0, 0, {255, 255, 255})
				DrawMarker(39, garagePos[1], garagePos[2], garagePos[3], 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 213, 195, 152, 200, 0, 0, 0, 1)

				if dst <= 1 then
					drawText("Apasa ~HC_38~E~w~ pentru a tracta masini !~n~~HC_53~F5~w~ pentru apeluri", 0.5, 0.85, 0.4, 255, 255, 255)
					if IsControlJustPressed(0, 38) then
						
                        local data = {
                            hash = GetHashKey("slamtruck"),
                            pos = vector4(garagePos[1], garagePos[2], garagePos[3], 140.0),
                        }

                        local i = 0
                        while not HasModelLoaded(data.hash) and i < 1000 do
                            RequestModel(data.hash)
                            Citizen.Wait(10)
                            i = i+1
                        end

                        if HasModelLoaded(data.hash) then

                            truckObject = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.pos[4], true, false)
                            NetworkFadeInEntity(truckObject,0)
                            SetVehicleFuelLevel(truckObject, 100.0)
                            SetVehicleOnGroundProperly(truckObject)
                            SetEntityInvincible(truckObject,false)
                            Citizen.InvokeNative(0xAD738C3085FE7E11, truckObject, true, true) -- set as mission entity
                            SetVehicleHasBeenOwnedByPlayer(truckObject, true)
                            local ped = PlayerPedId()
                            SetPedIntoVehicle(ped, truckObject, -1)
                            SetVehicleLivery(truckObject, 19)

                            local blip = AddBlipForEntity(truckObject)
                            SetBlipSprite(blip, 637)
                            SetBlipColour(blip, 45)
                            SetBlipScale(blip, 0.6)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Vehicul mecanici")
                            EndTextCommandSetBlipName(blip)

                            TriggerServerEvent("mechanic:setTruckObj", NetworkGetNetworkIdFromEntity(truckObject))

                            TriggerEvent("chatMessage", "^5Info^7: Foloseste ^1F5 ^7si apasa ^1Tracteaza^7 pentru a tracta masini")
                        end
						break
					end
				end
                
                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)
                dst = #(pedPos - garagePos)
                Citizen.Wait(1)
            end

            Citizen.Wait(500)
        end
    end)
end)


Citizen.CreateThread(function()
	local gasCoords = vec3(-1586.4603271484,-832.32244873047,9.9755907058716)
    local storeCoords = vec3(-1604.8725585938,-837.2373046875,10.156060218811)

	local blip = AddBlipForCoord(gasCoords)
	SetBlipSprite(blip, 361)
	SetBlipColour(blip, 1)
    SetBlipScale(blip, 0.6)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Combustibil")
	EndTextCommandSetBlipName(blip)

	local blip = AddBlipForCoord(storeCoords)
    SetBlipSprite(blip, 59)
    SetBlipColour(blip, 20)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Magazin (Mecanic)")
    EndTextCommandSetBlipName(blip)

	Citizen.Wait(1000)

	while true do
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		if not IsPedSittingInAnyVehicle(ped) then
			local dst = #(pedCoords - gasCoords)

			while dst <= 10 do
				DrawText3D(gasCoords.x, gasCoords.y, gasCoords.z + .4, "Combustibil", 1.0, 0, {255, 255, 255})
				DrawMarker(20, gasCoords.x, gasCoords.y, gasCoords.z, 0, 0, 0, 0, 0, 0, 0.401, 0.401, 0.4001, 254, 95, 85, 200, 0, 0, 0, 1)

				if dst <= 1 then
					drawText("Apasa ~r~E~w~ pentru a lua o canistra cu Combustibil !", 0.5, 0.85, 0.4, 255, 255, 255)

					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("mechanic:getGasCan")
						Citizen.Wait(5000)
						break
					end
				end

				Citizen.Wait(1)

				pedCoords = GetEntityCoords(ped)
                dst = #(pedCoords - gasCoords)
			end

			local dst = #(pedCoords - storeCoords)

			while dst <= 10 do
				DrawText3D(storeCoords.x, storeCoords.y, storeCoords.z + .4, "Truse de reparatie", 1.0, 0, {255, 255, 255})
				DrawMarker(20, storeCoords.x, storeCoords.y, storeCoords.z, 0, 0, 0, 0, 0, 0, 0.401, 0.401, 0.4001, 100, 79, 48, 200, 0, 0, 0, 1)

				if dst <= 1 then
					drawText("Apasa ~HC_85~E~w~ pentru a lua o Trusa de reparatie !", 0.5, 0.85, 0.4, 255, 255, 255)
					
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("mechanic:getRepairKit")
						Citizen.Wait(5000)
						break
					end
				end

				Citizen.Wait(1)

				pedCoords = GetEntityCoords(ped)
                dst = #(pedCoords - storeCoords)
			end
		end

		Citizen.Wait(3000)
	end

end)


local repairing = false

RegisterNetEvent("mechanic:repairClosestCar")
AddEventHandler("mechanic:repairClosestCar", function()

	if not repairing then

		local veh = 0
		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped, false) then
			veh = GetVehiclePedIsIn(ped, false)
		else
			veh = GetClosestVehicle(GetEntityCoords(ped), 10.0, 0, 4+2+1)
		end
		if veh ~= 0 then

			local waitTime = GetGameTimer() + 3000
			NetworkRequestControlOfEntity(veh)

			while not NetworkHasControlOfEntity(veh) and GetGameTimer() < waitTime do
				Citizen.Wait(10)
			end

			Citizen.CreateThread(function()
				repairing = true
				local minDimensions, maxDimensions = GetModelDimensions(GetEntityModel(veh))

				local hoodPos = GetOffsetFromEntityInWorldCoords(veh, 0.0, maxDimensions.y + 0.2, 0.0)
				local vehHeading = GetEntityHeading(veh)

				local dst = GetDistanceBetweenCoords(GetEntityCoords(ped), hoodPos, false)
				while dst < 15.0 and DoesEntityExist(veh) do

					DisableControlAction(0, 21, true)
					DisableControlAction(0, 22, true)

					DrawMarker(20, hoodPos, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 245, 176, 66, 200, 0, 0, 0, 1)

					if dst <= 1.0 then
						drawText("Apasa ~o~E~w~ pentru a repara masina", 0.5, 0.85, 0.4, 255, 255, 255)
						if IsControlJustPressed(0, 38) then

							RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
							while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
								Citizen.Wait(1)
							end

							SetVehicleDoorOpen(veh, 4, false)
							Citizen.Wait(500)


							SetEntityCoords(ped, hoodPos - vector3(0.0, 0.0, maxDimensions.z))
							SetEntityHeading(ped, (vehHeading + 180) % 360)

							Citizen.Wait(300)

							TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5, 1.0, 0.3, 48, 0.2, 0, 0, 0)
							FreezeEntityPosition(ped, true)

							Citizen.CreateThread(function()
								local untilTime = GetGameTimer() + 3000

								while GetGameTimer() < untilTime do
									drawText("Ai inceput sa repari masina...", 0.5, 0.85, 0.4, 245, 176, 66)
									Citizen.Wait(1)
								end
							end)

							Citizen.Wait(13000)
							TriggerServerEvent("mechanic:useRepairKit")
							SetVehicleEngineHealth(veh, 1000.0)
							
							StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5)
							FreezeEntityPosition(ped, false)

							Citizen.Wait(500)
							SetVehicleDoorShut(veh, 4, false)

							Citizen.CreateThread(function()
								local untilTime = GetGameTimer() + 4000

								while GetGameTimer() < untilTime do
									drawText("Intra in masina pentru a verifica reparatia", 0.5, 0.85, 0.4, 245, 176, 66)
									Citizen.Wait(1)
								end
							end)

							local maxtime = GetGameTimer() + 30000
							while GetVehiclePedIsIn(ped, false) ~= veh and GetGameTimer() <= maxtime do
								Citizen.Wait(500)
							end

							Citizen.CreateThread(function()
								SetVehicleEngineHealth(veh, 1000.0)
								Citizen.Wait(500)
								SetVehicleEngineOn(veh, true, false, true)
							end)

							break

						end
					end

					dst = GetDistanceBetweenCoords(GetEntityCoords(ped), hoodPos, false)
					Citizen.Wait(1)
				end

				repairing = false
			end)
			
		else
			local untilTime = GetGameTimer() + 3000

			while GetGameTimer() < untilTime do
				drawText("Nu a fost gasita nici o masina in apropiere", 0.5, 0.85, 0.4, 235, 64, 52)
				Citizen.Wait(1)
			end
		end
	end
end)


local attachedVehicle = nil

RegisterNetEvent("mechanic:startTow", function()
    if truckObject ~= nil then
        if attachedVehicle == nil then

            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local plyOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 5.0, 0.0)
            local rayHandle = StartShapeTestCapsule(plyCoords.x, plyCoords.y, plyCoords.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 10, GetPlayerPed(PlayerId()), 7)
            local _, _, _, _, frontVehicle = GetShapeTestResult(rayHandle)

            if frontVehicle and frontVehicle ~= 0 then

	            if frontVehicle ~= truckObject then
	            	FreezeEntityPosition(frontVehicle, false)
	                local towOffset = GetOffsetFromEntityInWorldCoords(truckObject, 0.0, -2.5, 0.4)
	                local towRot = GetEntityRotation(truckObject, 1)
	                local vehicleHeightMin, vehicleHeightMax = GetModelDimensions(GetEntityModel(frontVehicle))

                    AttachEntityToEntity(frontVehicle, truckObject, GetEntityBoneIndexByName(truckObject, "bodyshell"), 0, -2.1, 0.0 - vehicleHeightMin.z, 10.0, 0.0, 0, 1, 1, 0, 1, 0, 1)
                    attachedVehicle = frontVehicle       

	                Citizen.CreateThread(function()
	                    while attachedVehicle do
	                        if truckObject ~= nil then
                                if IsPedInVehicle(PlayerPedId(), truckObject) then
                                    drawText("Apasa ~HC_38~H~w~ pentru a lasa masina", 0.5, 0.85, 0.4, 255, 255, 255)

                                    if IsControlJustReleased(0, 104) then
                                        DetachEntity(attachedVehicle, false, false)
                                        attachedVehicle = nil
                                    end
                                end

	                        else
	                            DetachEntity(attachedVehicle, false, false)
	                            attachedVehicle = ni
	                        end
	                        Citizen.Wait(1)
	                    end
	                end)

	            end
	        end
        else
            local towOffset = GetOffsetFromEntityInWorldCoords(truckObject, 0.0, -10.0, 0.0)
            DetachEntity(attachedVehicle, false, false)
            SetEntityCoords(attachedVehicle, towOffset.x, towOffset.y, towOffset.z, 1, 0, 0, 1)
            PlaceObjectOnGroundProperly(attachedVehicle)
            attachedVehicle = nil
        end
    end
end)

local resName = GetCurrentResourceName()
AddEventHandler("onResourceStop", function(res)
    if res == resName then
        for k, object in pairs(objs) do
            DeleteEntity(object)
        end
        objs = {}
    end
end)
