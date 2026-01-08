
local searchedBins, trashModels <const> = {}, {
    GetHashKey('prop_bin_01a'),
    GetHashKey('prop_bin_03a'),
	GetHashKey('prop_bin_07b'),
	GetHashKey('prop_bin_07c'),
	GetHashKey('prop_bin_07a'),
	GetHashKey('prop_bin_08a'),
	GetHashKey('prop_cs_bin_02'),
    GetHashKey('prop_bin_05a'),
}

local reciclingPos, reciclingRot <const> = vector3(-460.2444152832,-1701.9600830078,18.837417602539), 252

local blip = AddBlipForCoord(reciclingPos)
SetBlipSprite(blip, 467) -- 527
SetBlipColour(blip, 64)
SetBlipScale(blip, 0.6)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Reciclare gunoaie")
EndTextCommandSetBlipName(blip)

Citizen.CreateThread(function()

    local pedId = tvRP.spawnNpc("recicling", {
        position = reciclingPos,
        rotation = reciclingRot,
        freeze = true,
        minDist = 3.5,
        
        model = "a_m_o_soucent_03",
        name = "George Rugina",
        ["function"] = function()
            TriggerServerEvent("vrp_reciclare:sellItems")
        end
    })

    while true do
        for i=1, #trashModels do
            local obj = GetClosestObjectOfType(pedPos.x, pedPos.y, pedPos.z, 1.0, trashModels[i], false, false, false)

            if obj ~= 0 and not searchedBins[obj] then
                local pos = GetEntityCoords(obj)

                while #(pos - pedPos) <= 1.8 do
                    -- if not isTrashAllowed(pos) then break end
                
                    DrawText3D(pos.x, pos.y, pos.z + 1.0, "[~HC_22~G~w~] Cauta in gunoi", 0.7)

                    if IsControlJustReleased(0, 47) then
                        searchedBins[obj] = true

                        TaskTurnPedToFaceEntity(tempPed, obj, -1)
                        RequestAnimDict("anim@gangops@morgue@table@")

                        while not HasAnimDictLoaded("anim@gangops@morgue@table@") do
                            Wait(1)
                        end

                        TaskPlayAnim(tempPed, 'anim@gangops@morgue@table@', 'player_search', 8.0, -8.0, -1, 1, 0, false, false, false)
                        Wait(10000)
                        
                        ClearPedTasks(tempPed)
                        triggerCallback("searchTrash", function(gotSomething)
                            if not gotSomething then
                                tvRP.subtitle("Tocmai te-a muscat un ~r~sobolan~w...")
                                tvRP.varyHealth(-5)
                            end
                        end)

                        break
                    end
                
                    Citizen.Wait(1)
                end
            end
        end

        Citizen.Wait(500)
    end
end)
