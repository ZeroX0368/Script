local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- // CẤU HÌNH // --
local Webhook_URL = "https://discord.com/api/webhooks/1370529951052468295/KYT9QTHy5rrsYAkwKpMKeeYO4Db5X9YkrT5qOrudk0SGcyIbXsHO4s1tLAPHQL77k0fK"
local Auto_Hop = true -- Tự động nhảy server sau khi thông báo hoặc không tìm thấy

-- // Hàm lấy danh sách Server để Hop // --
function serverHop()
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local function getServers(cursor)
        return HttpService:JSONDecode(game:HttpGet(sfUrl .. (cursor and "&cursor=" .. cursor or "")))
    end

    local server = getServers()
    for _, s in pairs(server.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end

-- // Hàm gửi thông báo Webhook // --
function sendWebhook(fruitName)
    local data = {
        ["embeds"] = {{
            ["title"] = "🍎 FRUIT SPAWN NOTIFIER",
            ["description"] = "Đã tìm thấy trái ác quỷ mới trong Server!",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "🍎 Fruit Name:", ["value"] = "```" .. fruitName .. "```", ["inline"] = false},
                {["name"] = "🌍 Location (Sea):", ["value"] = "```" .. tostring(game:GetService("Workspace").Map:GetAttribute("Sea") or "Unknown") .. "```", ["inline"] = true},
                {["name"] = "👥 Players:", ["value"] = "```" .. #game.Players:GetPlayers() .. "/" .. game.MaxPlayers .. "```", ["inline"] = true},
                {["name"] = "🆔 Job ID:", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false},
                {["name"] = "📜 Script Join:", ["value"] = "```game:GetService('TeleportService'):TeleportToPlaceInstance("..game.PlaceId..", '"..game.JobId.."')```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "Blox Fruit Finder • " .. os.date("%X")},
            ["image"] = {["url"] = "https://i.imgur.com/your_image_id.png"} -- Có thể thay link ảnh minh họa
        }}
    }

    if request then
        request({
            Url = Webhook_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end
end

-- // Kiểm tra Fruit trong Workspace // --
function checkFruit()
    local found = false
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and (string.find(v.Name, "Fruit") or v:FindFirstChild("Handle")) then
            sendWebhook(v.Name)
            found = true
            print("Đã tìm thấy: " .. v.Name)
            wait(5) -- Đợi gửi xong webhook
            break
        end
    end

    if not found then
        print("Không tìm thấy trái nào. Đang chuẩn bị nhảy Server...")
    end

    if Auto_Hop then
        serverHop()
    end
end

-- Chạy kiểm tra sau khi vào game
task.wait(5)
checkFruit()
