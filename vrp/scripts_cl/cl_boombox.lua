--[[

todo: de inlocuit xCarRadio cu asta pentru ca e un gunoi

local boomboxCoords <const> = {
    {vector3(-1382.0823974609,-614.66168212891,31.497905731201), title = "", running = false},
}

local boomboxRadius <const> = 15.0

local function isNearAnyBoombox(radius)
    local near = false
    for k, pos in pairs(boomboxCoords) do
        local dst = #(pedPos - pos)

        if dst <= (radius or boomboxRadius) then
            near = k
            break
        end
    end
    return near
end

Citizen.CreateThread(function()
    for k, pos in pairs(boomboxCoords) do
        local blip = AddBlipForCoord(pos[1])
        SetBlipSprite(blip, 590)
        SetBlipColour(blip, 0.8)
        SetBlipScale(blip, 84)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Locatie Party")
        EndTextCommandSetBlipName(blip)
    end

    while true do
        local ticks = 1000

        local boombox = isNearAnyBoombox(5.0)
        if boombox then
            boombox = boomboxCoords[boombox]
            
            local pos = boombox[1]
 
            local state = "~r~Nici o melodie nu se aude."
            if boombox.title then
                state =  "Melodie: ~g~"..boombox.title
            end

            DrawText3D(pos.x, pos.y, pos.z + 0.9, state, 1.0)
            DrawText3D(pos.x, pos.y, pos.z + 0.7, "[~g~E~w~] Porneste melodia", 1.0)
            DrawText3D(pos.x, pos.y, pos.z + 0.6, "[~y~[~w~] Schimba volum", 1.0)
            DrawText3D(pos.x, pos.y, pos.z + 0.5, "[~r~]~w~] Opreste melodia", 1.0)


            if IsControlJustReleased(0, 38) then
                TriggerServerEvent("vrp-boombox:trySetMusic")
            elseif IsControlJustReleased(0, 39) then
                TriggerServerEvent("vrp-boombox:setVolume")
            elseif IsControlJustReleased(0, 197) then
                TriggerServerEvent("vrp-boombox:stopSong")
            end

            ticks = 1
        end
        Citizen.Wait(ticks)
    end
end)

RegisterNUICallback("boombox:update", function(data, cb)
    cb("ok")

    if data.title and not (data.title == "stop") then
        sound = data.title
        return
    end

    sound = false
end)

RegisterNetEvent("vrp-boombox:playSound", function(boombox, video)
    local near = isNearAnyBoombox()
    if not near or not (near == boombox) then return end

    SendNUIMessage({interface = "boombox", type = "playUrl", url = video})

    Citizen.CreateThread(function()
        while true do
            local boombox = boomboxCoords[near]
            local dst = #(pedPos - boombox[1])

            if dst > 50 then
                if boombox.running then
                    SendNUIMessage({interface = "boombox", type = "stopSound"})
                    boombox.running = false
                end
            elseif dst < boomboxRadius then
                if not boombox.running and boombox.title then
                    SendNUIMessage({interface = "boombox", type = "playUrl", url = video})
                    boombox.running = true
                end
            end
            Citizen.Wait(100)
        end
    end)
end)
]]
