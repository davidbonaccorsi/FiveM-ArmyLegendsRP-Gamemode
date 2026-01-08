
local startingPos <const> = vector3(554.37707519531,2788.0952148438,38.195045471191)

local searchPos, searchRadius = vector3(3242.2421875,-662.01153564453,-142.24685668945), 200.0

local spawnPositions <const> = {
    {3471.88, -670.24, -125.89},
    {3384.94, -649.58, -107.65},
    {3273.78, -703.87, -150.69},
    {3328.33, -784.66, -139.01},
    {3315.93, -804.73, -141.23},
    {3348.0, -807.95, -134.09},
    {3382.09, -763.01, -107.21},
    {3361.87, -755.7, -111.05},
    {3323.38, -681.91, -102.89},
    {3350.54, -662.53, -100.61},
    {3319.74, -615.67, -129.41},
    {3315.52, -573.23, -118.31},
    {3307.13, -542.37, -111.11},
    {3300.83, -513.46, -107.21},
    {3299.3, -489.98, -110.09},
    {3270.94, -489.09, -76.43},
    {3209.37, -513.48, -101.81},
    {3213.04, -532.8, -106.91},
    {3240.81, -551.57, -123.89},
    {3177.05, -579.61, -122.21},
    {3168.05, -603.09, -100.73},
    {3140.22, -659.04, -58.13},
    {3174.6, -678.34, -56.99},
    {3185.55, -730.31, -46.01},
    {3190.69, -715.16, -50.75},
    {3193.21, -744.9, -72.05},
    {3178.08, -799.34, -60.35},
    {3131.92, -803.69, -40.67},
    {3098.82, -737.67, -35.45},
    {3071.43, -689.54, -42.47},
    {3079.61, -627.41, -19.49},
    {3109.74, -575.7, -46.01},
    {3143.68, -616.03, -63.71},
    {3139.43, -563.51, -45.35},
    {3132.16, -548.23, -57.77},
    {3125.16, -519.97, -42.05},
    {3209.74, -484.11, -74.75},
    {3258.09, -507.83, -100.85},
    {3158.8, -507.98, -42.89},
    {3256.3, -824.34, -145.31},
    {3422.66, -705.79, -49.79},
    {3398.12, -731.76, -42.27},
    {3409.71, -572.78, -28.83},
    {3377.41, -554.41, -14.75},
    {3212.18, -473.71, -44.35},
    {3121.89, -715.52, -17.15},
    {3159.89, -798.59, -43.87},
    {3288.79, -845.99, -134.11},
    {3216.6, -624.12, -140.03},
    {3162.92, -663.47, -71.55},
    {3214.3, -807.62, -79.23},
    {3183.26, -821.29, -75.71},
    {3061.36, -669.45, -33.79},
    {3209.63, -778.65, -115.07},
    {3280.29, -531.87, -118.21},
    {3345.81, -672.87, -82.15},
    {3200.84, -684.37, -117.19},
    {3091.41, -667.07, -33.99},
    {3239.18, -562.03, -53.73},
    {3296.68, -607.3, -76.93},
    {3279.07, -733.0, -76.93},
    {3272.82, -761.93, -102.53},
    {3134.53, -733.97, -20.61},
    {3099.09, -737.44, -36.93},
    {3298.81, -477.54, -111.65},
    {3361.07, -518.53, -38.05},
    {3327.62, -594.53, -120.13},
    {3307.74, -758.34, -144.93},
}

local picked = {}

local rndObjects <const> = {
    "prop_drop_armscrate_01b",
    "prop_drop_armscrate_01",
    "prop_money_bag_01",
    "bkr_prop_fakeid_binbag_01",
}

local function isSamePosition(p1, p2)
    if (p1[1] == p2[1]) and (p1[2] == p2[2]) and (p1[3] == p2[3]) then
        return true
    end
    return false
end

local function pickRandomLoot()
    local function pickSpawn()
        local tries = 0

        ::retryPick::
        Citizen.Wait(1)
        tries = tries + 1
        
        local k = math.random(1, #spawnPositions)
        local pick = spawnPositions[k]

        if picked[k] then goto retryPick end


        if picked[k] and (tries <= #spawnPositions) then
            goto retryPick
        end

        if not picked[k] then
            picked[k] = true
            return pick
        end
    end

    local spawn = pickSpawn()
    if spawn then
        local object = rndObjects[math.random(1, #rndObjects)]

        return {position = spawn, object = object} -- {..., item = item}
    end
end


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

    local pedId = vRP.spawnNpc("ResearcherStarter", {
        position = startingPos,
        rotation = 325,
        model = "a_m_m_tourist_01",
        freeze = true,
        minDist = 2.5,
        name = "George Cercetatoru",

        buttons = {
            {
                text = "Informatii despre job", 
                response = function()
                    SendNUIMessage({job = "researcher", group = inJob})
                    
                    return {false, true}
                end
            },

            {
                text = "Cumpara Scuba Kit",
                response = function()
                    local reply = promise.new()
                    
                    triggerCallback("work-researcher:getScubaKit", function(success, message)
                        if message then
                            return reply:resolve(message)
                        end

                        reply:resolve("Ti-ai cumparat Scuba Kit, te mai pot ajuta cu altceva?")
                    end)

                    return Citizen.Await(reply)
                end
            }
        }
    })

    table.insert(allJobPeds, "ResearcherStarter")

end)


local gameFinish
RegisterNUICallback("researcher:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end
    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}


local jobActive = false

AddEventHandler("jobs:onJobSet", function(job)
    
    Citizen.Wait(500)

    jobActive = (inJob == "Cercetator maritim")

    if jobActive then
        local evt
        evt = AddEventHandler("jobs:onJustFired", function()
            Citizen.Wait(100)
                  
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
        
        Citizen.CreateThread(function()
            Citizen.Wait(1500)
            vRP.subtitle("Oceanul iti pregateste mereu ~HC_10~obiecte noi~w~, scufunda-te si gaseste-le.", 8)
        end)

        local blip = AddBlipForRadius(searchPos, searchRadius)
        SetBlipColour(blip, 6)
        -- SetBlipFlashes(blip, true)
        SetBlipAlpha(blip, 50)

        table.insert(blips, blip)

        local inOcean
        local wasInOcean = false

        local input = false

        local ped = PlayerPedId()
        local pedPos = GetEntityCoords(ped)

        while jobActive do
            inOcean = (#(searchPos - pedPos) <= searchRadius)

            if inOcean then
                TriggerServerEvent("work-researcher:enterOcean")
            end

            while inOcean do
                inOcean = (#(searchPos - pedPos) <= searchRadius)
                wasInOcean = true
                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)
                Citizen.Wait(1)
            end

            if wasInOcean then
                wasInOcean = false
                TriggerServerEvent("work-researcher:leaveOcean", false)
            end
            

            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)

            Citizen.Wait(1)
        end
    end
end)

AddEventHandler("jobs:setLastJob", function(job, lastJob)
    if job == "Cercetator marin" then
        theJob = lastJob
    end
end)

local growInterval = 60000 * 5 -- 60.000 * 5 = 5 min

AddEventHandler("jobs:onJobSet", function(job)
    
    Citizen.Wait(500)

    if inJob == "Cercetator maritim" then

        Citizen.CreateThread(function()
            local function drawArrow(coords, label)
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
                local icon_scale = 1.0
                local text_scale = 0.25
            
                RequestStreamedTextureDict("basejumping", false)
                DrawSprite("basejumping", "arrow_pointer", screenX, screenY - 0.015, 0.015 * icon_scale, 0.025 * icon_scale, 180.0, 71, 105, 173, 255)
            
                if label then
                    SetTextCentre(true)
                    SetTextScale(0.0, text_scale)
                    SetTextEntry("STRING")
                    AddTextComponentString(label)
                    DrawText(screenX, screenY)
                end
            end

            Citizen.CreateThread(function()
                if not theJob.loot then
                    theJob.loot = {}

                    for i = 1, 30 do
                        local pick = pickRandomLoot()
                        if pick then
                            table.insert(theJob.loot, pick)
                        end
                    end

                    picked = {}

                    TriggerServerEvent("jobs:updateLastJob", theJob)
                end

                Citizen.Wait(10000)
                

                for k, loot in pairs(theJob.loot or {}) do
                    local objHash = GetHashKey(loot.object)
                    RequestModel(objHash)
                    while not HasModelLoaded(objHash) do
                        Citizen.Wait(100)
                    end

                    local x, y, z = table.unpack(loot.position)

                    local prop = CreateObject(objHash, x, y, z, true, true, false)
                    FreezeEntityPosition(prop, true)
                    SetEntityCollision(prop, false, false)
                    
                    local objectBlip = AddBlipForEntity(prop)
                    SetBlipSprite(objectBlip, 271)
                    SetBlipColour(objectBlip, 1)
                    SetBlipScale(objectBlip, 0.4)
                    SetBlipAsShortRange(objectBlip, true)

                    table.insert(blips, objectBlip)

                    loot.prop = prop
                    table.insert(objs, prop) -- safe remove
                end
            end)
            
            local input = false
            while inJob == "Cercetator maritim" do
                local wtime = 500

                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                for k, loot in pairs(theJob.loot or {}) do
                    local x, y, z = table.unpack(loot.position)

                    local dst = #(pedPos - vec3(x, y, z))

                    if dst <= 15 then
                        local state = false

                        if dst <= 5 then
                            drawArrow(loot.position, "Obiect necunoscut")
                        end


                        while dst <= 1.0 and DoesEntityExist(loot.prop) do
                            drawArrow(loot.position, "Obiect necunoscut")

                            if not input then
                                input = true
                                TriggerEvent("vrp-hud:showBind", {key = "E", text = "Cauta dupa obiecte"})
                            end

                            if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                FreezeEntityPosition(ped, true)

                                TaskTurnPedToFaceEntity(ped, loot.prop, 1000)
                                -- SetEntityHeading(ped, GetEntityHeading(loot.prop))
                                Citizen.Wait(1000)

                                
                                RequestAnimDict("anim@amb@drug_field_workers@weeding@male_a@idles")
                                while not HasAnimDictLoaded("anim@amb@drug_field_workers@weeding@male_a@idles") do
                                    Citizen.Wait(1) 
                                end

                                TaskPlayAnim(ped, "anim@amb@drug_field_workers@weeding@male_a@idles","idle_b", 1.5, 1.0, 0.3, 48, 0.2, 0, 0, 0)

                                Citizen.Wait(3000)
                                triggerCallback("gatherOceanLoot", function(gathered)
                                    if gathered then
                                        local loot = theJob.loot[k]
                                        DeleteEntity(loot.prop)
                                        table.remove(theJob.loot, k)
                                        TriggerServerEvent("jobs:updateLastJob", theJob)
                                        TriggerEvent("vrp-hud:showBind", false)
                                        input = false
                                    end
                                    
                                    Citizen.Wait(2000)
                                        
                                    StopAnimTask(ped, "anim@amb@drug_field_workers@weeding@male_a@idles","idle_b", 1.5)
                                    FreezeEntityPosition(ped, false)
                                end, k)

                                break
                            end

                            ped = PlayerPedId()
                            pedPos = GetEntityCoords(ped)

                            dst = #(pedPos - vec3(x, y, z))
                            Citizen.Wait(1)
                        end
                        
                        if input then
                            TriggerEvent("vrp-hud:showBind", false)
                            input = false
                        end

                        wtime = 1
                    elseif input then
                        TriggerEvent("vrp-hud:showBind", false)
                        input = false
                    end
                end

                Citizen.Wait(wtime)
            end
        end)

        while inJob == "Cercetator maritim" do
            if theJob.loot and (#theJob.loot < 30) then
                local max = math.max(30 - #theJob.loot, 1)

                for i = 1, max do
                    local pick = pickRandomLoot()
                    if pick then
                        local objHash = GetHashKey(pick.object)
                        RequestModel(objHash)
                        while not HasModelLoaded(objHash) do
                            Citizen.Wait(100)
                        end

                        local x, y, z = table.unpack(pick.position)

                        local prop = CreateObject(objHash, x, y, z, true, true, false)
                        FreezeEntityPosition(prop, true)
                        SetEntityCollision(prop, false, false)

                        pick.prop = prop
                        table.insert(objs, prop) -- safe remove

                        table.insert(theJob.loot, pick)
                        TriggerServerEvent("jobs:updateLastJob", theJob)
                    end
                end

                picked = {}
            end

            Citizen.Wait(growInterval)
        end
    end
end)

local scuba, mask, tank = false
RegisterNetEvent("work-researcher:useScuba", function(tog)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    scuba = tog
    SetPedDiesInWater(ped, not scuba)

    if not scuba then
        DeleteEntity(tank)
        DeleteEntity(mask)
        mask, tank = nil
        return
    end
    
    mask = CreateObject(GetHashKey('p_s_scuba_mask_s'), coords[1], coords[2], coords[3], true, true, true)
    tank = CreateObject(GetHashKey('p_s_scuba_tank_s'), coords[1], coords[2], coords[3]+1.0, true, true, true)

    AttachEntityToEntity(tank, ped, GetPedBoneIndex(ped, 24818), -0.30, -0.22, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
    AttachEntityToEntity(mask, ped, GetPedBoneIndex(ped, 12844), 0.0, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)    
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
