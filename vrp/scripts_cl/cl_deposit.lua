RegisterNetEvent("vrp-deposits:populateLocations", function(allDeposit)

    for i in pairs(allDeposit) do

        local blip = AddBlipForCoord(allDeposit[i].pos)
        SetBlipSprite(blip, 568)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 36)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Depozit")
        EndTextCommandSetBlipName(blip)

    end

    for k, data in pairs(allDeposit) do
        tvRP.setArea("vRP:depozit-"..data.name,data.pos[1], data.pos[2], data.pos[3], 15,
            {key = 'E', text =  "Depozit "..data.name.." ($"..data.fare.."/accesare)"},
            {
                type = 27,
                effect = false,
                x = 0.50,
                y = 0.50,
                z = 0.50,
                color = {255, 255, 255, 200,},
                coords = data.pos - vec3(0.0, 0.0, 0.9)
            },
            function()
                TriggerServerEvent("vrp-deposits:tryPayment", k)
            end)
    end
end)
