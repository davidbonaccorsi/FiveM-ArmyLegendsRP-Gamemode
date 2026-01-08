fx_version 'adamant'
game 'gta5'

client_scripts {
	'NativeUI.lua',
	'Client/**/*.lua'
}

dependency 'vrp'

server_scripts {
	"@vrp/lib/utils.lua",
	'Server/*.lua'
}

shared_scripts{
	"Config.lua",
	"Client/AnimationList.lua",
}