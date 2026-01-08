
local postModel = GetHashKey("bzzz_prop_shop_locker")

local postCoords <const> = {
    vector4(75.91, 119.34, 79.18 - 1.0, 160.0),
    vector4(203.16, 6619.75, 31.58 - 1.0, 180.0),
    -- vector4(1768.42, 3651.07, 34.45 - 1.0, 30.0),
    vector4(1783.5374755859,3642.6184082031,34.633296966553 - 1.0,300),
    vector4(-239.74928283691,-851.37188720703,30.63805770874 - 1.0, 250.0),
}

local objs = {}


local function drawArrow(coords, label)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    local icon_scale = 1.0
    local text_scale = 0.25

    RequestStreamedTextureDict("basejumping", false)
    DrawSprite("basejumping", "arrow_pointer", screenX, screenY - 0.015, 0.015 * icon_scale, 0.025 * icon_scale, 180.0, 44, 56, 144, 255)

    SetTextCentre(true)
    SetTextScale(0.0, text_scale)
    SetTextEntry("STRING")
    AddTextComponentString(label)
    DrawText(screenX, screenY)
end

RegisterNetEvent("vrp-post:notify", function()
    local dist = math.huge
    for k, v in pairs(postCoords) do
        local mts = #(pedPos - v.xyz)

        if mts < dist then
            dist = mts
        end
    end

    SendNUIMessage({interface = "postNotify", distance = math.floor(dist)})
end)

Citizen.CreateThread(function()
    RequestModel(postModel)
    while not HasModelLoaded(postModel) do
        Citizen.Wait(1)
    end

    for indx, coords in pairs(postCoords) do
        local prop = CreateObject(postModel, coords.x, coords.y, coords.z, false, true)
        
        PlaceObjectOnGroundProperly(prop)
        SetEntityHeading(prop, coords.w)
        FreezeEntityPosition(prop, true)
        SetEntityAsMissionEntity(prop, true, true)

        objs[indx] = prop

        local blip = AddBlipForCoord(coords.xyz)
        SetBlipSprite(blip, 814)
        SetBlipColour(blip, 38)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Locker postal")
        EndTextCommandSetBlipName(blip)
    end

    local input = false

    while true do
        for i, coords in pairs(postCoords) do
            local dst = #(pedPos - coords.xyz)

            local obj = objs[i]

            while dst <= 10 do
                Citizen.Wait(1)
                coords = GetOffsetFromEntityInWorldCoords(obj, 1.0, 0.0, 1.0)

                drawArrow(coords, "Locker postal")

                if dst <= 1 then
                    if not input then
                        input = true
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Acceseaza lockerul"})
                    end

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("vrp-post:useLocker")
                        Citizen.Wait(1000)
                        break
                    end
                elseif input then
                    TriggerEvent("vrp-hud:showBind", false)
                    input = false
                end

                dst = #(pedPos - coords.xyz)
            end
        end

        Citizen.Wait(1000)
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() then
        for k, obj in pairs(objs) do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
            objs[k] = nil
        end
    end
end)

