
local startingPos = vector3(442.86358642578,-628.36840820313,28.520700454712)

local cfg = {
    slots = {
        {
            {383.95178222656,-672.38928222656,28.626749038696,false},
            {308.06579589844,-769.2431640625,29.066480636597,true},
            {287.00546264648,-830.29132080078,28.991416931152,false},
            {202.1471862793,-823.34020996094,30.704166412354,false},
            {113.4388885498,-785.51971435547,31.145357131958,true},
            {59.819953918457,-771.97436523438,31.484436035156,false},
            {-91.658843994141,-712.63726806641,34.44185256958,false},
            {-59.426189422607,-570.55346679688,37.812110900879,false},
            {22.663593292236,-301.19915771484,46.994316101074,false},
            {-80.19522857666,-229.77349853516,44.571811676025,false},
            {-441.47723388672,-234.74183654785,35.826961517334,false},
            {-525.16973876953,-267.99383544922,35.046741485596,true},
            {-547.31787109375,-281.63656616211,34.929985046387,false},
            {-611.22149658203,-330.6091003418,34.601104736328,false},
            {-638.93035888672,-456.86349487305,34.570571899414,false},
            {-645.62585449219,-635.37078857422,31.698083877563,false},
            {-836.86456298828,-652.62054443359,27.643659591675,false},
            {-862.25762939453,-811.14093017578,19.078044891357,false},
            {-863.73980712891,-915.04229736328,15.269940376282,false},
            {-1055.7791748047,-774.55969238281,19.029218673706,false},
            {-882.73071289062,-665.12030029297,27.583999633789,false},
            {-661.72601318359,-667.23522949219,31.271213531494,false},
            {-287.46987915039,-667.232421875,32.960025787354,false},
            {9.1686506271362,-769.92706298828,31.494298934937,false},
            {146.09078979492,-819.81622314453,30.874410629272,false},
            {259.45211791992,-861.46954345703,29.056600570679,false},
            {260.91229248047,-930.73577880859,29.004741668701,false},
            {384.62881469727,-957.09716796875,29.136329650879,false},
            {395.70651245117,-1020.7994995117,29.141189575195,false},
            {253.41429138184,-1037.5472412109,29.009700775146,false},
            {259.74780273438,-967.86486816406,28.993034362793,false},
            {382.14178466797,-679.44781494141,28.994184494019,false},
            {471.14730834961,-581.6025390625,28.262229919434,false},
        },
        {
            {384.17993164062,-671.4033203125,28.974313735962,false},
            {305.66128540039,-767.892578125,28.96350479126,true},
            {255.65493774414,-929.77484130859,29.008729934692,false},
            {357.61987304688,-1063.6678466797,29.140043258667,true},
            {758.80633544922,-1008.9643554688,26.07061958313,false},
            {785.38818359375,-774.30285644531,26.125171661377,true},
            {909.14233398438,-820.15600585938,43.207050323486,false},
            {810.46252441406,-1083.3630371094,28.322309494019,false},
            {788.67242431641,-1371.0026855469,26.327402114868,true},
            {825.58850097656,-1640.9599609375,29.929622650146,true},
            {825.89965820312,-1725.6511230469,29.059896469116,false},
            {880.83404541016,-1766.9327392578,29.63178062439,true},
            {947.82757568359,-1868.8112792969,30.944728851318,false},
            {931.14483642578,-2060.3251953125,30.225858688354,false},
            {806.39788818359,-2058.3728027344,29.092140197754,false},
            {498.89181518555,-2047.6037597656,25.853607177734,false},
            {376.90856933594,-2154.94140625,15.157504081726,false},
            {177.67059326172,-2035.9572753906,18.043533325195,false},
            {269.87210083008,-1887.7775878906,26.526487350464,false},
            {362.3508605957,-1781.6437988281,28.784252166748,true},
            {457.90020751953,-1657.8531494141,29.101572036743,false},
            {457.90020751953,-1657.8531494141,29.101572036743,false},
            {187.73849487305,-1581.359375,29.03950881958,false},
            {75.599258422852,-1646.4627685547,29.042175292969,false},
            {2.8996891975403,-1615.4929199219,29.029308319092,false},
            {51.877277374268,-1534.4306640625,28.963457107544,true},
            {135.40718078613,-1414.5092773438,29.087251663208,false},
            {73.38166809082,-1364.4392089844,29.170404434204,false},
            {-209.98735046387,-1412.8438720703,31.022832870483,false},
            {-270.01574707031,-1163.5014648438,22.845315933228,false},
            {-200.85229492188,-915.87957763672,29.110847473145,false},
            {-270.58541870117,-821.53021240234,31.531391143799,false},
            {-227.09411621094,-700.11126708984,33.280132293701,false},
            {-149.23941040039,-714.47387695312,34.508083343506,false},
            {-59.448307037354,-570.25390625,37.855682373047,false},
            {80.69059753418,-562.71746826172,31.672183990479,false},
            {331.20361328125,-661.35681152344,29.036378860474,false},
            {454.40795898438,-679.98022460938,27.675146102905,false},
            {471.14730834961,-581.6025390625,28.262229919434,false},
        }
    },
}

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 513)
    SetBlipColour(blip, 42)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Sofer de autobuz")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("BusdriverStarter", {
        position = startingPos,
        rotation = 85,
        model = "cs_andreas",
        freeze = true,
        minDist = 2.5,
        name = "Mihai Soferul",
        ["function"] = function()
            SendNUIMessage({job = "busdriver", group = inJob})
        end
    })

    table.insert(allJobPeds, "BusdriverStarter")

end)

local spawnPoints = {
    {461.88647460938,-604.23504638672,28.499870300293},
    {460.90747070312,-611.00115966797,28.4997215271},
    {460.58682250977,-618.67462158203,28.499755859375},
    {459.89443969727,-625.63360595703,28.499780654907},
    {459.28652954102,-633.25457763672,28.499788284302},
    {458.39910888672,-640.00073242188,28.49979019165},
    {457.66687011719,-646.79254150391,28.260066986084}
}


local gameFinish
RegisterNUICallback("busdriver:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

local bus
RegisterNetEvent("work-busdriver:startJob", function(cpData)
    if inJob == "Sofer de autobuz" then
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
                vehpos = spawnPoints[math.random(1, #spawnPoints)],
            }
        end

        vRP.subtitle("Ai primit o noua ~b~cursa ~w~si pasagerii te asteapta, vezi harta pentru locatie.")
        if DoesEntityExist(bus) then
            local x, y, z = table.unpack(GetEntityCoords(bus))
            theJob.vehpos, theJob.vehrot = {x, y, z}, GetEntityHeading(bus)
        end

        TriggerServerEvent("jobs:updateLastJob", theJob)

        Citizen.CreateThread(function()
            local vehBlip

            while jobActive and not DoesEntityExist(bus) do
                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)

                local vpos = vector3(table.unpack(theJob.vehpos))

                if not vehBlip then
                    vehBlip = AddBlipForCoord(vpos)
                    SetBlipSprite(vehBlip, 326)
                    SetBlipColour(vehBlip, 3)
                    SetBlipScale(vehBlip, 0.5)
                    SetBlipAsShortRange(vehBlip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Autobuzul tau")
                    EndTextCommandSetBlipName(vehBlip)

                    table.insert(blips, vehBlip)
                end

                if #(pedPos - vpos) <= 15 then
                    if not theJob.vehrot then
                        theJob.vehrot = 220.0
                    end
                    
                    getVehicleObject({pos = theJob.vehpos, h = theJob.vehrot, hash = `tourbus`, setinveh = true}, function(nveh)
                        bus = nveh

                        RemoveBlip(vehBlip)

                        local blip = AddBlipForEntity(bus)
                        SetBlipSprite(blip, 326)
                        SetBlipColour(blip, 3)
                        SetBlipScale(blip, 0.6)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString("Vehiculul firmei")
                        EndTextCommandSetBlipName(blip)

                        table.insert(blips, blip)

                        TriggerServerEvent("jobs:setBusObj", NetworkGetNetworkIdFromEntity(bus))
                    end)

                    Citizen.Wait(1000)

                    break
                end

                Citizen.Wait(1000)
            end
            RemoveBlip(nblip)
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
                    AddTextComponentString("Oprire cu autobuzul")
                    EndTextCommandSetBlipName(smallCp)
                    table.insert(blips, smallCp)
                end
            end

            while jobActive do
                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                if theJob.slot then                    
                    local ongoing = false

                    while jobActive and DoesEntityExist(bus) and theJob.slot do
                        local busPos = GetEntityCoords(bus)

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

                            local dist = #(busPos.xy - vec2(x, y))
                            if dist <= 80 then
                                DrawMarker(1, x, y, z-1.0, 0, 0, 0, 0, 0, 0, 8.0, 8.0, 65.0, 175, 237, 174, 150)

                                if dist <= 3.5 then
                                    local gameResult = promise.new()
                                    
                                    if game then
                                        local enterdPoint = false;

                                        if not enterdPoint then
                                            FreezeEntityPosition(bus, true)
                                            enterdPoint = true;

                                            TriggerEvent("vrp-hud:updateMap", false)
                                            TriggerEvent("vrp-hud:setComponentDisplay", {
                                                serverHud = false,
                                                minimapHud = false,
                                                bottomRightHud = false,
                                                chat = false,
                                            })

                                            SendNUIMessage({job = "busGame"})

                                            gameFinish = function(ok)
                                                if not ok then
                                                    gameResult:resolve(false)
                                                    enterdPoint = false;
                                                    return
                                                end

                                                TriggerEvent("vrp-hud:updateMap", true)
                                                TriggerEvent("vrp-hud:setComponentDisplay", {
                                                    serverHud = true,
                                                    minimapHud = true,
                                                    bottomRightHud = true,
                                                    chat = true,
                                                })

                                                enterdPoint = false;
                                                gameResult:resolve(true)
                                            end

                                            FreezeEntityPosition(bus, false)
                                        end
                                    else
                                        gameResult:resolve(true)
                                    end

                                    if Citizen.Await(gameResult) then
                                        if theJob.nextstop + 1 <= #cfg.slots[theJob.slot] then
                                            theJob.nextstop = theJob.nextstop + 1
                                            TriggerServerEvent("jobs:updateLastJob", theJob)
                                            if game then
                                                vRP.subtitle("Toti pasagerii au urcat, mergi la ~b~urmatoarea statie~w~.", 2)
                                            end
                                        else
                                            triggerCallback("getPaid", function()
                                                theJob = {}
                                                TriggerServerEvent("jobs:updateLastJob", false)
                                                vRP.subtitle("~b~Minunat! ~w~Ai transportat toti pasagerii, asteapta urmatoarea ruta.")
                                            end, cpData)
                                        end

                                        local x, y, z, game = table.unpack(cfg.slots[theJob.slot][theJob.nextstop] or {})
                                        if x and y and z then
                                            setNextCheckpoint(vector3(x, y, z))
                                        end
                                        
                                        local nx, ny, nz, ngame = table.unpack(cfg.slots[theJob.slot][theJob.nextstop + 1] or {})
                                        if nx and ny and nz then
                                            setNextCheckpoint(vector3(nx, ny, nz))
                                        end
                                    end      
                                end
                            end

                            if nx and ny then
                                local ndist = #(busPos.xy - vec2(nx, ny))

                                if ndist <= 150 then
                                    DrawMarker(1, nx, ny, nz-1.0, 0, 0, 0, 0, 0, 0, 8.0, 8.0, 65.0, 251, 238, 165, 125)
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
    if job == "Sofer de autobuz" then
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

