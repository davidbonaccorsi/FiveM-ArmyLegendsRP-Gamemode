
-- Decides whether the player is able to perform a jump from a vehicle
function CanJumpFromVehicle(vehicle)
    local class = GetVehicleClass(vehicle)
    local speed = GetEntitySpeed(vehicle) * 3.6

    local whitelist = Config.jumpableVehicles

    -- Check whether the vehicle class or model is whitelisted
    if not Contains(whitelist.classes, class) and not ContainsHashed(whitelist.models, GetEntityModel(vehicle)) then
        return false
    end

    return speed >= (Config.minBikeSpeed or 5.0)
end

function ShouldFallOffVehicle(vehicle, holding)
    if IsEntityUpsidedown(vehicle) then
        return true
    end

    local difference = GetSpeedDifference(vehicle)
    local falloffForces = Config.roofHolding.falloffForces or 15.0
    if holding then
        falloffForces = falloffForces * Config.roofHolding.holdingForceMultiplier
    end

    return difference > falloffForces
end


local LAST_VEHICLE = nil
local LAST_SPEED = nil
function GetSpeedDifference(vehicle)
    return UseCache('GetSpeedDifference_' .. vehicle, function()
        local speed = GetEntitySpeed(vehicle) * 3.6

        local difference = 0
        if LAST_VEHICLE == vehicle then
            difference = math.abs(speed - LAST_SPEED)
        end

        LAST_SPEED = speed
        LAST_VEHICLE = vehicle
        return difference
    end, 100)
end

function KeybindTip(message)
    TriggerEvent("vrp-hud:notify", message, "info")
end

-- This function is responsible for all the tooltips displayed on top right of the screen, you could
-- replace it with a custom notification etc.
function Notify(message)
    TriggerEvent("vrp-hud:notify", message, "info")
end

-- Floating keybind help
function FloatingText(coords, message, arrowSide)
    local tag = 'KqBikeJumpHelpNotification'
    AddTextEntry(tag, message)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 2, 2, 90, arrowSide or 0, 2)
    BeginTextCommandDisplayHelp(tag)
    EndTextCommandDisplayHelp(2, false, false, -1)
end


--This function is responsible for drawing all the 3d texts
function Draw3DText(coords, textInput, scaleX)
    scaleX = scaleX * (Config.textScale or 1.0)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, coords, true)
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(scaleX * scale, scaleX * scale)
    SetTextFont(Config.textFont or 4)
    SetTextProportional(1)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
