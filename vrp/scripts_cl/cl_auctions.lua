RegisterNUICallback("bid", function(data, cb)
    TriggerServerEvent('vrp-auctions:bid')
    cb('ok')
end)

RegisterNUICallback('closeAuction', function(data, cb)
    TriggerServerEvent('vrp-auctions:closeAuction')
    cb('ok')
end)