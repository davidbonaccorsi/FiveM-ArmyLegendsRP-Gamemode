fx_version 'cerulean'
game 'gta5'

ui_page 'dist/index.html'

client_scripts {
    'client/main.lua'
}

files {
    'dist/index.html',
    'dist/nui.js',
    'dist/*.png',
    'dist/*.jpg',
    'dist/*.ogg'
}

dependencies {
    '/assetpacks',
    'webpack',
    'yarn',
    'vrp'
}

webpack_config 'webpack.config.js'
