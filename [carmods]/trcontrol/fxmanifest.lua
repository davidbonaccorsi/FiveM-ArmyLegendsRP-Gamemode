fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'KuzQuality | Kuzkay'
description 'Traction control by KuzQuality'
version '1.1.2'


--
-- Server
--

server_scripts {
    'config.lua',
    'server/server.lua',
}

--
-- Client
--

client_scripts {
    'config.lua',
    'client/cache.lua',
    'client/editable/editable.lua',
    'client/client.lua',
    'client/handling.lua',
}

escrow_ignore {
    'config.lua',
    'client/editable/*.lua',
}

dependency '/assetpacks'