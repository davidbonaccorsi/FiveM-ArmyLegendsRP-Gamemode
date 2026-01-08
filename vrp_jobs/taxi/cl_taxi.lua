
local startingPos = vector3(895.46307373047,-179.29476928711,74.70036315918)

local garagePos = vector3(916.28723144531,-170.58995056152,74.426849365234)

local fare = 500

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
    SetBlipSprite(blip, 198)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Taximetrist")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("TaxiStarter", {
        position = startingPos,
        rotation = 330,
        model = "g_m_y_mexgoon_02",
        freeze = true,
        minDist = 2.5,        
        name = "Luta Taximetristul",
        ["function"] = function()
            SendNUIMessage({job = "taxi", group = inJob})
        end
    })

    table.insert(allJobPeds, "TaxiStarter")

end)

local blips, objs = {}, {}

local jobActive
local taxiObj
AddEventHandler("jobs:onJobSet", function(job)
    Citizen.Wait(500)
    jobActive = (inJob == "Taximetrist")

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
        SetBlipSprite(blip, 811)
        SetBlipColour(blip, 60)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.6)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garaj (Taxi)")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)

        vRP.subtitle("Mergi pana la ~y~garajul~w~ destinat job-ului pentru a incepe munca.")
    end

    Citizen.CreateThread(function()
        while jobActive do
            local ped = PlayerPedId()
            local pedPos = GetEntityCoords(ped)

            local dst = #(pedPos - garagePos)

            if not DoesEntityExist(taxiObj) then
                taxiObj = nil
            end
            
            while dst <= 10 and jobActive do

                
				DrawText3D(garagePos[1], garagePos[2], garagePos[3]+0.4, "Autovehicul transport", 1.0, 0, {255, 255, 255})
				DrawMarker(36, garagePos[1], garagePos[2], garagePos[3], 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 255, 222, 42, 200, 0, 0, 0, 1)

				if dst <= 1 then
					drawText("Apasa ~y~E~w~ pentru a astepta comenzi !~n~~HC_ 55~F5~w~ pentru apeluri", 0.5, 0.85, 0.4, 255, 255, 255)
					if IsControlJustPressed(0, 38) then

                        if DoesEntityExist(taxiObj) then
                            TriggerEvent("vrp-hud:notify", "Ai deja un vehicul spawnat.", "error")
                        else
                            local data = {
                                hash = GetHashKey("taxi"),
                                pos = vector4(garagePos[1], garagePos[2], garagePos[3], 100.0),
                            }
    
                            local i = 0
                            while not HasModelLoaded(data.hash) and i < 1000 do
                                RequestModel(data.hash)
                                Citizen.Wait(10)
                                i = i+1
                            end
    
                            if HasModelLoaded(data.hash) then
    
                                taxiObj = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.pos[4], true, false)
                                NetworkFadeInEntity(taxiObj,0)
                                SetVehicleFuelLevel(taxiObj, 100.0)
                                SetVehicleOnGroundProperly(taxiObj)
                                SetEntityInvincible(taxiObj,false)
                                Citizen.InvokeNative(0xAD738C3085FE7E11, taxiObj, true, true) -- set as mission entity
                                SetVehicleHasBeenOwnedByPlayer(taxiObj, true)
                                local ped = PlayerPedId()
                                SetPedIntoVehicle(ped, taxiObj, -1)
                                SetVehicleLivery(taxiObj, 19)
    
                                local blip = AddBlipForEntity(taxiObj)
                                SetBlipSprite(blip, 198)
                                SetBlipColour(blip, 45)
                                SetBlipScale(blip, 0.6)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("Vehicul taxi")
                                EndTextCommandSetBlipName(blip)
    
                                TriggerServerEvent("jobs:setTaxiObj", NetworkGetNetworkIdFromEntity(taxiObj))
    
                            end
                            break
                        end
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

RegisterNetEvent("work-taxi:startTrackingTaxi", function(playerNet, vehNet, position, code)
    local driver = GetPlayerFromServerId(playerNet)
    local driverPed = GetPlayerPed(driver)

    if driverPed then
        local driverPos = GetEntityCoords(driverPed)

        local function drawArrow(coords, label)
            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
            local icon_scale = 1.0
            local text_scale = 0.25
        
            RequestStreamedTextureDict("basejumping", false)
            DrawSprite("basejumping", "arrow_pointer", screenX, screenY - 0.015, 0.015 * icon_scale, 0.025 * icon_scale, 180.0, 246, 255, 139, 255)
        
            SetTextCentre(true)
            SetTextScale(0.0, text_scale)
            SetTextEntry("STRING")
            AddTextComponentString(label)
            DrawText(screenX, screenY)
        end

        local ped = PlayerPedId()

        local cancel, wasCanceled = false, false
        cancel = RegisterNetEvent("work-taxi:cancelRoute", function()
            wasCanceled = true
            RemoveEventHandler(cancel)
        end)

        local dst = #(GetEntityCoords(ped) - driverPos)
        while dst > 3.5 do

            drawArrow(position, "Taximetristul vine aici")

            driverPos = GetEntityCoords(driverPed)
            dst = #(GetEntityCoords(ped) - driverPos)
            Citizen.Wait(1)
        end

        local veh, evt = NetworkGetEntityFromNetworkId(vehNet)
        evt = AddEventHandler("vrp:onPlayerEnterVehicle", function(theVehicle)
            if theVehicle == veh then
                vRP.subtitle("Ai urcat in taxi, tariful este de: ~y~$"..vRP.formatMoney(fare).."/km", 3)

                Citizen.CreateThread(function()

                    local evt, amount = nil, 0

                    evt = AddEventHandler("vrp:onPlayerLeaveVehicle", function(veh)
                    
                        if not wasCanceled then
                            TriggerServerEvent("work-taxi:payDriver", amount, playerNet, code)
                        else
                            vRPclient.notify(player, {"Cursa a fost anulata si nu trebuie sa platesti."})
                        end

                        RemoveEventHandler(evt)
                    end)

                    local km = 1000

                    local lastPoint, traveled = false, 0

                    local nextKm = traveled + km
                    while IsPedInVehicle(ped, veh, true) do
                        if wasCanceled then break end

                        local pos = GetEntityCoords(ped)

                        local dst = #((lastPoint or pos) - pos)
                        traveled = traveled + dst

                        if traveled >= nextKm then
                            traveled = traveled + dst
                
                            nextKm = traveled + km
                
                            amount = amount + fare
                
                            TriggerServerEvent("work-taxi:updateFare", amount, playerNet, code)
                            vRP.subtitle("Total de plata: ~g~$"..vRP.formatMoney(amount), 5)
                        end

                        lastPoint = GetEntityCoords(ped)
                        
                        Citizen.Wait(100)
                    end
                end)

                RemoveEventHandler(evt)
            end
        end)
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
