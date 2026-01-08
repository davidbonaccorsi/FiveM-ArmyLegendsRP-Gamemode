fx_version "bodacious"
game "gta5"
lua54 "yes"

description "ArmyLegends Romania - vRP Based"

ui_page "public/index.html"
loadscreen "assets/loadingscreen/index.html"

ui_page_preload "yes"

resource_type "map" {
    gameTypes = {
        ["Roleplay"] = true
    }
}

resource_type2 "gametype" {
    name = "Roleplay"
}

map "cfx/map.lua"

shared_scripts {
    "cfx/mapmanager_shared.lua",
} 

server_scripts{ 
    "cfx/mapmanager_server.lua",

    "lib/callback.lua",
    "lib/utils.lua",
    "base.lua",

    "modules/gui.lua",
    "modules/group.lua",
    "modules/admin.lua",
    "modules/vip.lua",
    "modules/factions.lua",
    
    "modules/survival.lua",
    "modules/player_state.lua",
    "modules/cloakroom.lua",
    
    "modules/money.lua",
    "modules/inventory.lua",
    "modules/identity.lua",
    "modules/level.lua",

    "modules/sound.lua",
    "modules/map.lua",
    "modules/basic_garage.lua",
    "modules/basic_market.lua",
    "modules/police.lua",
    "server.js",
    "apiserver.js",

    "scripts_sv/*.lua",
    "modules/mdt/**/*.lua", 
}

client_scripts{
    "cfx/mapmanager_client.lua",
    "cfx/spawnmanager.lua",
    "cfx/gamemode.lua",
    
    "lib/utils.lua",
    "client/Tunnel.lua",
    "client/Proxy.lua",
    "client/base.lua",
    "client/callback.lua",
    "client/npc.lua",

    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    
    "client/gui.lua",
    "client/admin.lua",
    "client/inventory.lua", 

    "client/identity.lua",
    "client/player_state.lua",
    "client/survival.lua",

    "client/map.lua",
    "client/basic_garage.lua",
    "client/basic_market.lua",
    "client/police.lua",
    "client/tunning/*.lua", 
    "scripts_cl/*",
    "client/admin/*",
    "client/mdt/**/*.lua",
}

files{
    "cfg/base.lua",
    "cfg/client.lua",
    "cfg/vehicles.lua",
    "cfg/markets.lua",
    "cfg/garages.lua",
    "cfg/tunning.lua",
    "cfg/bunker.lua",
    "cfg/gym.lua",
    "cfg/metro.lua",
    "cfg/clothes.lua",
    "cfg/inventory.lua",
    'cfg/fuelstation.lua',
    'cfg/discord.lua',
    "assets/**/*",
    "public/**"
}

data_file "DLC_ITYP_REQUEST" "stream/atm/loq_atm.ytyp"

server_export "IsRolePresent"
server_export "GetRoles"