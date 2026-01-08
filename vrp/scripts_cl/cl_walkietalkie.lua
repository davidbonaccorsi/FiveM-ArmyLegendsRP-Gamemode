local radioMenu = false
local radioData = {
    volume = 50,
    channel = 0,
    preset = false,

    onRadio = false,
    radioProp = false,
}

local cfg = {
    maxFrequency = 999,
    restricted = {},
}

local function connectRadio(channel)
    TriggerEvent("sound:play", "radioON")
    radioData.channel = channel

    if radioData.onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        radioData.onRadio = true
    end
    
    exports["pma-voice"]:setRadioChannel(channel)
    TriggerServerEvent("voice:setRadioChannel", channel)

    local channelObj = splitString(tostring(channel), ".")
    if channelObj[2] ~= nil and channelObj[2] ~= "" then
        tvRP.notify("Te-ai conectat la frecventa "..channel.." MHz", "info")
    else
        tvRP.notify("Te-ai conectat la frecventa "..channel..".00 MHz", "info")
    end
end

local function leaveRadio(silentQuit)
    TriggerEvent("sound:play", "radioOFF")

    radioData.channel = 0
    radioData.onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    
    if not silentQuit then
        tvRP.notify("Te-ai deconectat!", "warning")
    end
end

local function toggleRadioAnimation(pState)
    loadAnimDict("cellphone@")

    if pState then
        TaskPlayAnim(tempPed, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
        radioData.radioProp = CreateObject('prop_cs_hand_radio', 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(radioData.radioProp, tempPed, GetPedBoneIndex(tempPed, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
    else
        StopAnimTask(tempPed, "cellphone@", "cellphone_text_read_base", 1.0)
        ClearPedTasks(tempPed)

        if radioData.radioProp ~= 0 then
            DeleteObject(radioData.radioProp)
            DeleteEntity(radioData.radioProp)
            radioData.radioProp = 0
        end
    end
end


local function toggleRadio(toggle)
    radioMenu = toggle
    
    TriggerEvent("vrp:interfaceFocus", radioMenu)

    if radioMenu then
        toggleRadioAnimation(true)
    else
        toggleRadioAnimation(false)
    end

    SendNUIMessage({
        interface = "radio",
        state = radioMenu
    })
end

exports("IsRadioOn", function()
    return radioData.onRadio
end)

RegisterNetEvent('vrp:playerInComa', function()
    if radioData.channel ~= 0 then
        leaveRadio(true)
    end
end)

RegisterNetEvent("vrp-radio:useItem", function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent("vrp-radio:restrictChannels", function(x)
    cfg.restricted = x
end)

RegisterNUICallback('radio:join', function(data, cb)
    local channel = tonumber(data[1])
    if channel ~= nil then
        if channel <= cfg.maxFrequency and channel ~= 0 then
            if channel ~= radioData.channel then
                
                if cfg.restricted[channel] then
                    vRPserver.canJoinRadio({channel}, function(ok)
                        if ok then
                            connectRadio(channel)
                        else
                            tvRP.notify("Frecventa este indisponibila!", "error")
                        end
                    end)
                else
                    connectRadio(channel)
                end

            else
                tvRP.notify("Esti deja conectat pe acest canal!", "error")
            end
        else
            tvRP.notify("Frecventa este invalida!", "error")
        end
    else
        tvRP.notify("Frecventa este invalida!", "error")
    end

    cb("ok")
end)

RegisterNUICallback('radio:leave', function(data, cb)
    if radioData.channel == 0 then
        tvRP.notify("Nu esti conectat la nicio frecventa!", "error")
    else
        leaveRadio()
    end
    
    cb("ok")
end)

RegisterNUICallback("radio:volume_up", function(data, cb)
    if radioData.volume <= 95 then
        radioData.volume = radioData.volume + 5

        exports["pma-voice"]:setRadioVolume(radioData.volume)
    end

    cb("ok")
end)

RegisterNUICallback("radio:volume_down", function(data, cb)
    if radioData.volume >= 10 then
        radioData.volume = radioData.volume - 5

        exports["pma-voice"]:setRadioVolume(radioData.volume)
    end

    cb("ok")
end)

RegisterNUICallback("radio:volume_mute", function(data, cb)
    radioData.volume = 0
    exports["pma-voice"]:setRadioVolume(radioData.volume)

    cb("ok")
end)

RegisterNUICallback('radio:preset_request', function(data, cb)
	if data[1] then
		tvRP.notify("Alege presetul pe care vrei sa salvezi aceasta frecventa.")
        radioData.preset = data[1]
	end

    cb("ok")
end)

RegisterNUICallback("radio:preset_set", function(data, cb)
    if radioData.preset then
        if not data[1] then
            tvRP.notify("Presetul selectat este invalid.")
        else
            SetResourceKvp('radio:preset_'..data[1], radioData.preset)
            
            tvRP.notify("Ai setat frecventa "..radioData.preset.." pentru Preset #"..data[1])

            radioData.preset = nil
        end
    end
end)

RegisterNUICallback('radio:preset_join', function(data, cb)
    local preset = tonumber(GetResourceKvpString('radio:preset_'..data[1]))

    if preset then
        cb(preset)
    end
end)

RegisterNUICallback('radio:exit', function(data, cb)
    toggleRadio(false)
    cb("ok")
end)