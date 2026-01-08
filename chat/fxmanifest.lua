fx_version "cerulean"
game "gta5"
lua54 "yes"

dependency 'vrp'

ui_page "html/index.html"
ui_page_preload "yes"

author "@21proxy"
description "Chat System for ArmyLegend-RP"
version "b1.0"

client_scripts({
	"cl_*.lua",
})

server_scripts({
	"@vrp/lib/utils.lua",
	"sv_*.lua",
})

files({
	"html/**/*",
})