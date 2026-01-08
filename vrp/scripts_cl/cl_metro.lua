local cfg = module("cfg/metro")
RegisterNetEvent("vrp-metro:onPlayerEnteredTrain")

local allTrains, inAnyTrain = {}, false

local currentNode = false

local hasMetroTicket = false
RegisterNetEvent("vrp-metro:boughtTicket")
AddEventHandler("vrp-metro:boughtTicket", function(tog)
    hasMetroTicket = tog
end)

local function getCloseTrains(coords)
    local trams = {}

    local vehiclePool = GetGamePool("CVehicle")
    for k, vehicle in pairs(vehiclePool) do
        local distance = #(GetEntityCoords(vehicle) - coords)

        if distance <= 100 and GetEntityModel(vehicle) == `metrotrain` then
            table.insert(trams, {vehicle, distance, GetEntitySpeed(vehicle)})
        end
    end

    table.sort(trams, function(a, b)
        return a[2] < b[2]
    end)

    return trams
end

local ticketMachines = {`prop_train_ticket_02`, `prop_train_ticket_02_tu`, `v_serv_tu_statio3_`}


Citizen.CreateThread(function()
    local inputActive, eventSent = false, false
    local inTicketBuying = false

    for k, data in pairs(cfg.stopsBlips) do
        data.blip = AddBlipForCoord(data.pos)
        SetBlipSprite(data.blip, 386)
        SetBlipColour(data.blip, 6)
        SetBlipScale(data.blip, 0.4)
        SetBlipAsShortRange(data.blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Statie de metrou "..data.station)
        EndTextCommandSetBlipName(data.blip)
    end

    SwitchTrainTrack(0, true)
    SwitchTrainTrack(3, true)

    SetTrainTrackSpawnFrequency(0, 120000)
    SetRandomTrains(1)

    SetTrainsForceDoorsOpen(false)

    local lastCoords = pedPos
    while true do
        lastCoords = pedPos
        Citizen.Wait(1000)

        trains = getCloseTrains(pedPos)

        -- get closest train
        if #trains >= 1 then
            local train = trains[1][1]
            currentNode = false

            if train then
                currentNode = GetTrainCurrentTrackNode(train)
            end
        end

        inAnyTrain = IsPedInAnyTrain(tempPed)
        
        if not eventSent and inAnyTrain then
            eventSent = true
            TriggerEvent("vrp-metro:onPlayerEnteredTrain")

            if not hasMetroTicket then
                SetEntityCoords(tempPed, lastCoords.x, lastCoords.y, lastCoords.z)
                tvRP.notify("Ai nevoie de un bilet de calatorie valabil.", "error")
            end

        elseif not inAnyTrain and eventSent then
            TriggerEvent("vrp-metro:onPlayerLeftTrain")
            eventSent = false
        end

        
        for k, model in pairs(ticketMachines) do
            local machine = GetClosestObjectOfType(pedPos, 0.85, model, false)

            while DoesEntityExist(machine) and #(GetEntityCoords(machine) - pedPos) <= 2 do
                if not inputActive then
                    inputActive = true
                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Cumpara bilet ($"..cfg.ticketPrice..")"})
                end

                if IsControlJustReleased(0, 51) and not inTicketBuying then
                    inTicketBuying = true
                    local coords = GetEntityCoords(machine)
                    TriggerEvent("vrp-hud:showBind", false)
                    
                    RequestAnimDict("mini@atmbase")
                    RequestAnimDict("mini@atmenter")
                    while not HasAnimDictLoaded("mini@atmenter") do
                        Wait(1)
                    end
    
                    -- TaskLookAtEntity(tempPed, machine, 2000, 2048, 2)
                    -- Wait(500)
                    -- SetEntityCoords(tempPed, coords.x, coords.y, coords.z)
                    -- SetEntityHeading(tempPed, GetEntityHeading(machine))
                    -- Wait(2000)
                    TaskPlayAnim(tempPed, "mini@atmenter", "enter", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                    RemoveAnimDict("mini@atmenter")
                    Wait(4000)
                    TaskPlayAnim(tempPed, "mini@atmbase", "base", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                    RemoveAnimDict("mini@atmbase")
                    Wait(500)
                    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    
                    RequestAnimDict("mini@atmexit")
                    while not HasAnimDictLoaded("mini@atmexit") do
                        Wait(1)
                    end
                    TaskPlayAnim(tempPed, "mini@atmexit", "exit", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                    RemoveAnimDict("mini@atmexit")
                    Wait(500)
                    
                    TriggerServerEvent("vrp-metro:tryBuyTicket")
                    inTicketBuying = false
                end
            
                Citizen.Wait(1)
            end

            if inputActive then
                inputActive = false
                TriggerEvent("vrp-hud:showBind", false)
            end
        end

    end
end)


AddEventHandler("vrp-metro:onPlayerLeftTrain", function()
    if hasMetroTicket then
        TriggerServerEvent("vrp-metro:checkPlayerTickets")
    end
end)
