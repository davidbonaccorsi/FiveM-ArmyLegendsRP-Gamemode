fx_version "cerulean"
game "gta5"
lua54 "yes"

dependency 'vrp'

ui_page "html/index.html"
ui_page_preload "yes"

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
