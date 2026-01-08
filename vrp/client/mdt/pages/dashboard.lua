RegisterNUICallback('update:dashboard', function(data, cb)
    triggerCallback('updateMDTDashboard', function(result)
        cb(result)
    end)
end)

local Webhook;

RegisterNUICallback('take:photo', function(data, callback)
    local taking = true

    CreateMobilePhone(1)
    CellCamActivate(true, true)

    CreateThread(function()
        while taking do

            if IsControlJustPressed(1, 177) then
                taking = false
                DestroyMobilePhone()
                CellCamActivate(false, false)
            end

            if IsControlJustPressed(1, 176) then
                taking = false

                exports['screenshot-basic']:requestScreenshotUpload(Webhook, 'files[]', function(data)
                    local image = json.decode(data)
    
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    callback(image.attachments[1].proxy_url)              
                end)
            end

            Wait(0)
        end
    end)
end)

Citizen.CreateThread(function()
    triggerCallback('getWebhook', function(webhook)
        Webhook = webhook
    end)
end)