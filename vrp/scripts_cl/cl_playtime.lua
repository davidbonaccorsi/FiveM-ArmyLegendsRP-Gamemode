
--[[
RegisterNetEvent("vrp-playtimef:winSomething", function(win, title)
    SendNUIMessage({
        interface = "playtimeFlips",
        event = "winSomething",
        win = win,
        title = title,
    })
end)
]]

RegisterNUICallback("playtimeflips:rotatingCard", function(data, cb)
    Citizen.SetTimeout(3000, function()
        TriggerServerEvent("vrp-playtimef:winSomething")
    end)
    cb("ok")
end)
