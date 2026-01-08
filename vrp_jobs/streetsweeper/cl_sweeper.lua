
local startingPos = vector3(1070.5645751953,-780.34704589844,58.33911895752)

local cfg = {
    slots = {
        {
            {1173.1234130859,-761.52166748047,57.190551757812,false},
            {1172.8336181641,-820.42211914062,54.866130828857,false},
            {1058.3665771484,-838.21508789062,48.83353805542,false},
            {952.03186035156,-833.16979980469,43.690368652344,true},
            {629.25463867188,-842.41607666016,41.624752044678,true},
            {465.66812133789,-842.416015625,35.170501708984,true},
            {388.38534545898,-844.04815673828,28.758302688599,false},
            {317.22436523438,-849.97680664062,28.82377243042,false},
            {204.12088012695,-818.46295166016,30.352876663208,true},
            {234.02911376953,-681.83392333984,36.572814941406,true},
            {262.02850341797,-611.76470947266,41.994560241699,false},
            {308.34350585938,-497.34167480469,42.749946594238,false},
            {316.40545654297,-415.99996948242,44.435665130615,false},
            {350.751953125,-296.46597290039,53.279392242432,false},
            {394.49786376953,-151.11698913574,64.023155212402,false},
            {316.05041503906,-90.309829711914,68.697357177734,true},
            {180.62768554688,-44.34631729126,67.754745483398,false},
            {156.29277038574,30.054328918457,71.828804016113,true},
            {199.14791870117,164.83001708984,104.78601837158,false},
            {244.80345153809,169.58169555664,104.4552154541,false},
            {324.25305175781,146.27787780762,103.02651977539,true},
            {424.67990112305,109.17047119141,99.918838500977,true},
            {486.35140991211,86.969779968262,96.269546508789,false},
            {587.9404296875,52.199195861816,92.503196716309,true},
            {648.51873779297,33.260864257812,85.872108459473,false},
            {674.73529052734,14.660273551941,83.667053222656,true},
            {772.03784179688,-45.083263397217,80.35710144043,true},
            {841.06927490234,-89.423004150391,80.109535217285,true},
            {926.00823974609,-143.40766906738,75.096084594727,false},
            {1038.8610839844,-213.42248535156,69.680740356445,false},
            {1199.5911865234,-295.18606567383,68.601982116699,false},
            {1198.4967041016,-408.181640625,67.369277954102,true},
            {1178.4185791016,-490.20327758789,65.079765319824,false},
            {1174.0993652344,-612.50653076172,63.194789886475,false},
            {1184.8353271484,-666.56024169922,61.01643371582,false},
            {1189.5582275391,-742.02923583984,57.925884246826,false},
            {1069.0906982422,-755.14440917969,57.155254364014,false},
        },
        {
            {1086.1083984375,-755.36602783203,57.173122406006,false},
            {987.90704345703,-676.82745361328,56.8720703125,true},
            {1034.0689697266,-542.54553222656,59.923473358154,true},
            {973.35400390625,-557.73992919922,58.607604980469,false},
            {880.02557373047,-564.73492431641,56.67024230957,true},
            {963.25341796875,-486.10610961914,60.896743774414,false},
            {963.25341796875,-486.10610961914,60.896743774414,true},
            {1186.2951660156,-371.35516357422,68.349266052246,true},
            {1045.3581542969,-205.02598571777,69.569755554199,false},
            {931.234375,-131.04472351074,75.074516296387,true},
            {821.03564453125,-56.541660308838,80.006408691406,false},
            {896.02600097656,56.530654907227,78.30793762207,true},
            {1005.9691772461,186.89703369141,80.307456970215,true},
            {1095.7923583984,276.71884155273,87.63599395752,false},
            {1104.5509033203,418.96636962891,90.953514099121,true},
            {1042.6873779297,478.64562988281,94.211387634277,false},
            {924.61566162109,327.21789550781,87.889190673828,false},
            {799.51495361328,175.13185119629,80.63680267334,true},
            {699.49578857422,36.001808166504,83.622024536133,true},
            {629.90753173828,-51.389591217041,76.383346557617,false},
            {511.21914672852,-131.36006164551,59.18590927124,true},
            {485.54049682617,-290.88119506836,46.376537322998,true},
            {577.40509033203,-366.79568481445,43.082229614258,true},
            {645.65637207031,-401.74731445312,41.751613616943,false},
            {767.99353027344,-547.44110107422,32.529563903809,true},
            {805.69689941406,-705.02807617188,28.602230072021,true},
            {904.361328125,-814.52453613281,42.9137840271,false},
            {997.64697265625,-843.64044189453,47.003406524658,true},
            {1149.6968994141,-838.36096191406,54.080333709717,false},
            {1197.6297607422,-778.72155761719,56.625576019287,true},
            {1132.7967529297,-754.40350341797,57.139705657959,true},
            {1068.4973144531,-755.65753173828,57.183834075928,false},
        }
    },
}

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 384)
    SetBlipColour(blip, 18)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Curatator de strazi")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("SweeperStarter", {
        position = startingPos,
        rotation = 90,
        model = "s_m_y_winclean_01",
        freeze = true,
        minDist = 2.5,        
        name = "Bogdan Mizerabilul",
        ["function"] = function()
            SendNUIMessage({job = "streetsweeper", group = inJob})
        end
    })

    table.insert(allJobPeds, "SweeperStarter")

end)

local vehSpawnPoints = {
    {1107.4649658203,-780.30786132812,58.262691497803},
    {1107.7473144531,-778.82568359375,58.262691497803}
}


local gameFinish
RegisterNUICallback("streetsweeper:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

local sweeperObj
RegisterNetEvent("work-streetsweeper:startJob", function(cpData)
    if inJob == "Curatator de strazi" then
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
                slot = math.random(1, #cfg.slots),
                nextstop = 1,
                vehpos = vehSpawnPoints[math.random(1, #vehSpawnPoints)],
            }
        end

        vRP.subtitle("Strazile s-au murdarit~w~ si trebuie ~HC_10~curatate~w~, du-te si ia masina.")
        TriggerServerEvent("jobs:updateLastJob", theJob)
        
        Citizen.CreateThread(function()
            local vehBlip

            while jobActive and not DoesEntityExist(sweeperObj) do
                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)

                local vpos = vector3(table.unpack(theJob.vehpos))

                if not vehBlip then
                    vehBlip = AddBlipForCoord(vpos)
                    SetBlipSprite(vehBlip, 326)
                    SetBlipColour(vehBlip, 53)
                    SetBlipScale(vehBlip, 0.5)
                    SetBlipAsShortRange(vehBlip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Vehiculul firmei")
                    EndTextCommandSetBlipName(vehBlip)
    
                    table.insert(blips, vehBlip)
                end
    
                if #(pedPos - vpos) <= 15 then
                    if not theJob.vehrot then
                        theJob.vehrot = 270.0
                    end
                    
                    getVehicleObject({pos = theJob.vehpos, h = theJob.vehrot, hash = `airtug`}, function(nveh)
                        sweeperObj = nveh
                        TriggerServerEvent("jobs:setSweeperObj", NetworkGetNetworkIdFromEntity(sweeperObj))

                        RemoveBlip(vehBlip)

                        local blip = AddBlipForEntity(sweeperObj)
                        SetBlipSprite(blip, 326)
                        SetBlipColour(blip, 53)
                        SetBlipScale(blip, 0.6)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString("Vehiculul firmei")
                        EndTextCommandSetBlipName(blip)
    
                        table.insert(blips, blip)
                    end)

                    Citizen.Wait(1000)

                    break
                end

                Citizen.Wait(1000)
            end
        end)


        Citizen.CreateThread(function()
            local bigCp, smallCp = nil, nil

            local function setNextCheckpoint(coords)
                if bigCp and DoesBlipExist(bigCp) then
                    RemoveBlip(bigCp)
                end
                if smallCp and DoesBlipExist(smallCp) then
                    bigCp = smallCp
                    SetBlipScale(bigCp, 0.6)
                    SetBlipRoute(bigCp, true)
                    SetBlipColour(bigCp, 43)
                    SetBlipRouteColour(bigCp, 43)
                end

                if coords then
                    smallCp = AddBlipForCoord(coords)
                    
                    SetBlipSprite(smallCp, 271)
                    SetBlipScale(smallCp, 0.5)
                    SetBlipColour(smallCp, 36)
                    SetBlipRouteColour(smallCp, GetBlipColour(smallCp))
                    SetBlipAsShortRange(smallCp, true)

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Loc de curatat")
                    EndTextCommandSetBlipName(smallCp)
                    table.insert(blips, smallCp)
                end
            end

            while jobActive do

                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                if theJob.slot then
                    local ongoing

                    while jobActive and DoesEntityExist(sweeperObj) and theJob.slot do
                        local sweeperPos = GetEntityCoords(sweeperObj)

                        if not ongoing then    
                            local x, y, z, game = table.unpack(cfg.slots[theJob.slot][theJob.nextstop] or {})
                            if x and y and z then
                                setNextCheckpoint(vector3(x, y, z))
                            end
                            
                            local nx, ny, nz, ngame = table.unpack(cfg.slots[theJob.slot][theJob.nextstop + 1] or {})
                            if nx and ny and nz then
                                setNextCheckpoint(vector3(nx, ny, nz))
                            end

                            ongoing = true
                        end

                        if ongoing then
                            local x, y, z, game = table.unpack(cfg.slots[theJob.slot][theJob.nextstop] or {})
                            local nx, ny, nz, ngame = table.unpack(cfg.slots[theJob.slot][theJob.nextstop + 1] or {})

                            local dist = #(sweeperPos.xy - vec2(x, y))

                            if dist <= 80 then
                                if game then
                                    DrawMarker(1, x, y, z-1.0, 0, 0, 0, 0, 0, 0, 8.0, 8.0, 65.0, 251, 238, 165, 125)
                                else
                                    DrawMarker(1, x, y, z-1.0, 0, 0, 0, 0, 0, 0, 8.0, 8.0, 65.0, 175, 237, 174, 150)
                                end

                                if dist <= 3.5 then
                                    local gameResult = promise.new()
                                    
                                    if game then
                                        if math.floor(GetEntitySpeed(sweeperObj)*3.6) <= 30 then
                                            TriggerEvent("vrp-hud:updateMap", false)
                                            TriggerEvent("vrp-hud:setComponentDisplay", {
                                                serverHud = false,
                                                minimapHud = false,
                                                bottomRightHud = false,
                                                chat = false,
                                            })

                                            SendNUIMessage({job = "sweepergame"})

                                            gameFinish = function(ok)
                                                TriggerEvent("vrp-hud:updateMap", true)
                                                TriggerEvent("vrp-hud:setComponentDisplay", {
                                                    serverHud = true,
                                                    minimapHud = true,
                                                    bottomRightHud = true,
                                                    chat = true,
                                                })
                                                gameResult:resolve(true)
                                            end
                                        else
                                            gameResult:resolve(false)
                                        end
                                    else
                                        gameResult:resolve(true)
                                    end

                                    if Citizen.Await(gameResult) then
                                        if theJob.nextstop + 1 <= #cfg.slots[theJob.slot] then
                                            theJob.nextstop = theJob.nextstop + 1
                                            TriggerServerEvent("jobs:updateLastJob", theJob)

                                            if game then
                                                vRP.subtitle("Ai curatat aici, mergi la ~HC_10~urmatorul loc~w~.", 2)
                                            end

                                            ongoing = false
                                        else
                                            triggerCallback("getPaid", function()
                                                theJob = {}
                                                TriggerServerEvent("jobs:updateLastJob", false)
                                                vRP.subtitle("~HC_10~Minunat! ~w~Ai curatat peste tot, asteapta urmatoarea ruta.")
                                            end, cpData)
                                        end
                                        
                                        break
                                    end      
                                end
                            end

                            if nx and ny then
                                local ndist = #(sweeperPos.xy - vec2(nx, ny))

                                if ndist <= 150 then
                                    DrawMarker(1, nx, ny, nz-1.0, 0, 0, 0, 0, 0, 0, 8.0, 8.0, 65.0, 175, 237, 174, 150)
                                end
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
    if job == "Curatator de strazi" then
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
