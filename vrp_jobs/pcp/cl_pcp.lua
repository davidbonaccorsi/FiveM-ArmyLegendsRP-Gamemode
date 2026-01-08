
local startingPos = vector3(1754.1689453125,-1649.3403320313,112.65649414063)

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

local function drawText(text, x, y, scale, r, g, b)
	SetTextFont(0)
	SetTextCentre(1)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextDropShadow(30, 5, 5, 5, 255)
	SetTextEntry("STRING")
	SetTextColour(r, g, b, 255)
	AddTextComponentString(text)
	DrawText(x, y)
end

local theJob = {}

Citizen.CreateThread(function()

    local pedId = vRP.spawnNpc("PCPStarter", {
        position = startingPos,
        rotation = 272,
        model = "ig_g",
        freeze = true,
        minDist = 2.5,
        name = "Rosie Baronul",
        ["function"] = function()
            SendNUIMessage({job = "pcp", group = inJob})
        end
    })

    table.insert(allJobPeds, "PCPStarter")
end)


local gameFinish
RegisterNUICallback("pcp:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

RegisterNetEvent("work-pcptrafficker:startJob", function(cpData)
    if inJob == "Traficant de PCP" then
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
            theJob = {}
        end
        
        if not theJob.amount then
            triggerCallback("getPCPToDelivery", function(amm)
                theJob.slot = math.random(1, #cfg.slots)
                theJob.amount = tonumber(amm)
            end)
            Citizen.Wait(1000)
            TriggerServerEvent("jobs:updateLastJob", theJob)
        end
        
        Citizen.CreateThread(function()
            Citizen.Wait(1500)
            vRP.subtitle("Un dependent de droguri vrea sa cumpere ~HC_4~"..theJob.amount.." PCP~w~, vezi harta pentru locatie.", 8)

            TriggerServerEvent("work-pcptrafficker:requestPipeCoords")
        end)

        Citizen.CreateThread(function()

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
                            DrawMarker(20, npcPos + vector3(0.0, 0.0, 1.15), 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 205, 205, 205, 150, false, true)
                            
                            if dst <= 2 then
                                if not inputActive then
                                    inputActive = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Livreaza drogurile"})
                                end
    
                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    local deliver = promise.new()
                                    triggerCallback("hasItemAmount", function(hasPCP)
                                        if hasPCP then
                                            vRP.playAnim(false, {{"mp_common", "givetake1_a", 1}}, false, true)

                                            triggerCallback("getPaid", function()
                                                theJob = {}
                                                TriggerServerEvent("jobs:updateLastJob", theJob)
                                                vRP.subtitle("~HC_3~Minunat! ~w~Ai livrat PCP clientului, asteapta urmatoarea locatie.")
                                            end, cpData, theJob.amount)
                                            inputActive = false
                                            TriggerEvent("vrp-hud:showBind", false)
                                            deliver:resolve(true)
                                        else
                                            deliver:resolve(false)
                                            TriggerEvent("vrp-hud:notify", "Nu ai destule droguri, clientul vrea "..theJob.amount.." PCP !", "error")
                                        end
                                    end, "pcp", theJob.amount, true)

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
    if job == "Traficant de PCP" then
        theJob = lastJob

        Citizen.CreateThread(function()
            Citizen.Wait(500)
            if theJob.gatheringPipe then
                TriggerEvent("work-pcptrafficker:getPipeCoords", theJob.gatheringPipe)
            end
        end)
    end
end)


local combinePos = vec3(1977.6480712891,-2610.8088378906,3.5522463321686)

local packPos = vec3(1981.7822265625,-2610.4145507812,3.5522458553314)

AddEventHandler("jobs:onJobSet", function(job)
    
    Citizen.Wait(500)

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    local input = false

    local combining = false

    
    Citizen.CreateThread(function()
        
        local input = false

        while inJob == "Traficant de PCP" do
            local dst = #(pedPos.xy - packPos.xy)

            if dst <= 5 then
                DrawMarker(20, packPos, 0, 0, 0, 0, 0, 0, 0.201, 0.201, 0.2001, 205, 205, 205, 200, 0, 0, 0, 1)
                
                if dst < 1 then
                    if not input then
                        input = true
                        TriggerEvent("vrp-hud:showBind", {key = "E", text = "Impacheteaza praful"})
                    end

                    if IsControlJustReleased(0, 38) then

                        if not combining then
                            TriggerEvent("vrp-hud:notify", "Nu ai amestecat prafurile !", "error")
                        else
                            local done = promise.new()
                            triggerCallback("hasItemAmount", function(hasItem)
                                if hasItem then
                                    SetEntityCoords(ped, packPos[1], packPos[2], packPos[3]-1.0)
                                    SetEntityHeading(ped, packPos[4])
                                    
                                    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                                    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
                                        Citizen.Wait(1) 
                                    end

                                    TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5, 1.0, 0.3, 48, 0.2, 0, 0, 0)
                                    FreezeEntityPosition(ped, true)

                                    TriggerEvent("vrp-hud:showBind", false)

                                    Citizen.CreateThread(function()
                                        local untilTime = GetGameTimer() + 3000

                                        while GetGameTimer() < untilTime do
                                            drawText("Ai inceput sa impachetezi amestecul...", 0.5, 0.85, 0.4, 155, 155, 155)
                                            Citizen.Wait(1)
                                        end
                                    end)

                                    Citizen.Wait(5000)
                                    TriggerServerEvent("work-pcptrafficker:combineAllDust")
                                    Citizen.Wait(1000)
                                    
                                    StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5)
                                    FreezeEntityPosition(ped, false)

                                    input = false
                                    combining = false
                                    done:resolve(true)
                                elseif ok ~= "full" then
                                    vRP.subtitle("Ai nevoie de o ~HC_4~punga de plastic~w~ pentru a impacheta amestecul")
                                    done:resolve(false)
                                end
                            end, "zipbagcoca", 1, true)
                            Citizen.Await(done)
                        end
                    end

                elseif input then
                    TriggerEvent("vrp-hud:showBind", false)
                    input = false
                end
            
            else
                Citizen.Wait(1000)
            end

            Citizen.Wait(1)
        end
    end)

    while inJob == "Traficant de PCP" do
        local dst = #(pedPos.xy - combinePos.xy)

        if dst <= 10 then
            DrawMarker(20, combinePos, 0, 0, 0, 0, 0, 0, 0.201, 0.201, 0.2001, 205, 205, 205, 200, 0, 0, 0, 1)
            
            if dst < 2 then
                if not input then
                    input = true
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Combina praful"})
                end

                if IsControlJustPressed(0, 38) then
                    if combining then
                        TriggerEvent("vrp-hud:notify", "Impacheteaza amestecul precedent inainte de a face altul !", "error")
                    else

                        local response = promise.new()
                        triggerCallback("canCombinePCPDust", function(ok)
                            if ok then
                                SetEntityCoords(ped, combinePos.x, combinePos.y, combinePos.z - 1.0)
                                SetEntityHeading(ped, combinePos.w)
                                
                                RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                                while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
                                    Citizen.Wait(1) 
                                end

                                TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5, 1.0, 0.3, 48, 0.2, 0, 0, 0)
                                FreezeEntityPosition(ped, true)

                                TriggerEvent("vrp-hud:showBind", false)

                                Citizen.CreateThread(function()
                                    local untilTime = GetGameTimer() + 3000

                                    while GetGameTimer() < untilTime do
                                        drawText("Ai inceput sa combini prafurile ilegale...", 0.5, 0.85, 0.4, 155, 155, 155)
                                        Citizen.Wait(1)
                                    end
                                end)

                                Citizen.Wait(13000)
                                TriggerEvent("vrp-hud:notify", "Ai amestecat prafurile, acum pune amestecul in pliculete!")
                                Citizen.Wait(2000)
                                
                                StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5)
                                FreezeEntityPosition(ped, false)
                                input = false
                                combining = true
                                response:resolve(true)
                            else
                                response:resolve(false)
                            end
                        end)
                        Citizen.Await(response)
                    end
                end
            elseif input then
                TriggerEvent("vrp-hud:showBind", false)
                input = false
            end
        
        else
            Citizen.Wait(1000)
        end

        ped = PlayerPedId()
        pedPos = GetEntityCoords(ped)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent("work-pcptrafficker:getPipeCoords", function(coords)
    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    for k, v in pairs(coords) do
        local blip = AddBlipForCoord(v[1], v[2], v[3])
        SetBlipSprite(blip, 140)
        SetBlipDisplay(blip, 10)
        SetBlipColour(blip, 43)
        SetBlipScale(blip, 0.6)

        blips["pipe"..k] = blip
    end

    Citizen.CreateThread(function()
        Citizen.Wait(500)
        vRP.subtitle("Pamantul e numai bun pentru ~HC_19~cules piperidina~w~, vezi harta pentru locatie.")
    end)

    if not (inJob == "Traficant de PCP") then
        TriggerEvent("vrp-hud:notify", "Nu esti un Traficant de PCP !", "error")
        return
    end
    
    theJob.gatheringPipe = coords

    Citizen.CreateThread(function()
        while inJob == "Traficant de PCP" do
            
            for k, v in pairs(coords) do
                local dst = #(pedPos.xy - vec2(v[1], v[2]))

                if dst <= 50 then
                    DrawMarker(20, v[1], v[2], v[3], 0, 0, 0, 0, 0, 0, 0.201, 0.201, 0.2001, 138, 203, 136, 200, 0, 0, 0, 1)

                    if dst <= 1 then
                        if not v[5] then
                            v[5] = true
                            TriggerEvent("vrp-hud:showBind", {key = "E", text = "Culege piperidina"})
                        end

                        if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(ped, true) then
                            SetEntityCoords(ped, v[1], v[2], v[3]-1.0)
                            SetEntityHeading(ped, v[4] + 0.0)
                            FreezeEntityPosition(ped, true)

                            RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                            while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
                                Citizen.Wait(1) 
                            end

                            TaskPlayAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5, 1.0, 0.3, 1, 0.2, 0, 0, 0)

                            SendNUIMessage({job = "pcpgame"})
                            local gameDone = promise.new()
                            gameFinish = function()
                                gameDone:resolve(true)
                            end
                            
                            if Citizen.Await(gameDone) then
                                triggerCallback("gatherPiperine", function(gathered)
                                    if gathered then
                                        coords[k] = nil
                                        theJob.gatheringPipe = next(coords) and coords or nil
                                        RemoveBlip(blips["pipe"..k])
                                        blips["pipe"..k] = nil
                                        TriggerServerEvent("jobs:updateLastJob", theJob)
                                        TriggerEvent("vrp-hud:showBind", false)
                                        FreezeEntityPosition(ped, false)
                                        StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer", 1.5)
                                    end
                                end, k)
                            end
                        end

                    elseif v[5] then
                        TriggerEvent("vrp-hud:showBind", false)
                        v[5] = false
                    end
                end
            end
            
            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)
            Citizen.Wait(1)
        end
    end)
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

