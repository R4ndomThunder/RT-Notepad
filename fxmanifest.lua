fx_version 'adamant'
games { 'rdr3', 'gta5' }

author 'R4ndomThunder'
description 'A Notepad script for who can\'t talk'
version '1.0.0'

lua54 "yes"

shared_script{
    '@ox_lib/init.lua',   
    'config.lua',
}

client_script 'client.lua'
server_script {
    'server.lua',
    '@oxmysql/lib/MySQL.lua',
}

ui_page 'nui/index.html'
files {
    'nui/index.html',
	'nui/style.css',
	'nui/app.js'
}

dependency 'pma-voice'