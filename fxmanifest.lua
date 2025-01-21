fx_version 'cerulean'
game 'gta5'

client_scripts {
    'client.lua'
}

server_scripts {
    "@vrp/lib/utils.lua",
    'server.lua' -- Caso tenha lógica no servidor
}

shared_scripts {
    '@vrp/lib/utils.lua',
    'config.lua'
}

dependencies {
    'vrp' -- Certifique-se de que o nome é exatamente "vrp"
}
