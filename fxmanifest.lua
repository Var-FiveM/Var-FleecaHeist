fx_version "cerulean"
game "gta5"

lua54 'yes'

client_script "client/*.lua"

server_script {
	"server/*.lua", 
	'@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    "shared/*.lua"
}

escrow_ignore {
	"client/event.lua",
	"client/functions.lua",
	"server/**/*",
	"shared/**/*"
}