-- Créditos: #Clebin047
-- Criado para o fórum FIVEMDEV.ORG
-- Não seja cuzão, dê os créditos se for repostar

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")

RegisterServerEvent("guarda:verificarPermissao")
AddEventHandler("guarda:verificarPermissao", function(user_id, permissoes)
    local source = source
    local temPermissao = false

    if not user_id then
        TriggerClientEvent("guarda:callbackPermissao", source, temPermissao)
        return
    end

    for _, permissao in ipairs(permissoes) do
        if vRP.hasPermission(user_id, permissao) then
            temPermissao = true
            break
        else
        end
    end
    TriggerClientEvent("guarda:callbackPermissao", source, temPermissao)
end)
