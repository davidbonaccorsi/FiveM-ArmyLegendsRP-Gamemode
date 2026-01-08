local cfg = module('cfg/bunker')

local activeBunker
local bunkerEnterLocation = vector3(902.72698974609,-3182.3837890625,-97.056098937988)
local bunkerExit = vector3(903.18737792969,-3182.3420410156,-97.05241394043)
local bunkerMenu = vector3(908.45532226563,-3207.2561035156,-97.188003540039)
local chestPos = vector3(892.93206787109,-3221.1682128906,-98.229919433594)

-- Citizen.CreateThread(function()
--     for bunker, coords in pairs(cfg.bunkers) do
--         bunkerBlips[bunker] = AddBlipForCoord(coords)
--         SetBlipSprite(bunkerBlips[bunker], 557)
--         SetBlipColour(bunkerBlips[bunker], 31)
--         SetBlipScale(bunkerBlips[bunker], 0.7)
--         SetBlipAsShortRange(bunkerBlips[bunker], true)
--         BeginTextCommandSetBlipName("STRING")
--         AddTextComponentString("Buncar")
--         EndTextCommandSetBlipName(bunkerBlips[bunker])
--     end
-- end)

function SpawnVehicle(model, coords)
    local mhash = GetHashKey(model)

	local i = 0
	while not HasModelLoaded(mhash) and i < 1000 do
		RequestModel(mhash)
		Citizen.Wait(10)
		i = i+1
	end

    if HasModelLoaded(mhash) then
        local x,y,z = table.unpack(coords)
		local nveh = CreateVehicle(mhash, coords[1],coords[2],coords[3]+0.5, coords[4] or GetEntityHeading(PlayerPedId()) , true, false)
        NetworkFadeInEntity(nveh, 0)
        SetPedIntoVehicle(GetPlayerPed(-1), nveh, -1)

        SetVehicleOnGroundProperly(nveh)

        local vehCoords = GetEntityCoords(nveh)
        local px, py, pz = table.unpack(vehCoords)
        local x, y, z = px - GetEntityForwardX(nveh) * 6, py - GetEntityForwardY(nveh) * 6, pz + 0.90
        local rx = GetEntityRotation(nveh, 2)

        local camRotation = rx + vector3(0.0, 0.0, 0.0)
        local camCoords = vector3(x, y, z)

        ClearFocus()
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())

        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, true, false)

        SetTimeout(1000, function()
            RenderScriptCams(false, true, 1000, true, false)
            SetCamActive(cam, false)
            DestroyCam(cam, true)
            cam = false
        end)

        return nveh
    end
    return false
end

Citizen.CreateThread(function()
    RequestIpl("grdlc_int_01_shell")
    RequestIpl("gr_grdlc_int_01")
    RequestIpl("gr_grdlc_int_02")
    RequestIpl("gr_entrance_placement")
    RequestIpl("gr_grdlc_interior_placement")
    RequestIpl("gr_grdlc_interior_placement_interior_0_grdlc_int_01_milo_")
    RequestIpl("gr_grdlc_interior_placement_interior_1_grdlc_int_02_milo_")
    -- Outside
    RequestIpl("gr_case0_bunkerclosed")
    RequestIpl("gr_case1_bunkerclosed")
    RequestIpl("gr_case2_bunkerclosed")
    RequestIpl("gr_case3_bunkerclosed")
    RequestIpl("gr_case4_bunkerclosed")
    RequestIpl("gr_case5_bunkerclosed")
    RequestIpl("gr_case6_bunkerclosed")
    RequestIpl("gr_case7_bunkerclosed")
    RequestIpl("gr_case9_bunkerclosed")
    RequestIpl("gr_case10_bunkerclosed")
    RequestIpl("gr_case11_bunkerclosed")
end)

local bunkerActive = {}
Citizen.CreateThread(function()
    while true do

        for bunker, coords in pairs(cfg.bunkers) do
            local dst = #(coords - pedPos)
            while dst <= 10 do
		  
                if dst <= 1 then
                    if not bunkerActive[bunker] then
                        bunkerActive[bunker] = true
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Intra in Buncar"})
                    end
    
                    if IsControlJustPressed(0, 38) then
                        if bunkerActive[bunker] then
                            TriggerEvent("vrp-hud:showBind", false)
                        end

                        triggerCallback('getBunkerData', function(data)
                            activeBunker = bunker
                            SendNUIMessage({
                                interface = 'bunker',
                                data = data
                            })
                        end, bunker)
                        Citizen.Wait(1024)
                        break
                    end
                elseif bunkerActive[bunker] then
                    TriggerEvent("vrp-hud:showBind", false)
                    bunkerActive[bunker] = nil
                end

                DrawMarker(30, coords, 0, 0, 0, 0, 0, 0, 0.65, 0.65, 0.65, 255, 255, 255, 100, false, true, false, true)    
                pedPos = GetEntityCoords(PlayerPedId())
                dst = #(coords - pedPos)
                Citizen.Wait(1)
            end
		end
		Citizen.Wait(2000)
	end
end)

RegisterNetEvent('vrp-bunker:enter', function(bunker)
    activeBunker = bunker
    local ped = PlayerPedId()

    FreezeEntityPosition(ped, true)
    DoScreenFadeOut(1000, true)
    Wait(1500)
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, bunkerEnterLocation[1], bunkerEnterLocation[2], bunkerEnterLocation[3], true, false, false, true)

    local maxWait = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and maxWait > GetGameTimer() do
        Citizen.Wait(1)
    end

    EnableInteriorProp(258561,"standard_bunker_set")
    EnableInteriorProp(258561,"Bunker_Style_C")
    EnableInteriorProp(258561,"Office_Upgrade_set")
    EnableInteriorProp(258561,"Gun_schematic_set")
    EnableInteriorProp(258561,"security_upgrade")
    EnableInteriorProp(258561,"gun_range_lights")
    EnableInteriorProp(258561,"gun_locker_upgrade")
    RefreshInterior(258561)

    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(500, true)

    local keyActive = {}
    while true do

        local menuDst = #(bunkerMenu - pedPos)
        if menuDst <= 15 then
            DrawMarker(20, bunkerMenu, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 255, 255, 255, 255, false, true, false, true)
        
            if menuDst <= 1 then
            
                if not keyActive["menu"] then
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Acceseaza meniul"})
                    keyActive["menu"] = true
                end
        
                if IsControlJustReleased(0, 38) then
                    if keyActive["menu"] then
                        TriggerEvent("vrp-hud:showBind", false)
                        keyActive["menu"] = false
                    end
                    
                    triggerCallback('getBunkerMenuData', function(data)
                        if data then
                            SendNUIMessage({
                                interface = "bunkerInfo",
                                data = {
                                    craftings = cfg.bunkerCraftings,
                                    ownedCraftings = data.bunkerData,
                                    bunkerMissions = data.bunkerMissions,
                                    bunkerExpire = data.bunkerExpire,
                                }
                            })
                        else
                            tvRP.notify('Doar proprietarul are acces la acest meniu', 'error')
                        end
                    end)
                end
            elseif keyActive["menu"] then
                TriggerEvent("vrp-hud:showBind", false)
                keyActive["menu"] = false
            end
        end

        local chestDst = #(chestPos - pedPos)
        if chestDst <= 15 then
            DrawMarker(20, chestPos, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 255, 255, 255, 255, true, true, false, true)  
        
            if chestDst <= 1 then
            
                if not keyActive["chest"] then
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Foloseste cufarul"})
                    keyActive["chest"] = true
                end
        
                if IsControlJustReleased(0, 38) then
        
                    if keyActive["chest"] then
                        TriggerEvent("vrp-hud:showBind", false)
                        keyActive["chest"] = false
                    end
                    
                    TriggerServerEvent("vRP:bunkerChest")
                end
            elseif keyActive["chest"] then
                TriggerEvent("vrp-hud:showBind", false)
                keyActive["chest"] = false
            end
        end
        
        local dst = #(bunkerExit - pedPos)
        if dst <= 30 then
            DrawMarker(30, bunkerExit, 0, 0, 0, 0, 0, 0, 0.65, 0.65, 0.65, 255, 255, 255, 100, true, true, false, true)  

            if dst <= 1 then
                if not keyActive['exit'] then
                    TriggerEvent('vrp-hud:showBind', {key = "E", text = "Iesi din Buncar"})
                    keyActive['exit'] = true
                end

                if IsControlJustReleased(0, 38) then
                    if keyActive['exit'] then
                        TriggerEvent('vrp-hud:showBind', false)
                        keyActive['exit'] = false
                    end

                    TriggerServerEvent('vrp-bunker:exit')

                    FreezeEntityPosition(ped, true)
                    DoScreenFadeOut(1000, true)
                    Citizen.Wait(1500)
                    ClearPedTasksImmediately(ped)

                    local exitLocation = cfg.bunkers[activeBunker]
                    SetEntityCoords(ped, exitLocation[1], exitLocation[2], exitLocation[3], true, false, false, true)

                    local maxWait = GetGameTimer() + 5000
                    while not HasCollisionLoadedAroundEntity(ped) and maxWait > GetGameTimer() do
                        Citizen.Wait(1)
                    end

                    FreezeEntityPosition(ped, false)
                    DoScreenFadeIn(500, true)
                    break
                end

            elseif keyActive['exit'] then
                TriggerEvent('vrp-hud:showBind', false)
                keyActive['exit'] = false
            end
        end
        Wait(1)
    end
end)

RegisterNetEvent('vrp-bunker:buyAnim', function(bunker)
    activeBunker = bunker
    
    -- RequestCutscene("bunk_int", 8)
    -- local timeout = GetGameTimer() + 10000

    -- while not HasCutsceneLoaded() and GetGameTimer() < timeout do
    --     Wait(0)
    -- end

    EnableInteriorProp(258561,"standard_bunker_set")
    EnableInteriorProp(258561,"Bunker_Style_C")
    EnableInteriorProp(258561,"Office_Upgrade_set")
    EnableInteriorProp(258561,"Gun_schematic_set")
    EnableInteriorProp(258561,"security_upgrade")
    EnableInteriorProp(258561,"gun_range_lights")
    EnableInteriorProp(258561,"gun_locker_upgrade")
    RefreshInterior(258561)

    local ped = PlayerPedId()

    -- SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    -- RegisterEntityForCutscene(ped, 'MP_1', 0, 0, 64)

    TriggerEvent("vrp-hud:updateMap")
    TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = false})

    -- if HasCutsceneLoaded() then
    --     StartCutscene("bunk_int")

    --     while not (DoesCutsceneEntityExist('MP_1', 0)) do
    --         Wait(0)
    --     end

    --     SetTimeout(100, function()
    --         if IsCutsceneActive() then
    --             local coords = GetWorldCoordFromScreenCoord(0.5, 0.5)
    --             NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 1000, 0)
    --         end
    --     end)

    --     while IsCutsceneActive() do
    --         Wait(0)
    --     end

        TriggerEvent("vrp-hud:updateMap", true)
        TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = true})
        
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        DoScreenFadeOut(1000, true)
        Wait(1500)
        ClearPedTasksImmediately(ped)
        SetEntityCoords(ped, bunkerEnterLocation[1], bunkerEnterLocation[2], bunkerEnterLocation[3], true, false, false, true)
        DisplayRadar(true)

        local maxWait = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and maxWait > GetGameTimer() do
            Citizen.Wait(1)
        end
        
        FreezeEntityPosition(ped, false)
        DoScreenFadeIn(500, true)

        local keyActive = {}
        while true do
            local menuDst = #(bunkerMenu - pedPos)
            if menuDst <= 15 then
                DrawMarker(20, bunkerMenu, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 255, 255, 255, 255, false, true, false, true)
            
                if menuDst <= 1 then
                
                    if not keyActive["menu"] then
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Acceseaza meniul"})
                        keyActive["menu"] = true
                    end
                
                    if IsControlJustReleased(0, 38) then
                        if keyActive["menu"] then
                            TriggerEvent("vrp-hud:showBind", false)
                            keyActive["menu"] = false
                        end

                        triggerCallback('getBunkerMenuData', function(data)
                            if data then
                                SendNUIMessage({
                                    interface = "bunkerInfo",
                                    data = {
                                        craftings = cfg.bunkerCraftings,
                                        ownedCraftings = data.bunkerData,
                                        bunkerMissions = data.bunkerMissions,
                                        bunkerExpire = data.bunkerExpire,
                                    }
                                })
                            else
                                tvRP.notify('Doar proprietarul are acces la acest meniu', 'error')
                            end
                        end)
                    end
                elseif keyActive["menu"] then
                    TriggerEvent("vrp-hud:showBind", false)
                    keyActive["menu"] = false
                end
            end

            local chestDst = #(chestPos - pedPos)
            if chestDst <= 15 then
                DrawMarker(20, chestPos, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 255, 255, 255, 255, true, true, false, true)  
            
                if chestDst <= 1 then
                
                    if not keyActive["chest"] then
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Foloseste cufarul"})
                        keyActive["chest"] = true
                    end
                
                    if IsControlJustReleased(0, 38) then
                    
                        if keyActive["chest"] then
                            TriggerEvent("vrp-hud:showBind", false)
                            keyActive["chest"] = false
                        end

                        TriggerServerEvent("vRP:bunkerChest")
                    end
                elseif keyActive["chest"] then
                    TriggerEvent("vrp-hud:showBind", false)
                    keyActive["chest"] = false
                end
            end

            local dst = #(bunkerExit - pedPos)
            if dst <= 30 then
                DrawMarker(30, bunkerExit, 0, 0, 0, 0, 0, 0, 0.65, 0.65, 0.65, 255, 255, 255, 100, true, true, false, true)  

                if dst <= 1 then
                    if not keyActive['exit'] then
                        TriggerEvent('vrp-hud:showBind', {key = "E", text = "Iesi din Buncar"})
                        keyActive['exit'] = true
                    end

                    if IsControlJustReleased(0, 38) then
                        if keyActive['exit'] then
                            TriggerEvent('vrp-hud:showBind', false)
                            keyActive['exit'] = false
                        end

                        TriggerServerEvent('vrp-bunker:exit')

                        FreezeEntityPosition(ped, true)
                        DoScreenFadeOut(1000, true)
                        Citizen.Wait(1500)
                        ClearPedTasksImmediately(ped)

                        local exitLocation = cfg.bunkers[activeBunker]
                        SetEntityCoords(ped, exitLocation[1], exitLocation[2], exitLocation[3], true, false, false, true)

                        local maxWait = GetGameTimer() + 5000
                        while not HasCollisionLoadedAroundEntity(ped) and maxWait > GetGameTimer() do
                            Citizen.Wait(1)
                        end

                        FreezeEntityPosition(ped, false)
                        DoScreenFadeIn(500, true)
                        break
                    end

                elseif keyActive['exit'] then
                    TriggerEvent('vrp-hud:showBind', false)
                    keyActive['exit'] = false
                end
            end
            Wait(1)
        end
    -- end
end)

Citizen.CreateThread(function()
    for name, data in pairs(cfg.bunkerCraftings) do
        tvRP.spawnNpc("vrp-bunkerCrafting:"..name, {
            position = data and data.npc and data.npc.position or vector3(0, 0, 0),
            rotation = data and data.npc and data.npc.rotation or 0,
            model = data and data.npc and data.npc.model or "a_m_y_beach_01",
            freeze = true,
            minDist = 1.5,
            name = data and data.npc and data.npc.name or "Bunker Crafting",
            ["function"] = function()
                triggerCallback('getCraftingData', function(bunker)
                    if not bunker then
                        return tvRP.notify('Doar Proprietarul poate accesa acest crafting!', 'error')
                    end
                    
                    SendNUIMessage({
                        interface = 'bunkerCraft',
                        act = 'open',
                        data = {
                            location = name,
                            chances = data.craftingChance,
                            amount = data.amount,
                            minutes = data.time,
                            name = data.name,
                            item = data.item,
                            items = data.need,
                            bought = bunker.bought,
                            userItems = bunker.userItems,
                            bunkerInfo = bunker.bunkerData,
                        }
                    })
                end, name)
            end
        })
    end
end)

RegisterNetEvent('vrp-bunker:stealVehicle', function(model, spawnLocation, dropLocation)
    TriggerEvent("vrp-hud:hint", "Masina ti-a fost marcata pe harta, depleaseaza te cat mai repede la ea!", "Furt Auto", "fa-sharp fa-solid fa-truck")

    local mhash, i = GetHashKey(model), 0
    while not HasModelLoaded(mhash) and i < 1000 do
        RequestModel(mhash)
        Citizen.Wait(10)
        i = i+1
    end

    DoScreenFadeOut(1000, true)
    Citizen.Wait(1000)
    ClearPedTasksImmediately(PlayerPedId())

    local exitLocation = cfg.bunkers[activeBunker]
    SetEntityCoords(tempPed, exitLocation[1], exitLocation[2], exitLocation[3], true, false, false, true)
    Citizen.Wait(1000)
    DoScreenFadeIn(500)
    
    local missionStarted = false
    local vehicle = CreateVehicle(mhash, spawnLocation[1], spawnLocation[2], spawnLocation[3], GetEntityHeading(PlayerPedId()), true, false)
    SetVehicleNeedsToBeHotwired(vehicle,true)

    local carBlip = AddBlipForCoord(spawnLocation)
    SetBlipSprite(carBlip, 1)
    SetBlipDisplay(carBlip, 4)
    SetBlipColour(carBlip, 1)
    SetBlipAsShortRange(carBlip, true)
    SetBlipRoute(carBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fura Vehicul (Obiectiv Misiune)")
    EndTextCommandSetBlipName(carBlip)

    while not missionStarted do
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TriggerEvent("vrp-hud:hint", "Livreaza masina in zona marcata pe harta!", "Livreaza Masina", "fa-sharp fa-solid fa-truck")

            if DoesBlipExist(carBlip) then
                RemoveBlip(carBlip)
            end
    
            carBlip = AddBlipForCoord(dropLocation)
            SetBlipSprite(carBlip, 1)
            SetBlipDisplay(carBlip, 4)
            SetBlipColour(carBlip, 33)
            SetBlipAsShortRange(carBlip, true)
            SetBlipRoute(carBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Locatie Vanzare (Obiectiv Misiune)")
            EndTextCommandSetBlipName(carBlip)
            
            TriggerServerEvent('vRP:addPlayerWanted', 3, 'Furt de masina')
            missionStarted = true
            break    
        end 
        local vehPos = GetEntityCoords(vehicle)
        local vehDst = #(pedPos - vehPos)

        if vehDst <= 25 then
            DrawMarker(2, vehPos[1], vehPos[2], vehPos[3] + 2.50, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 247, 227, 1, 255, true, true)
        end

        Citizen.Wait(1)
    end 

    while DoesEntityExist(vehicle) and missionStarted do
        local vehPos = GetEntityCoords(vehicle)
        local vehDst = #(pedPos - vehPos)
        local dst = #(vehPos - dropLocation)
            while GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() do
                vehPos = GetEntityCoords(vehicle)
                dst = #(vehPos - dropLocation)

                if dst <= 25 then
                    DrawMarker(0, dropLocation[1], dropLocation[2], dropLocation[3] + 0.20, 0, 0, 0, 0, 0, 0, 6.60, 6.60, 12.60, 255, 255, 255, 30, true, true, false, true)
                    DrawMarker(20, dropLocation[1], dropLocation[2], dropLocation[3] + 2.60, 0, 0, 0, 0, 0, 0, 4.60, 4.60, -4.60, 247, 227, 1, 255, true, true, false, true)

                    if dst <= 2.5 then
                        FreezeEntityPosition(vehicle, true)
                        FreezeEntityPosition(PlayerPedId(), true)
                        DoScreenFadeOut(1000, true)
                        Citizen.Wait(1500)
                        ClearPedTasksImmediately(PlayerPedId())

                        DeleteEntity(vehicle)

                        local maxWait = GetGameTimer() + 5000
                        while DoesEntityExist(vehicle) and maxWait > GetGameTimer() do
                            DeleteEntity(vehicle)
                            Citizen.Wait(1)
                        end

                        FreezeEntityPosition(PlayerPedId(), false)
                        DoScreenFadeIn(500, true)
                        TriggerServerEvent('vrp-bunker:missionDone', true)
                        missionStarted = false
                        break
                    end
                end
                vehPos = GetEntityCoords(vehicle)
                dst = #(vehPos - dropLocation)
                Wait(1)
            end
            if not GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                if vehDst <= 25 then
                    DrawMarker(2, vehPos[1], vehPos[2], vehPos[3] + 2.50, 0, 0, 0, 0, 0, 0, 1.10, 0.90, -0.90, 247, 227, 1, 255, true, true)
                end
            end 
        Wait(1)
    end
    if DoesBlipExist(carBlip) then
        RemoveBlip(carBlip)
    end
end)

RegisterNetEvent('vrp-bunker:transport-mission', function(deliveryLocation)
    TriggerEvent("vrp-hud:showBind", false)
    TriggerEvent("vrp-hud:hint", "Livreaza masina la locatia marcata pe harta!", "Furt Auto", "fa-sharp fa-solid fa-truck")

    local exitLocation = cfg.bunkers[activeBunker]
    local vehicle = SpawnVehicle('pounder2', {exitLocation[1], exitLocation[2], exitLocation[3], GetEntityHeading(PlayerPedId())})

    DoScreenFadeOut(1000, true)
    Citizen.Wait(1000)
    ClearPedTasksImmediately(PlayerPedId())

    local mhash, i = GetHashKey('pounder2'), 0
    while not HasModelLoaded(mhash) and i < 1000 do
        RequestModel(mhash)
        Citizen.Wait(10)
        i = i+1
    end

    local vehicle = CreateVehicle(mhash, exitLocation[1], exitLocation[2], exitLocation[3], GetEntityHeading(PlayerPedId()), true, false)
    while not DoesEntityExist(vehicle) do
        Wait(1)
    end

    SetPedIntoVehicle(tempPed, vehicle, -1)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetEntityInvincible(vehicle, false)
    DoScreenFadeIn(500, true)
    TriggerEvent("vrp-hud:showBind", false)

    local carBlip = AddBlipForCoord(deliveryLocation)
    SetBlipSprite(carBlip, 1)
    SetBlipDisplay(carBlip, 4)
    SetBlipColour(carBlip, 1)
    SetBlipAsShortRange(carBlip, true)
    SetBlipRoute(carBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Locatie Livrare (Obiectiv Misiune)")
    EndTextCommandSetBlipName(carBlip)

    while DoesEntityExist(vehicle) do
        local dst = #(pedPos - deliveryLocation)

        if dst <= 25 then
            DrawMarker(0, deliveryLocation[1], deliveryLocation[2], deliveryLocation[3] + 0.20, 0, 0, 0, 0, 0, 0, 6.60, 6.60, 12.60, 255, 255, 255, 30, true, true, false, true)
            DrawMarker(20, deliveryLocation[1], deliveryLocation[2], deliveryLocation[3] + 2.60, 0, 0, 0, 0, 0, 0, 4.60, 4.60, -4.60, 247, 227, 1, 255, true, true, false, true)

            if dst <= 2.5 then
                FreezeEntityPosition(vehicle, true)
                FreezeEntityPosition(PlayerPedId(), true)
                DoScreenFadeOut(1000, true)
                Citizen.Wait(1500)
                ClearPedTasksImmediately(PlayerPedId())

                DeleteEntity(vehicle)

                local maxWait = GetGameTimer() + 5000
                while DoesEntityExist(vehicle) and maxWait > GetGameTimer() do
                    DeleteEntity(vehicle)
                    Citizen.Wait(1)
                end

                if DoesBlipExist(carBlip) then
                    carBlip = RemoveBlip(carBlip)
                end

                FreezeEntityPosition(PlayerPedId(), false)
                DoScreenFadeIn(500, true)
                TriggerServerEvent('vrp-bunker:missionDone', true)
                break
            end
        end

        Wait(1)
    end
end)

local missionActive
RegisterNetEvent("vrp-bunker:steal-drugs", function(coords, deliveryLocation)
    DoScreenFadeOut(1000, true)
    Citizen.Wait(1000)
    ClearPedTasksImmediately(PlayerPedId())

    local exitLocation = cfg.bunkers[activeBunker]
    SetEntityCoords(tempPed, exitLocation[1], exitLocation[2], exitLocation[3], true, false, false, true)
    Citizen.Wait(1000)
    DoScreenFadeIn(500)

    local carCoords = vec3(1728.540, 3313.890, 41.223)
    local deliveryCoords = vec3(615.6168, -409.908, 25.072)

    local enemies, enemySpawn <const> = {}, {
        vec4(1745.097, 3291.632, 41.103, 206.41),
        vec4(1737.483, 3293.477, 41.163, 206.41),
        vec4(1730.833, 3297.285, 41.223, 206.41),
        vec4(1738.119, 3286.475, 41.135, 206.41),
        vec4(1723.602, 3303.942, 41.223, 206.41),
        vec4(1737.484, 3310.934, 41.223, 206.41),
        vec4(1737.017, 3324.304, 41.223, 206.41)
    }

    Citizen.CreateThread(function()
        local carBlip = AddBlipForCoord(carCoords)

        SetBlipSprite(carBlip, 1)
        SetBlipDisplay(carBlip, 4)
        SetBlipColour(carBlip, 1)
        SetBlipAsShortRange(carBlip, true)
        SetBlipRoute(carBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Fura Vehicul (Obiectiv Misiune)")
        EndTextCommandSetBlipName(carBlip)

        local vehicleHash = GetHashKey("benson")

        RequestModel(vehicleHash)
        while not HasModelLoaded(vehicleHash) do Citizen.Wait(50) end

        local vehicle = CreateVehicle(vehicleHash, carCoords, 0.0, true)

        SetVehicleDoorsLocked(vehicle, 2) 
        SetVehicleFuelLevel(vehicle, 100.0)

        for _, spawnLocation in next, enemySpawn do
            local enemyHash = GetHashKey("s_m_y_blackops_01") 

            RequestModel(enemyHash)
            while not HasModelLoaded(enemyHash) do Citizen.Wait(50) end
    
            AddRelationshipGroup("Attackers")
            SetPedRelationshipGroupHash(tempPed, GetHashKey("PLAYER"))
    
            SetRelationshipBetweenGroups(5, GetHashKey("Attackers"), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("Attackers"))
        
            local enemy = CreatePed(5, enemyHash, spawnLocation, true, true, true)
            GiveWeaponToPed(enemy, GetHashKey("WEAPON_PISTOL"), 1000, false, true) 

            SetPedCombatAttributes(enemy, 46, true) 
            SetPedCombatAttributes(enemy, 0, true)

            SetPedCombatRange(enemy, 2) 

            SetPedCombatMovement(enemy, 3)
            SetCanAttackFriendly(enemy)

            SetPedRelationshipGroupHash(enemy, GetHashKey("Attackers"))
            SetModelAsNoLongerNeeded(enemyHash)

            table.insert(enemies, enemy)
        end

        missionActive = true

        tvRP.notify("Ai inceput misiunea, du-te la locatia setata pe GPS.")

        while missionActive do
            local ped = tempPed
            local pedCoords = GetEntityCoords(ped)

            local dst = #(pedCoords - GetEntityCoords(vehicle))

            if dst <= 5 and not vehicleUnlocked then                
                if not keyActive then
                    keyActive = true
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Pentru a descuia vehiculul."})
                end

                if IsControlJustPressed(0, 38) then
                    keyActive = TriggerEvent("vrp-hud:showBind")

                    local windowBroken = not IsVehicleWindowIntact(vehicle, 0)

                    if not windowBroken then
                        triggerCallback("tryOpenVehicle", function(success)
                            if not success then
                                TriggerEvent("vrp-hud:hint", "Poti trage in toate geamurile masinii pentru a o descuia.", "Misiune", "fa-sharp fa-solid fa-truck")

                                return tvRP.notify("Iti lipseste kit-ul de unelte.", "error")
                            end
    
                            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
    
                            SetVehicleAlarm(vehicle, true)
                            StartVehicleAlarm(vehicle)
    
                            Citizen.Wait(11500)
    
                            SetVehicleDoorsLocked(vehicle, 1)
                            SetVehicleDoorsLockedForAllPlayers(vehicle)
    
                            ClearPedTasks(ped)
                            TaskEnterVehicle(ped, vehicle, 10.0, 1, 2.0, 0, 0)
    
                            vehicleUnlocked = true
                        end)
                    else
                        SetVehicleDoorsLocked(vehicle, 1)
                        SetVehicleDoorsLockedForAllPlayers(vehicle)

                        vehicleUnlocked = true
                    end
                end
            elseif GetVehiclePedIsIn(ped) == vehicle then
                if DoesBlipExist(carBlip) then
                    carBlip = RemoveBlip(carBlip)

                    deliveryBlip = AddBlipForCoord(deliveryCoords)
                    SetBlipSprite(deliveryBlip, 1)
                    SetBlipDisplay(deliveryBlip, 4)
                    SetBlipColour(deliveryBlip, 70)
                    SetBlipAsShortRange(deliveryBlip, true)
                    SetBlipRoute(deliveryBlip, true)
                    BeginTextCommandSetBlipName("STRING")

                    AddTextComponentString("Livreaza Vehicul (Obiectiv Misiune)")
                    EndTextCommandSetBlipName(deliveryBlip)

                    TriggerEvent("vrp-hud:hint", "Livreaza masina la locatia setata pe GPS.", "Misiune", "fa-sharp fa-solid fa-truck")
                end

                if #(GetEntityCoords(vehicle) - deliveryCoords) <= 10 then
                    missionPassed = true
                    tvRP.notify("Ai ajuns la destinatie.", "success")

                    SetVehicleEngineOn(vehicle, false, true, true)

                    DoScreenFadeOut(1000, true)
                    Wait(1500)

                    DeleteEntity(vehicle)
                    DoScreenFadeIn(500, true)
                end
            end

            if not DoesEntityExist(vehicle) or GetEntityHealth(tempPed) <= 105 then
                for _, enemy in next, enemies do
                    if DoesEntityExist(enemy) then
                        DeletePed(enemy)
                    end
                end

                enemies = {}

                carBlip = RemoveBlip(carBlip)
                deliveryBlip = RemoveBlip(deliveryBlip)

                missionActive = TriggerServerEvent('vrp-bunker:missionDone', missionPassed)

                break
            end

            if dst > 5 or vehicleUnlocked and keyActive then
                keyActive = TriggerEvent("vrp-hud:showBind")
            end

            Citizen.Wait(1)
        end
    end)
end)

RegisterNUICallback('bunker:startMission', function(data, cb)
    TriggerServerEvent('vrp-bunker:startMission', data[1])
    cb('sugi pl dumpere')
end)

RegisterNUICallback("bunker:craft", function(data, cb)
    triggerCallback('tryCompletBunkerNecesary', function(bunkerData)
        cb(bunkerData)
    end)
end)

RegisterNUICallback("bunker:sell", function(data, cb)
    TriggerServerEvent('vrp-bunker:sell', data[1])
    cb('sell')
end)

RegisterNUICallback('bunker:lock', function(data, cb)
    TriggerServerEvent('vrp-bunker:lock', data[1])
    cb('lock')
end)

RegisterNUICallback("bunker:enter", function(data, cb)
    TriggerServerEvent('vrp-bunker:enter', data[1])
    cb('enter')
end)

RegisterNUICallback("bunker:buy", function(data, cb)
    TriggerServerEvent('vrp-bunker:buy', activeBunker)
    cb('bought')
end)

RegisterNUICallback("bunker:collectCrafting", function(data, cb)
    TriggerClientEvent('vrp-bunker:tryCollectBunkerCrafted', data[1])
    cb('muie')
end)

RegisterNUICallback("bunker:buyCrafting", function(data, cb)
    TriggerServerEvent('vrp-bunker:buyLocation', data[1])
    cb('sugi pl dumpere')
end)

RegisterNUICallback("bunker:exit", function(data, cb)
    TriggerServerEvent('vrp-bunker:exit')

    FreezeEntityPosition(tempPed, true)
    DoScreenFadeOut(1000, true)
    Citizen.Wait(1500)
    ClearPedTasksImmediately(tempPed)

    local exitLocation = cfg.bunkers[activeBunker]
    SetEntityCoords(tempPed, exitLocation[1], exitLocation[2], exitLocation[3], true, false, false, true)

    local maxWait = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(tempPed) and maxWait > GetGameTimer() do
        Citizen.Wait(1)
    end

    FreezeEntityPosition(tempPed, false)
    DoScreenFadeIn(500)
    cb('exit')
end)

RegisterNUICallback('bunker:close', function(data, cb)
    bunkerActive = {}
    cb('close')
end)

RegisterNuiCallback('bunker:buyDays', function(data, cb)
    TriggerServerEvent('vrp-bunker:buyBunkerDays')
    cb('ok')
end)