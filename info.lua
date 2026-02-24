-- Universal Game Info → Discord Webhook

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local webhook = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"

local placeId = game.PlaceId
local jobId = game.JobId
local maxPlayers = Players.MaxPlayers

-- Get Game Name
local function getGameName()
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(placeId).Name
    end)
    return success and result or "Unknown Game"
end

-- Send to Discord
local function sendWebhook()
    local currentPlayers = #Players:GetPlayers()

    local data = {
        ["embeds"] = {{
            ["title"] = "🎮 Roblox Server Info",
            ["color"] = 65280,
            ["fields"] = {
                {
                    ["name"] = "Game Name",
                    ["value"] = getGameName(),
                    ["inline"] = false
                },
                {
                    ["name"] = "Game ID",
                    ["value"] = tostring(placeId),
                    ["inline"] = true
                },
                {
                    ["name"] = "Server ID",
                    ["value"] = jobId,
                    ["inline"] = false
                },
                {
                    ["name"] = "Players",
                    ["value"] = currentPlayers .. "/" .. maxPlayers,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Auto Updated"
            }
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    if syn and syn.request then
        syn.request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    elseif request then
        request({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end
end

-- Send when player joins/leaves
Players.PlayerAdded:Connect(sendWebhook)
Players.PlayerRemoving:Connect(sendWebhook)

-- Send when script runs
sendWebhook()
