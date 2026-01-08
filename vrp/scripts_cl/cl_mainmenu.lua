RegisterCommand("menu", function()
    TriggerEvent("vrp-hud:updateMap", false)
    TriggerEvent("vrp-hud:setComponentDisplay", {["*"] = false})

    triggerCallback('getMenuData', function(data)
        SendNUIMessage({
            interface = 'menu',
            data = data,
        })
    end)
end)

RegisterNUICallback('getAcountData', function(data, cb)
    triggerCallback('menu:userData', function(accountData)
        cb(accountData)
    end)
end)

RegisterNUICallback('menu:investMenu', function(data, cb)
    TriggerServerEvent('vRP:requestInvestMenu')
    cb('ok')
end)

RegisterNUICallback("menu:factionData", function(data, cb)
    triggerCallback('getFactionData', function(factionData)
        cb(factionData)
    end)
end)

RegisterNUICallback("faction:depositMoney", function(data, cb)
    triggerCallback("faction:deposit", function(res)
        cb(res)
    end, data[1])
end)

RegisterNUICallback("faction:withdrawMoney", function(data, cb)
    triggerCallback("faction:withdraw", function(res)
        cb(res)
    end, data[1])
end)

RegisterNUICallback("faction:kick", function(data, cb)
    triggerCallback("faction:kick", function(res)
        cb(res)
    end, data[1])
end)

RegisterNUICallback("faction:managePlayer", function(data, cb)
    triggerCallback("faction:setRank", function(res)
        cb(res)
    end, data[1], data[2])
end)

RegisterNUICallback("faction:deleteRank", function(data, cb)
    triggerCallback("faction:deleteRank", function(res)
        cb(res)
    end, data[1])
end)

RegisterNUICallback("faction:createRank", function(data, cb)
    triggerCallback("faction:createRank", function(res)
        cb(res)
    end, data[1])
end)

RegisterNUICallback("menu:refferal", function(data, cb)
    triggerCallback('openRefferal', function(refferalData)
        cb(refferalData)
    end)
end)

RegisterNUICallback('menu:openDaily', function(data, cb)
    triggerCallback('openDaily', function(dailyData)
        cb(dailyData)
    end)
end)

RegisterNUICallback('daily:collect', function(data, cb)
    triggerCallback('collectDaily', function(dailyData)
        cb(dailyData)
    end)
end)

RegisterNUICallback('menu:settings', function(data, cb)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),0,-1) -- Open settings menu
end)

RegisterKeyMapping('menu', 'Main Menu', 'keyboard', 'M')