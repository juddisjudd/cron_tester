fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Judd'
description 'Cron Expression Tester'
version '1.0.0'

shared_script '@ox_lib/init.lua'

server_scripts {
    '@ox_lib/imports/cron/server.lua',
    'test.lua'
}

dependencies {
    'ox_lib'
}