
local outTruck = {}
local truckLoad = {}

local assignedToStore = {}

local deliveryPoints = {
    {369.29016113281,338.25021362305,103.26509857178}, -- 1 
    {-1225.3659667969,-897.95587158203,12.393788337708}, -- 2
    {-2961.8840332031,369.94876098633,14.771399497986}, -- 3 
    {-3252.8720703125,987.94799804688,12.450061798096}, -- 4
    {1717.3729248047,6416.4814453125,33.424499511719}, -- 5
    {1688.2346191406,4913.1977539063,42.078151702881}, -- 6 
    {1962.3944091797,3755.1962890625,32.243103027344}, -- 7
    {2682.4702148438,3293.9040527344,55.24068069458}, -- 8
    {1153.6990966797,-332.74505615234,68.758361816406}, -- 9
    {-44.298030853271,-1741.1284179688,29.153104782104}, -- 10
    {-1462.8759765625,-372.03665161133,39.299655914307}, -- 11
    {-724.00476074219,-913.03802490234,19.01392364502}, -- 12
    {540.49371337891,2658.72265625,42.228118896484}, -- 13
    {1410.6964111328,3619.8618164063,34.894443511963}, -- 14
    {1117.8586425781,-984.55480957031,46.292625427246}, -- 15
    {31.071229934692,-1314.1639404297,29.523321151733}, -- 16
    {2555.4470214844,406.15258789063,108.4535446167}, -- 17
    {-1824.1516113281,779.73559570313,137.85501098633}, -- 18
    {1161.3020019531,2695.3403320313,37.925876617432}, -- 19
    {1189.4449462891,-3105.6052246094,5.6651039123535}, -- 20
    {-3050.6306152344,592.83856201172,7.5616374015808}, -- 21
    {-1003.313659668,-2844.4938964844,13.947402000427}, -- 22
    {-170.50810241699,6309.9321289063,31.200551986694}, -- 23
    {181.4634552002,6633.1396484375,31.566083908081}, -- 24
    {-565.31341552734,301.39596557617,83.124839782715}, -- 25
    {-353.78353881836,215.58480834961,86.606063842773}, -- 26
    {85.944389343262,-1285.1953125,29.254451751709}, -- 27
    {2002.7342529297,3038.333984375,47.214946746826}, -- 28
    {361.97418212891,293.58685302734,103.49806976318}, -- 29
    {1189.5119628906,-3105.1584472656,5.6964302062988}, -- 30
    {-817.48052978516,-727.59002685547,23.779056549072}, -- 31
    {-605.83154296875,-1059.64453125,21.787498474121}, -- 32
    {434.31600952148,-1513.4475097656,29.287366867065}, -- 33
    {8.0156497955322,-1836.3444824219,24.765073776245}, -- 34
    {-513.14825439453,-596.02667236328,30.29833984375}, -- 35
    {-266.51571655273,-2081.3974609375,27.620628356934}, -- 36
    {1579.6885986328,6449.8095703125,25.043088912964}, -- 37
    {724.63104248047,-757.64428710938,25.351375579834}, -- 38
    {-1808.5416259766,-1227.6684570313,13.017274856567}, -- 39
    {415.60864257813,-787.32287597656,29.345500946045}, -- 40
    {70.426582336426,-1427.3441162109,29.311668395996}, -- 41
    {141.64616394043,-244.18249511719,51.51411819458}, -- 42
    {-221.98748779297,-272.75180053711,48.984268188477}, -- 43
    {-1194.5419921875,-731.76568603516,20.832500457764}, -- 44
    {-700.04455566406,-141.65258789063,37.676094055176}, -- 45
    {-1443.7648925781,-258.89846801758,46.207786560059}, -- 46
    {-834.85858154297,-1068.9388427734,11.263131141663}, -- 47
    {1190.45703125,2726.8383789063,38.004650115967}, -- 48
    {20.120676040649,6510.1469726563,31.492172241211}, -- 49
    {-3180.3149414063,1027.3153076172,20.818542480469}, -- 50
    {-1132.0322265625,2698.2072753906,18.800397872925}, -- 51
    {340.76422119141,-561.94982910156,28.743741989136}, -- 52
    {-260.60580444336,-2075.7316894531,27.620620727539}, -- 53
    {-1007.079284668,-2851.7512207031,13.948402404785}, -- 54
}


RegisterServerEvent("jobs:setMarketTruckObj", function(netid)
    local player = source
    local user_id = vRP.getUserId(player)
    
    local vehicle = NetworkGetEntityFromNetworkId(netid)

    Citizen.Wait(100)

    if DoesEntityExist(vehicle) then
        outTruck[user_id] = vehicle
    end
end)

RegisterServerEvent("jobs:deleteMarketTruck", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if outTruck[user_id] then
        DeleteEntity(outTruck[user_id])
        outTruck[user_id] = nil
    end

    truckLoad[user_id] = nil

    if assignedToStore[user_id] then
        exports.vrp:setMarketProvider(assignedToStore[user_id], nil)
        assignedToStore[user_id] = nil
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if outTruck[user_id] then
        if DoesEntityExist(outTruck[user_id]) then
            DeleteEntity(outTruck[user_id])
        end

        outTruck[user_id] = nil
    end

    truckLoad[user_id] = nil

    if assignedToStore[user_id] then
        exports.vrp:setMarketProvider(assignedToStore[user_id], nil)
        assignedToStore[user_id] = nil
    end
end)

AddEventHandler("jobs:onPlayerFired", function(user_id)
    if outTruck[user_id] then
        if DoesEntityExist(outTruck[user_id]) then
            DeleteEntity(outTruck[user_id])
        end
        
        outTruck[user_id] = nil
    end

    truckLoad[user_id] = nil

    if assignedToStore[user_id] then
        exports.vrp:setMarketProvider(assignedToStore[user_id], nil)
        assignedToStore[user_id] = nil
    end
end)

RegisterServerEvent("work-provider:getBox", function()
    local player = source
    local user_id = vRP.getUserId(player)

    truckLoad[user_id] = (truckLoad[user_id] or 0) + 1
end)

RegisterServerEvent("work-provider:workForMarket", function(bizId)
    local player = source
    local user_id = vRP.getUserId(player)
    local market = exports["vrp"]:getMarketData(bizId)

    if exports["vrp_jobs"]:hasJob(user_id, "Furnizor de stocuri") then
        if not outTruck[user_id] then
            vRPclient.notify(player, {"Ai nevoie de o duba pentru a lucra ca furnizor.", "error"})
            return
        end

        if market then

            if market.worker then
                vRPclient.notify(player, {"Cursa este indisponibila.", "error"})
                return
            end

            exports.vrp:setMarketProvider(bizId, user_id)
            assignedToStore[user_id] = bizId
            TriggerClientEvent("work-provider:startRoute", player, bizId, exports["vrp"]:getMarketLoad(bizId), deliveryPoints[bizId])
        end
    end
end)

RegisterServerEvent("work-provider:loadMarket", function()
    local player = source
    local user_id = vRP.getUserId(player)

    if exports["vrp_jobs"]:hasJob(user_id, "Furnizor de stocuri") then
        if assignedToStore[user_id] then
            local bizId = assignedToStore[user_id]
            local market = exports["vrp"]:getMarketOrder(bizId)

            if bizId and market then
                
                if not market.worker or (not market.worker == user_id) then return end

                local need = market.load * 2 -- market + warehouse
                

                if (truckLoad[user_id] or 0) < need then
                    vRPclient.notify(player, {"Nu ai incarcat destula marfa.", "error"})
                
                else

                    vRP.giveJobMoney(user_id, market.reward, "Furnizor de stocuri")
                    exports.vrp:setMarketProvider(bizId, nil)

                    exports.vrp:restockMarket(bizId)

                end

                assignedToStore[user_id] = nil
                truckLoad[user_id] = nil

            end
        end
    end
end)
