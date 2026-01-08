
local startingPos = vector3(-2166.505859375,5197.1948242188,16.880399703979)

local chemistPos = vector3(1391.9638671875,3605.6708984375,38.941940307617)

local cfg = {
    slots = {
        {268.79962158203,-1985.7272949219,20.413827896118,140},
        {427.27899169922,-1842.1076660156,28.463443756104,315},
        {168.85313415527,-1863.1490478516,24.205423355103,64},
        {236.10025024414,-2045.8663330078,18.379985809326,329},
        {165.25131225586,-1945.0799560547,20.235416412354,225},
        {149.1735534668,-1960.8555908203,19.458770751953,220},
        {109.2041015625,-2015.9682617188,18.406114578247,163},
        {118.46211242676,-1920.8854980469,21.323419570923,52},
        {105.35874176025,-1900.9675292969,21.406679153442,333},
        {105.03990936279,-1976.5155029297,20.964458465576,14},
        {-42.777168273926,-1859.3254394531,26.19730758667,139},
        {-3.3230361938477,-1821.1666259766,29.54323387146,232},
        {531.47595214844,-1769.5170898438,28.816122055054,356},
        {561.52954101562,-1747.7801513672,33.442638397217,157},
        {523.97515869141,-1966.0201416016,26.54633140564,305},
        {188.89622497559,-2019.1413574219,18.288768768311,262},
        {295.96255493164,-1714.8173828125,29.179161071777,223},
        {66.516288757324,-1868.6539306641,22.799407958984,315},
        {168.30490112305,-1708.4404296875,29.291677474976,316},
        {320.89599609375,-1732.3082275391,29.71498298645,49},
        {-1157.6446533203,-1518.0360107422,10.632730484009,218},
        {-1165.2664794922,-1567.009765625,4.4518995285034,304},
        {-1103.7145996094,-1600.1147460938,4.6708540916443,123},
        {-1062.5412597656,-1662.5628662109,4.5590515136719,121},
        {-1291.9291992188,-1609.4945068359,4.0965523719788,217},
        {-1132.1450195312,-1552.453125,4.3198938369751,117},
    },
}

local possibleModels = {
    "u_m_m_aldinapoli",
    "u_m_m_bikehire_01",
    "u_m_y_smugmech_01",
    "u_m_y_proldriver_01",
    "u_m_m_streetart_01",
    "u_m_o_tramp_01",
    "u_m_y_dancelthr_01",
    "u_m_y_hippie_01",
    "u_m_y_militarybum",
    "a_m_m_rurmeth_01",
    "a_m_m_salton_03",
    "a_m_o_soucent_02",
}

local theJob = {}

Citizen.CreateThread(function()

    local pedId = vRP.spawnNpc("WeedStarter", {
        position = startingPos,
        rotation = 93,
        model = "G_M_Y_SalvaBoss_01",
        freeze = true,
        minDist = 2.5,
        name = "George Traficantul",
        buttons = {
            {
                text = "Informatii despre job",
                response = function()
                    SendNUIMessage({job = "weed", group = inJob})
                    
                    return {false, true}
                end
            },

            {
                text = "Vreau sa cumpar seminte",
                response = function()
                    local reply = promise.new()

                    triggerCallback('buySeeds', function(res)
                        reply:resolve(res)
                    end)
    
                    return Citizen.Await(reply)
                end
            }
        }
    })

    table.insert(allJobPeds, "WeedStarter")

    local pedId = vRP.spawnNpc("WeedChemist", {
		position = chemistPos,
		rotation = 290,
		model = "s_m_y_factory_01",
		freeze = true,
		minDist = 1.5,
		name = "Victor Chimistul",
		buttons = {
			{text = "Vreau sa produc Marijuana", response = function()
                local reply = promise.new()
                triggerCallback('useChemSetWeed', function(res)
                    reply:resolve(res)
                end)

                return Citizen.Await(reply)
            end},
			{text = "Vreau sa produc PCP", response = function()
                local reply = promise.new()
                triggerCallback('useChemSetPcp', function(res)
                    reply:resolve(res)
                end)

                return Citizen.Await(reply)
            end},
        }
	})

	table.insert(allJobPeds, "WeedChemist")

end)


local gameFinish
RegisterNUICallback("weed:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

RegisterNetEvent("work-weedtrafficker:startJob", function(cpData)
    if inJob == "Traficant de iarba" then
        local jobActive = true
        local evt
        evt = AddEventHandler("jobs:onJustFired", function()
            Citizen.Wait(100)
            if not inJob and jobActive then
                jobActive = false
                theJob = {}
            end

            RemoveEventHandler(evt)
        end)

        if not next(theJob) then
            theJob = {
                plants = {},
            }
        end
        
        if not theJob.amount then
            triggerCallback("getWeedToDelivery", function(amm)
                theJob.slot = math.random(1, #cfg.slots)
                theJob.amount = tonumber(amm)
            end)
            Citizen.Wait(1000)
            TriggerServerEvent("jobs:updateLastJob", theJob)
        end
        Citizen.CreateThread(function()
            Citizen.Wait(1500)
            vRP.subtitle("Un dependent de droguri vrea sa cumpere ~y~"..theJob.amount.." Marijuana~w~, vezi harta pentru locatie.", 8)
        end)


        Citizen.CreateThread(function()
            local function deepcopy(orig)
                local orig_type = type(orig)
                local copy
                if orig_type == 'table' then
                    copy = {}
                    for orig_key, orig_value in next, orig, nil do
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    end
                    setmetatable(copy, deepcopy(getmetatable(orig)))
                else -- number, string, boolean, etc
                    copy = orig
                end
                return copy
            end

            local npcWaiting = true
            while jobActive do
                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                if theJob.slot and theJob.amount then
                    local x, y, z, h = table.unpack(cfg.slots[theJob.slot])
                    
                    local blip = AddBlipForRadius(x, y, z, 100.0)
                    SetBlipColour(blip, 5)
                    SetBlipAlpha(blip, 150)
                    table.insert(blips, blip)

                    local model = possibleModels[math.random(1, #possibleModels)]
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(1)
                    end
                
                    local ped = CreatePed(0, model, x, y, z - 1.0, h + 0.0, false, true)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
                    SetModelAsNoLongerNeeded(model)
                    table.insert(objs, ped)

                    local npcPos = GetEntityCoords(ped)
                    
                    while npcWaiting do
                        local ped = PlayerPedId()
                        local pedPos = GetEntityCoords(ped)

                        local dst = #(pedPos.xy - vec2(x, y))

                        if dst <= 10 then
                            DrawMarker(20, npcPos + vector3(0.0, 0.0, 1.15), 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 94, 106, 89, 150, false, true)
                            
                            if dst <= 2 then
                                if not inputActive then
                                    inputActive = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Livreaza drogurile"})
                                end
    
                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    local deliver = promise.new()
                                    triggerCallback("hasItemAmount", function(hasWeed)
                                        if hasWeed then
                                            vRP.playAnim(false, {{"mp_common", "givetake1_a", 1}}, false, true)

                                            triggerCallback("getPaid", function()
                                                theJob = {
                                                    plants = deepcopy(theJob.plants),
                                                }
                                                TriggerServerEvent("jobs:updateLastJob", theJob)
                                                vRP.subtitle("~HC_20~Minunat! ~w~Ai livrat Marijuana clientului, asteapta urmatoarea locatie.")
                                            end, cpData, theJob.amount)
                                            inputActive = false
                                            TriggerEvent("vrp-hud:showBind", false)
                                            deliver:resolve(true)
                                        else
                                            deliver:resolve(false)
                                            TriggerEvent("vrp-hud:notify", "Nu ai destule droguri, clientul vrea "..theJob.amount.." Marijuana !", "error")
                                        end
                                    end, "weed", theJob.amount, true)

                                    if Citizen.Await(deliver) then
                                        npcWaiting = false
                                    end
                                end
                            elseif inputActive then
                                TriggerEvent("vrp-hud:showBind", false)
                                inputActive = false
                            end
                        end

                        Citizen.Wait(1)
                    end
                    
                elseif next(blips) then
                    for _, blipid in pairs(blips) do
                        RemoveBlip(blipid)
                    end
                    blips = {}
                end
                
                if not theJob.slot then
                    jobActive = false
                end
                
                Citizen.Wait(2000)
            end
            
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
        end)
    end
end)

AddEventHandler("jobs:setLastJob", function(job, lastJob)
    if job == "Traficant de iarba" then
        theJob = lastJob
    end
end)

local growInterval = 60000 -- 60.000

local isWithinPlantationArea
AddEventHandler("jobs:onJobSet", function(job)
    
    Citizen.Wait(500)

    if inJob == "Traficant de iarba" then
        
        local plantatie = vector3(1898.6564941406, 5055.654296875, 48.238231658936)

        local blip = AddBlipForCoord(plantatie)
        SetBlipSprite(blip, 140)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 25)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Plantatie de seminte")
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)


        isWithinPlantationArea = function()
            local ped = PlayerPedId()
            local pedPos = GetEntityCoords(ped)

            return #(pedPos - plantatie) <= 40
        end

        Citizen.CreateThread(function()
            local function drawArrow(coords, label)
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
                local icon_scale = 1.0
                local text_scale = 0.25
            
                RequestStreamedTextureDict("basejumping", false)
                DrawSprite("basejumping", "arrow_pointer", screenX, screenY - 0.015, 0.015 * icon_scale, 0.025 * icon_scale, 180.0, 140, 157, 133, 255)
            
                SetTextCentre(true)
                SetTextScale(0.0, text_scale)
                SetTextEntry("STRING")
                AddTextComponentString(label)
                DrawText(screenX, screenY)
            end

            Citizen.CreateThread(function()
                Citizen.Wait(5000)
                vRP.subtitle("Pamantul e numai bun pentru ~HC_20~plantat seminte~w~, vezi harta pentru locatie.")
            end)

            Citizen.CreateThread(function()
                Citizen.Wait(10000)
                
                local objHash = GetHashKey("prop_weed_01")
                RequestModel(objHash)
                while not HasModelLoaded(objHash) do
                    Citizen.Wait(100)
                end

                for k, plant in pairs(theJob.plants or {}) do
                    local x, y, z = table.unpack(plant.position)

                    local prop = CreateObject(objHash, x, y, ((z-1.0)-(tonumber(plant.grow) or 0)), true, true, false)
                    FreezeEntityPosition(prop, true)
                    SetEntityCollision(prop, false, false)

                    plant.prop = prop
                    table.insert(objs, prop) -- safe remove
                end
            end)
            
            local input = false
            while inJob == "Traficant de iarba" do
                local wtime = 500

                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                for k, plant in pairs(theJob.plants or {}) do
                    local x, y, z = table.unpack(plant.position)

                    local dst = #(pedPos.xy - vec2(x, y))

                    if dst <= 15 then
                        local state = "Planta in crestere..."

                        if plant.completed then
                            state = "Planta poate fi culeasa"
                        end

                        drawArrow(plant.position, state)

                        if plant.completed then
                            while dst <= 2 and DoesEntityExist(plant.prop) do
                                drawArrow(plant.position, state)

                                if not input then
                                    input = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Culege planta"})
                                end

                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    SendNUIMessage({job = "weedgame"})
                                    local gameDone = promise.new()
                                    
                                    gameFinish = function()
                                        gameDone:resolve(true)
                                    end
                                    
                                    if Citizen.Await(gameDone) then
                                        triggerCallback("gatherWeedPlant", function(gathered)
                                            if gathered then
                                                DeleteEntity(plant.prop)
                                                table.remove(theJob.plants, k)
                                                TriggerServerEvent("jobs:updateLastJob", theJob)
                                                TriggerEvent("vrp-hud:showBind", false)
                                                input = false
                                            end
                                        end, k)
                                    end
                                end

                                ped = PlayerPedId()
                                pedPos = GetEntityCoords(ped)

                                dst = #(pedPos.xy - vec2(x, y))
                                Citizen.Wait(1)
                            end
                            if input then
                                TriggerEvent("vrp-hud:showBind", false)
                                input = false
                            end
                        end

                        wtime = 1
                    end
                end

                Citizen.Wait(wtime)
            end
        end)

        while inJob == "Traficant de iarba" do
            for k, plant in pairs(theJob.plants or {}) do
                if (plant.grow or 0) > 0 then
                    plant.grow = plant.grow - 1
                    local x, y, z = table.unpack(plant.position)
                    SetEntityCoords(plant.prop, x, y, (z-1.0)-tonumber(plant.grow))

                    if plant.grow < 1 then
                        plant.completed = true
                    end
                end
            end
            TriggerServerEvent("jobs:updateLastJob", theJob)

            Citizen.Wait(growInterval)
        end
    end
end)

RegisterNetEvent("work-weedtrafficker:plantSeed", function()
    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    if not (inJob == "Traficant de iarba") then
        TriggerEvent("vrp-hud:notify", "Nu esti un Traficant de iarba !", "error")
        return
    end

    local function isPlantNear()
        local near = false

        for k, v in pairs(theJob.plants or {}) do
            if v.prop then
                local plantPos = GetEntityCoords(v.prop)
                if #(pedPos - plantPos) <= 3.5 then
                    near = true
                    break
                end
            end
        end
        return near
    end

    if isWithinPlantationArea() then
        if not isPlantNear() then
            triggerCallback("hasItemAmount", function(hasItem)
                if hasItem then

                    local anim = "WORLD_HUMAN_GARDENER_PLANT"
                    TaskStartScenarioInPlace(ped, anim, 0, true)

                    local untilTime = GetGameTimer() + 15000
                    FreezeEntityPosition(ped, true)
                    while GetGameTimer() < untilTime do
                        Citizen.Wait(100)
                    end
                    ClearPedTasks(ped)
                    FreezeEntityPosition(ped, false)

                    local objHash = GetHashKey("prop_weed_01")
                    RequestModel(objHash)
                    while not HasModelLoaded(objHash) do
                        Citizen.Wait(100)
                    end

                    local plant = {position = {pedPos.x, pedPos.y, pedPos.z}, grow = 5}
                    local x, y, z = table.unpack(plant.position)

                    local prop = CreateObject(objHash, x, y, ((z-1.0)-(tonumber(plant.grow) or 0)), true, true, false)
                    FreezeEntityPosition(prop, true)
                    SetEntityCollision(prop, false, false)
                    table.insert(theJob.plants, plant)
                    TriggerServerEvent("jobs:updateLastJob", theJob)

                    plant.prop = prop
                    table.insert(objs, prop) -- safe remove
                end
            end, "drug_seeds", 1, true)                
        else
            TriggerEvent("vrp-hud:notify", "Exista deja o planta langa !", "error")
        end
    else
        TriggerEvent("vrp-hud:notify", "Nu esti in zona de plantare !", "error")
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

