
local startingPos = vector3(657.03680419922,-779.4013671875,24.549482345581)

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

    local pedId = vRP.spawnNpc("HackerStarter", {
        position = startingPos,
        rotation = 177,
        model = "ig_lestercrest",
        freeze = true,
        minDist = 2.5,
        name = "Petronel Calculatoristul",
        ["function"] = function()
            SendNUIMessage({job = "hacker", group = inJob})
        end
    })

    table.insert(allJobPeds, "HackerStarter")

end)


local gameFinish
RegisterNUICallback("hacker:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

RegisterNetEvent("work-hacker:getHackZone", function(locationId, locationData)

    Citizen.CreateThread(function()
        Citizen.Wait(500)
        vRP.subtitle("O noua ~HC_37~vulnerabilitate~w~ a fost descoperita, vezi harta pentru locatie.")
    end)

    if theJob then
        theJob.zone = locationData
        theJob.rnd = locationId
    end
    	
	local pos = {locationData[1], locationData[2], locationData[3]}
	local hackInProgress = true

	local blip = AddBlipForRadius(pos[1], pos[2], pos[3], locationData.radius + 0.0001)
	SetBlipColour(blip, 43)
	SetBlipAlpha(blip, 50)

    blips.radius = blip

	local blip = AddBlipForCoord(pos[1], pos[2], pos[3])
	SetBlipSprite(blip, 619)
	SetBlipDisplay(blip, 10)
	SetBlipColour(blip, 43)
	SetBlipFlashes(blip, true)
	SetBlipRoute(blip, true)
	SetBlipRouteColour(blip, 43)

	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Locatie Hacker")
    EndTextCommandSetBlipName(blip)

    blips.location = blip

	local inHackZone, minigame = false
    local function getdist(x1, x2, y1, y2)
        return math.sqrt((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1))
    end


    
    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    local evt
    evt = RegisterNetEvent("work-hacker:startMinigame", function()
        if not inHackZone then
            TriggerEvent("vrp-hud:notify", "Nu esti in zona corecta!", "error")
            return
        end

        if IsPedInAnyVehicle(ped, true) and GetIsVehicleEngineRunning(GetVehiclePedIsIn(ped, true)) then
            TriggerEvent("vrp-hud:notify", "Trebuie sa opresti motorul pentru a fura date!", "error")
            return
        end

        minigame = "doing"

        exports.fallouthack:startGame(10, 5, function(win)
            if math.random(1, 5) < 3 then -- [1, 2]
                TriggerEvent("vrp-hud:notify", "Din pacate ti s-a stricat laptopul", "error")
                triggerCallback("hasItemAmount", function() end, "laptop_h", 1, true)
            end
            TriggerServerEvent("work-hacker:checkHack", win)

            minigame = "stop"
        end)

        RemoveEventHandler(evt)
    end)

    while true do
        
        inHackZone = (getdist(pedPos.x, pos[1], pedPos.y, pedPos[2]) <= locationData.radius)
        if inHackZone and not minigame then
            drawText("Foloseste ~HC_37~laptopul ~w~pentru a incepe sa furi date", 0.5, 0.85, 0.4, 255, 255, 255)
        end

        if minigame == "stop" then break end

        ped = PlayerPedId()
        pedPos = GetEntityCoords(ped)
        Citizen.Wait(1)
    end



    if blips.radius then
        RemoveBlip(blips.radius)
        blips.radius = nil
    end
    
    if blips.location then
        RemoveBlip(blips.location)
        blips.location = nil
    end
end)

RegisterNetEvent("work-hacker:startJob", function(cpData)
    if inJob == "Hacker" then
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
            triggerCallback("getUSBToDelivery", function(amm)
                theJob.slot = math.random(1, #cfg.slots)
                theJob.amount = tonumber(amm)
            end)
            Citizen.Wait(1000)
            TriggerServerEvent("jobs:updateLastJob", theJob)
        end
        Citizen.CreateThread(function()
            Citizen.Wait(1500)
            vRP.subtitle("Un necunoscut vrea sa cumpere ~HC_37~"..theJob.amount.." USB cu date furate~w~, vezi harta pentru locatie.", 8)
        end)


        Citizen.CreateThread(function()

            local function getdist(x1, x2, y1, y2)
                return math.sqrt((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1))
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

                        local dst = getdist(pedPos.x, x, pedPos.y, y)

                        if dst <= 10 then
                            DrawMarker(20, npcPos + vector3(0.0, 0.0, 1.15), 0, 0, 0, 0, 0, 0, 0.45, 0.45, -0.45, 106, 196, 191, 150, false, true)
                            
                            if dst <= 2 then
                                if not inputActive then
                                    inputActive = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Livreaza datele furate"})
                                end
    
                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    local deliver = promise.new()
                                    triggerCallback("hasItemAmount", function(hasUSB)
                                        if hasUSB then
                                            vRP.playAnim(false, {{"mp_common", "givetake1_a", 1}}, false, true)

                                            triggerCallback("getPaid", function()
                                                theJob = {}
                                                TriggerServerEvent("jobs:updateLastJob", theJob)
                                                vRP.subtitle("~HC_37~Minunat! ~w~Ai livrat USB cu date furate clientului, asteapta urmatoarea locatie.")
                                            end, cpData, theJob.amount)
                                            inputActive = false
                                            TriggerEvent("vrp-hud:showBind", false)
                                            deliver:resolve(true)
                                        else
                                            deliver:resolve(false)
                                            TriggerEvent("vrp-hud:notify", "Nu ai destule stickuri, clientul vrea "..theJob.amount.." USB cu date furate !", "error")
                                        end
                                    end, "fullusbstick", theJob.amount, true)

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
    if job == "Hacker" then
        theJob = lastJob
    
        Citizen.CreateThread(function()
            Citizen.Wait(5000)
            if theJob.zone then
                TriggerEvent("work-hacker:getHackZone", theJob.rnd, theJob.zone)
            end
        end)
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

