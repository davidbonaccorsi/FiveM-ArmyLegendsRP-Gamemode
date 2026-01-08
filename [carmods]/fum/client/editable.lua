function IsWhitelisted(vehicle)
    for index, value in ipairs(Config.whitelist.vehicles) do
        if GetHashKey(value) == GetEntityModel(vehicle) then
            return true
        end
    end

    return false
end

if Config.toggleCommands then
    RegisterCommand('stopsmoke', function(source, args)
        smokeActive = false
        TriggerEvent("vrp-hud:notify", "Ai oprit fumul custom", "info")
    end)
    
    RegisterCommand('startsmoke', function(source, args)
        smokeActive = true
        TriggerEvent("vrp-hud:notify", "Ai pornit fumul custom", "info")
    end)
end
