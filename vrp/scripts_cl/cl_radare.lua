
local radarLocations <const> = { -- true if highway
    {vec3(1625.3563232422,1127.9216308594,82.791496276855), 150, true},
    {vec3(2417.4465332031,999.10333251953,85.641822814941), 150, true},
    {vec3(814.40270996094,2237.5202636719,48.883251190186), 100, false},
    {vec3(1225.0501708984,3530.3823242188,35.114650726318), 100, false},
    {vec3(2160.0808105469,3769.7890625,33.237197875977), 100, false},
    {vec3(2789.1125488281,4417.7983398438,48.76490020752), 150, true},
    {vec3(195.57791137695,6553.984375,32.117206573486), 70, false},
    {vec3(-1625.0883789062,4870.9013671875,61.16637802124), 150, true},
    {vec3(-1752.6302490234,825.19464111328,142.10498046875), 100, false},
    {vec3(315.17474365234,-453.94430541992,43.58472442627), 70 , false},
    {vec3(-43.64066696167,-739.65991210938,33.25972366333), 70, false},
    {vec3(-982.98962402344,-1238.9930419922,5.7244672775269), 70, false},
    {vec3(843.02844238281,-1603.595703125,32.327499389648), 100, false},
    {vec3(456.54037475586,-2029.3002929688,24.160375595093), 70, false},
    {vec3(-822.25085449219,-2546.0708007812,13.964283943176), 70, false},
}

local function getNearestRadar()
    local pos = GetEntityCoords(PlayerPedId())
    local dst, speed = 9999999999.0, 50

    for k, v in pairs(radarLocations) do
        local distance = #(pos - v[1])
        if distance < dst then
            dst = distance
            speed = v[2]
        end
    end

    return speed
end

AddEventHandler('vrp:onPlayerEnterVehicle', function(veh, isDriver)
    local isCop = exports.vrp:isCop()
    
    if not isDriver then return end
    
    while veh == playerVehicle do
        for k, radar in pairs(radarLocations) do
            local vehPos = GetEntityCoords(veh)
            local dst = #(vehPos - radar[1])
            local kmSpeed = math.ceil(GetEntitySpeed(veh) * 3.6)

            -- dst 50: bugged?
            if dst <= 90 and not (lastRadar == k) and not isCop then
                local cid, model = exports.vrp:checkVehicle(veh)

                if cid and model then

                    if (kmSpeed > radar[2] and tonumber(kmSpeed) - tonumber(radar[2]) >= 10) then
                        TriggerServerEvent('vrp-tickets:speedRadar', kmSpeed, radar[2], GetVehicleNumberPlateText(veh), model)
                        TriggerEvent("vrp-hud:notify", "Ai primit o amenda pentru depasirea limitei de viteza, o gasesti in posta.\nViteza: "..kmSpeed.."/"..radar[2].." MAX", "error", "Camera de viteza")
                    end

                    if radar[3] then
                        local model = tvRP.getNearestOwnedVehicle(10)
                        if model then
                            TriggerServerEvent("vignette:check", model)
                        end
                    end

                    lastRadar = k -- temporary fix
                    
                    Citizen.CreateThread(function()
                        Citizen.Wait(2500)
                        lastRadar = nil
                    end)

                    Citizen.Wait(2000)
                end
            end
            Citizen.Wait(100)
        end

        SendNUIMessage({
            interface = 'speedLimit',
            limit = getNearestRadar(),
        })

        Citizen.Wait(1000)
    end
end)

