
local objHash = GetHashKey("hei_prop_bank_cctv_02")

local camCoords = {
	-- rot = {down/up, tilt, right/left}
	{pos = vector3(302.79559326172,-1028.7559814453,84.335180664063), defRot = vector3(-20.0, 0.0, 180.0)},
	{pos = vector3(-662.123046875,-853.89892578125,51.656372070313), defRot = vector3(-20.0, 0.0, 20.0)},
	{pos = vector3(-225.52087402344,-910.0615234375,49.836669921875), defRot = vector3(-20.0, 0.0, 20.0)},

	-- Pacific
	{pos = vector3(238.2683, 224.5893, 108.5765), defRot = vector3(-20.0, 0.0, 230.0)},
	{pos = vector3(243.2956, 214.1091, 108.5765), defRot = vector3(-20.0, 0.0, 320.0)},
	{pos = vector3(257.2969, 214.889, 116.2107), defRot = vector3(-50.0, 0.0, 70.0)},
	{pos = vector3(251.656, 226.8291, 110.7206), defRot = vector3(-30.0, 0.0, 240.0)},
	{pos = vector3(262.8342, 224.267, 104.3928), defRot = vector3(-20.0, 0.0, 70.0)},
	{pos = vector3(262.3081, 217.8172, 108.468), defRot = vector3(-30.0, 0.0, 180.0)},
	{pos = vector3(237.4923, 211.3623, 108.4765), defRot = vector3(-30.0, 0.0, 20.0)},
	{pos = vector3(193.8097, 217.4009, 142.1217), defRot = vector3(-50.0, 0.0, 240.0)},
	{pos = vector3(225.4583, -1159.728, 35.93193), defRot = vector3(-20.0, 0.0, 30.0)}
}

Citizen.CreateThread(function()
    for i in pairs(camCoords) do
        camCoords[i].obj = CreateObject(objHash, camCoords[i].pos, false, true, false)
        FreezeEntityPosition(camCoords[i].obj, true)
    end
end)

RegisterCommand("createcam", function()

    local tempPos = GetEntityCoords(PlayerPedId()) + vector3(0, 0, 2.0)

    local obj = CreateObject(objHash, tempPos, false, true, false)

    while true do

        local newValues = false

        if IsControlJustPressed(0, 177) then -- esc
            break
        end

        if IsControlPressed(0, 241) then -- scroll up
            tempPos = tempPos + vector3(0, 0, 0.005)
            newValues = true
        elseif IsControlPressed(0, 242) then -- scroll down
            tempPos = tempPos - vector3(0, 0, 0.005)
            newValues = true
        end

        if IsControlPressed(0, 172) then -- up
            tempPos = tempPos + vector3(0, 0.005, 0)
            newValues = true
        end

        if IsControlPressed(0, 173) then -- down
            tempPos = tempPos - vector3(0, 0.005, 0)
            newValues = true
        end

        if IsControlPressed(0, 174) then -- left
            tempPos = tempPos + vector3(0.005, 0, 0)
            newValues = true
        end

        if IsControlPressed(0, 175) then -- right
            tempPos = tempPos - vector3(0.005, 0, 0)
            newValues = true
        end

        if newValues then
            SetEntityCoords(obj, tempPos)
        end

        Citizen.Wait(1)
    end

    print(tempPos)
    DeleteEntity(obj)
end)

local function CreateInstructions(passedScaleform, buttonsMessages)
    local tempScaleform = RequestScaleformMovie(passedScaleform)
    while not HasScaleformMovieLoaded(tempScaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(tempScaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(tempScaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    local buttonCount = 0
    for k, v in pairs(buttonsMessages) do
        PushScaleformMovieFunction(tempScaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(buttonCount)
        N_0xe83a3e3557a56640(GetControlInstructionalButton(2, v.button, true))
        BeginTextCommandScaleformString("STRING")
        AddTextComponentScaleform(v.name)
        EndTextCommandScaleformString()
        PopScaleformMovieFunctionVoid()
        buttonCount = buttonCount + 1
    end

    PushScaleformMovieFunction(tempScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(tempScaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(70)
    PopScaleformMovieFunctionVoid()

    return tempScaleform
end

local activeCam, dynamicRot, zoom, activeCamId, streetName, drawHelper, nighVision = false, nil, nil, nil, nil, true,false

local function stopCam()
    if activeCam then
        activeCam = false

        DoScreenFadeOut(500)
        Citizen.Wait(500)

        RenderScriptCams(false, false, 0, true, false)
        DestroyAllCams(true)

        ClearTimecycleModifier()
        FreezeEntityPosition(PlayerPedId(), false)
        ClearFocus()
        SetNightvision(false)

        Citizen.Wait(500)
        DoScreenFadeIn(1000)
        TriggerEvent("vrp-hud:updateMap", true)
        TriggerEvent("vrp-hud:setComponentDisplay", {
            serverHud = true,
            minimapHud = true,
            bottomRightHud = true,
            chat = true,
        })
    end
end

local function setCam(camId)

    local pos, rot = camCoords[camId].pos, camCoords[camId].defRot

    if activeCam then

        SetFocusArea(pos, vector3(0, 0, 0))

        if not camCoords[activeCamId].obj or GetEntityHealth(camCoords[activeCamId].obj) > 980 then
            DoScreenFadeOut(200)
            Citizen.Wait(200)
        end

        dynamicRot = rot
        zoom = 60.0
        activeCamId = camId

        SetCamCoord(activeCam, pos)
        SetCamFov(activeCam, zoom)
        SetCamRot(activeCam, rot)
        streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(pos.x, pos.y, pos.z))

        DoScreenFadeIn(200)
        return
    end

    activeCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamCoord(activeCam, pos)
    SetCamRot(activeCam, rot)

    dynamicRot = rot
    zoom = 60.0
    activeCamId = camId

    SetCamFov(activeCam, zoom)
    SetCamActive(activeCam, true)

    DoScreenFadeOut(500)
    Citizen.Wait(500)

    SetFocusArea(pos, vector3(0, 0, 0))
    RenderScriptCams(true, false, 0, true, true)

    streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(pos.x, pos.y, pos.z))

    Citizen.Wait(500)
    DoScreenFadeIn(1000)

    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)

        SetTimecycleModifier("CAMERA_BW")
        SetTimecycleModifierStrength(0.5)

        local controlsScaleform = CreateInstructions("instructional_buttons", {{
            name = "Exit",
            button = 200
        }, {
            name = "",
            button = 242
        }, {
            name = "Zoom",
            button = 241
        }, {
            name = "Viteza",
            button = 21
        }, {
            name = "",
            button = 175
        }, {
            name = "",
            button = 173
        }, {
            name = "",
            button = 172
        }, {
            name = "Misca Camera",
            button = 174
        }, {
            name = "",
            button = 38
        }, {
            name = "Schimba Camera",
            button = 44
        }, {
            name = "Viziune nocturna",
            button = 74
        }})

        local x, y = 0.84, 0.04


        TriggerEvent("vrp-hud:updateMap", false)
        TriggerEvent("vrp-hud:setComponentDisplay", {
            serverHud = false,
            minimapHud = false,
            bottomRightHud = false,
            chat = false,
        })

        while activeCam do

            ::reLoop::

            if camCoords[activeCamId].obj and GetEntityHealth(camCoords[activeCamId].obj) < 980 then
                SetTextFont(0)
                SetTextProportional(0)
                SetTextCentre(true)
                SetTextScale(0.4, 0.4)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextEntry("STRING")
                SetTextColour(255, 255, 255, 255)
                AddTextComponentString("No Signal")
                DrawText(0.5, 0.5)
                DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 255)
            else
                local year, month, day, hour, minute, second = GetLocalTime()
                local txt = string.format("%s / %02d.%02d.%d %02d:%02d:%02d", streetName, day, month, year, hour, minute, second)

                SetTextFont(0)
                SetTextProportional(0)
                SetTextCentre(true)
                SetTextScale(0.35, 0.35)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextEntry("STRING")
                SetTextColour(255, 255, 255, 255)
                AddTextComponentString(txt)
                DrawText(x, y)
                DrawRect(x, y + 0.012, string.len(txt) / 180, 0.04, 255, 0, 0, 75)

                SetTextFont(4)
                SetTextProportional(0)
                SetTextCentre(true)
                SetTextScale(0.35, 0.35)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextEntry("STRING")
                SetTextColour(255, 255, 255, 255)
                AddTextComponentString("Ministerul Afacerilor Interne")
                DrawText(x, y - 0.02)
            end

            if drawHelper then
                DrawScaleformMovieFullscreen(controlsScaleform, 255, 255, 255, 255, 0)
            end

            local newValues = false
            local coef = 0.07

            if IsControlJustPressed(0, 177) then -- ESC / Backspace
                stopCam()
                break
            end

            if IsControlPressed(0, 21) then -- shift
                coef = 0.4
            end

            if IsControlPressed(0, 172) then -- up
                if dynamicRot.x < rot.x + 20.0 then
                    dynamicRot = dynamicRot + vector3(coef, 0, 0)
                    newValues = true
                end
            end

            if IsControlPressed(0, 173) then -- down
                if dynamicRot.x > rot.x - 60.0 then
                    dynamicRot = dynamicRot - vector3(coef, 0, 0)
                    newValues = true
                end
            end

            if IsControlPressed(0, 174) then -- left
                dynamicRot = dynamicRot + vector3(0, 0, coef)
                newValues = true
            end

            if IsControlPressed(0, 175) then -- right
                dynamicRot = dynamicRot - vector3(0, 0, coef)
                newValues = true
            end

            if IsControlPressed(0, 241) then -- scrool up
                if zoom > 5.0 then
                    zoom = zoom - 0.5
                    SetCamFov(activeCam, zoom)
                end
            elseif IsControlPressed(0, 242) then -- scroll down
                if zoom < 50.0 then
                    zoom = zoom + 0.5
                    SetCamFov(activeCam, zoom)
                end
            end

            if IsControlJustPressed(0, 73) then
                drawHelper = not drawHelper
            end

            if IsControlJustPressed(0, 74) then
                nighVision = not nighVision
                SetNightvision(nighVision)
            end

            if IsControlJustPressed(0, 44) then
                local prevId = activeCamId - 1
                if prevId < 1 then
                    prevId = #camCoords
                end
                setCam(prevId)
            elseif IsControlJustPressed(0, 38) then
                local nextId = activeCamId + 1
                if nextId > #camCoords then
                    nextId = 1
                end
                setCam(nextId)
            end

            if newValues then
                SetCamRot(activeCam, dynamicRot)
            end

            DisableControlAction(0,19,true)
			DisableControlAction(0,22,true)
			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,37,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,143,true)
			DisableControlAction(0,170,true)

            Citizen.Wait(1)
        end
    end)
end

RegisterNetEvent("police:watchCameras", setCam)
