fx_version 'cerulean'
games { 'gta5' }
author 'AlexSamurai'

ui_page 'ui/index.html'

client_scripts {
    '@vrp/client/Proxy.lua',
    '@vrp/client/Tunnel.lua',
    'client.lua'
}

files {
    'ui/index.html',
    'ui/main.js',
    'ui/jquery.js',
    'ui/style.css',
    'ui/bg.png'
}