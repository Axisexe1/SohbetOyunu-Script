local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Sohbet Oyunu | Script",
    Author = "By Axis.",
    Folder = "SohbetOyunu",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.Insert
})

local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local VisualsTab = Window:Tab({ Title = "Visuals / ESP", Icon = "eye" })
local BoostTab = Window:Tab({ Title = "Boost", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

local ActionSection = PlayerTab:Section({ 
    Title = "Action", 
    Opened = true 
})

ActionSection:Slider({
    Title = "Speed",
    Desc = "",
    Icon = "gauge",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

ActionSection:Slider({
    Title = "JumpPower",
    Desc = "",
    Icon = "arrow-up",
    Step = 1,
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
})

local infJump = false
local infJumpConn

local function startInfJump()
    local player = game.Players.LocalPlayer
    infJumpConn = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Space and infJump then
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function stopInfJump()
    if infJumpConn then
        infJumpConn:Disconnect()
        infJumpConn = nil
    end
end

ActionSection:Toggle({
    Title = "Infinite Jump",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        infJump = state
        if state then
            startInfJump()
        else
            stopInfJump()
        end
    end
})

local noclip = false
local noclipConn

local function startNoclip()
    noclipConn = game:GetService("RunService").Stepped:Connect(function()
        if not noclip then return end
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

ActionSection:Toggle({
    Title = "Noclip",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        noclip = state
        if state then
            startNoclip()
        else
            stopNoclip()
        end
    end
})

local antivoid = false
local antivoidConn

local function getNearestPart(pos, char)
    local nearest = nil
    local minDist = math.huge
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored and part.CanCollide and not part:IsDescendantOf(char) then
            if part.Size.Magnitude > 2 then
                local dist = (part.Position - pos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = part
                end
            end
        end
    end
    return nearest
end

local function startAntiVoid()
    antivoidConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not antivoid then return end
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if hrp.Position.Y < -50 then
            local nearest = getNearestPart(hrp.Position, char)
            if nearest then
                hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, nearest.Size.Y / 2 + 5, 0))
            else
                local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end

local function stopAntiVoid()
    if antivoidConn then
        antivoidConn:Disconnect()
        antivoidConn = nil
    end
end

ActionSection:Toggle({
    Title = "Anti-Void",
    Desc = "Boşluğa Düşmenizi Engeller",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        antivoid = state
        if state then
            startAntiVoid()
        else
            stopAntiVoid()
        end
    end
})

local FlySection = PlayerTab:Section({ 
    Title = "Fly", 
    Opened = true 
})

local flying = false
local flySpeed = 50
local flyConnection
local bodyGyro
local bodyVelocity

local function startFly()
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.Parent = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = hrp

    flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame

        local move = Vector3.zero
        local UIS = game:GetService("UserInputService")

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end

        bodyVelocity.Velocity = move * flySpeed
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect() end
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end

    local char = game.Players.LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then 
        humanoid.PlatformStand = false 
        humanoid.AutoRotate = true 
    end
end

FlySection:Toggle({
    Title = "Fly",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        flying = state
        if state then
            startFly()
        else
            stopFly()
        end
    end
})

FlySection:Slider({
    Title = "Fly Speed",
    Desc = "",
    Icon = "gauge",
    Step = 1,
    Value = { Min = 10, Max = 400, Default = 50 },
    Callback = function(value)
        flySpeed = value
    end
})

local TPSection = PlayerTab:Section({ 
    Title = "Teleport", 
    Opened = true 
})

local selectedPlayer = nil

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local playerDropdown = TPSection:Dropdown({
    Title = "Select Player",
    Desc = "",
    Values = getPlayerNames(),
    Value = nil,
    Callback = function(option)
        selectedPlayer = option
    end
})

TPSection:Button({
    Title = "Teleport",
    Desc = "",
    Icon = "arrow-right",
    Callback = function()
        if not selectedPlayer then return end
        local target = game.Players:FindFirstChild(selectedPlayer)
        if not target then return end
        local targetChar = target.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myChar = game.Players.LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if targetHrp and myHrp then
            myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 0, 3)
        end
    end
})

TPSection:Button({
    Title = "Refresh",
    Desc = "",
    Icon = "refresh-cw",
    Callback = function()
        playerDropdown:SetValues(getPlayerNames())
    end
})

local atpeEnabled = false
local atpeConnection = nil
local lastPos = nil
local atpeCooldown = false

TPSection:Toggle({
    Title = "ATPE",
    Desc = "Biri Sizi Yanına Çekiyorsa Eski Yerinize Işınlanırsınız.",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        atpeEnabled = state
        if state then
            atpeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not atpeEnabled or atpeCooldown then return end
                local char = game.Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                if lastPos == nil then
                    lastPos = hrp.Position
                else
                    local dist = (hrp.Position - lastPos).Magnitude
                    
                    if dist > 30 then
                        atpeCooldown = true
                        hrp.CFrame = CFrame.new(lastPos)
                        task.wait(0.5)
                        lastPos = hrp.Position
                        atpeCooldown = false
                    else
                        if dist > 1 and not (char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0.1) then
                            lastPos = hrp.Position
                        elseif dist < 1 then
                            lastPos = hrp.Position
                        end
                    end
                end
            end)
        else
            if atpeConnection then
                atpeConnection:Disconnect()
                atpeConnection = nil
            end
            lastPos = nil
        end
    end
})

local ESPSection = VisualsTab:Section({ 
    Title = "ESP", 
    Opened = true 
})

local espEnabled = false
local espStyle = "Highlight"
local espColor = Color3.fromRGB(255, 0, 0)
local highlights = {}

local function applyStyle(hl)
    if not hl then return end
    hl.FillColor = espColor
    hl.OutlineColor = espColor
    if espStyle == "Highlight" then
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
    else
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
    end
end

local function createHighlight(char)
    if not char then return end
    local old = char:FindFirstChild("ESP_Highlight")
    if old then old:Destroy() end
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = char
    hl.Parent = char
    
    applyStyle(hl)
    highlights[char] = hl
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if espEnabled then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer then
                    local char = plr.Character
                    if char then
                        if not highlights[char] or not highlights[char].Parent then
                            createHighlight(char)
                        else
                            applyStyle(highlights[char])
                        end
                    end
                end
            end
            for char, hl in pairs(highlights) do
                if not char.Parent or not char:IsDescendantOf(workspace) then
                    hl:Destroy()
                    highlights[char] = nil
                end
            end
        else
            for char, hl in pairs(highlights) do
                hl:Destroy()
            end
            table.clear(highlights)
        end
    end
end)

ESPSection:Toggle({
    Title = "Player ESP",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        espEnabled = state
    end
})

ESPSection:Dropdown({
    Title = "ESP Style",
    Desc = "",
    Values = { "Highlight", "Entire" },
    Value = "Highlight",
    Callback = function(option)
        espStyle = option
    end
})

ESPSection:Colorpicker({
    Title = "ESP Color",
    Desc = "",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        espColor = color
    end
})

local NameDistanceSection = VisualsTab:Section({ 
    Title = "Name & Distance", 
    Opened = true 
})

local nameEnabled = false
local distanceEnabled = false
local nameTags = {}
local distanceTags = {}

local function createNameTag(plr)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Size = 16
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Font = 6
    
    nameTags[plr] = { main = text }
end

local function createDistanceTag(plr)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = false
    text.Size = 14
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Font = 6
    
    distanceTags[plr] = { main = text }
end

task.spawn(function()
    while true do
        task.wait()
        local cam = workspace.CurrentCamera
        
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local myChar = game.Players.LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if hrp and myHrp then
                    local bodyPos = cam:WorldToViewportPoint(hrp.Position)
                    local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                    
                    if nameEnabled then
                        if not nameTags[plr] then createNameTag(plr) end
                        local tag = nameTags[plr]
                        tag.main.Visible = true
                        tag.main.Text = plr.Name
                        tag.main.Position = Vector2.new(bodyPos.X, bodyPos.Y)
                    else
                        if nameTags[plr] then nameTags[plr].main.Visible = false end
                    end
                    
                    if distanceEnabled then
                        if not distanceTags[plr] then createDistanceTag(plr) end
                        local tag = distanceTags[plr]
                        local dist = math.floor((hrp.Position - myHrp.Position).Magnitude)
                        tag.main.Visible = true
                        tag.main.Text = tostring(dist) .. "m"
                        tag.main.Position = Vector2.new(legPos.X, legPos.Y)
                    else
                        if distanceTags[plr] then distanceTags[plr].main.Visible = false end
                    end
                else
                    if nameTags[plr] then nameTags[plr].main.Visible = false end
                    if distanceTags[plr] then distanceTags[plr].main.Visible = false end
                end
            end
        end
        
        for plr, tag in pairs(nameTags) do
            if not plr.Parent then
                tag.main:Remove()
                nameTags[plr] = nil
            end
        end
        for plr, tag in pairs(distanceTags) do
            if not plr.Parent then
                tag.main:Remove()
                distanceTags[plr] = nil
            end
        end
    end
end)

NameDistanceSection:Toggle({
    Title = "Name",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        nameEnabled = state
    end
})

NameDistanceSection:Toggle({
    Title = "Distance",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        distanceEnabled = state
    end
})

local MiscSection = VisualsTab:Section({ 
    Title = "Misc", 
    Opened = true 
})

local originalBrightness = game:GetService("Lighting").Brightness
local originalAmbient = game:GetService("Lighting").Ambient
local fullbrightEnabled = false

MiscSection:Toggle({
    Title = "Fullbright",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        fullbrightEnabled = state
        local lighting = game:GetService("Lighting")
        if state then
            lighting.Brightness = 3
            lighting.ClockTime = 12
            lighting.GlobalShadows = false
            lighting.FogEnd = 100000
        else
            lighting.Brightness = originalBrightness
            lighting.GlobalShadows = true
        end
    end
})

MiscSection:Slider({
    Title = "Ambient",
    Desc = "",
    Step = 1,
    Value = { Min = 0, Max = 255, Default = originalAmbient.R * 255 },
    Callback = function(value)
        local v = value / 255
        game:GetService("Lighting").Ambient = Color3.fromRGB(v * 255, v * 255, v * 255)
    end
})

local BoostSection = BoostTab:Section({ 
    Title = "Auto Farm", 
    Opened = true 
})

local autoFarmEnabled = false
local autoFarmSpeed = 20
local tpX = 245
local tpY = 72
local tpZ = 297
local autoFarmConnection
local autoFarmNoclipConn
local autoFarmSitConn
local targetFolder = nil
local moneyList = {}
local charAddedConn
local autoFarmNoclipActive = false

local function findFolder()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Folder") then
            for _, child in ipairs(obj:GetChildren()) do
                if child.Name == "CashTemplate" or child.Name == "ParkourMoney" then
                    return obj
                end
            end
        end
    end
    return nil
end

local function collectMoney()
    moneyList = {}
    if not targetFolder then return end
    for _, child in ipairs(targetFolder:GetChildren()) do
        if child.Name ~= "CashTemplate" and child.Name ~= "MoneySound" and child:IsA("BasePart") then
            table.insert(moneyList, child)
        end
    end
end

local function startNoclip()
    autoFarmNoclipConn = game:GetService("RunService").Stepped:Connect(function()
        if not autoFarmEnabled then return end
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if autoFarmNoclipConn then
        autoFarmNoclipConn:Disconnect()
        autoFarmNoclipConn = nil
    end
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function startSitBlock()
    autoFarmSitConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        local char = game.Players.LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = false
        end
    end)
end

local function stopSitBlock()
    if autoFarmSitConn then
        autoFarmSitConn:Disconnect()
        autoFarmSitConn = nil
    end
end

local function getNearestMoney(hrp)
    local nearest = nil
    local minDist = math.huge
    for _, part in ipairs(moneyList) do
        if part and part.Parent and part.Transparency < 1 then
            local dist = (part.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = part
            end
        end
    end
    return nearest, minDist
end

local function startAutoFarm()
    targetFolder = findFolder()
    if not targetFolder then
        WindUI:Notify({ Title = "Error", Content = "Script Fix Yemiştir. Düzelmesini Bekleyin.", Icon = "x" })
        return
    end
    
    collectMoney()
    if #moneyList == 0 then
        WindUI:Notify({ Title = "Error", Content = "Script Fix Yemiştir. Düzelmesini Bekleyin.", Icon = "x" })
        return
    end
    
    startNoclip()
    autoFarmNoclipActive = true
    startSitBlock()
        if charAddedConn then charAddedConn:Disconnect() end
    charAddedConn = game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        if not autoFarmEnabled then return end
        task.wait(0.5)
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHrp then
        newHrp.CFrame = CFrame.new(tpX, tpY, tpZ)
        end
    end)
    
    autoFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end

        local nearest, dist = getNearestMoney(hrp)
        
        if not nearest then
            if autoFarmNoclipActive then
                stopNoclip()
                autoFarmNoclipActive = false
                if humanoid then humanoid.PlatformStand = false end
                workspace.Gravity = 196.2
                hrp.CFrame = CFrame.new(tpX, tpY, tpZ)
            end
            task.wait(1)
            return
        end
        
        if not autoFarmNoclipActive then
            startNoclip()
            autoFarmNoclipActive = true
        end
        
        
        if dist < 1.5 then
            hrp.CFrame = CFrame.new(nearest.Position)
            table.remove(moneyList, table.find(moneyList, nearest))
            return
        end
        
        if humanoid and not humanoid.PlatformStand then
            humanoid.PlatformStand = true
        end
        workspace.Gravity = 0
        
        local dir = (nearest.Position - hrp.Position).Unit
        hrp.CFrame = hrp.CFrame + dir * (autoFarmSpeed * 0.016)
    end)
end

BoostSection:Toggle({
    Title = "AutoFarm",
    Desc = "",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        if state then
            startAutoFarm()
        else
            autoFarmNoclipActive = false        
            if charAddedConn then
                charAddedConn:Disconnect()
                charAddedConn = nil
            end
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            stopNoclip()
            stopSitBlock()
            
            local char = game.Players.LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                humanoid.PlatformStand = false
            end
            workspace.Gravity = 196.2
        end
    end
})

BoostSection:Slider({
    Title = "Farm Speed",
    Desc = "Yüksek hız önerilmez",
    Step = 1,
    Value = { Min = 10, Max = 70, Default = 20 },
    Callback = function(value)
        autoFarmSpeed = value
    end
})

local Boost2Section = BoostTab:Section({ 
    Title = "AutoFarm2", 
    Opened = true 
})

local parkourSpeed = 0.5
local parkourTeleporting = false

Boost2Section:Button({
    Title = "Auto Farm 2",
    Desc = "Parkur Ödüllerini Alır",
    Icon = "zap",
    Callback = function()
        if parkourTeleporting then return end
        parkourTeleporting = true
        
        local folder = findFolder()
        if not folder then
            WindUI:Notify({ Title = "Error", Content = "Script Fix Yemiştir. Düzelmesini Bekleyin.", Icon = "x" })
            parkourTeleporting = false
            return
        end
        
        local parkourList = {}
        for _, child in ipairs(folder:GetChildren()) do
            if child.Name == "ParkourMoney" then
                table.insert(parkourList, child)
            end
        end
        
        if #parkourList == 0 then
            WindUI:Notify({ Title = "Error", Content = "Script Fix Yemiştir. Düzelmesini Bekleyin.", Icon = "x" })
            parkourTeleporting = false
            return
        end
        
        task.spawn(function()
            for i, model in ipairs(parkourList) do
                if not parkourTeleporting then break end
                local char = game.Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                
                local targetPos
                if model:IsA("Model") then
                    local ok, pivot = pcall(function() return model:GetPivot() end)
                    if ok then targetPos = pivot.Position else targetPos = model.Position end
                else
                    targetPos = model.Position
                end
                
                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                task.wait(parkourSpeed)
            end
            local finalChar = game.Players.LocalPlayer.Character
            local finalHrp = finalChar and finalChar:FindFirstChild("HumanoidRootPart")
            if finalHrp then
                finalHrp.CFrame = CFrame.new(tpX, tpY, tpZ)
            end

            parkourTeleporting = false
            WindUI:Notify({ Title = "Başarıyla Gerçekleşti!", Content = "Parkur Ödülleri Alındı", Icon = "check" })
        end)
    end
})

Boost2Section:Slider({
    Title = "Delay",
    Desc = "",
    Step = 0.05,
    Value = { Min = 0.5, Max = 5, Default = 0.5 },
    Callback = function(value)
        parkourSpeed = value
    end
})

local YDPTSection = BoostTab:Section({ 
    Title = "Dropped Cash", 
    Opened = true 
})

local ydptEnabled = false
local ydptConn
local ydptProcessing = false
local processedMoney = {}

local function getDroppedCashFolder()
    return workspace:FindFirstChild("DroppedCash")
end

local function clickMoney(money)
    local clickDetector = money:FindFirstChildOfClass("ClickDetector")
    if not clickDetector then return false end
    fireclickdetector(clickDetector)
    return true
end

local function startYDPT()
    ydptConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not ydptEnabled or ydptProcessing then return end
        
        local folder = getDroppedCashFolder()
        if not folder then return end
        
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetMoney = nil
        for _, money in ipairs(folder:GetChildren()) do
            if money.Name == "Money" and money.Parent and not processedMoney[money] then
                targetMoney = money
                break
            end
        end
        
        if targetMoney then
            ydptProcessing = true
            processedMoney[targetMoney] = true
            
            local originalCFrame = hrp.CFrame
            local moneyPos = targetMoney.Position
            
            hrp.CFrame = CFrame.new(moneyPos + Vector3.new(0, 3, 0))
            task.wait(0.15)
            
            clickMoney(targetMoney)
            task.wait(0.15)
            
            hrp.CFrame = originalCFrame
            task.wait(0.3)
            
            if targetMoney.Parent then
                processedMoney[targetMoney] = nil
            end
            
            ydptProcessing = false
        end
    end)
end

local function stopYDPT()
    if ydptConn then
        ydptConn:Disconnect()
        ydptConn = nil
    end
    ydptProcessing = false
    table.clear(processedMoney)
end

YDPTSection:Toggle({
    Title = "YBPT",
    Desc = "Yere bırakılan paraları toplar",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        ydptEnabled = state
        if state then
            startYDPT()
        else
            stopYDPT()
        end
    end
})

local SettingsSection = SettingsTab:Section({ 
    Title = "Settings", 
    Opened = true 
})

SettingsSection:Dropdown({
    Title = "Theme",
    Desc = "",
    Values = { "Dark", "Rose", "Plant", "Red", "Indigo", "Sky", "Violet", "Amber", "Emerald", "Midnight", "Crimson" },
    Value = "Dark",
    Callback = function(option)
        WindUI:SetTheme(option)
    end
})

SettingsSection:Button({
    Title = "Rejoin",
    Desc = "",
    Icon = "refresh-cw",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local player = game.Players.LocalPlayer
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
})

SettingsSection:Button({
    Title = "Server Hop",
    Desc = "",
    Icon = "shuffle",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local placeId = game.PlaceId
        
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if not success or not response then
            WindUI:Notify({ Title = "Error", Content = "Sunucu Listesi Alınamadı", Icon = "x" })
            return
        end
        
        local data = HttpService:JSONDecode(response)
        local servers = {}
        
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers == 0 then
            WindUI:Notify({ Title = "Error", Content = "Uygun Sunucu Bulunamadı", Icon = "x" })
            return
        end
        
        local randomServer = servers[math.random(1, #servers)]
        WindUI:Notify({ Title = "Bilgi", Content = "Sunucuya geçiliyor...", Icon = "info" })
        
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(placeId, randomServer, game.Players.LocalPlayer)
    end
})

SettingsSection:Button({
    Title = "v1.2",
    Callback = function() end
})
