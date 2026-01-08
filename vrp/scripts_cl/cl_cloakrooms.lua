
local cam, inMenu = false, false


RegisterNetEvent("vrp-closets:openMenu")
AddEventHandler("vrp-closets:openMenu", function(theCloset, allUniform)
    inMenu = true
    TriggerEvent("vrp-hud:updateMap", false)
    TriggerEvent("vrp-hud:setComponentDisplay", {
        serverHud = false,
        minimapHud = false,
        bottomRightHud = false,
        chat = false
    })
    TriggerEvent("vrp:interfaceFocus", true)

    local px, py, pz = table.unpack(pedPos)
    local x, y, z = px + GetEntityForwardX(tempPed) * 2.5, py + GetEntityForwardY(tempPed) * 2.5, pz + 1.25
    local rx = GetEntityRotation(tempPed, 2)

    local camRotation = rx + vector3(-25.0, 0.0, 179.5)
    local camCoords = vector3(x, y, z)

    ClearFocus()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false)
    FreezeEntityPosition(tempPed, true)

    Citizen.Wait(500)
    SendNUIMessage({
        act = "interface",
        target = "factionCloset",
        event = "build",
        data = {theCloset, #allUniform},
    })
end)

RegisterNetEvent("vrp-closets:selectUniform", function(uniform)

    SendNUIMessage({
        act = "interface",
        target = "factionCloset",
        event = "update",
        current = uniform,
    })

end)

RegisterNUICallback("changeClosetUniform", function(data, cb)
    TriggerServerEvent("vrp-closets:setUniform", data[1], (IsPedMale(tempPed) == 1))
    cb("ok")
end)

RegisterNUICallback("resetClosetUniform", function(data, cb)
    TriggerServerEvent("vrp-closets:resetUniform")
    cb("ok")
end)

RegisterNUICallback("exitCloset", function(data, cb)
    TriggerEvent("vrp:interfaceFocus", false)
    TriggerServerEvent("vrp-closets:exitCloset")
    TriggerEvent("vrp-hud:updateMap", true)
    TriggerEvent("vrp-hud:setComponentDisplay", {
        serverHud = true,
        minimapHud = true,
        bottomRightHud = true,
        chat = true
    })
    Citizen.SetTimeout(2500, function()
		inMenu = false
	end)

    if cam then
        ClearFocus()
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(cam, false)
        FreezeEntityPosition(tempPed, false)
        cam = false
    end

    cb("ok")
end)

RegisterNetEvent("vrp-closets:populateClosets", function(allCloakroom)
    Citizen.CreateThread(function()

        while true do
    
            for _, data in pairs(allCloakroom) do
                while #(data[2] - pedPos) <= 5 do
                    
                    if not inMenu then
                        local rgb = data[4] or {255, 223, 8}
                        DrawMarker(1, data[2] - vec3(0.0, 0.0, 1.0), 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.85, rgb[1], rgb[2], rgb[3], 200)
                        DrawText3D(data[2].x, data[2].y, data[2].z, data[1].."~n~Vestiar", 1.0)
        
    
                        local newDst = #(data[2] - pedPos)
                        if newDst <= 0.5 then
                            SetEntityHeading(tempPed, data[3] + 0.0)
                            TriggerServerEvent("vrp-closets:openMenu", data[1], (IsPedMale(tempPed) == 1))
                            break
                        end
                    end
                        
                    Citizen.Wait(1)
                end
            end
    
            Citizen.Wait(3000)
        end
    
    end)
end)