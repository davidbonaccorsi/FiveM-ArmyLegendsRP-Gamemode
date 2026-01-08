
local isPrisoner = false
RegisterNetEvent("jail:setPrisonerState", function(tog)
    isPrisoner = tog
end)

local escapePos = vector3(1777.5665283203,2485.3815917969,45.849655151367)

local function drawArrow(coords, label)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
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

local activeEscape, canEscape = false, false
local mainPrisoner = false
RegisterNetEvent("vrp-jailbreak:setParticipant", function(tog)
    canEscape = tog
end)

local function createProp(hash, ...)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    local obj = CreateObject(hash, ...)
    SetModelAsNoLongerNeeded(hash)
    return obj
end

Citizen.CreateThread(function()

    local jailPos = vector3(-3837.1481933594,-4085.5886230469,57.432655334473)
    
    local blip = AddBlipForCoord(jailPos)
    SetBlipSprite(blip, 188)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Puscarie")
    EndTextCommandSetBlipName(blip)

    local blip = AddBlipForCoord(escapePos)
    SetBlipSprite(blip, 255)
    SetBlipColour(blip, 36)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punct de evadare")
    EndTextCommandSetBlipName(blip)
    SetBlipScale(blip, 0.6)

    local inputActive = false

    if true then return end -- dezactivat pana la update ca n am timp sa l fac
    while true do

        local dst = #(escapePos - pedPos)
        while dst <= 8.5 do
            local text = "Punct de evadare"
            if activeEscape then
                text = "Evadare in desfasurare"
            end

            drawArrow(escapePos, text)

            if dst <= 1.5 then

                if not inputActive then
                    inputActive = true

                    local text = "Evadeaza din puscarie"
                    if activeEscape and canEscape then
                        text = "Intra in tunel"
                    end
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = text})
                end

                if IsControlJustReleased(0, 38) then

                    if not activeEscape then
                        FreezeEntityPosition(tempPed, true)
                        SetEntityCoords(tempPed, escapePos.x, escapePos.y, escapePos.z - 1.0)
                        SetEntityHeading(tempPed, 211.9629)
                        local dict = "random@burial"
                        RequestAnimDict(dict)
                        while not HasAnimDictLoaded(dict) do Wait(0) end
                        TaskPlayAnim(tempPed, dict, "a_burial", -8.0, 8.0, -1, 1, 1.0)
                        RequestCollisionAtCoord(pedPos)
                        local prop = createProp(`prop_tool_shovel`, escapePos.x, escapePos.y, escapePos.z + 1.0, true, true, false)
                        local off, rot = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
                        AttachEntityToEntity(prop, tempPed, GetPedBoneIndex(tempPed, 28422), off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, false, true, 2, true)
                        Citizen.Wait(5000)
                        FreezeEntityPosition(tempPed, false)
                        ClearPedTasks(tempPed)
                        DeleteEntity(prop)

                        TriggerEvent("vrp-hud:showBind", false)
                        inputActive = false

                        mainPrisoner = true
                        activeEscape, canEscape = true, true
                    end
                end

            elseif inputActive then
                TriggerEvent("vrp-hud:showBind", false)
                inputActive = false
            end

            Citizen.Wait(1)
            dst = #(escapePos - pedPos)
        end

        if inputActive then
            TriggerEvent("vrp-hud:showBind", false)
            inputActive = false
        end
    
        if not isPrisoner then
            Citizen.Wait(1000)
        end
        Citizen.Wait(1)
    end
end)
