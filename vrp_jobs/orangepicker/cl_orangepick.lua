
local startingPos = vector3(2031.8414306641,4732.9262695312,41.615966796875)

local cfg = {
    slots = {
        {
            {2063.6215820312,4819.1806640625,41.807682037354},
            {2085.9113769531,4825.310546875,41.590587615967},
            {2099.0234375,4841.671875,41.644805908203},
            {2083.1625976562,4854.458984375,41.801616668701},
            {2060.5886230469,4841.6596679688,41.881744384766},
            {2101.447265625,4878.1962890625,41.087623596191},
            {2117.6022949219,4841.5791015625,41.592170715332},
            {2122.5854492188,4861.7211914062,41.089935302734},
            {2122.8220214844,4884.4155273438,40.886497497559},
            {2146.8227539062,4867.1396484375,40.610782623291},
            {1980.9835205078,4771.8051757812,41.920120239258},
            {2003.8551025391,4786.2973632812,41.783493041992},
            {2015.3638916016,4800.3369140625,41.984069824219},
            {2030.93359375,4801.537109375,41.886054992676},
        }
    },
}

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 280)
    SetBlipColour(blip, 51)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Culegator de portocale")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("OrangePickerStarter", {
        position = startingPos,
        rotation = 30,
        model = "a_m_m_farmer_01",
        freeze = true,
        minDist = 2.5,        
        name = "Portocala Culegatorul",
        ["function"] = function()
            SendNUIMessage({job = "orangepicker", group = inJob})
        end
    })

    table.insert(allJobPeds, "OrangePickerStarter")

end)

local vehSpawnPoint = {2043.8155517578,4742.2260742188,41.612327575684}



local gameFinish
RegisterNUICallback("orangepicker:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish()
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

local caddyObj

RegisterNetEvent("work-orangepicker:startJob", function(cpData)
    if inJob == "Culegator de portocale" then
        local jobActive = true

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
                slot = math.random(1, #cfg.slots),
                nexttree = 1,
                vehpos = vehSpawnPoint,
            }
        end

        vRP.subtitle("Portocalele au ~y~crescut~w~ si trebuie culese, vezi harta pentru locatie.")
        TriggerServerEvent("jobs:updateLastJob", theJob)
        
        Citizen.CreateThread(function()
            local nblip
            while jobActive and not DoesEntityExist(caddyObj) do
                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)

                local vpos = vector3(table.unpack(theJob.vehpos))

                if not nblip then
                    local blip = AddBlipForCoord(vpos)
                    SetBlipSprite(blip, 326)
                    SetBlipColour(blip, 51)
                    SetBlipScale(blip, 0.6)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Vehiculul culegatorului")
                    EndTextCommandSetBlipName(blip)

                    nblip = blip
                    table.insert(blips, nblip)
                end

                if #(pedPos - vpos) <= 15 then
                    if not theJob.vehrot then
                        theJob.vehrot = 70.0
                    end
                    
                    getVehicleObject({pos = theJob.vehpos, h = theJob.vehrot, hash = `caddy3`}, function(nveh)
                        caddyObj = nveh
                        SetVehicleColours(caddyObj, 38, 47)
                        TriggerServerEvent("jobs:setCaddyObj", NetworkGetNetworkIdFromEntity(caddyObj))
                    end)

                    Citizen.Wait(1000)

                    break
                end

                Citizen.Wait(1000)
            end

            RemoveBlip(nblip)
        end)

        Citizen.CreateThread(function()
            local inputActive = false

            while jobActive do

                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                if theJob.slot then
                    local x, y, z = table.unpack(cfg.slots[theJob.slot][theJob.nexttree])

                    if not blips.location then
                        local blip = AddBlipForCoord(x, y, z)
                        SetBlipSprite(blip, 486)
                        SetBlipScale(blip, 0.6)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString("Pom cu portocale")
                        EndTextCommandSetBlipName(blip)
    
                        blips.location = blip
                    end
                    local blip = blips.location
                    SetBlipColour(blip, 73)
                    SetBlipCoords(blip, x, y, z)
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, GetBlipColour(blip))

                    while jobActive do

                        local dist = #(pedPos.xy - vec2(x, y))

                        if dist <= 10 then
                            DrawMarker(20, x, y, z, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.35, 255, 167, 90, 200, false, true, false, true)
                        
                            if dist <= 2 and not ongoing then
                                if not inputActive and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    inputActive = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Culege portocale"})
                                end

                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    TriggerEvent("vrp-hud:showBind", false)

                                    ongoing = true

                                    SendNUIMessage({job = "orangegame"})
                                    local game = promise.new()

                                    gameFinish = function()
                                        game:resolve(true)
                                    end

                                    Citizen.Await(game)

                                    if theJob.nexttree + 1 <= #cfg.slots[theJob.slot] then
                                        theJob.nexttree = theJob.nexttree + 1
                                        TriggerServerEvent("jobs:updateLastJob", theJob)

                                        if game then
                                            vRP.subtitle("Ai cules portocalele aici, mergi la ~y~urmatorul pom~w~.", 2)
                                        end
                                    else
                                        triggerCallback("getPaid", function()
                                            theJob = {}
                                            TriggerServerEvent("jobs:updateLastJob", false)
                                            vRP.subtitle("~y~Minunat! ~w~Ai cules toate portocalele, asteapta urmatoarea locatie.")
                                        end, cpData)
                                    end

                                    ongoing = false

                                    break
                                end
                            elseif inputActive then
                                TriggerEvent("vrp-hud:showBind", false)
                                inputActive = false
                            end
                        end

                        ped = PlayerPedId()
                        pedPos = GetEntityCoords(ped)

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
            
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end

            if DoesEntityExist(buildObj) then
                DeleteEntity(buildObj)
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
    if job == "Culegator de portocale" then
        theJob = lastJob
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
