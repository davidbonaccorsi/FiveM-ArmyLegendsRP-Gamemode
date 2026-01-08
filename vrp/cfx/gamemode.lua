AddEventHandler('onClientMapStart', function()
    exports.vrp:setAutoSpawn(true)
    exports.vrp:forceRespawn()
end)