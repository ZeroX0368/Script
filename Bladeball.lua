local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Driving Empire - Auto Money", "Midnight")

-- Variables
local _G = {
    AutoFarm = false,
    FarmSpeed = 200 -- Tốc độ cày (Đừng để quá cao kẻo văng khỏi map)
}

-- Main Tab
local Main = Window:NewTab("Main")
local Section = Main:NewSection("Auto Money (Miles)")

Section:NewToggle("Auto Farm Money", "Tự động lái xe để kiếm tiền", function(state)
    _G.AutoFarm = state
    
    if state then
        spawn(function()
            while _G.AutoFarm do
                local char = game.Players.LocalPlayer.Character
                local veh = char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart and char.Humanoid.SeatPart.Parent
                
                if veh and veh:IsA("Model") then
                    -- Di chuyển xe về phía trước
                    veh:PivotTo(veh:GetPivot() * CFrame.new(0, 0, -(_G.FarmSpeed / 10)))
                else
                    print("Vui lòng ngồi vào xe để bắt đầu Farm!")
                end
                task.wait(0.01)
            end
        end)
    end
end)

Section:NewSlider("Farm Speed", "Điều chỉnh tốc độ cày tiền", 300, 50, function(s)
    _G.FarmSpeed = s
end)

-- Teleport Tab
local Teleport = Window:NewTab("Teleport")
local TPSection = Teleport:NewSection("Dịch chuyển nhanh")

TPSection:NewButton("Dealership", "Đến cửa hàng xe", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-650, 5, 550)
end)

TPSection:NewButton("Race Track", "Đến đường đua", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1200, 5, -2500)
end)

-- Settings Tab
local Settings = Window:NewTab("Settings")
local SSection = Settings:NewSection("Hệ thống")

SSection:NewKeybind("Đóng/Mở Menu", "Phím tắt menu", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

SSection:NewButton("Anti-AFK", "Tránh bị văng game khi treo máy", function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    print("Đã bật Anti-AFK")
end)
