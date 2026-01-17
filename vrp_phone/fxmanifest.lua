fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "html/index.html"
ui_page_preload "yes"

dependency 'vrp'

version "1.0"

client_scripts({
	"@vrp/client/Tunnel.lua",
	"cl_*.lua",
})

server_scripts({
	"@vrp/lib/utils.lua",
	"sv_*.lua",
})

files({
	"html/**/*",
})
