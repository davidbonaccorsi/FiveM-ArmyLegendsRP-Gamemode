
RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:clear')
RegisterNetEvent('__cfx_internal:serverPrint')

local showServerPrints, chatActive = false, true
Citizen.CreateThread(function()
    SetTextChatEnabled(false)

    AddEventHandler('chatMessage', function(msg, type)
        if chatActive then
            SendNUIMessage({act = "onMessage", type = type, msg = msg})
        end
    end)

    RegisterCommand("clearchat", function()
        TriggerEvent("chat:clear")
    end)

    RegisterNetEvent("vrp-hud:setComponentDisplay")
    AddEventHandler("vrp-hud:setComponentDisplay", function(components)
        for k, state in pairs(components) do
            if k == "*" or k == "chat" then
                SendNUIMessage({act = "onComponentDisplaySet", tog = state})
            end
        end
    end)

    RegisterCommand("logserver", function()
        showServerPrints = not showServerPrints
        print("Server prints [LOGGER]: "..(showServerPrints and "ON" or "OFF"))
    end)

    RegisterCommand("togchat", function()
        chatActive = not chatActive

        if not chatActive then
            TriggerEvent("chat:clear")
        end
    end)

    AddEventHandler("chat:clear", function()
        SendNUIMessage({act = "clear"})
    end)

    RegisterNetEvent("printInClient", function(text)
        print(text)
    end)

    AddEventHandler('__cfx_internal:serverPrint', function(msg)
        if showServerPrints then
            print(msg)
        
            SendNUIMessage({act = "onMessage", type = "msg", msg = msg})
        end
    end)
end)

RegisterNetEvent("vl:checkForWeapon", function(sender)
    TriggerServerEvent("vl:sendDataAboutWeapon", sender, GetSelectedPedWeapon(PlayerPedId()))
end)

RegisterCommand("openchat", function()
    SetNuiFocus(true, true)

    SendNUIMessage({act = "build"})
end)

RegisterKeyMapping("openchat", "Chat with other players", "keyboard", "t")

RegisterNUICallback('chatResult', function(data, cb)
    local id = PlayerId()
    local theMessage = data[1]
    
    if theMessage:sub(1, 1) == '/' then
      ExecuteCommand(theMessage:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), theMessage)
    end
  
    cb('ok')
end)

local webhook = "https://discord.com/api/webhooks/1246773120891748453/FTY_8mTK4wxHYt_HCkNLsfA0BGlXAfo1GazVVgRybxx6GgqBwDEqy_oqLeLIpXAZvgBZ"
RegisterNetEvent("AC:requestScreenshot")
AddEventHandler("AC:requestScreenshot", function(player, theCmd)
	-- exports['screenshot-basic']:requestScreenshot(function(data)
	-- 	TriggerLatentServerEvent("AC:sendScreenshot", 2000000, player, data)
	-- end)

    exports['screenshot-basic']:requestScreenshotUpload(webhook, "files[]", function(data)
        TriggerLatentServerEvent("AC:sendScreenshot", 2000000, player, data)
    end)
end)

RegisterNUICallback("setFocus", function(data, cb)
    SetNuiFocus(data[1], data[1])
    cb("ok")
end)


local function DrawText3D(x,y,z, text, scl, stopWaiting) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    if dist <= 15.0 or stopWaiting then
    
        local scale = scl
        if not stopWaiting then
            scale = (1/dist)*scl
            local fov = (1/GetGameplayCamFov())*100
            scale = scale*fov
        end
     
        if onScreen then
                SetTextScale(0.0*scale, 1.1*scale)
                SetTextFont(0)
                SetTextProportional(1)
                SetTextColour(230, 0, 0, 255)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(2, 0, 0, 0, 150)
                SetTextDropShadow()
                SetTextOutline()
                SetTextEntry("STRING")
                SetTextCentre(1)
                AddTextComponentString(text)
                DrawText(_x,_y)
        end
    elseif not stopWaiting then
        Citizen.Wait(500)
    end
end

RegisterCommand("header", function()
	local ped = PlayerPedId()
	local header = GetEntityHeading(ped)
	local x, y, z = table.unpack(GetEntityCoords(ped))
	local untilTime = GetGameTimer() + 10000
	while untilTime > GetGameTimer() do
		DrawText3D(x, y, z+0.5, header, 1.3)
		Citizen.Wait(1)
	end
end)

RegisterCommand("scoreboard", function()
    TriggerServerEvent("scoreboard:show")
end)
RegisterKeyMapping("scoreboard", "Vezi scoreboardul", "keyboard", "F10")

RegisterCommand("jobs", function()
    TriggerEvent("chatMessage", "^5Info: ^7Pentru a vedea joburile disponibile pe server intra pe discordul nostru ^2discord.gg/armylegendsrp^7 la sectiunea ^5#tutoriale-joburi")
end)

local activePed
RegisterNetEvent('vrp-drugs:createTestPed', function(data)
    print(json.encode(data))

    if activePed then DeleteEntity(activePed) end
    RequestModel(data.model)
    while not HasModelLoaded(data.model) do
        Wait(1)
    end

    activePed = CreatePed(0, data.model, data.pos - vector3(0, 0, 1.0), data.h + 0.0, false, true)
    FreezeEntityPosition(activePed, true)
    SetEntityInvincible(activePed, true)
    SetBlockingOfNonTemporaryEvents(activePed, true)
    TaskStartScenarioInPlace(activePed, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
    SetModelAsNoLongerNeeded(data.model)
end)