
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Templo Hub " .. Fluent.Version,
    SubTitle = "Project Baki 3",
    TabWidth = 100,
    Size = UDim2.fromOffset(320, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local warn = Tabs.Main:AddSection("Not all of them will work")

-- Coletando os nomes dos trainers do workspace
local trainers = {}
for _, trainer in pairs(workspace:WaitForChild("Game"):WaitForChild("Trainers"):GetChildren()) do
    if trainer:IsA("Model") then
        table.insert(trainers, trainer.Name)
    end
end

local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
    Title = "",
    Values = trainers,
    Multi = false,
    Default = #trainers > 0 and 1 or nil, -- Evita erro caso trainers esteja vazio
})

if #trainers > 0 then
    Dropdown:SetValue(trainers[1])
end

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("Quest"):InvokeServer(Value)
end)

-- Criando o Toggle de GodMode
local GodMod = Tabs.Main:AddToggle("GodMode", { Title = "GodMode", Default = false })

GodMod:OnChanged(function(t)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local healPlate = nil
    local running = true

    -- Função para encontrar o HealPlate
    local function findHealPlate()
        if healPlate and healPlate.Parent then
            return healPlate
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "HealPlate" then
                healPlate = obj
                return healPlate
            end
        end
        return nil
    end

    -- Loop assíncrono para o GodMode
    task.spawn(function()
        while t and running do
            local healPlate = findHealPlate()
            if healPlate and character and character:FindFirstChild("HumanoidRootPart") then
                healPlate.CFrame = CFrame.new(character.HumanoidRootPart.Position - Vector3.new(0, character.HumanoidRootPart.Size.Y / 2, 0))
                healPlate.Transparency = 1
                healPlate.CanCollide = false
            end
            task.wait(1)
        end
        running = false
    end)
end)


local AutoRelics = Tabs.Main:AddToggle("AutoRelics", { Title = "Auto Relics", Default = false })

AutoRelics:OnChanged(function(enabled)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local trinketFolder = workspace:WaitForChild("Game"):WaitForChild("Trinkets"):WaitForChild("Spawned")
    local running = enabled
    local connection = nil

    -- Função para teleportar para a primeira Part encontrada
    local function teleportToRelic()
        for _, relic in pairs(trinketFolder:GetChildren()) do
            if relic:IsA("Part") and relic:FindFirstChild("TouchInterest") then
                humanoidRootPart.CFrame = relic.CFrame + Vector3.new(0, 3, 0) -- Teleporta acima
                task.wait(0.7) -- Tempo para evitar bugs
                return
            end
        end
    end

    -- Loop para verificar continuamente
    task.spawn(function()
        while running do
            if AutoRelics.Value then
                teleportToRelic()
            end
            task.wait(1)
        end
    end)

    -- Aguarda novas relíquias sendo geradas e teleporta automaticamente
    if enabled then
        connection = trinketFolder.ChildAdded:Connect(function(child)
            if child:IsA("Part") and AutoRelics.Value then
                teleportToRelic()
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end)
