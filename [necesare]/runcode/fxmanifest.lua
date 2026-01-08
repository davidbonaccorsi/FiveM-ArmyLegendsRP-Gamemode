-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Allows server owners to execute arbitrary server-side or client-side JavaScript/Lua code. *Consider only using this on development servers.'
repository 'https://github.com/citizenfx/cfx-server-data'
lua54 'yes'

game 'common'
fx_version 'bodacious'




server_scripts {
    "@vrp/lib/utils.lua",
    'runcode_sv.lua',
    'runcode_web.lua'
}

shared_scripts {
    'runcode_shared.lua',
    'runcode.js',
}

client_scripts {
    "@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
    'runcode_cl.lua',
    'runcode_ui.lua',
}

ui_page 'web/nui.html'
files {
    'web/nui.html'
}
