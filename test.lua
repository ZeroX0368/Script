-- Blox Fruit Shop Stock Notifier
-- This script monitors the fruit shop and sends notifications to a Discord Webhook

local WebhookURL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT" -- Replace with your Discord Webhook URL

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function sendWebhook(title, description, color)
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 65280, -- Default green
            ["footer"] = {
                ["text"] = "Blox Fruit Stock Notifier"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local success, err = pcall(function()
        HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("Failed to send webhook: " .. tostring(err))
    end
end

local function checkStock()
    -- Blox Fruit shop logic typically involves Remotes or checking specific folders
    -- This is a template logic as the actual game structure is protected/complex
    local shopItems = {}
    
    -- Attempt to get stock from ReplicatedStorage or typical Blox Fruit remotes
    local success, stockData = pcall(function()
        -- Using common remote name for shop data if available
        return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("GetShopFruits")
    end)

    if success and stockData then
        local stockList = ""
        for _, fruit in pairs(stockData) do
            if fruit.OnSale then
                stockList = stockList .. "🍎 **" .. tostring(fruit.Name) .. "** - Price: " .. tostring(fruit.Price) .. "\n"
            end
        end
        
        if stockList ~= "" then
            sendWebhook("Shop Stock Updated", "Current fruits in shop:\n\n" .. stockList, 3447003)
        end
    else
        -- Fallback: If remote not found, try to look for UI or folder-based stock
        local fruitStock = ReplicatedStorage:FindFirstChild("FruitStock")
        if fruitStock then
            local stockList = ""
            for _, fruit in pairs(fruitStock:GetChildren()) do
                stockList = stockList .. "🍎 **" .. fruit.Name .. "**\n"
            end
            if stockList ~= "" then
                sendWebhook("Shop Stock Updated (Folder View)", "Current fruits in shop:\n\n" .. stockList, 3447003)
            end
        else
            warn("Could not fetch shop data. Ensure you are using a compatible executor and in-game.")
        end
    end
end

-- Notify when script starts
sendWebhook("Notifier Started", "Blox Fruit Stock Notifier is now running!", 16776960)

-- Check stock every 15 minutes
spawn(function()
    while true do
        checkStock()
        wait(900) -- 15 minutes
    end
end)

print("Blox Fruit Shop Stock Notifier loaded!")
