
RegisterCommand("shop", function()
    SendNUIMessage({interface = "premiumShop", act = "build"})    
end)

AddEventHandler("vrp-hud:updateMoney", function(cash, bank, coins)
    SendNUIMessage({interface = "premiumShop", act = "update", coins = coins})
end)

RegisterNUICallback("shop:getCoins", function(data, cb)
    vRPserver.getCoins({}, function(coins)
        
        cb(coins)
    end)
end)

RegisterNUICallback("shop:buyProduct", function(data, cb)
    TriggerServerEvent("vrp-premium:getProduct", data[1])
    cb("ok")
end)