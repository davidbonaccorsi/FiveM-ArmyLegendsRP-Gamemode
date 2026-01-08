fx_version 'adamant'
game 'gta5'

ui_page 'html/index.html'

server_scripts {
	'@vrp/lib/utils.lua',
	'server.lua'
}

client_scripts {
	'@vrp/client/Proxy.lua',
	'@vrp/client/Tunnel.lua',
	'client.lua'
} 

files {
	'html/**/*'
}

