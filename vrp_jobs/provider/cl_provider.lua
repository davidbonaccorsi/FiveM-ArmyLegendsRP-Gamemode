
local startingPos = vector3(845.64312744141,-902.80096435547,25.251472473145)

local garagePos = vector3(888.35632324219,-889.26599121094,26.662425994873)

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

local function DrawText3D(x,y,z, text, scl, font, colors) 

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(colors[1], colors[2], colors[3], 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

local theJob = {}

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(startingPos)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 36)
    SetBlipScale(blip, 0.5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Furnizor de stocuri")
    EndTextCommandSetBlipName(blip)

    local pedId = vRP.spawnNpc("ProviderStarter", {
        position = startingPos,
        rotation = 275,
        model = "s_m_m_ups_02",
        freeze = true,
        minDist = 2.5,
        name = "Andrei Furnizorul",
        ["function"] = function()
            SendNUIMessage({job = "provider", group = inJob})
        end
    })

    table.insert(allJobPeds, "ProviderStarter")

end)

local spawnPoints = {
    {854.23046875,-906.02416992188,25.342262268066,271.0},
    {854.2294921875,-902.57885742188,25.343305587769,271.0},
    {853.92694091797,-899.15252685547,25.336053848267,271.0},
    {853.86047363281,-895.78356933594,25.333713531494,271.0},
    {853.68566894531,-892.36169433594,25.327545166016,271.0},
    {853.71948242188,-888.90954589844,25.329519271851,271.0},
    {853.56707763672,-885.68591308594,25.325151443481,271.0}
}


local gameFinish
RegisterNUICallback("provider:gameDone", function(data, cb)
    if type(gameFinish) == "function" then
        gameFinish(data[1])
    end

    gameFinish = false
    
    cb("ok")
end)

local blips, objs = {}, {}

local jobActive
local truckObj

AddEventHandler("jobs:onJobSet", function(job)
    Citizen.Wait(500)
    jobActive = (inJob == "Furnizor de stocuri")

    if not jobActive then
        for k, object in pairs(objs) do
            DeleteEntity(object)
        end

        objs = {}

        if next(blips) then
            for k, blip in pairs(blips) do
                RemoveBlip(blip)
            end

            blips = {}
        end
        
        truckObj = nil
    else
        local blip = AddBlipForCoord(garagePos)
        SetBlipSprite(blip, 473)
        SetBlipColour(blip, 16)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garaj (Furnizor de stocuri)")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)
    end

    Citizen.CreateThread(function()
        while jobActive do
            local ped = PlayerPedId()
            local pedPos = GetEntityCoords(ped)

            local dst = #(pedPos - garagePos)
            
            while dst <= 10 and jobActive do
				DrawText3D(garagePos[1], garagePos[2], garagePos[3]-0.25, "Garaj Dube", 1.0, 0, {255, 255, 255})
				DrawMarker(1, garagePos[1], garagePos[2], garagePos[3]-1.1, 0, 0, 0, 0, 0, 0, 1.601, 1.601, 0.6001, 251, 238, 165, 200, 0, 0, 0, 1)

				if dst <= 1 then
					if truckObj and IsPedInVehicle(ped, truckObj, true) then
                        drawText("Apasa ~HC_16~ENTER~w~ pentru a parca duba !", 0.5, 0.85, 0.4, 255, 255, 255)
                        if IsControlJustPressed(0, 18) then
                            TriggerServerEvent("jobs:deleteMarketTruck")
                            truckObj = nil
                            break
                        end
                    elseif not truckObj then
                        drawText("Apasa ~HC_55~E~w~ pentru o duba !~n~Foloseste ~HC_ 55~telefonul~w~ pentru comenzi", 0.5, 0.85, 0.4, 255, 255, 255)

                        if IsControlJustPressed(0, 38) then
                            
                            local data = {
                                hash = GetHashKey("burrito3"),
                                pos = vector4(garagePos[1], garagePos[2], garagePos[3], 100.0),
                            }
    
                            local i = 0

                            RequestModel(data.hash)

                            while not HasModelLoaded(data.hash) and i < 1000 do
                                Citizen.Wait(10)
                                i = i + 1
                            end
    
                            if HasModelLoaded(data.hash) then
                                truckObj = CreateVehicle(data.hash, data.pos[1], data.pos[2], data.pos[3]+0.5, data.pos[4], true, false)
                                NetworkFadeInEntity(truckObj, 1)
                                SetVehicleFuelLevel(truckObj, 100.0)
                                SetVehicleOnGroundProperly(truckObj)
                                SetEntityInvincible(truckObj, false)
                                Citizen.InvokeNative(0xAD738C3085FE7E11, truckObj, true, true)
                                SetVehicleHasBeenOwnedByPlayer(truckObj, true)
                                
                                local ped = PlayerPedId()
                                SetPedIntoVehicle(ped, truckObj, -1)
    
                                local blip = AddBlipForEntity(truckObj)
                                SetBlipSprite(blip, 616)
                                SetBlipColour(blip, 45)
                                SetBlipScale(blip, 0.5)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("Vehicul furnizor")
                                EndTextCommandSetBlipName(blip)
    
                                TriggerServerEvent("jobs:setMarketTruckObj", NetworkGetNetworkIdFromEntity(truckObj))
    
                            end

                            break
                        end

                    end
				end
                
                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)

                dst = #(pedPos - garagePos)

                Citizen.Wait(1)
            end

            Citizen.Wait(500)
        end
    end)
end)


local depositPos = {1218.3657226562,-3231.6811523438,5.6074275970459}

RegisterNetEvent("work-provider:startRoute", function(bizId, load, finishPos)
    vRP.subtitle("Ai inceput sa furnizezi stocuri la ~HC_16~Magazin "..bizId.."~w~, mergi la depozit.")

    local x, y, z = table.unpack(depositPos)

    if not blips.deposit then
        local blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 1)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Depozit de stocuri")
        EndTextCommandSetBlipName(blip)

        blips.deposit = blip
    end

    local blip = blips.deposit
    SetBlipColour(blip, 31)
    SetBlipCoords(blip, x, y, z)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, GetBlipColour(blip))

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    Citizen.CreateThread(function()
        RequestAnimDict("anim@heists@box_carry@")

        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Citizen.Wait(1)
        end
        
        local dist = #(pedPos.xy - vec2(x, y))

        local inTruck, ongoing = 0
		local boxPos = vec3(1218.5183105469,-3236.8244628906,5.5853037834167)
        
        RequestModel("prop_cs_cardbox_01")

        while not HasModelLoaded("prop_cs_cardbox_01") do
            Citizen.Wait(1)
        end

        while jobActive and (inTruck < load) do

            if dist <= 40 then

                DrawMarker(43, x, y, z-1.0, 0, 0, 0, 0, 0, 0, 3.201, 3.201, 1.4001, 255, 194, 170, 100)

                if dist <= 3 then
                    drawText("Apasa ~HC_16~ENTER~w~ pentru a incarca marfa !", 0.5, 0.85, 0.4, 255, 255, 255)

                    if IsControlJustPressed(0, 18) and not IsPedInAnyVehicle(ped) and not ongoing then
                        if not DoesEntityExist(truckObj) then
                            TriggerEvent("vrp-hud:notify", "Ai nevoie de o duba pentru a incarca marfa.", "error", "Furnizor de stocuri")
                            goto continue
                        end
                        
                        local game = promise.new()

                        TriggerEvent("vrp-hud:updateMap", false)
                        TriggerEvent("vrp-hud:setComponentDisplay", {
                            serverHud = false,
                            minimapHud = false,
                            bottomRightHud = false,
                            chat = false,
                        })

                        ongoing = true

                        SendNUIMessage({job = "providergame"})

                        gameFinish = function()
                            TriggerEvent("vrp-hud:updateMap", true)
                            TriggerEvent("vrp-hud:setComponentDisplay", {
                                serverHud = true,
                                minimapHud = true,
                                bottomRightHud = true,
                                chat = true,
                            })

                            ongoing = false

                            if not objs.box then
                                objs.box = CreateObject(GetHashKey("prop_cs_cardbox_01"), boxPos, true)
                                FreezeEntityPosition(objs.box, true)
                            end

                            FreezeEntityPosition(objs.box, false)
                            AttachEntityToEntity(objs.box, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
                            ClearPedTasks(ped)
                        
                            local trunkPos = GetOffsetFromEntityInWorldCoords(truckObj, 0.0, -3.1, 0.0)

                            while jobActive and DoesEntityExist(truckObj) do
                                local dst = #(pedPos - trunkPos)

                                DisableControlAction(0, 21, true)
                                DisableControlAction(0, 22, true)

                                DrawMarker(20, trunkPos, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 255, 194, 170, 200, 0, 0, 0, 1)

                                if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                                    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                                end

                                if dst <= 1.5 then
                                    drawText("Apasa ~HC_55~E~w~ pentru a pune marfa in duba", 0.5, 0.85, 0.4, 255, 255, 255)

                                    if IsControlJustReleased(0, 38) then
                
                                        SetVehicleDoorOpen(truckObj, 2, false)
                                        SetVehicleDoorOpen(truckObj, 3, false)
                                        Citizen.Wait(1000)
        
                                        DeleteEntity(objs.box)
                                        ClearPedTasksImmediately(ped)
                                        objs.box = nil
        
                                        Citizen.Wait(500)
                                        SetVehicleDoorShut(truckObj, 2, false)
                                        SetVehicleDoorShut(truckObj, 3, false)
        
                                        inTruck = inTruck + 1
                                        TriggerServerEvent("work-provider:getBox")

                                        Citizen.CreateThread(function()
                                            local untilTime = GetGameTimer() + 1500
                                            
                                            local more = math.max(0, load - inTruck)
                                            if more > 0 then
                                                while GetGameTimer() < untilTime do
                                                    drawText("Mai ai de adus ~HC_55~"..more.." ~w~cutii", 0.5, 0.85, 0.4, 255, 255, 255)
                                                    Citizen.Wait(1)
                                                end
                                            end
                                        end)

                                        ClearPedTasksImmediately(ped)
                                        Citizen.Wait(1500)
                                        
                                        break
                                    end
                                end
                                
                                ped = PlayerPedId()
                                pedPos = GetEntityCoords(ped)

                                Citizen.Wait(1)
                            end

                            game:resolve(true)
                        end

                        Citizen.Await(game)
                        ::continue::
                    end
                end
            end

            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)

            dist = #(pedPos.xy - vec2(x, y))

            Citizen.Wait(1)
        end


        -- finish mission
        if blips.deposit and DoesBlipExist(blips.deposit) then
            RemoveBlip(blips.deposit)
            blips.deposit = nil
        end

        vRP.subtitle("Ai terminat de incarcat marfa, mergi la ~HC_16~magazin~w~ pentru a o descarca.")

        
        local x, y, z = table.unpack(finishPos)

        if not blips.market then
            local blip = AddBlipForCoord(x, y, z)
            SetBlipSprite(blip, 474)
            SetBlipScale(blip, 0.6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Magazin cumparator")
            EndTextCommandSetBlipName(blip)

            blips.market = blip
        end

        local blip = blips.market
        SetBlipColour(blip, 31)
        SetBlipCoords(blip, x, y, z)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, GetBlipColour(blip))


        dist = #(pedPos.xy - vec2(x, y))

        local alert, inStore = false, 0

        local done = false

        while jobActive and DoesEntityExist(truckObj) do
            ::start::
            if dist <= 50 then
                if not alert then
                    alert = true
                    Citizen.CreateThread(function()
                        local untilTime = GetGameTimer() + 5000
                                            
                        while GetGameTimer() < untilTime do
                            drawText("Parcheaza duba pentru a descarca marfa.", 0.5, 0.85, 0.4, 255, 255, 255)
                            Citizen.Wait(1)
                        end
                    end)
                end
            elseif alert then
                alert = false
            end

            while dist > 50 do
                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)

                dist = #(pedPos.xy - vec2(x, y))

                Citizen.Wait(1)
            end

            -- speed*3.6 = kmh
            local trunkPos
            while jobActive and math.floor((GetEntitySpeed(truckObj) * 3.6)) < 2 and not done do

                if done then break end

                if not trunkPos then
                    trunkPos = GetOffsetFromEntityInWorldCoords(truckObj, 0.0, -3.1, 0.0)
                
                    SetVehicleDoorOpen(truckObj, 2, false)
                    SetVehicleDoorOpen(truckObj, 3, false)
                end

                local dst = #(pedPos - trunkPos)
                DrawMarker(20, trunkPos, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 255, 194, 170, 200, 0, 0, 0, 1)
                
                if dst <= 1.5 then
                    drawText("Apasa ~HC_55~E~w~ pentru a descarca marfa din duba", 0.5, 0.85, 0.4, 255, 255, 255)
                    if IsControlJustReleased(0, 38) then

                        local stopLoop = false

                        Citizen.CreateThread(function()
                            while jobActive and not stopLoop do 
                                                            
                                if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
                                    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
                                end

                                if dist <= 10 then
                                    DrawMarker(1, x, y, z-1.1, 0, 0, 0, 0, 0, 0, 1.601, 1.601, 0.6001, 251, 238, 165, 200, 0, 0, 0, 1)
                                    if dist > 1.5 then
                                        if dst > 1.5 then
                                            drawText("Mergi si descarca marfa la magazin.", 0.5, 0.85, 0.4, 255, 255, 255)
                                        end
                                    else
                                        
                                        if dist <= 1.5 then
                                            drawText("Apasa ~HC_55~E~w~ pentru a descarca marfa la magazin", 0.5, 0.85, 0.4, 255, 255, 255)
                                            if IsControlJustPressed(0, 38) then
                                                
                                                inStore = inStore + 1
                                                TriggerServerEvent("work-provider:getBox")
                                                Citizen.CreateThread(function()
                                                    local untilTime = GetGameTimer() + 1500
                                                    
                                                    local more = math.max(0, inTruck - inStore)
                                                    if more > 0 then
                                                        while GetGameTimer() < untilTime do
                                                            drawText("Mai ai de adus ~HC_55~"..more.." ~w~cutii", 0.5, 0.85, 0.4, 255, 255, 255)
                                                            Citizen.Wait(1)
                                                        end
                                                    else

                                                        SetVehicleDoorShut(truckObj, 2, false)
                                                        SetVehicleDoorShut(truckObj, 3, false)
                                                    
                                                        if blips.market then
                                                            RemoveBlip(blips.market)
                                                            blips.market = nil
                                                        end

                                                        done = true
                                                        stopLoop = true
                                                    end
                                                end)
                                                
                                                
                                                DeleteEntity(objs.box)
                                                objs.box = nil
                                                
                                                ClearPedTasksImmediately(ped)
                                                
                                                Citizen.Wait(1500)
                                                break
                                            end
                                        end
                                    end
                                end

                                Citizen.Wait(1)
                            end
                        end)

                        if not objs.box then
                            objs.box = CreateObject(GetHashKey("prop_cs_cardbox_01"), pedPos.x, pedPos.y, pedPos.z-3.0, true)
                            FreezeEntityPosition(objs.box, true)
                        end

                        FreezeEntityPosition(objs.box, false)
                        AttachEntityToEntity(objs.box, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
                        ClearPedTasks(ped)
                        
                        break
                    end
                end


                ped = PlayerPedId()
                pedPos = GetEntityCoords(ped)

                dist = #(pedPos.xy - vec2(x, y))

                Citizen.Wait(1)
            end
            
            ped = PlayerPedId()
            pedPos = GetEntityCoords(ped)

            dist = #(pedPos.xy - vec2(x, y))

            Citizen.Wait(1)

            if not done then goto start end

            ::stop::
            vRP.subtitle("~HC_16~Minunat! ~w~Ai terminat de descarcat marfa, poti lucra la alt magazin.")
            TriggerServerEvent("work-provider:loadMarket")
            break
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

