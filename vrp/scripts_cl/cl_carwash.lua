
local carWashLocations = {
    vector3(34.940032958984,-1391.9873046875,29.351984024048),
    vector3(174.05953979492,-1736.6518554688,29.291803359985),
    vector3(-699.93640136719,-932.19720458984,19.01390838623),
    vector3(888.12005615234,-2101.5070800781,30.465698242188),
}

Citizen.CreateThread(function()
    for k, blipLocation in pairs(carWashLocations) do
        local theBlip = AddBlipForCoord(blipLocation)
        SetBlipSprite(theBlip, 100)
        SetBlipScale(theBlip, 0.4)
        SetBlipAsShortRange(theBlip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Spalatorie Auto")
        EndTextCommandSetBlipName(theBlip)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(carWashLocations) do
        tvRP.setArea("vRP:carWash"..k,v[1], v[2], v[3], 15,
            {key = 'E', text = 'Spala-ti masina'},
            {
                type = 1,
				x = 2.4,
				y = 2.4,
				z = 0.4,
                color = {0, 155, 125, 150},
                coords = v - vec3(0, 0, 1.0),
            },
            function()

                if not (playerVehicle == 0) then

                    vRPserver.canWashVehicle({}, function(canPay)
                        if canPay then
                            TriggerEvent("vrp-hud:showBind", false)
                            menuActive = false
                            TriggerEvent("vrp:progressBar", {
                                duration = 2500,
                                text = "Iti este spalata masina..",
                            })
                            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
                            FreezeEntityPosition(vehicle, true)
                            Wait(5000)
                            SetVehicleDirtLevel(vehicle, 0.0)
                            FreezeEntityPosition(vehicle, false)
                        else
                            tvRP.notify('Nu ai destui bani la tine, ai nevoie de 100$!', 'error')
                        end
                    end)
                end
            end)
    end
end)