local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- WEBHOOK
local url_webhook = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"

function sendToDiscord()
    local fruitData = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("CommF_")
        :InvokeServer("GetFruits")

    if not fruitData then
        warn("Không thể lấy dữ liệu Stock!")
        return
    end

    local stockText = ""
    local count = 0

    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count += 1
            stockText ..= ("🍎 **%s** — `$%s`\n"):format(fruit.Name, fruit.Price)
        end
    end

    if stockText == "" then
        stockText = "❌ Hiện tại không có trái nào được bán."
    end

    -- COMPONENTS V2
    local data = {
        ["components"] = {
            {
                ["type"] = 10, -- Container
                ["components"] = {
                    {
                        ["type"] = 11,
                        ["content"] = "🛒 **BLOX FRUIT STOCK NOTIFIER**"
                    },
                    {
                        ["type"] = 11,
                        ["content"] = "Danh sách trái ác quỷ đang bán:"
                    },
                    {
                        ["type"] = 12, -- Section
                        ["components"] = {
                            {
                                ["type"] = 11,
                                ["content"] = ("📦 **Stock (%d loại):**\n%s"):format(count, stockText)
                            }
                        }
                    },
                    {
                        ["type"] = 11,
                        ["content"] = "🖥 **Server Info**\n`JobId: " .. game.JobId .. "`"
                    },
                    {
                        ["type"] = 11,
                        ["content"] = "⏰ Cập nhật lúc: `" .. os.date("%X") .. "`"
                    }
                }
            }
        }
    }

    if request then
        request({
            Url = url_webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
        print("✅ Đã gửi Discord Components V2!")
    else
        warn("Executor không hỗ trợ HttpRequest!")
    end
end

sendToDiscord()
