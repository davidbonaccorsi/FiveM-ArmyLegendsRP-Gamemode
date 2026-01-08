local activeRobbery, stopTimer, vaultCam = false
local currentStep = 1

local doorsLocked, robberyProps = {}, {}

local robberyEvents = {
    {
        coords = vec3(257.10, 220.30, 106.28),
        text = "Pentru a incepe jaful",

        callback = function()
            local locationCoords = vec4(257.40, 220.20, 106.35, 336.48)
            local ptfxCoords = vec3(257.39, 221.20, 106.29)

            triggerCallback("startBankRobbery", function(canRob, err)
                if not canRob then return tvRP.notify(err, "error") end

                currentStep = 2

                RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                RequestModel("hei_p_m_bag_var22_arm_s")

                RequestNamedPtfxAsset("scr_ornate_heist")

                while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                    Citizen.Wait(50)
                end

                local ped = tempPed
                local pedCoords = GetEntityCoords(ped)

                SetEntityHeading(ped, locationCoords.w)

                Citizen.Wait(100)

                local rot = GetEntityRotation(ped)
                local bagScene = NetworkCreateSynchronisedScene(locationCoords.x, locationCoords.y, locationCoords.z, rot.x, rot.y, rot.z, 2, false, false, 1065353216, 0, 1.3)

                local bag = CreateObject(joaat("hei_p_m_bag_var22_arm_s"), locationCoords.x, locationCoords.y, locationCoords.z, true, true)
                SetEntityCollision(bag, false, true)

                NetworkAddPedToSynchronisedScene(ped, bagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, bagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)

                SetPedComponentVariation(ped, 5, 0, 0, 0)
                NetworkStartSynchronisedScene(bagScene)
                Citizen.Wait(1500)

                local bombKey = joaat(`hei_prop_heist_thermite`)
                RequestModel(bombKey)

                while not HasModelLoaded(bombKey) do Citizen.Wait(50) end

                local bomba = CreateObject(bombKey, pedCoords.x, pedCoords.y, pedCoords.z + 0.2, true, true, true)
                SetEntityCollision(bomba, false, true)

                AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                Citizen.Wait(4000)
                DeleteObject(bag)

                SetPedComponentVariation(ped, 5, 45, 0, 0)
                DetachEntity(bomba, 1, 1)
                FreezeEntityPosition(bomba, true)

                SetPtfxAssetNextCall("scr_ornate_heist")

                local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfxCoords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                NetworkStopSynchronisedScene(bagScene)

                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)

                SetTimeout(8000, function()
                    ClearPedTasks(ped)
                    DeleteObject(bomba)

                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("vrp-robbery:changeDoorState", 1)
                end)
            end)
        end
    },

    {
        coords = vec3(262.35, 223.00, 107.05),
        text = "Hack Security Panel",

        callback = function()
            triggerCallback("canHackTerminal", function(canHack, err)
                if not canHack then return tvRP.notify(err, "error") end

                minigame = true

                local idModel = joaat(`p_ld_id_card_01`)

                RequestModel(idModel)
                while not HasModelLoaded(idModel) do Citizen.Wait(50) end

                local ped = tempPed
                local pedCoords = GetEntityCoords(ped)

                Citizen.Wait(100)

                local identityCard = CreateObject(idModel, pedCoords.x, pedCoords.y, pedCoords.z, true, true)
                local boneIndex = GetPedBoneIndex(ped, 28422)
                local panel = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 1.0, joaat("hei_prop_hei_securitypanel"))

                AttachEntityToEntity(identityCard, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
                TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)

                Citizen.Wait(1500)
                AttachEntityToEntity(identityCard, panel, boneIndex, -0.09, -0.02, -0.08, 270.0, 0.0, 270.0, true, true, false, true, 1, true)
                FreezeEntityPosition(identityCard)

                Citizen.Wait(500)
                ClearPedTasksImmediately(ped)

                Citizen.Wait(1500)

                exports.fallouthack:startGame(10, 3, function(passed)
                    if passed then
                        currentStep = 3
                        TriggerServerEvent("vrp-robbery:changeDoorState", 3)
                    else
                        TriggerServerEvent("vrp-robbery:robberyAlert", true)
                    end

                    minigame = false
                end)
            end)
        end
    },

    {
        coords = vec3(253.00, 228.40, 102.20),
        text = "Hack Security Panel",

        callback = function()
            triggerCallback("canHackTerminal", function(canHack, err)
                if not canHack then return tvRP.notify(err, "error") end

                minigame = true

                local idModel = joaat(`p_ld_id_card_01`)

                RequestModel(idModel)
                while not HasModelLoaded(idModel) do Citizen.Wait(50) end

                local ped = tempPed
                local pedCoords = GetEntityCoords(ped)

                Citizen.Wait(100)

                local identityCard = CreateObject(idModel, pedCoords.x, pedCoords.y, pedCoords.z, true, true)
                local boneIndex = GetPedBoneIndex(ped, 28422)
                local panel = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 1.0, joaat("hei_prop_hei_securitypanel"))

                AttachEntityToEntity(identityCard, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
                TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)

                Citizen.Wait(1500)
                AttachEntityToEntity(identityCard, panel, boneIndex, -0.09, -0.02, -0.08, 270.0, 0.0, 270.0, true, true, false, true, 1, true)
                FreezeEntityPosition(identityCard)

                Citizen.Wait(500)
                ClearPedTasksImmediately(ped)

                Citizen.Wait(1500)

                TriggerEvent("vrp-hud:updateMap")
                TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = false})

                currentStep = 4
                TriggerServerEvent("vrp-robbery:openVault")
        
                SetTimecycleModifier("scanline_cam_cheap")
                SetTimecycleModifierStrength(2.0)
                
                vaultCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
                SetCamCoord(vaultCam, 261.97290039062,225.82472229004,104.07398986816)
                SetCamRot(vaultCam, -20.0, 0.0, 90.0, 2)
            
                RenderScriptCams(1, 0, 0, 1, 1)

                local passed = exports.fallouthack:runDefaultRandom()
                
                if (passed == 1) then
                    currentStep = 4
                    TriggerServerEvent("vrp-robbery:openVault")
            
                    SetTimecycleModifier("scanline_cam_cheap")
                    SetTimecycleModifierStrength(2.0)
                    
                    vaultCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
                    SetCamCoord(vaultCam, 261.97290039062,225.82472229004,104.07398986816)
                    SetCamRot(vaultCam, -20.0, 0.0, 90.0, 2)
                
                    SetNuiFocus(true, true)
                    RenderScriptCams(1, 0, 0, 1, 1)
                else
                    TriggerServerEvent("vrp-robbery:robberyAlert", not (passed == 1))

                    TriggerEvent("vrp-hud:updateMap", true)
                    TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = true})
    
                    minigame = false
                end
            end)
        end
    },
    
    {
        coords = vec3(252.95, 220.70, 101.76),
        text = "Planteaza Bomba Termica",

        callback = function()
            local locationCoords = vec4(252.95, 220.70, 101.76, 160.0)
            local ptfxCoords = vec3(252.985, 221.70, 101.72)

            triggerCallback("canPlantProximity", function(canPlant, err)
                if not canPlant then return tvRP.notify(err, "error") end

                currentStep = 5

                RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                RequestModel("hei_p_m_bag_var22_arm_s")

                RequestNamedPtfxAsset("scr_ornate_heist")

                while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                    Citizen.Wait(50)
                end

                local ped = tempPed
                local pedCoords = GetEntityCoords(ped)

                SetEntityHeading(ped, locationCoords.w)

                Citizen.Wait(100)

                local rot = GetEntityRotation(ped)

                local bagScene = NetworkCreateSynchronisedScene(locationCoords.x, locationCoords.y, locationCoords.z, rot.x, rot.y, rot.z, 2, false, false, 1065353216, 0, 1.3)

                local bag = CreateObject(joaat("hei_p_m_bag_var22_arm_s"), locationCoords.x, locationCoords.y, locationCoords.z, true, true)
                SetEntityCollision(bag, false, true)

                NetworkAddPedToSynchronisedScene(ped, bagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, bagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)

                SetPedComponentVariation(ped, 5, 0, 0, 0)
                NetworkStartSynchronisedScene(bagScene)
                Citizen.Wait(1500)

                local bombKey = joaat(`hei_prop_heist_thermite`)
                RequestModel(bombKey)

                while not HasModelLoaded(bombKey) do Citizen.Wait(50) end

                local bomba = CreateObject(bombKey, pedCoords.x, pedCoords.y, pedCoords.z + 0.2, true, true, true)
                SetEntityCollision(bomba, false, true)

                AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                Citizen.Wait(4000)
                DeleteObject(bag)

                SetPedComponentVariation(ped, 5, 45, 0, 0)
                DetachEntity(bomba, 1, 1)
                FreezeEntityPosition(bomba, true)

                SetPtfxAssetNextCall("scr_ornate_heist")

                local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfxCoords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                NetworkStopSynchronisedScene(bagScene)

                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)

                SetTimeout(8000, function()
                    ClearPedTasks(ped)    
                    DeleteObject(bomba)
    
                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("vrp-robbery:changeDoorState", 4)
                end)
            end)
        end
    },
    
    {
        coords = vec3(261.65, 215.60, 101.76),
        text = "Planteaza Bomba Termica",

        callback = function()
            local locationCoords = vec4(261.65, 215.60, 101.76, 252.0)
            local ptfxCoords = vec3(261.68, 216.63, 101.75)

            triggerCallback("canPlantProximity", function(canPlant, err)
                if not canPlant then return tvRP.notify(err, "error") end

                currentStep = 6

                RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
                RequestModel("hei_p_m_bag_var22_arm_s")

                RequestNamedPtfxAsset("scr_ornate_heist")

                while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_UTK") do
                    Citizen.Wait(50)
                end

                local ped = tempPed
                local pedCoords = GetEntityCoords(ped)

                SetEntityHeading(ped, locationCoords.w)

                Citizen.Wait(100)

                local rot = GetEntityRotation(ped)

                local bagScene = NetworkCreateSynchronisedScene(locationCoords.x, locationCoords.y, locationCoords.z, rot.x, rot.y, rot.z, 2, false, false, 1065353216, 0, 1.3)

                local bag = CreateObject(joaat("hei_p_m_bag_var22_arm_s"), locationCoords.x, locationCoords.y, locationCoords.z, true, true)
                SetEntityCollision(bag, false, true)

                NetworkAddPedToSynchronisedScene(ped, bagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, bagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)

                SetPedComponentVariation(ped, 5, 0, 0, 0)
                NetworkStartSynchronisedScene(bagScene)
                Citizen.Wait(1500)

                local bombKey = joaat(`hei_prop_heist_thermite`)
                RequestModel(bombKey)

                while not HasModelLoaded(bombKey) do Citizen.Wait(50) end

                local bomba = CreateObject(bombKey, pedCoords.x, pedCoords.y, pedCoords.z + 0.2, true, true, true)
                SetEntityCollision(bomba, false, true)

                AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
                Citizen.Wait(4000)
                DeleteObject(bag)

                SetPedComponentVariation(ped, 5, 45, 0, 0)
                DetachEntity(bomba, 1, 1)
                FreezeEntityPosition(bomba, true)

                SetPtfxAssetNextCall("scr_ornate_heist")

                local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfxCoords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                NetworkStopSynchronisedScene(bagScene)

                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
                TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)

                SetTimeout(8000, function()
                    ClearPedTasks(ped)    
                    DeleteObject(bomba)
    
                    StopParticleFxLooped(effect, 0)
                    TriggerServerEvent("vrp-robbery:changeDoorState", 5)
                end)
            end)
        end
    }
}

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(tempPed)
        local data = robberyEvents[currentStep]

        if data then
            local distance = #(playerCoords - data.coords)
    
            while distance < 10 and not minigame do    
                if distance < 2.5 then
                    if not keyActive then
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = data.text})
                        keyActive = true
                    end
    
                    if IsControlJustReleased(0, 38) then
                        keyActive = TriggerEvent("vrp-hud:showBind")

                        data.callback()
                        break
                    end
    
                elseif keyActive then
                    keyActive = TriggerEvent("vrp-hud:showBind")
                end
                
                Wait(1)

                data = robberyEvents[currentStep]

                playerCoords = GetEntityCoords(tempPed)
                distance = #(playerCoords - data.coords)

                if not data then break end
            end
        end

        Wait(1024)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(tempPed)

        for _, data in next, doorsLocked do
            if #(playerCoords - data.coords) <= 10 then
                local x, y, z = table.unpack(data.coords)

                local door = GetClosestObjectOfType(x, y, z, 1.0, data.objModel)

                if door ~= 0 then
                    SetEntityCanBeDamaged(door)

                    if not data.locked then
                        NetworkRequestControlOfEntity(door)
                        FreezeEntityPosition(door)
                    else
                        local locked, heading = GetStateOfClosestDoorOfType(data.objModel, x, y, z, locked, heading)

                        if math.abs(heading) < 0.02 then
                            NetworkRequestControlOfEntity(door)
                            FreezeEntityPosition(door, true)
                        end
                    end
                end
            end
        end

        Wait(1024)
    end
end)

RegisterNetEvent("vrp-robbery:updateDoors", function(doors)
    doorsLocked = doors
end)

RegisterNetEvent("vrp-robbery:startRobbery", function()
    activeRobbery = true

    for _, data in next, GlobalState.propsToSpawn do
        local x, y, z = table.unpack(data.coords)

        robberyProps[data.grab] = {
            obj = CreateObject(data.hash, x, y, z, 1, 0, 0),
            coords = data.coords,
            text = data.text
        }

        if data.grab == 3 or data.grab == 4 then
            local heading = GetEntityHeading(robberyProps[data.grab].obj)

            SetEntityHeading(robberyProps[data.grab].obj, heading + 150.0)
        end

        SendNUIMessage {
            action = "updateActions",
            robberyData = robberyProps,
        }
    end

    SendNUIMessage {action = "showActions"}
    
    local keyActive

    while activeRobbery do
        local playerCoords = GetEntityCoords(tempPed)

        if tvRP.isInComa() or #(playerCoords - vec3(257.10, 220.30, 106.28)) >= 40 then
            TriggerServerEvent("vrp-robbery:robberyAlert", true)
            break
        end

        for index, data in next, robberyProps do
            local distance = #(playerCoords - data.coords)

            while not data.looted and distance < 2 do

                if not keyActive then
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Pentru a colecta"})
                    keyActive = true
                end

                if IsControlJustReleased(0, 38) then
                    data.looted = true
                    startLooting(index)
                end

                Wait(1)

                playerCoords = GetEntityCoords(tempPed)
                distance = #(playerCoords - data.coords)
            end
        end

        if keyActive then
            keyActive = TriggerEvent("vrp-hud:showBind")
        end

        Wait(1024)
    end
end)

RegisterNetEvent("vrp-robbery:changeVaultState", function(lock)
    local obj = GetClosestObjectOfType(253.92, 224.56, 101.88, 1.0, joaat("v_ilev_bk_vaultdoor"))

    FreezeEntityPosition(obj)
    local objHeading = GetEntityHeading(obj)

    if not lock then
        Citizen.CreateThread(function()
            local ptfxCoords = vec3(253.7, 223.8, 101.9)
    
            local effects = {
                ['scr_agencyheistb'] = 'scr_env_agency3b_smoke',
                ['core'] = 'exp_grd_bzgas_smoke'
            }
    
            for dict, name in next, effects do
                RequestNamedPtfxAsset(dict)
                while not HasNamedPtfxAssetLoaded(dict) do Citizen.Wait(50) end
                            
                SetPtfxAssetNextCall(dict)
    
                local fx = StartParticleFxLoopedAtCoord(name, ptfxCoords, 0.0, 0.0, 0.0, 1.0, false, false, false, 0)
    
                SetTimeout(9150, function()
                    StopParticleFxLooped(fx, 0)
                end)
            end
    
            Citizen.Wait(4500)
    
            if vaultCam then
                DestroyCam(vaultCam, 0)
                RenderScriptCams(0, 0, 1, 1, 1)
                ClearTimecycleModifier("scanline_cam_cheap")
            
                SetNuiFocus(false)
            
                TriggerEvent("vrp-hud:updateMap", true)
                TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = true})
            end
        end)
    end

    repeat
	    local rotation = GetEntityHeading(obj) + (.05 * (lock and 2.5 or - 1))

        SetEntityHeading(obj, rotation)

        Citizen.Wait(10)
        objHeading = GetEntityHeading(obj)

    until math.abs(objHeading - (lock and 160 or 20)) <= 1

    FreezeEntityPosition(obj, true)
end)

RegisterNetEvent("vrp-robbery:startTimer", function(time)
	local sec, min = 0, time

	Citizen.CreateThread(function()
		while min + sec > 0 and not stopTimer do
			Citizen.Wait(1000)
			sec -= 1

			if sec < 0 then
				min -= 1
				sec = 59
			end
            
            SendNUIMessage {
                action = "updateTime",
                time = ("%02d:%02d"):format(min,sec)
            }
		end

        SendNUIMessage {action = "closeActions"}
	end)
end)

RegisterNetEvent("vrp-robbery:finishRobbery", function()
    stopTimer, activeRobbery = true
    
    SendNUIMessage {action = "closeActions"}

    Citizen.CreateThread(function()
        local gases, gasCoords = {}, {
            vec4(262.78, 213.22, 101.68, .8),
            vec4(257.71, 216.64, 101.68, 1.5),
            vec4(252.71, 218.22, 101.68, 1.5)
        }
    
        for index, data in next, gasCoords do
            SetPtfxAssetNextCall("core")
    
            gases[index] = StartNetworkedParticleFxNonLoopedAtCoord("veh_respray_smoke", data.x, data.y, data.z, .0, .0, .0, data.w)
        end
        
        local gasTime = GetGameTimer() + 20000
    
        while gasTime > GetGameTimer() do
            local playerCoords = GetEntityCoords(tempPed)
            
            local closestDistance = math.min(
                #(playerCoords - vec3(252.71, 218.22, 101.68)),
                #(playerCoords - vec3(262.78, 213.22, 101.68))
            )
    
            if closestDistance <= 5 then
                ApplyDamageToPed(tempPed, 3)
                Wait(350)
            end
    
            Wait(1)
        end
    end)

    for _, data in next, robberyProps do
        if DoesEntityExist(data.obj) then
            DeleteObject(data.obj)
        end
    end

    robberyProps = {}
    currentStep = 1
    stopTimer, activeRobbery = false
end)

RegisterNetEvent("vrp-robbery:updateLoot", function()
    SendNUIMessage {
        action = "updateActions",
        robberyData = robberyProps,
    }
end)

function startLooting(index)
    local ped = tempPed
    local pedCoords = GetEntityCoords(ped)

    local data = GlobalState.propsToSpawn[index]
    if not data then return end

    local trolley = GetClosestObjectOfType(data.coords, 1.0, data.hash)
    local rewardModel = joaat(data.rewardModel or `hei_prop_heist_cash_pile`)

    local function collectReward()
        RequestModel(rewardModel)

        while not HasModelLoaded(rewardModel) do Citizen.Wait(50) end

        local rewardObj = CreateObject(rewardModel, pedCoords, true)

        FreezeEntityPosition(rewardObj, true)
	    SetEntityInvincible(rewardObj, true)

	    SetEntityNoCollisionEntity(rewardObj, ped)

	    SetEntityVisible(rewardObj)
	    AttachEntityToEntity(rewardObj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)

        Citizen.CreateThread(function()
	        local timer = GetGameTimer() + 37000
    
            while timer > GetGameTimer() do
                local visible = HasAnimEventFired(ped, joaat("CASH_APPEAR")) or HasAnimEventFired(ped, joaat("RELEASE_CASH_DESTROY"))

                if visible then
                    SetEntityVisible(rewardObj, HasAnimEventFired(ped, joaat("CASH_APPEAR")))
                end
    
                Wait(1)
            end
    
            DeleteObject(rewardObj)
        end)
    end

    local emptyObj = data.emptyObj or 769923921

    if IsEntityPlayingAnim(trolley, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
		return
    end

    Citizen.CreateThread(function()
        local bag = joaat("hei_p_m_bag_var22_arm_s")
    
        RequestAnimDict("anim@heists@ornate_bank@grab_cash")
        
        RequestModel(bag)
        RequestModel(emptyObj)
    
        while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyObj) and not HasModelLoaded(bag) do
            Citizen.Wait(100)
        end
        
        while not NetworkHasControlOfEntity(trolley) do
	    	NetworkRequestControlOfEntity(trolley)
            Citizen.Wait(1)
	    end
    
        local trolleyCoords = GetEntityCoords(trolley)
        local trolleyRot = GetEntityRotation(trolley)
        
        local bagEntity = CreateObject(bag, pedCoords, true)
        local bagScene = NetworkCreateSynchronisedScene(trolleyCoords, trolleyRot, 2, false, false, 1065353216, 0, 1.3)
    
	    NetworkAddPedToSynchronisedScene(ped, bagScene, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bagEntity, bagScene, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    
        SetPedComponentVariation(ped, 5, 0, 0, 0)
	    NetworkStartSynchronisedScene(bagScene)
    
	    Citizen.Wait(1500)
    
	    collectReward()
    
        local grabScene = NetworkCreateSynchronisedScene(trolleyCoords, trolleyRot, 2, false, false, 1065353216, 0, 1.3)

        NetworkAddPedToSynchronisedScene(ped, grabScene, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bagEntity, grabScene, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)

        NetworkAddEntityToSynchronisedScene(trolley, grabScene, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(grabScene)

        Citizen.Wait(37000)

        local exitScene = NetworkCreateSynchronisedScene(trolleyCoords, trolleyRot, 2, false, false, 1065353216, 0, 1.3)

        NetworkAddPedToSynchronisedScene(ped, exitScene, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bagEntity, exitScene, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)

        NetworkStartSynchronisedScene(exitScene)
        
        local newTrolley = CreateObject(emptyObj, trolleyCoords + vec3(.0, .0, - .985), true)
        SetEntityRotation(newTrolley, trolleyRot)

        DeleteObject(trolley)

        PlaceObjectOnGroundProperly(newTrolley)

        Citizen.Wait(1800)

        if DoesEntityExist(bagEntity) then
            DeleteEntity(bagEntity)
        end

        TriggerServerEvent("vrp-robbery:tableReward", index)
        SetPedComponentVariation(ped, 5, 45, 0, 0)
        
        RemoveAnimDict("anim@heists@ornate_bank@grab_cash")

        SetModelAsNoLongerNeeded(emptyObj)
        SetModelAsNoLongerNeeded(bag)
    end)
end