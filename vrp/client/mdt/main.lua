local function ToggleNUI(state)
    triggerCallback('isUserCop', function(isCop)
        if isCop then
            SetNuiFocus(state, state)

            ToggleAnimation(state)
            TriggerEvent('vRP:toggleMDT', state)

            local tog = not state
            TriggerEvent("vrp-hud:updateMap", tog)
            TriggerEvent("vrp-hud:setComponentDisplay", {
                serverHud = tog,
                minimapHud = tog,
                chat = tog,
            })
        end
    end)
end

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() == name then
        ToggleAnimation(false)
        CellCamActivate(false)
        DestroyMobilePhone()
    end
end)

RegisterCommand("mdt", function()
    ToggleNUI(true)
end)

RegisterKeyMapping("mdt", "Deschide MDT-UL Politiei", "keyboard", "F9")

RegisterNUICallback('mdt:close', function(data, callback)
    ToggleNUI(false)
    callback(true)
end)

RegisterNUICallback('mdt:toggle:nui', function(data, callback)
    ToggleNUI(data.state)
    
    if data.page then
        TriggerEvent("vRP:toggleMDTPage", data)
    end

    callback(true)
end)