
local vRP = exports.vrp:link()
local vRPphone = Tunnel.getInterface("vRP_phone", "vRP_phone")

local phoneOn, phoneData = false, {}

local metaData = {
    splash = GetResourceKvpString("phoneSplash") or 1,
    ringer = GetResourceKvpString("phoneRinger") or 3
}

RegisterNetEvent("vrp-phone:clearCache", function()
    SetResourceKvp("phoneSplash", 1)
    SetResourceKvp("phoneRinger", 3)
    SetResourceKvp("phoneGallery", "[]")

    metaData.splash = 1
    metaData.ringer = 3
    phoneData.gallery = {}
end)

exports("isOpen", function()
	return phoneOn
end)

local function getNameFromContact(number)
    if phoneData.contacts[number] then
        return phoneData.contacts[number].name
    end

    return false
end

local function checkContactStatus(number)
    if not phoneData then
        return false
    end
    
    if phoneData.contacts[number] then
        return phoneData.contacts[number].status
    end

    return false
end

RegisterNetEvent("vrp-phone:loadPhone", function(data)
    
    data.gallery = json.decode(GetResourceKvpString("phoneGallery") or "[]")

    SendNUIMessage({act = "setNumber", number = data.number, iban = data.identity.iban})

    phoneData = data

    for _, data in pairs(phoneData.messagesFront) do
        data.name = getNameFromContact(data.number)
    end
end)

exports("getCharacterName", function()
    return phoneData.identity.firstname.." "..phoneData.identity.name
end)

exports("getCharacterIban", function()
    return phoneData.identity.iban
end)

RegisterNetEvent("vrp-phone:notify", function(msg, time)
    SendNUIMessage({
        act = "notify",
        msg = msg,
        time = time,
        phoneOn = phoneOn
    })
end)


RegisterNetEvent("vrp-hud:updateMap")
AddEventHandler("vrp-hud:updateMap", function(toggle)
    SendNUIMessage({act = "setMapState", toggle = toggle})
end)


RegisterNUICallback("closePhone", function(data, cb)
    phoneOn = false
    -- if not IsPedInAnyVehicle(PlayerPedId()) then
    --     TriggerEvent("vrp-hud:updateMap", phoneOn)
    -- end

	if not phoneData.inCall or not phoneData.inCall.ongoing then
		startPhoneAnimation('cellphone_text_out')

		Citizen.SetTimeout(400, function()
			StopAnimTask(PlayerPedId(), phoneAnim.lib, phoneAnim.anim, 2.5)
			deletePhoneProp()

			phoneAnim.lib = nil
			phoneAnim.anim = nil
		end)
	elseif phoneData.inCall and phoneData.inCall.ongoing then
		phoneAnim.lib = nil
		phoneAnim.anim = nil
		startPhoneAnimation('cellphone_text_to_call')
	end

    cb("ok")
end)

local resName = GetCurrentResourceName()
local function callback(cbName, cb, ...)
	TriggerServerEvent(resName..":s_callback:"..cbName, ...)
	return RegisterNetEvent(resName..":c_callback:"..cbName, function(...)
		cb(...)
	end)
end

function triggerCallback(cbName, cb, ...)
	local ev = false
	local f = function(...)
		if ev ~= false then
			RemoveEventHandler(ev)
		end
		cb(...)
	end
	ev = callback(cbName, f, ...)
	return ev
end

RegisterCommand("phone", function()
    if phoneData.number and not phoneOn then
        vRPphone.hasPhone({}, function(hasPhone)
            if not hasPhone then
                vRP.notify("Nu ai un telefon mobil", "error")
            else

                triggerCallback("vl:isPlayerHandcuffed", function(isHandcuffed)
                    print(isHandcuffed)
                    if isHandcuffed then return end

                    phoneOn = true

                    local data = {
                        splash = metaData.splash,
                        ringer = metaData.ringer,
                        number = phoneData.number,
                    }
            
                    SendNUIMessage({act = "build", data = data})
                    -- CreateThread(function()
                    --     while phoneOn do
                    --         DisableControlAction(0, 1, true) -- disable mouse look
                    --         DisableControlAction(0, 200, true) -- disable mouse look
                    --         DisableControlAction(0, 2, true) -- disable mouse look
                    --         DisableControlAction(0, 3, true) -- disable mouse look
                    --         DisableControlAction(0, 4, true) -- disable mouse look
                    --         DisableControlAction(0, 5, true) -- disable mouse look
                    --         DisableControlAction(0, 6, true) -- disable mouse look
                    --         DisableControlAction(0, 263, true) -- disable melee
                    --         DisableControlAction(0, 264, true) -- disable melee
                    --         DisableControlAction(0, 257, true) -- disable melee
                    --         DisableControlAction(0, 140, true) -- disable melee
                    --         DisableControlAction(0, 141, true) -- disable melee
                    --         DisableControlAction(0, 142, true) -- disable melee
                    --         DisableControlAction(0, 143, true) -- disable melee
                    --         DisableControlAction(0, 177, true) -- disable escape
                    --         DisableControlAction(0, 200, true) -- disable escape
                    --         DisableControlAction(0, 202, true) -- disable escape
                    --         DisableControlAction(0, 322, true) -- disable escape
                    --         DisableControlAction(0, 245, true) -- disable chat
                    --         Citizen.Wait(1)
                    --     end
                    -- end)
                    -- if not IsPedInAnyVehicle(PlayerPedId()) then
                    --     TriggerEvent("vrp-hud:updateMap", phoneOn)
                    -- end
            
                    local anim = 'cellphone_text_in'
                    if phoneData.inCall then
                        anim = 'cellphone_call_to_text'
                    end
            
                    startPhoneAnimation(anim)
            
                    Citizen.SetTimeout(250, function()
                        newPhoneProp()
                    end)
                    
                end)
        
            end
        
        end)
    end
end)

RegisterKeyMapping('phone', 'Deschide Telefon', 'keyboard', 'L')

RegisterNUICallback("setRingerSound", function(data, cb)
    metaData.ringer = data[1]
    SetResourceKvp("phoneRinger", data[1])

    cb("ok")
end)

RegisterNUICallback("setWallpaper", function(data, cb)
    metaData.splash = data[1]
    SetResourceKvp("phoneSplash", data[1])

    cb("ok")
end)

RegisterNUICallback("takePhoto", function(data, cb)
    phoneFocus = false
    SetNuiFocus(phoneFocus, phoneFocus)

    CreateMobilePhone(1)
    CellCamActivate(true, true)

    vRPphone.getWebhook({}, function(webhook)
        local inCamera, frontCam = true, false
        local takingPhoto = false

        StopAnimTask(PlayerPedId(), phoneAnim.lib, phoneAnim.anim, 2.5)
        deletePhoneProp()

        phoneAnim.lib = nil
        phoneAnim.anim = nil

        while inCamera do

            if IsControlJustReleased(1, 27) then
                frontCam = not frontCam
                Citizen.InvokeNative(0x2491A93618B7D838, frontCam)

            elseif IsControlJustReleased(1, 177) then
                inCamera = false
                cb(false)
            elseif IsControlJustReleased(1, 176) then
                if not takingPhoto then
                    takingPhoto = true

                    exports['screenshot-basic']:requestScreenshotUpload(webhook, "files[]", function(data)
                        local image = json.decode(data) or {}

                        if image.attachments then

                            table.insert(phoneData.gallery, image.attachments[1].proxy_url)
                            
                            Citizen.Wait(100)
                            SetResourceKvp("phoneGallery", json.encode(phoneData.gallery))

                            inCamera = false
                            cb(true)
                        else
                            cb(false)
                        end
                    end)
                end
            end

            Citizen.Wait(1)
        end

        DestroyMobilePhone()
        CellCamActivate(false, false)

        local anim = 'cellphone_text_in'
        if phoneData.inCall then
            anim = 'cellphone_call_to_text'
        end

        startPhoneAnimation(anim)

        Citizen.SetTimeout(250, function()
            newPhoneProp()
        end)
        
        phoneFocus = true
        SetNuiFocus(phoneFocus, phoneFocus)

    end)
end)

RegisterNUICallback("openShop", function(data, cb)
    ExecuteCommand("shop")
    cb("ok")
end)

RegisterNUICallback("openInvestments", function(data, cb)
    TriggerServerEvent("vrp-investments:openMenu")
    cb("ok")
end)
RegisterNUICallback("setMapPosition", function(data, cb)
    local x, y = tonumber(data[1]), tonumber(data[2])
    SetNewWaypoint(x, y)
    
    cb("ok")
end)

RegisterNUICallback("callTaxi", function(data, cb)
    TriggerServerEvent("vrp-phone:callService", "taxi")
    cb("ok")
end)

RegisterNUICallback("suggestContact", function(data, cb)
    vRPphone.suggestContact({})
    cb("ok")
end)

RegisterNUICallback("donateToCharity", function(data, cb)
    vRPphone.donateToCharity({data[1]}, function(response)
        cb(response)
    end)
end)

RegisterNUICallback("transferToIban", function(data, cb)
    vRPphone.transferToIban({data[1], data[2]}, function(response)
        cb(response)
    end)
end)

RegisterNUICallback("getBankMoney", function(data, cb)
    vRPphone.getBankMoney({}, function(money)
        cb(money)
    end)
end)

RegisterNUICallback("getGalleryImages", function(data, cb)
    cb(phoneData.gallery)
end)

RegisterNetEvent("vrp-phone:newAd", function(theAd)
    table.insert(phoneData.ads, theAd)
end)

RegisterNUICallback("getAnnouncements", function(data, cb)
    cb(phoneData.ads)
end)

RegisterNUICallback("getShareFeed", function(data, cb)
    cb({phoneData.shareFeed, phoneData.shareLiked})
end)

RegisterNUICallback("postShare", function(data, cb)
    TriggerServerEvent("vrp-phone:shareImage", data)
    cb("ok")
end)

RegisterNUICallback("unlikeShare", function(data, cb)
    local key = data[1]
    if phoneData.shareFeed[key] then
        TriggerServerEvent("vrp-phone:unlikeShare", key)

        phoneData.shareLiked[key] = false
    end

    cb("ok")
end)

RegisterNUICallback("likeShare", function(data, cb)
    local key = data[1]
    if phoneData.shareFeed[key] then
        TriggerServerEvent("vrp-phone:likeShare", key)

        phoneData.shareLiked[key] = true
    end

    cb("ok")
end)

RegisterNetEvent("vrp-phone:refreshShareFeed", function(type, value)
    if type == "newShare" then
        table.insert(phoneData.shareFeed, value)
    elseif type == "like" then
        phoneData.shareFeed[value].likes += 1
    elseif type == "unlike" then
        phoneData.shareFeed[value].likes -= 1
    end

    if phoneOn then
        Citizen.Wait(100)
        SendNUIMessage({act = "refreshShareFeed"})
    end
end)

RegisterNUICallback("isWorkingAsProvider", function(data, cb)
    cb(exports["vrp_jobs"]:getActiveJob() == "Furnizor de stocuri")
end)

RegisterNUICallback("getProviderOrders", function(data, cb)
    vRPphone.getMarketStockOrders({}, function(orders)
        cb(orders)
    end)
end)

RegisterNUICallback("getVignetteModels", function(data, cb)
    vRPphone.getVignetteModels({}, function(models)
        cb(models)
    end)
end)

RegisterNUICallback("getVignetteForModel", function(data, cb)
    TriggerServerEvent("vignette:buy", data[1])
    cb("ok")
end)

RegisterNUICallback("getActiveAuction", function(data, cb)
    vRPphone.getActiveAuction({}, function(auction)
        cb(auction)
    end)
end)

RegisterNUICallback("joinActiveAuction", function(data, cb)
    TriggerServerEvent("vrp-auctions:tryToJoin")
    cb("ok")
end)

RegisterNUICallback("callForService", function(data, cb)
    TriggerServerEvent("vrp-phone:callService", data[1])
    cb("ok")
end)

RegisterNUICallback("addNewContact", function(data, cb)
    if not phoneData.contacts[2] then
        phoneData.contacts[data[2]] = {
            name = data[1]
        }

        for _, data in pairs(phoneData.messagesFront) do
            if data.number == data[2] then
                data.name = data[1]
            end
        end

        TriggerServerEvent("vrp-phone:addContact", data)
        cb(true)
    else
        cb(false)
    end
end)

RegisterNUICallback("editContact", function(data, cb)
    local lastNumber = data[1][2]
    local newNumber = data[3]
    local currentIndx = lastNumber

    phoneData.contacts[currentIndx].name = data[2]

    if lastNumber ~= newNumber then
        currentIndx = newNumber

        phoneData.contacts[currentIndx] = phoneData.contacts[lastNumber]
        phoneData.contacts[lastNumber] = nil
    end

    for _, data in pairs(phoneData.messagesFront) do
        if data.number == currentIndx then
            data.name = phoneData.contacts[currentIndx].name
        end
    end

    TriggerServerEvent("vrp-phone:editContact", lastNumber, currentIndx, phoneData.contacts[currentIndx].name)
    cb("ok")
end)

RegisterNUICallback("deleteContact", function(data, cb)
    if phoneData.contacts[data[1]] then
        phoneData.contacts[data[1]] = nil

        for _, data in pairs(phoneData.messagesFront) do
            if data.number == data[1] then
                data.name = nil
            end
        end

        TriggerServerEvent("vrp-phone:deleteContact", data[1])
        cb(true)
        
    else
        cb(false)
    end
end)

RegisterNetEvent("vrp-phone:updateContactStatus", function(phone, tog)

    if phoneData.contacts and phoneData.contacts[phone] then
        phoneData.contacts[phone].status = tog
    end
end)

RegisterNUICallback("getContactsList", function(data, cb)
    cb(phoneData.contacts)
end)

RegisterNetEvent("vrp-phone:addLastCall", function(phone)
    table.insert(phoneData.lastCalls, phone)
end)

RegisterNUICallback("getLastCalls", function(data, cb)
    cb(phoneData.lastCalls)
end)


RegisterNUICallback("callNumber", function(data, cb)

    if data[1] ~= phoneData.number then
        vRPphone.getCallState({data[1]}, function(response)
            response.inCall = phoneData.inCall

            if response.available and not response.inCall then
                
                TriggerServerEvent("vrp-phone:callNumber", data[1])

                local senderAddition = tostring(phoneData.number):gsub("-", "")
                local targetAddition = tostring(data[1]):gsub("-", "")

                phoneData.inCall = {
                    number = data[1],
                    ongoing = false,
                    voice = tonumber(senderAddition) + tonumber(targetAddition),
                }

                Citizen.CreateThread(function()
                    while phoneData.inCall and not phoneData.inCall.ongoing do
                        SendNUIMessage({act = "playDialingSound"})
                        Citizen.Wait(5250)
                    end
                end)

                Citizen.CreateThread(function()
                    while phoneData.inCall and not phoneData.inCall.ongoing do
                        Citizen.Wait(100)
                    end
                
                    if phoneData.inCall then
                        exports['pma-voice']:addPlayerToCall(phoneData.inCall.voice)
                    end
                end)

            end

            response.contact = getNameFromContact(data[1])
    
            cb(response)
        end)
    
    else
        cb(false)
    end
end)

RegisterNetEvent("vrp-phone:cancelCall", function()
    if phoneData.inCall then
        exports['pma-voice']:removePlayerFromCall(phoneData.inCall.voice)

        phoneData.inCall = nil
    end

    if not phoneOn then
		StopAnimTask(PlayerPedId(), phoneAnim.lib, phoneAnim.anim, 2.5)
		deletePhoneProp()
    end
	phoneAnim.lib = nil
	phoneAnim.anim = nil

    SendNUIMessage({act = "cancelCallDisplay"})
end)

RegisterNetEvent("vrp-phone:getCalled", function(number)
    SendNUIMessage({act = "getCalled", number = number, contact = getNameFromContact(number)})


    local senderAddition = tostring(phoneData.number):gsub("-", "")
    local targetAddition = tostring(number):gsub("-", "")

    phoneData.inCall = {
        number = number,
        ongoing = false,
        canAccept = true,
        voice = tonumber(senderAddition) + tonumber(targetAddition),
    }

    Citizen.CreateThread(function()
        while phoneData.inCall and not phoneData.inCall.ongoing do
            SendNUIMessage({act = "playRingerSound"})
            Citizen.Wait(15000)
        end
    end)

    while phoneData.inCall and not phoneData.inCall.ongoing do
        Citizen.Wait(100)
    end

    if phoneData.inCall then
        exports['pma-voice']:addPlayerToCall(phoneData.inCall.voice)
    end

end)

RegisterNetEvent("vrp-phone:setCallAsAnswered", function()
    if phoneData.inCall then
        phoneData.inCall.ongoing = true
        SendNUIMessage({act = "setCallDisplayAsAnswered"})
    
        local anim = 'cellphone_text_to_call'
        if not phoneOn then
			anim = 'cellphone_call_listen_base'
		end
        
        startPhoneAnimation(anim)
    
    end
end)

RegisterNUICallback("acceptCall", function(data, cb)
    if phoneData.inCall and phoneData.inCall.canAccept then
        TriggerServerEvent("vrp-phone:acceptCall")
    end

    cb("ok")
end)

RegisterNUICallback("endCurrentCall", function(data, cb)
    TriggerServerEvent("vrp-phone:endCall")

    cb("ok")
end)

local suggestedContacts = {}

RegisterNetEvent("vrp-phone:getSuggested", function(phone, name)
    suggestedContacts[phone] = name
end)

RegisterNUICallback("deleteSuggestedContact", function(data, cb)
    suggestedContacts[data[1]] = nil
    cb("ok")
end)

RegisterNUICallback("getSharedContacts", function(data, cb)
    cb(suggestedContacts)
end)

RegisterNUICallback("getMessagesList", function(data, cb)

    for _, data in pairs(phoneData.messagesFront) do
        data.status = checkContactStatus(data.number)
    end

    cb(phoneData.messagesFront)
end)

RegisterNetEvent("vrp-phone:refreshFrontMessages", function(msgData)
    while not phoneData.messagesFront do
        Citizen.Wait(100)
    end
    
    for index, data in pairs(phoneData.messagesFront) do
		if data.number == msgData.sender then
			table.remove(phoneData.messagesFront, index)
		end
	end

    if msgData.type == "location" then
        msgData.msg = "Shared location"
    end

	table.insert(phoneData.messagesFront, 1, {
        number = msgData.sender,
        name = getNameFromContact(msgData.sender),
        msg = msgData.msg,
        time = msgData.time
    })

    if not msgData.skipRefresh then
        SendNUIMessage({act = "refreshConversation", number = msgData.sender})

        SendNUIMessage({act = "smsNotify", msg = msgData.msg, number = msgData.sender})
    end
end)

RegisterNUICallback("hasAnyMsgWithContact", function(data, cb)
    vRPphone.hasAnyMsgWithContact({data[1]}, function(result)
        cb(result)
    end)
end)

RegisterNUICallback("getConversationMessages", function(data, cb)
    vRPphone.getConversationMessages({data[1]}, function(messages)
        cb(messages)
    end)
end)

RegisterNUICallback("getCoordsForMessage", function(data, cb)
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(ped))

    cb({x, y})
end)

RegisterNUICallback("sendMessage", function(data, cb)
    TriggerServerEvent("vrp-phone:sendMessage", data)
    cb("ok")
end)

phoneFocus = false
RegisterNUICallback("setFocus", function(data, cb)
    phoneFocus = data[1]
    SetNuiFocus(phoneFocus, phoneFocus)
    
    cb("ok")
end)

RegisterCommand('phonefocus', function()
	if phoneOn then
		phoneFocus = not phoneFocus
        SetNuiFocus(phoneFocus, phoneFocus)
	end
end)

RegisterKeyMapping('phonefocus', 'Misca Camera', 'MOUSE_BUTTON', 'MOUSE_RIGHT')

