fx_version "cerulean"
game "gta5"
lua54 "yes"
description "vRP Turfs - Hillside"
dependency "vrp"
ui_page "html/index.html"
ui_page_preload "yes"
files {
    "html/**/*",
}
client_scripts {
    "@vrp/client/Tunnel.lua",
    "@vrp/client/Proxy.lua",
    "client.lua"
}
server_scripts {
    "@vrp/lib/utils.lua",
    "server.lua"
}
