fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "html/index.html"
ui_page_preload "yes"

description "Jobs System"
version "1.0"

dependency 'vrp'

client_scripts({
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	"all_client.lua",
	"**/cl_*.lua",
})

server_scripts({
	"@vrp/lib/utils.lua",
    "universal.lua",
	"**/sv_*.lua",
})

files({
	"html/**/*",
})

data_file 'DLC_ITYP_REQUEST' 'stream/props/bzzz_props_gardenpack.ytyp'
