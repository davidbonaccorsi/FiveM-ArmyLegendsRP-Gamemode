local ncSpeeds = {0, 0.5, 2, 4, 6, 10, 20, 45}
local isInNoclip, ncIndex, entityInNoclip, isNoclipInv = false, 1, nil, false
local currentSpeed = tonumber(ncSpeeds[ncIndex])

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 289, true))
    ButtonMessage("Iesi din Noclip")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 85, true))
    ButtonMessage("Sus")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 46, true))
    ButtonMessage("Jos")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 34, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 35, true))
    ButtonMessage("Stanga / Dreapta")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 32, true))
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 33, true))
    ButtonMessage("Fata / Spate")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(1, 49, true))
    ButtonMessage("Vrei sa fi invizibil?")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, 21, true))
    ButtonMessage("Viteza de mers ["..ncIndex.."]")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(100)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local buttons
Citizen.CreateThread(function()
    buttons = setupScaleform("instructional_buttons")
end)

function tvRP.toggleNoclip()
    local pedId = PlayerPedId()
    isInNoclip = not isInNoclip

    if IsPedInAnyVehicle(pedId, false) then
        entityInNoclip = GetVehiclePedIsIn(pedId, false)
    else
        entityInNoclip = pedId
    end

    SetEntityCollision(entityInNoclip, not isInNoclip, not isInNoclip)
    FreezeEntityPosition(entityInNoclip, isInNoclip)
    SetEntityInvincible(entityInNoclip, isInNoclip)
    SetVehicleRadioEnabled(entityInNoclip, not isInNoclip)

    if isNoclipInv then
        isNoclipInv = not isNoclipInv
        SetEntityVisible(entityInNoclip, not isNoclipInv, 0)
        if entityInNoclip ~= PlayerPedId() then
            SetEntityVisible(PlayerPedId(), not isNoclipInv, 0)
        end
    end

    while isInNoclip do
        Citizen.Wait(1)

        DrawScaleformMovieFullscreen(buttons)

        local yoff = 0.0
        local zoff = 0.0

        if IsControlJustPressed(1, 21) then
            ncIndex = ncIndex + 1
            if ncIndex > #ncSpeeds then ncIndex = 1 end
            currentSpeed = tonumber(ncSpeeds[ncIndex])
            setupScaleform("instructional_buttons")
        end

        DisableControlAction(0, 23, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 266, true)
        DisableControlAction(0, 267, true)
        DisableControlAction(0, 268, true)
        DisableControlAction(0, 269, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 20, true)
        DisableControlAction(0, 74, true)
        DisableControlAction(0, 75, true)

        if IsDisabledControlPressed(0, 32) then
            yoff = 0.5
        end

        if IsDisabledControlPressed(0, 33) then
            yoff = -0.5
        end

        if IsDisabledControlPressed(0, 34) then
            SetEntityHeading(entityInNoclip, GetEntityHeading(entityInNoclip)+2)
        end

        if IsDisabledControlPressed(0, 35) then
            SetEntityHeading(entityInNoclip, GetEntityHeading(entityInNoclip)-2)
        end

        if IsDisabledControlPressed(0, 85) then
            zoff = 0.2
        end

        if IsDisabledControlPressed(0, 46) then
            zoff = -0.2
        end

        if IsDisabledControlJustPressed(1, 49) then
            isNoclipInv = not isNoclipInv

            SetEntityVisible(entityInNoclip, not isNoclipInv, 0)
            if entityInNoclip ~= PlayerPedId() then
                SetEntityVisible(PlayerPedId(), not isNoclipInv, 0)
            end
        end

        local newPos = GetOffsetFromEntityInWorldCoords(entityInNoclip, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
        local heading = GetEntityHeading(entityInNoclip)
        SetEntityVelocity(entityInNoclip, 0.0, 0.0, 0.0)
        SetEntityRotation(entityInNoclip, 0.0, 0.0, 0.0, 0, false)
        SetEntityHeading(entityInNoclip, heading)
        SetEntityCoordsNoOffset(entityInNoclip, newPos.x, newPos.y, newPos.z, isInNoclip, isInNoclip, isInNoclip)
    end
end

RegisterCommand("noclip", function()
    vRPserver.tryNoclipToggle({})
end)
RegisterKeyMapping("noclip", "Activeaza/dezactiveaza noclip", "keyboard", "F2")

function tvRP.isNoclip()
    return isInNoclip
end

exports("isInNoclip", tvRP.isNoclip)

function tvRP.tptoWaypoint()
    tvRP.gotoWaypoint()
end