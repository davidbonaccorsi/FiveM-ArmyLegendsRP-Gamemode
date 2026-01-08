
Citizen.CreateThread(function()
    local pedCoords = vector3(-589.91510009766,-920.38024902344,23.869049072266)
    local menuCoords = vector3(-589.90740966797,-921.78741455078,23.875942230225)

    local blip = AddBlipForCoord(menuCoords)
	SetBlipSprite(blip, 459)
    SetBlipColour(blip, 59)
    SetBlipScale(blip, 0.6)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("CNN")
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Life Invader")
    EndTextCommandSetBlipName(blip)

	tvRP.spawnNpc("lifeInvader", {
        position = pedCoords,
        rotation = 180,
        model = "ig_avery",
        freeze = true,
        minDist = 5,        
        name = "Jared Vasquez",
    })

    tvRP.setArea("vRP:lifeInvader",menuCoords[1], menuCoords[2], menuCoords[3], 15,
    {key = 'E', text =  "Publica un anunt comercial"},
    {
        type = 27,
        effect = false,
        x = 0.50,
        y = 0.50,
        z = 0.50,
        color = {255, 255, 255, 200},
        coords = menuCoords - vec3(0.0, 0.0, 0.9)
    },
    function()
        TriggerServerEvent("vrp-lifeinvader:tryPostingAnn")
    end)
end)

RegisterNetEvent("vrp-hud:addAnnounce", function(name, phone, msg)
    SendNUIMessage({
        interface = "lifeInvaderPost",
        data = {name = name, phone = phone, msg = msg}
    })

    PlaySoundFrontend(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset")
end)

RegisterNUICallback("addAnnouncement", function(data, cb)
    TriggerServerEvent("vrp-hud:addAnnounce", data[1])
    cb("ok")
end)
