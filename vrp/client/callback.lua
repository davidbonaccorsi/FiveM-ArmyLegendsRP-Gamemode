-- Credits: @plesalex100

local resName = GetCurrentResourceName()

local function callback(cbName, cb, ...)
    TriggerServerEvent("vrp_cbs:" .. cbName, ...)
    return RegisterNetEvent("vrp_cbs:" .. cbName, function(...)
        cb(...)
    end)
end

function triggerCallback(cbName, cb, ...)
    local ev = false
    local f = function(...)
        if ev ~= false then
            RemoveEventHandler(ev)
        end
        if cb then cb(...) end
    end
    ev = callback(cbName, f, ...)
    return ev
end