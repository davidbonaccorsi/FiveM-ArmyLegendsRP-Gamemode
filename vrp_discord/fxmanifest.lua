fx_version 'adamant'
game 'gta5'


dependency "vrp"

client_scripts{ 
	"@vrp/lib/Proxy.lua",
  "@vrp/lib/Tunnel.lua",
  "client.lua",
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua",
  "cfg/discord.lua",
}