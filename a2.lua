local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criando a janela principal do Fluent
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
        table.insert(trainers, trainer.Name) -- Adicionando os nomes dos trainers
    end
end

-- Criando o Dropdown para selecionar o Trainer
local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
    Title = "Escolha um Trainer",
    Values = trainers,
    Multi = false,
    Default = (#trainers > 0 and trainers[1] or nil), -- Evita erro caso `trainers` esteja vazio
})

if #trainers > 0 then
    Dropdown:SetValue(trainers[1])
end

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)

    -- Invocando o comando de Quest para o trainer selecionado
    local args = { [1] = Value } -- Nome do trainer selecionado

    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("Quest"):InvokeServer(unpack(args))
end)

-- Adicionando o Toggle para o Kill Aura
local KillAuraToggle = Tabs.Main:AddToggle("Kill Aura", {
    Default = false,
    Tooltip = "Ativa ou desativa a Kill Aura."
})

local KillAuraActive = false

KillAuraToggle:OnChanged(function(State)
    KillAuraActive = State

    if State then
        print("Kill Aura ativada")
        
        -- Função para a Kill Aura, procurando por mobs no workspace
        task.spawn(function()
            while KillAuraActive do
                for _, mob in pairs(workspace:WaitForChild("Game"):WaitForChild("Mobs"):GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
                        local humanoid = mob:FindFirstChild("Humanoid")
                        
                        -- Invocando o comando de ataque para o mob atual
                        local args = {
                            [1] = "Light Punch",
                            [2] = 1,
                            [3] = humanoid, -- Certifique-se de que o servidor aceita isso como alvo
                            [6] = false
                        }
                        
                        -- Enviando a requisição para o servidor
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("BasicCombat"):FireServer(unpack(args))
                    end
                end
                task.wait(0.5) -- Usa `task.wait` para melhor desempenho
            end
        end)
    else
        print("Kill Aura desativada")
    end
end)
