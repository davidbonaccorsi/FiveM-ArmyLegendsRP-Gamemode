
local inAnyTrash, canHide = false, true

local dumpModels <const> = {
    GetHashKey("prop_dumpster_01a"),
    GetHashKey("prop_dumpster_02a"),
    GetHashKey("prop_dumpster_02b"),
    GetHashKey("prop_dumpster_4a"),
    GetHashKey("prop_dumpster_4b"),
}

local deniedPos = {
    vec3(490.37628173828,-998.93664550781,27.785396575928),
}

local function isTrashAllowed(pos)
    local allowed = true
    for k, v in pairs(deniedPos) do
        if #(pos - v) <= 5.0 then
            allowed = false
            break
        end
    end
    return allowed
end

local function getOutOfTrash()
    inAnyTrash = false
    SetEntityCollision(tempPed, true, true)
    DetachEntity(tempPed, true, true)
    SetEntityVisible(tempPed, true, false)
    ClearPedTasks(tempPed)
    SetEntityCoords(tempPed, GetOffsetFromEntityInWorldCoords(tempPed, 0.0, -0.7, -0.75))
end

Citizen.CreateThread(function()
    while true do
        for i=1, #dumpModels do
            local obj = GetClosestObjectOfType(pedPos.x, pedPos.y, pedPos.z, 1.0, dumpModels[i], false, false, false)

            if obj ~= 0 then
                local pos = GetEntityCoords(obj)

                while #(pos - pedPos) <= 1.8 do
                    if not isTrashAllowed(pos) then break end
                
                    if not inAnyTrash then
                        DrawText3D(pos.x, pos.y, pos.z + 1.0, "[~HC_27~E~w~] Ascunde-te in gunoi", 0.7)

                        if IsControlJustReleased(0, 51) then
                            if not IsEntityAttached(tempPed) then
                                AttachEntityToEntity(tempPed, obj, -1, 0.0, -0.3, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)  
                                RequestAnimDict("timetable@floyd@cryingonbed@base")
                                
                                while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                                    Wait(1)
                                end

                                TaskPlayAnim(tempPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                                Wait(50)
                                SetEntityVisible(tempPed, false, false)
                                
                                inAnyTrash = true

                                while inAnyTrash do

                                    local obj = GetEntityAttachedTo(tempPed)
                                    local pos = GetEntityCoords(obj)

                                    if DoesEntityExist(obj) or not tvRP.isInComa() then
                                        SetEntityCollision(tempPed, false, false)
                                        DrawText3D(pos.x, pos.y, pos.z + 1.0, "[~g~E~w~] Iesi din gunoi", 0.650)

                                        if not IsEntityPlayingAnim(tempPed, 'timetable@floyd@cryingonbed@base', 3) then
                                            RequestAnimDict("timetable@floyd@cryingonbed@base")
                                            
                                            while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                                                Wait(1)
                                            end

                                            TaskPlayAnim(tempPed, 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                                        end

                                        if IsControlJustReleased(0, 51) then
                                            getOutOfTrash()
                                            break
                                        end
                                    else
                                        getOutOfTrash()
                                    end

                                    Wait(1)
                                end

                            else
                                tvRP.notify("Cineva se ascunde deja in acest tomberon!", "error", false, "fas fa-trash")
                            end
                        end
                    end

                    Citizen.Wait(1)
                end
            end
        end

        Citizen.Wait(500)
    end
end)
