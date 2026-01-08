
local startingPos = vector3(-848.66363525391,-799.65399169922,19.383190155029)

local cfg = {
    slots = {
        {
            {-821.79718017578,-788.76831054688,18.556669235229,270,"prop_woodpile_02a"},
            {-828.49426269531,-797.38818359375,18.556673049927,275,"prop_pooltable_02"},
            {-821.36590576172,-807.95037841797,18.529392242432,270,"prop_skid_pillar_01"},
            {-829.00952148438,-787.04180908203,18.556669235229,5,"prop_ld_balcfnc_02b"},
            {-842.38854980469,-789.79614257812,18.5631275177,90,"prop_fncwood_01c"},
        },
        {
            {1400.9260253906,-750.49084472656,66.13112487793,80,"prop_const_fence01a"},
            {1401.6405029297,-746.50323486328,66.13112487793,80,"prop_const_fence01a"},
            {1402.7344970703,-752.66638183594,66.13112487793,170,"prop_const_fence01a"},
            {1412.6885986328,-752.63775634766,66.23112487793,0,"prop_doghouse_01"},
            {1413.9721679688,-744.75207519531,66.23112487793,360,"prop_table_02_chr"},
            {1413.7144775391,-746.5537109375,66.23112487793,170,"prop_table_para_comb_04"},
            {1413.4144287109,-748.64147949219,66.23112487793,170,"prop_table_02_chr"},
        },
        {
            {-459.68014526367,-998.79614257812,22.887395858765,90,"prop_shuttering03"},
            {-453.03308105469,-998.85888671875,22.887395858765,90,"prop_shuttering03"},
            {-473.41256713867,-1007.201965332,22.54553604126,70,"prop_woodpile_02a"},
            {-446.93350219727,-975.78021240234,24.89811706543,180,"prop_skid_pillar_01"},
            {-451.34628295898,-971.29284667969,24.903675079346,90,"prop_skid_pillar_01"},
            {-442.25677490234,-988.95593261719,22.856884002686,279,"prop_portaloo_01a"},
            {-441.99285888672,-991.466796875,22.865697860718,270,"prop_portaloo_01a"}
        }
    },
    takeObjPos = {
        { -- slot 1
            {-817.7158203125,-788.64398193359,19.556703567505}, -- prop_woodpile_02a
            {-828.74145507812,-795.91979980469,19.556669235229}, -- prop_pooltable_02
            {-824.43402099609,-803.24896240234,19.584390640259}, -- prop_skid_pillar_01
            {-828.89923095703,-788.36834716797,19.556667327881}, -- prop_ld_balcfnc_02b
            {-841.10070800781,-789.68225097656,19.56308555603}, -- prop_fncwood_01c
        },
        { -- slot 2
            {1404.8599853516,-750.13293457031,67.181350708008}, -- prop_const_fence01a
            {1404.8599853516,-750.13293457031,67.181350708008}, -- prop_const_fence01a
            {1404.8599853516,-750.13293457031,67.181350708008}, -- prop_const_fence01a
            {1413.0848388672,-750.87811279297,67.231224060059}, -- prop_doghouse_01
            {1410.4006347656,-744.69036865234,67.230941772461}, -- prop_table_02_chr
            {1410.4006347656,-744.69036865234,67.230941772461}, -- prop_table_para_comb_04
            {1410.4006347656,-744.69036865234,67.230941772461}, -- prop_table_02_chr
        },
        { -- slot 3
            {-464.40426635742,-1002.0283813477,23.717430114746}, -- prop_shuttering03
            {-453.15509033203,-1004.6870727539,23.896766662598}, -- prop_shuttering03
            {-469.2428894043,-1007.8524780273,23.54524230957}, -- prop_woodpile_02a
            {-451.54022216797,-971.69134521484,25.903739929199}, -- prop_skid_pillar_01
            {-447.23754882812,-973.98376464844,25.898120880127}, -- prop_skid_pillar_01
            {-443.37466430664,-986.37591552734,23.822025299072}, -- prop_portaloo_01a
            {-443.36782836914,-994.16125488281,23.815649032593}, -- prop_portaloo_01a
        }
    }
}

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 801)
    SetBlipColour(blip, 9)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Constructor")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("ConstructorStarter", {
        position = startingPos,
        rotation = 90,
        model = "s_m_y_construct_02",
        freeze = true,
        minDist = 2.5,        
        name = "Bob Constructorul",
        ["function"] = function()
            SendNUIMessage({job = "constructor", group = inJob})
        end
    })

    table.insert(allJobPeds, "ConstructorStarter")

end)


local blips, objs = {}, {}

RegisterNetEvent("work-builder:startJob", function(cpData)
    if inJob == "Constructor" then
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
                propid = 1,
            }
        end
        vRP.subtitle("Ai primit o ~o~lucrare~w~ noua, vezi harta pentru locatie.")
        TriggerServerEvent("jobs:updateLastJob", theJob)

        local function isCorrectToBuild(dst, heading)
            local x, y, z, h = table.unpack(cfg.slots[theJob.slot][theJob.propid] or {})
            local diff = math.abs((heading - h + 180) % 360 - 180)
            local cdiff = math.abs((h - heading + 180) % 360 - 180)

            local angle = 180.0
            if dst <= 2 and (diff <= 2 or (cdiff > angle - 3.0 and cdiff < angle + 3.0)) then
                return true
            end
            return false
        end
        
        Citizen.CreateThread(function()
            local inputActive = false
            local obj, buildObj = false

            local function spawnPreviewObject(x, y, z, h, model)
                local objHash = GetHashKey(model)
                
                RequestModel(objHash)
                while not HasModelLoaded(objHash) do
                  Citizen.Wait(100)
                end
                
                if DoesEntityExist(obj) then
                  DeleteEntity(obj)
                end
          
                obj = CreateObject(objHash, x, y, z, false, true, false)
                SetEntityHeading(obj, tonumber(h) + 0.0)
                SetEntityAlpha(obj, 200)
                SetEntityCollision(obj, false, false)
                FreezeEntityPosition(obj, true)
                table.insert(objs, obj)

                if not blips.location then
                    local blip = AddBlipForCoord(x, y, z)
                    SetBlipSprite(blip, 1)
                    SetBlipScale(blip, 0.6)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Lucrare")
                    EndTextCommandSetBlipName(blip)

                    blips.location = blip
                end
                local blip = blips.location
                SetBlipColour(blip, 44)
                SetBlipCoords(blip, x, y, z)
                SetBlipRoute(blip, true)
                SetBlipRouteColour(blip, GetBlipColour(blip))
            end

            local tookObject = false

            while jobActive do

                local ped = PlayerPedId()
                local pedPos = GetEntityCoords(ped)
                
                if theJob.slot then
                    local propConfig = cfg.slots[theJob.slot][theJob.propid]
                    
                    if not obj or not DoesEntityExist(obj) then
                        local x, y, z, h, model = table.unpack(propConfig)
                        spawnPreviewObject(x, y, z, h, model)
                    end

                    local vpos = vector3(propConfig[1], propConfig[2], propConfig[3])
                    
                    while DoesEntityExist(obj) and jobActive do
                        
                        local myDst = #(pedPos - vpos)

                        if myDst <= 10 and not tookObject then
                            local pos = vec3(table.unpack(cfg.takeObjPos[theJob.slot][theJob.propid]))
                            DrawMarker(21, pos, 0, 0, 0, 0, 0, 0, 0.45, 0.45, 0.45, 235, 134, 31, 200, true, true)

                            if #(pedPos - pos) <= 2 then
                                if not inputActive then
                                    inputActive = true
                                    TriggerEvent("vrp-hud:showBind", {key = "E", text = "Incepe sa construiesti"})
                                end

                                if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), true) then
                                    tookObject = true
                                    inputActive = false
                                    TriggerEvent("vrp-hud:showBind", false)

                                    exports["vrp_jobs"]:setBoxAnim(true, false)

                                    Citizen.CreateThread(function()
                                        
                                        TriggerEvent("vrp-hud:updateMap", false)
                                        TriggerEvent("vrp-hud:setComponentDisplay", {
                                            serverHud = false,
                                            minimapHud = false,
                                            chat = false,
                                        })
                                        TriggerEvent("vrp-hud:showBind", {key = "⬆", text = "Muta obiectul in sus"})
                                        TriggerEvent("vrp-hud:showBind", {key = "⬇", text = "Muta obiectul in jos"})
                                        TriggerEvent("vrp-hud:showBind", {key = "⬅", text = "Creste rotatia"})
                                        TriggerEvent("vrp-hud:showBind", {key = "➡", text = "Scade rotatia"})
                                        TriggerEvent("vrp-hud:showBind", {key = "ENTER", text = "Construieste"})

                                        Citizen.CreateThread(function()

                                            local objHash = GetHashKey(propConfig[5])
                                            local tempPos = GetEntityCoords(PlayerPedId()) + vector3(1.0, 1.0, 1.0)

                                            local heading = 0.0

                                            local function spawnObject()

                                                RequestModel(objHash)
                                                while not HasModelLoaded(objHash) do
                                                    Citizen.Wait(100)
                                                end
                                                
                                                if DoesEntityExist(buildObj) then
                                                    DeleteEntity(buildObj)
                                                end

                                                buildObj = CreateObject(objHash, tempPos, false, true, false)
                                                SetEntityHeading(buildObj, heading)
                                                SetEntityAlpha(buildObj, 225)
                                                SetEntityCollision(buildObj, false, false)
                                                FreezeEntityPosition(buildObj, true)
                                                PlaceObjectOnGroundProperly(buildObj)
                                            end
                                            spawnObject()

                                            local addPos = 0.0

                                            while jobActive do
                                                
                                                local hit, coords, entity = RayCastGameplayCamera(15.0)
                                                tempPos = coords
                                            
                                                if not DoesEntityExist(buildObj) then
                                                    spawnObject()
                                                end

                                                if hit then
                                                    SetEntityCoords(buildObj, coords.x, coords.y, coords.z + addPos)
                                                end

                                                
                                                -- DrawMarker(28, coords + vec3(0.0, 0.0, 1.0), 0, 0, 0, 0, 0, 0, 0.040, 0.040, 0.040, 246, 255, 139, 255)

                                                if IsControlPressed(0, 174) then
                                                    heading = heading + 0.25
                                                    if heading > 360 then
                                                        heading = 0.0
                                                    end
                                                end

                                                if IsControlPressed(0, 175) then
                                                    heading = heading - 0.25
                                                    if heading < 0 then
                                                        heading = 360.0
                                                    end
                                                end

                                                if IsControlPressed(0, 172) then
                                                    addPos = addPos + 0.025
                                                end

                                                if IsControlPressed(0, 173) then
                                                    addPos = addPos - 0.025
                                                    if addPos < 0 then
                                                        addPos = 0.0
                                                    end
                                                end

                                                SetEntityHeading(buildObj, heading)

                                                if IsControlJustReleased(0, 215) and not IsPedInAnyVehicle(PlayerPedId()) then
                                                    local dst = #(GetEntityCoords(buildObj) - vpos)
                                                    if isCorrectToBuild(dst, heading) then
                                                        SetEntityAlpha(buildObj, 255)
                                                        SetEntityCollision(buildObj, true, true)
                                                        table.insert(objs, buildObj)
                                                        DeleteEntity(obj)
                                                        exports["vrp_jobs"]:setBoxAnim(false)
                                                        tookObject = false
                                                        SetEntityCoords(buildObj, vpos)
                                                        buildObj = false

                                                        if theJob.propid + 1 <= #cfg.slots[theJob.slot] then
                                                            theJob.propid = theJob.propid + 1
                                                            TriggerServerEvent("jobs:updateLastJob", theJob)
                                                            vRP.subtitle("Ai terminat de construit aici, mergi la ~o~urmatorul obiect~w~.", 2)
                                                        else
                                                            triggerCallback("getPaid", function()
                                                                theJob = {}
                                                                TriggerServerEvent("jobs:updateLastJob", false)
                                                                vRP.subtitle("~o~Minunat! ~w~Ai terminat de construit, asteapta urmatoarea lucrare.")
                                                            end, cpData)
                                                        end
                                                        break
                                                    else
                                                        vRP.subtitle("Pozitionarea obiectului este ~r~incorecta~w~, incearca din nou.", 1)
                                                    end    
                                                end

                                                Citizen.Wait(1)
                                            end

                                            TriggerEvent("vrp-hud:showBind", false)

                                            TriggerEvent("vrp-hud:updateMap", true)
                                            TriggerEvent("vrp-hud:setComponentDisplay", {
                                                serverHud = true,
                                                minimapHud = true,
                                                chat = true,
                                            })

                                        end)
                                    end)
                                end
                            elseif inputActive then
                                TriggerEvent("vrp-hud:showBind", false)
                                inputActive = false
                            end
                        end

                        if #(vpos - pedPos) <= 35 then
                            SetEntityDrawOutline(obj, true)
                            local r, g, b = 243, 64, 64
                            local dst = #(GetEntityCoords(buildObj) - vpos)
                            if isCorrectToBuild(dst, GetEntityHeading(buildObj)) then
                                r, g, b = 88, 146, 88
                            end
                            SetEntityDrawOutlineColor(r, g, b, 200)
                            SetEntityDrawOutlineShader(1)
                        else
                            SetEntityDrawOutline(obj, false)
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
    if job == "Constructor" then
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
