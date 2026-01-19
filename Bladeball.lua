local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // Cấu hình tham số // --
local Config = {
    ParryRange = 25,       -- Khoảng cách để tự kích hoạt đỡ
    SpamRange = 12,        -- Khoảng cách cực gần để bắt đầu Spam (phòng thủ tốc độ cao)
    DebugMode = true       -- Hiện thông báo trong F9 khi đỡ thành công
}

-- // Tìm Remote điều khiển việc đỡ bóng // --
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ParryButton")

-- // Hàm kiểm tra xem bóng có đang hướng về phía mình không // --
local function isBallTargetingMe(ball)
    -- Kiểm tra thuộc tính target của bóng (Blade Ball thường lưu ở đây)
    return ball:GetAttribute("Target") == LocalPlayer.Name
end

-- // Vòng lặp chính // --
RunService.PreRender:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local ballsFolder = workspace:FindFirstChild("Balls")
    
    if ballsFolder then
        for _, ball in pairs(ballsFolder:GetChildren()) do
            -- Chỉ xử lý nếu bóng là bóng đang thi đấu (Real Ball)
            if ball:GetAttribute("IsRealBall") == true then
                local distance = (ball.Position - root.Position).Magnitude
                local velocity = ball.AssemblyLinearVelocity.Magnitude
                
                -- Tính toán thời gian bóng chạm vào người dựa trên vận tốc
                -- Càng nhanh thì khoảng cách kích hoạt phải càng xa một chút
                local dynamicRange = math.clamp(velocity * 0.15, Config.SpamRange, Config.ParryRange)

                if isBallTargetingMe(ball) then
                    -- 1. Chế độ Auto Spam (Khi bóng cực gần và bay cực nhanh)
                    if distance <= Config.SpamRange then
                        Remote:FireServer()
                        if Config.DebugMode then print("🔥 SPAM PARRY!") end
                    
                    -- 2. Chế độ Auto Parry (Bình thường)
                    elseif distance <= dynamicRange then
                        Remote:FireServer()
                        if Config.DebugMode then print("🛡️ AUTO PARRY - Khoảng cách: " .. math.floor(distance)) end
                    end
                end
            end
        end
    end
end)

print("✅ Script Auto Parry & Spam đã kích hoạt thành công!")
