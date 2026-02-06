-- Sistema AFK Ultra Completo Blox Fruits - Executor
-- Autor: Xesteer | Todos os eventos para Discord
-- Minimalista, monitorando frutas, bosses, ilhas, Legend Haki/Sword e Lua

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

------------------------------------------------------------
-- WEBHOOKS CONFIGURADOS
------------------------------------------------------------
local Webhooks = {
    FruitsSpawned    = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    RareBoss         = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    MiragemIsland    = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    KitsuneIsland    = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    PrehistoricIsland= "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    LegendHaki       = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    LegendSword      = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    FullMoon         = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
    NearFullMoon     = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"
}

------------------------------------------------------------
-- FUNÇÃO DE ENVIO DE WEBHOOK
------------------------------------------------------------
local function sendWebhook(eventType, description)
    local webhookUrl = Webhooks[eventType]
    if not webhookUrl then return end

    local payload = {
        embeds = {{
            title = eventType:gsub("([A-Z])"," %1"):gsub("^ ",""),
            description = description,
            fields = {
                {name="Players", value=tostring(#Players:GetPlayers())},
                {name="Job-id", value=tostring(game.JobId)},
                {name="Script", value="```game:GetService('ReplicatedStorage')._ServerBrowser:InvokeServer('teleport','"..game.JobId.."')```"}
            },
            color = 5111808
        }}
    }

    task.spawn(function()
        local success, err = pcall(function()
            HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
        if not success then warn("Falha ao enviar webhook: "..tostring(err)) end
    end)
end

------------------------------------------------------------
-- MONITORAMENTO DE EVENTOS
------------------------------------------------------------

-- 1. Frutas spawnadas
local function monitorFruits()
    local folder = ReplicatedStorage:WaitForChild("_Game"):WaitForChild("Fruits")
    folder.ChildAdded:Connect(function(fruit)
        sendWebhook("FruitsSpawned","{Fruit Name: "..fruit.Name.."}")
    end)
end

-- 2. Bosses raros
local function monitorRareBosses()
    local folder = ReplicatedStorage:WaitForChild("_Game"):WaitForChild("RareBosses")
    folder.ChildAdded:Connect(function(boss)
        sendWebhook("RareBoss","{Boss Name: "..boss.Name.."}")
    end)
end

-- 3. Ilhas especiais
local function monitorIslands()
    local islands = {"MiragemIsland","KitsuneIsland","PrehistoricIsland"}
    for _, island in ipairs(islands) do
        local folder = ReplicatedStorage:WaitForChild("_Game"):WaitForChild(island)
        folder.ChildAdded:Connect(function(_)
            sendWebhook(island,"{Island Spawned}")
        end)
    end
end

-- 4. Legend Haki e Legend Sword
local function monitorLegends()
    local hakiFolder = ReplicatedStorage:WaitForChild("_Game"):WaitForChild("LegendHaki")
    hakiFolder.ChildAdded:Connect(function(_)
        sendWebhook("LegendHaki","{Legend Haki Spawned}")
    end)

    local swordFolder = ReplicatedStorage:WaitForChild("_Game"):WaitForChild("LegendSword")
    swordFolder.ChildAdded:Connect(function(_)
        sendWebhook("LegendSword","{Legend Sword Spawned}")
    end)
end

-- 5. Lua cheia / Lua quase cheia
local function monitorMoon()
    local moon = ReplicatedStorage:WaitForChild("_Game"):WaitForChild("MoonStatus")
    moon.Changed:Connect(function(status)
        if status == "FullMoon" then
            sendWebhook("FullMoon","{Full Moon Event}")
        elseif status == "NearFullMoon" then
            sendWebhook("NearFullMoon","{Near Full Moon Event}")
        end
    end)
end

------------------------------------------------------------
-- INICIALIZAÇÃO
------------------------------------------------------------
task.spawn(monitorFruits)
task.spawn(monitorRareBosses)
task.spawn(monitorIslands)
task.spawn(monitorLegends)
task.spawn(monitorMoon)

print("✅ Sistema AFK Blox Fruits ativo! Todos os eventos deste servidor serão enviados automaticamente para os webhooks.")
r:InvokeServer('teleport', '"..jobId.."')")}
    })
end

local function onFullMoonEvent(sea)
    sendEvent("FullMoon", { {"Status", "A lua cheia apareceu!"}, {"Sea", sea or "Desconhecido"} })
end

print("✅ Sistema de Notificações Discord pronto com webhooks originais!")
        title      = "👹 Rare Boss Spawned",
        color      = 0xE95F5D,
        thumbnail  = "https://i.imgur.com/boss_icon.png"
    },
    FruitsSpawned = { webhookUrl = "COLOQUE_SEU_WEBHOOK_AQUI", title = "🍍 Fruits Spawned", color = 0xFFB90F },
    FullMoon = { webhookUrl = "COLOQUE_SEU_WEBHOOK_AQUI", title = "🌕 Full Moon", color = 0xEEEEEE },
    NearFullMoon = { webhookUrl = "COLOQUE_SEU_WEBHOOK_AQUI", title = "🌖 Near Full Moon", color = 0xCCCCCC },
}

------------------------------------------------------------
-- FUNÇÕES AUXILIARES
------------------------------------------------------------

-- Formata texto como bloco de código para Discord
local function codeBlock(lang, text)
    return string.format("```%s\n%s\n```", lang or "", text)
end

-- Normaliza campos para embeds
local function buildFields(fields)
    local output = {}
    if type(fields) ~= "table" then return output end

    for _, f in ipairs(fields) do
        if type(f) == "table" then
            local name  = f.name or f[1]
            local value = f.value or f[2]
            local inline = f.inline or f[3] or false
            if name and value then
                table.insert(output, { name = tostring(name), value = tostring(value), inline = inline })
            end
        end
    end
    return output
end

-- Função para enviar webhooks com tratamento de Rate-Limit
local function postWebhook(url, payload, retries)
    retries = retries or 3
    local jsonData = HttpService:JSONEncode(payload)
    
    local success, err = pcall(function()
        HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        if err:match("429") and retries > 0 then
            task.wait(5) -- Aguarda 5s e tenta novamente
            return postWebhook(url, payload, retries - 1)
        else
            warn("❌ Falha ao enviar webhook: " .. tostring(err))
            return false
        end
    end
    
    return true
end

------------------------------------------------------------
-- FUNÇÃO PRINCIPAL DE ENVIO DE EVENTOS
------------------------------------------------------------

local function sendEvent(eventType, fields, override)
    override = override or {}
    local config = eventConfigs[eventType]

    if not config then
        warn("❌ Evento não configurado: " .. tostring(eventType))
        return
    end

    local embed = {
        title   = override.title or config.title,
        color   = override.color or config.color,
        fields  = buildFields(fields),
        footer  = { text = "Xesteer Community" }
    }

    if override.thumbnail or config.thumbnail then
        embed.thumbnail = { url = override.thumbnail or config.thumbnail }
    end

    if override.image or config.image then
        embed.image = { url = override.image or config.image }
    end

    local payload = { embeds = { embed } }
    local sent = postWebhook(config.webhookUrl, payload)

    if sent then
        print("✅ Evento enviado: " .. embed.title)
    end
end

------------------------------------------------------------
-- FUNÇÕES DE EXEMPLO (Integre no seu jogo)
------------------------------------------------------------

-- Fruta Lendária
local function onLegendaryFruitSpawned(name, location, rarity)
    sendEvent("FruitsSpawned", {
        {"Fruta", name},
        {"Localização", location},
        {"Raridade", rarity}
    }, { title = "🍀 FRUTA LENDÁRIA ENCONTRADA!", color = 0xFF4500 })
end

-- Boss Raro
local function onRareBossSpawned(bossName, playersOnline, jobId)
    sendEvent("RareBoss", {
        {"Boss", bossName},
        {"Players Online", tostring(playersOnline)},
        {"Job-Id", jobId},
        {"Script Teleporte", codeBlock("lua", "game:GetService('ReplicatedStorage')._ServerBrowser:InvokeServer('teleport', '"..jobId.."')")}
    })
end

-- Lua Cheia
local function onFullMoonEvent(sea)
    sendEvent("FullMoon", { {"Status", "A lua cheia apareceu!"}, {"Sea", sea or "Desconhecido"} })
end

print("✅ Sistema de Notificações Discord pronto para uso!")
    LegendSword = {
        webhookUrl = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
        title      = "🗡️ Legend Sword",
        color      = 0x6E4C38, -- #6E4C38
    },
    RareBoss = {
        webhookUrl = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
        title      = "👹 Rare Boss Spawned",
        color      = 0xE95F5D, -- #E95F5D
        thumbnail  = "https://i.imgur.com/boss_icon.png"
    },
    FruitsSpawned = {
        webhookUrl = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
        title      = "🍍 Fruits Spawned",
        color      = 0xFFB90F, -- #FFB90F
    },
    FullMoon = {
        webhookUrl = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
        title      = "🌕 Full Moon",
        color      = 0xEEEEEE, -- #EEEEEE
    },
    NearFullMoon = {
        webhookUrl = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT",
        title      = "🌖 Near Full Moon",
        color      = 0xCCCCCC, -- #CCCCCC
    },
}

------------------------------------------------------------
-- FUNÇÕES AUXILIARES
------------------------------------------------------------

-- Formata texto como bloco de código para embeds do Discord.
local function codeBlock(lang, text)
    lang = lang or ""
    return string.format("```%s\n%s\n```", lang, text)
end

-- Normaliza e valida os campos do Embed.
local function buildFields(rawFields)
    local out = {}
    if type(rawFields) ~= "table" then return out end

    for _, f in ipairs(rawFields) do
        if type(f) == "table" and (f.name and f.value or (f[1] and f[2])) then
            local name  = f.name or f[1]
            local value = f.value or f[2]
            local inline = f.inline or f[3]
            table.insert(out, { name = tostring(name), value = tostring(value), inline = not not inline })
        end
    end
    return out
end

------------------------------------------------------------
-- FUNÇÃO PRINCIPAL DE ENVIO DE WEBHOOK
------------------------------------------------------------

local function sendEvent(eventType, fields, overrideOptions)
    -- 1. Validação dos parâmetros de entrada
    if type(eventType) ~= "string" or eventType == "" then
        warn("❌ [sendEvent] Tipo de evento inválido ou ausente.")
        return
    end

    local config = eventConfigs[eventType]
    if not config then
        warn("❌ [sendEvent] Configuração não encontrada para o evento: " .. eventType)
        return
    end

    local webhookUrl = config.webhookUrl
    if type(webhookUrl) ~= "string" or not webhookUrl:match("^https?://discord.com/api/webhooks/%d+/%w+") then
        warn("❌ [sendEvent] Webhook URL inválido para o evento: " .. eventType .. ". Por favor, verifique-o no Discord.")
        return
    end

    -- 2. Construção do Embed
    local finalTitle     = (overrideOptions and overrideOptions.title) or config.title
    local finalColor     = (overrideOptions and overrideOptions.color) or config.color
    local finalThumbnail = (overrideOptions and overrideOptions.thumbnail) or config.thumbnail
    local finalImage     = (overrideOptions and overrideOptions.image) or config.image
    local finalFields    = buildFields(fields)

    local embed = {
        title   = finalTitle,
        color   = finalColor,
        fields  = finalFields,
        footer  = { text = "Xesteer Community" }
    }
    
    if finalThumbnail then
        embed.thumbnail = { url = finalThumbnail }
    end

    if finalImage then
        embed.image = { url = finalImage }
    end

    local payload = { embeds = { embed } }
    local jsonData = HttpService:JSONEncode(payload)

    -- 3. Envio da requisição com tratamento de erros.
    local success, errorMessage = pcall(function()
        HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("✅ Evento enviado com sucesso: " .. (finalTitle or eventType))
    else
        if errorMessage:match("429") then
            warn("⚠️ [sendEvent] Erro de Rate-Limit (429) para o evento " .. eventType .. ". Aguardando 5 segundos e tentando novamente.")
            task.wait(5)
            success, errorMessage = pcall(function()
                HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
            end)
            if success then
                print("✅ Evento reenviado com sucesso após Rate-Limit: " .. (finalTitle or eventType))
            else
                warn("❌ [sendEvent] Falha no reenvio para " .. eventType .. ": " .. tostring(errorMessage))
            end
        else
            warn("❌ [sendEvent] Erro fatal ao enviar webhook para o evento " .. eventType .. ": " .. tostring(errorMessage))
        end
    end
end

------------------------------------------------------------
-- EXEMPLOS DE USO
-- Esses exemplos demonstram como chamar a função `sendEvent`
-- com os dados de um evento.
-- Você precisará integrar esta chamada à sua lógica de jogo.
------------------------------------------------------------

-- Notificação de uma Fruta Lendária spawnada
-- Use esta função quando uma fruta for encontrada no jogo.
local function onLegendaryFruitSpawned(fruitName, location, value)
    sendEvent("FruitsSpawned", {
        {"Fruta", fruitName},
        {"Localização", location},
        {"Valor", value}
    }, {
        title = "FRUTA LENDÁRIA ENCONTRADA!",
        color = 0xFF4500 -- Cor Laranja
    })
end

-- Exemplo de uso da função acima
-- onLegendaryFruitSpawned("Dragon Fruit", "Sea 3 - Mansion", "Extremamente Rara")

-- Notificação de Boss Raro
-- Use esta função quando um boss for spawnado.
local function onRareBossSpawned(bossName, playersOnline, serverJobId)
    sendEvent("RareBoss", {
        {"Boss", bossName},
        {"Players Online", tostring(playersOnline)},
        {"Job-Id", serverJobId},
        {"Teleport Script", codeBlock("lua", "game:GetService('ReplicatedStorage')._ServerBrowser:InvokeServer('teleport', '" .. serverJobId .. "')")}
    })
end

-- Exemplo de uso da função acima
-- onRareBossSpawned("Rip Indra", 15, "c1a2b3d4-xxxx-xxxx-xxxx-eeeeeeeeeeee")

-- Notificação de Evento de Lua
-- Use esta função para notificar sobre a Lua Cheia.
local function onFullMoonEvent()
    sendEvent("FullMoon", {
        {"Status", "A lua cheia apareceu! Corram para a Miragem Island!"},
        {"Sea", "Sea 3"}
    })
end

-- Exemplo de uso da função acima
-- onFullMoonEvent()

print("✅ O sistema de notificação do Discord está rodando e pronto para ser chamado por outros scripts!")
