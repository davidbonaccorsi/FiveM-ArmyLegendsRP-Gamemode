
local function build_client_cams(player)
    local function createCams(player)
        local user_id = vRP.getUserId(player)
        
        if not vRP.isUserPolitist(user_id) then
            vRPclient.notify(player, {"Doar politisti pot accesa camerele!", "error"})
            return
        end

        TriggerClientEvent("police:watchCameras", player, 1)
    end

    local x, y, z = table.unpack({434.72775268555,-998.56750488281,39.416877746582})
    vRP.setArea(player, "vRP_policeCams:1", x, y, z, 15, {key = "E", text = "Acceseaza camerele"},
    {
        type = 20,
        x = 0.25,
        y = 0.25,
        z = -0.25,
        color = {224, 224, 224, 150},
        coords = {x, y, z},
    }, createCams)
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        build_client_cams(source)
    end
end)