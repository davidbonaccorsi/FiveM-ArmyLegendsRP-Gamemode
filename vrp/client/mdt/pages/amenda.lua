RegisterNUICallback('create:amenda', function(data, cb)
    triggerCallback('createAmenda', function(info)
        cb(info)
    end, data.amenda)
end)

