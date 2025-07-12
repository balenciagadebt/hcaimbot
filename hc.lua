```lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Drawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robloxian1337/Drawing-Library/main/Drawing.lua"))()

getgenv().dhlock = {
    enabled = false,
    showfov = true,
    fov = 50,
    keybind = Enum.UserInputType.MouseButton2,
    teamcheck = false,
    wallcheck = false,
    alivecheck = false,
    lockpart = "Head",
    lockpartair = "Head",
    smoothness = 0.03,
    predictionX = 0.135,
    predictionY = 0.125,
    fovcolorlocked = Color3.new(1, 0, 0),
    fovcolorunlocked = Color3.new(0, 1, 0),
    toggle = false,
    blacklist = {}
}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera
local fovCircle = nil

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local function setupFovCircle()
    fovCircle = Drawing.new("Circle")
    fovCircle.Transparency = 0.5
    fovCircle.Thickness = 2
    fovCircle.NumSides = 100
    fovCircle.Radius = getgenv().dhlock.fov
    fovCircle.Visible = getgenv().dhlock.showfov
    fovCircle.Color = getgenv().dhlock.fovcolorunlocked
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

local function getNearestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local nearest = nil
    local shortestDist = getgenv().dhlock.fov

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and not table.find(getgenv().dhlock.blacklist, otherPlayer.Name) then
            local otherChar = otherPlayer.Character
            local targetPart = otherChar:FindFirstChild(getgenv().dhlock.lockpart)
            if targetPart and otherChar:FindFirstChild("Humanoid") then
                if not getgenv().dhlock.alivecheck or otherChar.Humanoid.Health > 0 then
                    if not getgenv().dhlock.teamcheck or otherPlayer.Team ~= player.Team then
                        if not getgenv().dhlock.wallcheck or not Workspace:FindPartOnRayWithIgnoreList(Ray.new(camera.CFrame.Position, targetPart.Position - camera.CFrame.Position), {character}) then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    nearest = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == getgenv().dhlock.keybind then
        if getgenv().dhlock.toggle then
            getgenv().dhlock.enabled = not getgenv().dhlock.enabled
        else
            getgenv().dhlock.enabled = true
        end
        fovCircle.Color = getgenv().dhlock.enabled and getgenv().dhlock.fovcolorlocked or getgenv().dhlock.fovcolorunlocked
        print("Aimbot " .. (getgenv().dhlock.enabled and "locked on, time to fuck up the block!" or "off, you chickening out?"))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == getgenv().dhlock.keybind and not getgenv().dhlock.toggle then
        getgenv().dhlock.enabled = false
        fovCircle.Color = getgenv().dhlock.fovcolorunlocked
        print("Aimbot off, what, you scared?")
    end
end)

RunService.RenderStepped:Connect(function()
    if getgenv().dhlock.enabled then
        local target = getNearestTarget()
        if target then
            local targetPos = target.Position + Vector3.new(getgenv().dhlock.predictionX, getgenv().dhlock.predictionY, 0)
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            camera.CFrame = currentCFrame:Lerp(targetCFrame, getgenv().dhlock.smoothness)
        end
    end
    if fovCircle then
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
end)

setupFovCircle()
print("Hood Customs aimbot loaded. Time to run these streets, motherfucker.")
```
