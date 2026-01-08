
-- credits: @youngsinatra99

local gameDone

exports("startGame", function(length, retries, cb)
    gameDone = function(res)
        cb(res)
        gameDone = nil
    end
    SendNUIMessage({
        action = "open",
        length = length,
        retries = retries or false,
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("result", function(data, cb)
    if gameDone then
        gameDone(data[1])
    end
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
    cb("ok")
end)
