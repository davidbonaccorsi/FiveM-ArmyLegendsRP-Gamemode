fx_version 'adamant'
game 'gta5'

ui_page 'furni/html/furniture.html'

dependency 'vrp'

client_scripts {
	'@vrp/client/Tunnel.lua',
	'utils.lua',
	'config.lua',
	'client/main.lua',
	'client/houseloader.lua',

	-- furni
	'furni/config.lua',
	'furni/client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'utils.lua',
	'houses.lua',
	'config.lua',
	'server/main.lua'
}

files {
	'stream/shellprops.ytyp',
	'stream/shellpropsv2.ytyp',
	'stream/shellpropsv9.ytyp',
	-- furni
	'furni/html/furniture.html',

	'furni/html/aim.png',
	'furni/html/back.png',
	'furni/html/cancel.png',
	'furni/html/dec.png',
	'furni/html/down.png',
	'furni/html/edit.png',
	'furni/html/exit.png',
	'furni/html/forward.png',
	'furni/html/icon1.png',
	'furni/html/inc.png',
	'furni/html/left.png',
	'furni/html/remove.png',
	'furni/html/right.png',
	'furni/html/slide.png',
	'furni/html/test.png',
	'furni/html/up.png',

	'furni/html/affirm-detuned.wav',
	'furni/html/affirm-melodic2.wav',
	'furni/html/affirm-melodic3.wav',
	'furni/html/alert-echo.wav',
	'furni/html/camera_click.wav',
	'furni/html/click-analogue-1.wav',
	'furni/html/click-round-pop-1.wav',
	'furni/html/click-round-pop-2.wav',
	'furni/html/click-round-pop-3.wav'
}

server_export 'giveHousingAuction'

data_file 'DLC_ITYP_REQUEST' 'stream/shellprops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/shellpropsv2.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/shellpropsv9.ytyp'

-- client_script '@vrp/client/allResources.lua'