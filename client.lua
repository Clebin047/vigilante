-- Créditos: #Clebin047
-- Criado para o fórum FIVEMDEV.ORG
-- Não seja cuzão, dê os créditos se for repostar

Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local guardas = {}
local grupoGuardas = GetHashKey("grupo_guardas")

AddRelationshipGroup("grupo_guardas")
SetRelationshipBetweenGroups(0, grupoGuardas, grupoGuardas)

function LoadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
end

function VerificarPermissoes(user_id, permissoes, callback)
    local eventName = "guarda:callbackPermissao" .. user_id .. GetGameTimer()

    AddEventHandler(eventName, function(result)
        callback(result)
        RemoveEventHandler(eventName)
    end)
    TriggerServerEvent("guarda:verificarPermissao", user_id, permissoes)
end

local function criarGuarda(index, config, guardaIndex)
    local rotaIndex = guardaIndex % #config.rotas + 1
    local modelHash = GetHashKey(config.mguarda)
    LoadModel(modelHash)

    local coords = config.rotas[rotaIndex]
    local guarda = CreatePed(4, modelHash, coords.x, coords.y, coords.z, 0.0, true, true)

    SetPedRelationshipGroupHash(guarda, grupoGuardas)
    SetPedCombatAttributes(guarda, 46, true)
    SetPedFleeAttributes(guarda, 0, false)

    local armaHash = GetHashKey(config.arma)
    GiveWeaponToPed(guarda, armaHash, 255, false, true)
    SetCurrentPedWeapon(guarda, armaHash, true) 
    TaskGoStraightToCoord(guarda, coords.x, coords.y, coords.z, 1.0, -1, 0.0, 0.0)

    guardas[index] = { ped = guarda, config = config, rotaIndex = rotaIndex, guardaIndex = guardaIndex }
end

CreateThread(function()
    while true do
        for i, guardaData in pairs(guardas) do
            local ped = guardaData.ped
            local rota = guardaData.config.rotas
            local config = guardaData.config

            if DoesEntityExist(ped) and not IsEntityDead(ped) then
                local jogadorMaisProximo = GetClosestPlayerToPed(ped, config.distanciaDeteccao)

                if jogadorMaisProximo then
                    local jogadorId = GetPlayerServerId(NetworkGetEntityOwner(jogadorMaisProximo))
                    
                    VerificarPermissoes(jogadorId, config.permissoes, function(temPermissao)
                        if temPermissao then

                            local atualCoords = GetEntityCoords(ped)
                            local destino = rota[guardaData.rotaIndex]

                            if #(atualCoords - vector3(destino.x, destino.y, destino.z)) < 1.5 then
                                if config.rotaSequencial then
                                    guardaData.rotaIndex = (guardaData.rotaIndex % #rota) + 1
                                else
                                    guardaData.rotaIndex = math.random(1, #rota)
                                end
                                destino = rota[guardaData.rotaIndex]
                            end

                            TaskGoStraightToCoord(ped, destino.x, destino.y, destino.z, 1.0, -1, 0.0, 0.0)
                        else
                            if GetEntityHealth(jogadorMaisProximo) > 101 then
                                TaskCombatPed(ped, jogadorMaisProximo, 0, 16)
                            end
                        end
                    end)
                else

                    local atualCoords = GetEntityCoords(ped)
                    local destino = rota[guardaData.rotaIndex]

                    if #(atualCoords - vector3(destino.x, destino.y, destino.z)) < 1.5 then
                        if config.rotaSequencial then
                            guardaData.rotaIndex = (guardaData.rotaIndex % #rota) + 1
                        else
                            guardaData.rotaIndex = math.random(1, #rota)
                        end
                        destino = rota[guardaData.rotaIndex]
                    end

                    TaskGoStraightToCoord(ped, destino.x, destino.y, destino.z, 1.0, -1, 0.0, 0.0)
                end
            end
        end
        Wait(1000)
    end
end)

function VerificarPermissoes(jogadorId, permissoes, callback)
    TriggerServerEvent("guarda:verificarPermissao", jogadorId, permissoes)
    RegisterNetEvent("guarda:callbackPermissao")
    AddEventHandler("guarda:callbackPermissao", function(temPermissao)
        callback(temPermissao)
    end)
end

CreateThread(function()
    for i, config in ipairs(Config.Guardas) do
        for j = 1, config.quantidade do
            criarGuarda(i .. "-" .. j, config, j)
        end
    end
end)

function GetClosestPlayerToPed(ped, radius)
    local players = GetActivePlayers()
    local closestPlayer, closestDistance = nil, radius

    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(ped))
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = playerPed
        end
    end
    return closestPlayer
end
