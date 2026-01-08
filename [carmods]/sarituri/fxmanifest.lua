fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'KuzQuality | Kuzkay'
description 'Bike jump by KuzQuality'
version '1.0.0'

client_scripts {
    'locale.lua',
    'config.lua',
    'client/editable/editable.lua',
    'client/cache.lua',
    'client/functions.lua',
    'client/client.lua',
    'client/jump.lua',
    'client/roof.lua',
}

server_scripts {
    'config.lua',
    'locale.lua',
    'server/server.lua',
}

escrow_ignore {
    'config.lua',
    'locale.lua',
    'client/editable/*.lua',
}

dependency '/assetpacks'