RegisterNetEvent("vRP:toggleMDT", function(state)
    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'OPEN' or 'CLOSE' })  
end)

RegisterNetEvent('vRP:toggleMDTPage', function(data)
    SendNUIMessage({
        action = 'SWITCH',
        args = {
            name = data.page.name,
            data = data.page.data
        }
    })
end)

RegisterNetEvent('vRP:sendMdtNui', function(data)
    SendNUIMessage(data)
end)