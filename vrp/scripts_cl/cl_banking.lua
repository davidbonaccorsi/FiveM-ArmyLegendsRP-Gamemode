local bankLocations = {
    vec4(148.56719970703,-1042.0727539062,29.368001937866,345.0),
    vec4(312.91717529297,-280.38824462891,54.164710998535,345.5),
    vec4(242.46852111816,226.84658813477,106.28745269775, 161.0),
    vec4(-1310.1940917969,-821.94616699219,17.148408889771, 208.0),
    vec4(-1212.5307617188,-332.63464355469,37.780956268311,31.5),
    vec4(-2960.9104003906,482.14541625977,15.697008132935,90.0),
    vec4(-112.27479553223,6471.1274414062,31.626714706421,136.5),
    vec4(-352.26284790039,-51.222023010254,49.036499023438,345.0),
    vec4(1175.9016113281,2708.5439453125,38.087959289551,185.0),
    vec4(-561.55157470703,-583.06335449219,41.430225372314, 177.0),
}

local atmObjects = {
    -870868698,
    -1126237515,
    -1364697528,
    506770882,
}

local oneAtm, atmPos = false, false

local function isNearAtm()
    for i = 1, #atmObjects do
        local atm = GetClosestObjectOfType(pedPos, 6.5, atmObjects[i], false, false, false)

        if DoesEntityExist(atm) then
            if atm ~= oneAtm then
                oneAtm = atm
                atmPos = GetEntityCoords(atm)
            end

            local dist = #(atmPos - pedPos)
            
            if dist <= 1.5 then
                return {
                    pos = atmPos,
                    entity = atm
                }
            end
        end
    end

    return false
end

local function isNearBank()
    for _, pos in pairs(bankLocations) do
        if #(vec3(pos.x, pos.y, pos.z) - pedPos) <= 2.5 then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    local requestedUse = false
    local atmSent = false
    while true do

        while isNearAtm() or isNearBank() do
            if not requestedUse then
                requestedUse = true
                TriggerEvent("vrp-hud:showBind", {key = "E", text = "Acceseaza cont bancar"})
            end
            
            local atm = isNearAtm()
            if atm and not atmSent then
                TriggerEvent("vrp-atmrob:registerATM", atm)
                atmSent = true
            end

            if IsControlJustReleased(0, 51) then
                vRPserver.getBankingData({}, function(data)
                    ExecuteCommand("e atm")
                    Wait(850)

                    data.machine = atm and "atm" or "bank"
                    -- data.name = exports["vrp_phone"]:getCharacterName()
                    -- data.iban = exports["vrp_phone"]:getCharacterIban()

                    local var1, var2 = GetStreetNameAtCoord(pedPos.x, pedPos.y, pedPos.z)
                    local street = GetStreetNameFromHashKey(var1)
                    local district = GetStreetNameFromHashKey(var2)

                    if street:len() < 2 then
                        street = district
                    end

                    data.location = street:upper()

                    TriggerEvent("vrp:interfaceFocus", true)
                    SendNUIMessage({interface = "bank", act = "build", data = data})
                end)
            end

            Wait(1)
        end

        if requestedUse then
            TriggerEvent("vrp-hud:showBind", false)
            requestedUse = false
        end

        if atmSent then
            atmSent = false
        end

        Wait(500)
    end
end)


Citizen.CreateThread(function()
	for k,v in ipairs(bankLocations)do
	    local blip = AddBlipForCoord(v.x, v.y, v.z)
	    SetBlipSprite(blip, 108)
	    SetBlipDisplay(blip, 4)
	    SetBlipScale(blip, 0.6)
	    SetBlipColour(blip, 2)
	    SetBlipAsShortRange(blip, true)
	    BeginTextCommandSetBlipName("STRING")
	    AddTextComponentString(tostring("Banca"))
	    EndTextCommandSetBlipName(blip)

        local ped = tvRP.spawnNpc("Banking"..k, {
            position = vec3(v.x, v.y, v.z),
            rotation = v[4] or 0.0,
            model = "a_f_y_business_04",
            freeze = true,
            minDist = 3.2,        
            name = "Mariana Georgescu",
        })
	end
end)

RegisterNetEvent("vrp-banking:updateScreenVal", function(key, value)
    SendNUIMessage({ interface = "bank", act = "update", key = key, value = value })
end)

RegisterNetEvent("vrp-banking:notification", function(...)
    TriggerEvent("vrp-hud:notify", ..., "error")
end)

RegisterNUICallback("bank:close", function(data, cb)
    TriggerEvent("vrp:interfaceFocus", false)
    ExecuteCommand("e c")

    cb("ok")
end)

RegisterNUICallback("bank:deposit", function(data, cb)
    vRPserver.tryBankDeposit({})
    cb("ok")
end)

RegisterNUICallback("bank:withdraw", function(data, cb)
    vRPserver.tryBankWithdraw({})
    cb("ok")
end)

RegisterNUICallback("bank:transfer", function(data, cb)
    vRPserver.tryBankTransfer({})
    cb("ok")
end)

RegisterNUICallback("bank:factionWithdraw", function(data, cb)
    vRPserver.tryFactionWithdraw({})
    cb("ok")
end)

RegisterNUICallback("bank:factionReplenish", function(data, cb)
    vRPserver.tryFactionDeposit({})
    cb("ok")
end)

RegisterNUICallback("bank:charity", function(data, cb)
    TriggerServerEvent("vrp-banking:donateToCharity")
    cb("ok")
end)