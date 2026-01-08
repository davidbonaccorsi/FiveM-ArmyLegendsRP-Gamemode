
local dirtyCoords = vec3(154.50932312012,-1274.0792236328,20.336097717285)
local jewelCoords = vec3(2728.1672363281,4142.1274414062,44.287971496582)

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

local gameFinish
RegisterNUICallback("dirty:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

Citizen.CreateThread(function()
    
    local pedId = vRP.spawnNpc("JewelBuyer", {
        position = jewelCoords,
        rotation = 80,
        model = "u_m_y_gabriel",
        freeze = true,
        minDist = 2.5,        
        name = "Mihai Diamantul",
        ["function"] = function()
            TriggerServerEvent("vrp_vangelico:sellJews")
        end
    })

    table.insert(allJobPeds, "JewelBuyer")
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)

		if not IsPedSittingInAnyVehicle(ped) then 
		    local dst = #(pedCoords - dirtyCoords)
		    while dst <= 10 do
		    	DrawText3D(dirtyCoords.x, dirtyCoords.y, dirtyCoords.z + .4, "Spalare de bani", 1.0, 0, {255, 255, 255})
		    	DrawMarker(1, dirtyCoords.x, dirtyCoords.y, dirtyCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 0.901, 0.901, 0.8001, 53, 154, 71, 200, 0, 0, 0, 1)

		    	if dst <= 1 then
		    		drawText("Apasa ~HC_25~E~w~ pentru a spala Bani Murdari !~n~3.500 bani murdari ~w~+$~g~2.800", 0.5, 0.85, 0.4, 255, 255, 255)

		    		if IsControlJustPressed(0, 38) then
                        triggerCallback("canWashMoney", function(result, mafia, time)
                            if result then
                                SendNUIMessage({job = "dirtygame"})
                                gameFinish = function(ok)
                                    if ok then
                                        TriggerServerEvent("jobs:washDirtyMoney")
                                    end
                                end
                            elseif not mafia then
                                vRP.subtitle("Doar membrii unui ~r~gang~w~ sau a unei ~r~mafii~w~ pot spala bani !")
                            else
                                vRP.subtitle("Spalatoria a ramas fara bani !~n~Trebuie sa astepti ~r~"..time.." secunde")
                            end
                        end)

                        Citizen.Wait(100)
                        
		    			break
		    		end
		    	end

		    	Citizen.Wait(1)

                pedCoords = GetEntityCoords(ped)
		    	dst = #(pedCoords - dirtyCoords)
		    end
        end

        Citizen.Wait(1024)
    end
end)