
local startingPos = vector3(-675.16284179688,5825.4506835938,17.346885681152)

local storePos = vector3(-674.33605957031,5838.8579101562,17.398435592651)

local gunshopPos = vector3(-679.33581542969,5837.154296875,17.398433685303)

local huntPos, huntRadius = vec3(-1464.5980224609,4573.728515625,42.793586730957), 250.0

local animalModels <const> = {
	[GetHashKey("a_c_panther")] = true,
	[GetHashKey("a_c_rabbit_01")] = true,
	[GetHashKey("a_c_chickenhawk")] = true, 
	[GetHashKey("a_c_cormorant")] = true,
	[GetHashKey("a_c_crow")] = true,
	[GetHashKey("a_c_deer")] = true,
	[GetHashKey("a_c_boar")] = true
}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 141)
    SetBlipColour(blip, 10)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vanator")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("HunterStarter", {
        position = startingPos,
        rotation = 95,
        model = "ig_hunter",
        freeze = true,
        minDist = 2.5,        
        name = "Iulian Vanatorul",
        ["function"] = function()
            SendNUIMessage({job = "hunter", group = inJob})
        end
    })

    table.insert(allJobPeds, "HunterStarter")

    local pedId = vRP.spawnNpc("VanatorStore", {
		position = storePos,
		rotation = 135,
		model = "ig_josef",
		freeze = true,
		minDist = 3.5,
		name = "Alexandru Cormoranu",
		buttons = {
			{text = "Vreau sa vand materiale vanate", response = function()
                local reply = promise.new()
                triggerCallback('sellDropsHunter', function(res)
                    reply:resolve(res)
                end)

                return Citizen.Await(reply)
            end},
		}
	})

	table.insert(allJobPeds, "VanatorStore")

end)


local blips, objs, evs = {}, {}, {}

local jobActive = false

local nearAnimals = {}

AddEventHandler("jobs:onJobSet", function(job)
    
    Citizen.Wait(500)

    jobActive = (inJob == "Vanator")

    if jobActive then
        local evt
        evt = AddEventHandler("jobs:onJustFired", function()
            Citizen.Wait(100)
                  
            if next(blips) then
                for _, blipid in pairs(blips) do
                    RemoveBlip(blipid)
                end
                blips = {}
            end

            for k, object in pairs(objs) do
                DeleteEntity(object)
            end
            objs = {}

            for k, evt in pairs(evs) do
                RemoveEventHandler(evt)
            end

            RemoveEventHandler(evt)
        end)
        
        Citizen.CreateThread(function()
            Citizen.Wait(1500)
            TriggerServerEvent("work-forester:initPlayer")
            vRP.subtitle("Animalele abia asteapta sa fie ~HC_199~vanate~w~, mergi in padure.", 8)
        end)

        table.insert(evs, RegisterNetEvent("work-hunter:handleAnimal", function(nid, relationship, taskWander)
            ::tryCheckNid::
            if not NetworkDoesNetworkIdExist(nid) then
                Citizen.Wait(5000)
                if not jobActive then
                    return
                end
                goto tryCheckNid
            end
            local animal = NetworkGetEntityFromNetworkId(nid)
            
            local animalBlip = AddBlipForEntity(animal)
            SetBlipSprite(animalBlip, 271)
            SetBlipColour(animalBlip, 1)
            SetBlipScale(animalBlip, 0.4)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Animal")
            EndTextCommandSetBlipName(animalBlip)
            table.insert(blips, animalBlip)

            local pos = GetEntityCoords(animal)

            for height = 0, 800, 2 do
                Citizen.Wait(1)
                local ground, newZ = GetGroundZFor_3dCoord(pos.x,pos.y,height+0.0001)
                
                if ground then
                    pos = vector3(pos.x, pos.y, newZ + 1)
                    break
                end
            end
            SetEntityCoordsNoOffset(animal, pos.x, pos.y, pos.z, true)
        
            if relationship then
                SetPedRelationshipGroupHash(animal, 0x7BEA6617)
            end
            if taskWander then
                Citizen.CreateThread(function()
                    while jobActive do
                        if IsEntityDead(animal) then
                            -- RemoveBlip(animalBlip)
                            break
                        end
                        TaskWanderInArea(animal, huntPos, huntRadius - 20.0, 10, 0.2)
                        Citizen.Wait(2000)
                    end
                end)
            end
        end))

        local blip = AddBlipForRadius(huntPos, huntRadius)
        SetBlipColour(blip, 2)
        SetBlipAlpha(blip, 50)

        table.insert(blips, blip)

        local inForest
        local wasInForest = false

        local input = false

        local ped = PlayerPedId()
        local pedPos = GetEntityCoords(ped)

        while jobActive do
            inForest = (#(huntPos - pedPos) <= huntRadius)

            local dst = #(gunshopPos - pedPos)

            print(dst)

            if dst <= 10 then
                DrawMarker(31, gunshopPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 178, 144, 132, 100, 0, 0, 0, true)

                if dst <= 2 then
                    if not input then
                        input = true
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Magazin vanator (musket/gloante)"})
                    end

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("work-hunter:getMusket")
                        TriggerEvent("vrp-hud:showBind", false)
                        input = false
                        Citizen.Wait(1000)
                    end

                elseif input then
                    TriggerEvent("vrp-hud:showBind", false)
                    input = false
                end
            end

            if inForest then
                TriggerServerEvent("work-hunter:enterForest")
                TriggerEvent("dmg:setMusket", true)
            end

            while inForest do
                inForest = (#(huntPos - pedPos) <= huntRadius)
                wasInForest = true

                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)

                Citizen.Wait(1)
            end

            if wasInForest then
                wasInForest = false
                TriggerEvent("dmg:setMusket", false)
            end
            

            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)

            Citizen.Wait(1)
        end
    end
end)

AddEventHandler("jobs:onJobSet", function(job)
    Citizen.Wait(600)

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)
    Citizen.CreateThread(function()
        while jobActive do
            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)
            Citizen.Wait(1)
        end
    end)

    local input = false

    Citizen.CreateThread(function()
        while jobActive do
            ::retryDraw::
            local near = false
            if next(nearAnimals) then
                for i in pairs(nearAnimals) do
                    DrawMarker(20, nearAnimals[i].pos, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 100, 0, 0, 0, true)
                
					if #(pedPos - nearAnimals[i].pos) <= 1.5 then
                        near = true

                        if not input then
                            input = true
                            TriggerEvent("vrp-hud:showBind", {key = "E", text = "Jupoaie animalul"})
                        end

                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("vrp-hud:showBind", false)

                            TaskTurnPedToFaceEntity(ped, nearAnimals[i].animal, 2000)
                            Citizen.Wait(1500)


							RequestAnimDict("anim@gangops@facility@servers@bodysearch@")
							RequestAnimDict("amb@medic@standing@kneel@base")
							while not HasAnimDictLoaded("anim@gangops@facility@servers@bodysearch@") do
								Citizen.Wait(50)
							end

							local animDuration = GetAnimDuration("anim@gangops@facility@servers@bodysearch@", "player_search")
                            local cutting = true
                            Citizen.CreateThread(function()
                                local viewMode = GetFollowPedCamViewMode()
                                SetGameplayCamRelativePitch(0, 1.0)
                                SetFollowPedCamViewMode(4)
                                SetPedCurrentWeaponVisible(ped, false)

                                local weaponObj = CreateWeaponObject("weapon_musket", 0, pedPos, true, 1.0)
                                NetworkRegisterEntityAsNetworked(weaponObj)
                                AttachEntityToEntity(weaponObj, ped, GetPedBoneIndex(ped, 0x68BD), vector3(0.35, 0.31, -0.95), vector3(-90.0, 0.0, 82.0), 0, false, false, true, 0, true)

                                Citizen.CreateThread(function()
                                    -- local activeSrc = {}

                                    -- local activePly = GetActivePlayers()
                                    -- for _, ply in ipairs(activePly) do
                                    --     table.insert(activeSrc, GetPlayerServerId(ply))
                                    -- end
                                    Citizen.Wait((animDuration*1000) / 1.8)
                                    -- TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "stab_animal", 0.4, activeSrc)
                                end)

                                while cutting do
                                    DisableAllControlActions(0)
                                    Citizen.Wait(1)
                                end

                                DeleteEntity(weaponObj)
                                SetFollowPedCamViewMode(viewMode)
                                SetPedCurrentWeaponVisible(ped, true)
                            end)

                            TaskPlayAnim(ped, "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false)
                            TaskPlayAnim(ped, "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false)
                            Citizen.Wait(animDuration*1000)
                            ClearPedTasksImmediately(ped)

                            cutting = false
                            if nearAnimals[i] then
                                TriggerServerEvent("work-hunter:sacrificeAnimal", NetworkGetNetworkIdFromEntity(nearAnimals[i].animal), GetPedCauseOfDeath(nearAnimals[i].animal))
                                local animal, evt = nearAnimals[i].animal
                                evt = RegisterNetEvent("work-hunter:deleteAnimal", function()
                                    if DoesEntityExist(animal) then
                                        DeleteEntity(animal)
                                        TriggerEvent("vrp-hud:notify", "Animalul este putrezit.", "error")
                                    end
                                    RemoveEventHandler(evt)
                                end)
                            end

                            nearAnimals = {}

                            goto retryDraw
                        end

                    end
                end
                if not near and input then
                    TriggerEvent("vrp-hud:showBind", false)
                    input = false
                end    
            else
                if input then
                    TriggerEvent("vrp-hud:showBind", false)
                    input = false
                end
                Citizen.Wait(1000)
            end

            Citizen.Wait(1)
        end
    end)

    while jobActive do
        
		nearAnimals = {}

		local handle, pedFound = FindFirstPed()
		local finished = false

		repeat
			if DoesEntityExist(pedFound) then
				if animalModels[GetEntityModel(pedFound)] then
					if IsEntityDead(pedFound) then
						local animalPos = GetEntityCoords(pedFound)
						if #(animalPos - pedPos) < 20.0 then
							table.insert(nearAnimals, {animal = pedFound, pos = GetOffsetFromEntityInWorldCoords(pedFound, 0.0, 0.0, 0.6)}) -- + vector3(0, 0, 0.3)
						end
					end
				end
			end
			finished, pedFound = FindNextPed(handle)
		until not finished
		EndFindPed(handle)

		Citizen.Wait(2000)
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
