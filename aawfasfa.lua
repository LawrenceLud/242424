local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Templo Hub " .. Fluent.Version,
    SubTitle = "Project Baki 3",
    TabWidth = 100,
    Size = UDim2.fromOffset(350, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    ShadowFarm = Window:AddTab({ Title = "Shadow Farm", Icon = "" }),
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
    Multi = false
})

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("Quest"):InvokeServer(Value)
end)

-- Toggle para GodMode
local GodMod = Tabs.Main:AddToggle("GodMode", { 
    Title = "GodMode", 
    Default = false 
})

local godModeRunning = false

GodMod:OnChanged(function(t)
    godModeRunning = t

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local healPlate = nil

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

    task.spawn(function()
        while godModeRunning do
            local healPlate = findHealPlate()
            if healPlate and character and character:FindFirstChild("HumanoidRootPart") then
                healPlate.CFrame = character.HumanoidRootPart.CFrame
                healPlate.Size = Vector3.new(0.1, 0.1, 0.1)
                healPlate.Transparency = 1
                healPlate.CanCollide = false
            end
            task.wait(1) -- Aumentamos o intervalo para reduzir a carga
        end

        if not godModeRunning then
            local healPlate = findHealPlate()
            if healPlate then
                healPlate.Size = Vector3.new(1, 1, 1)
                healPlate.Transparency = 1
                healPlate.CanCollide = true
            end
        end
    end)
end)

-- Função para usar a habilidade "Liver Blows"
local function usarHabilidade()
    local ClientToServer = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer")
    ClientToServer:WaitForChild("Skill"):FireServer("Liver Blows")
    task.wait(0.1)
    ClientToServer:WaitForChild("Skill"):FireServer("PRESSED", "Liver Blows", false)
    task.wait(0.1)
    ClientToServer:WaitForChild("Skill"):FireServer("RELEASED", "Liver Blows")
end

-- Função para atacar o inimigo mais próximo dentro de um raio específico
local function atacarInimigo(raio)
    local jogador = game.Players.LocalPlayer
    local npcMaisProximo = nil
    local distanciaMinima = raio

    for _, npc in pairs(workspace.Game.Players:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Name ~= jogador.Name then
            local npcHumanoidRootPart = npc:FindFirstChild("HumanoidRootPart")
            local jogadorHumanoidRootPart = jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart")
            
            if npcHumanoidRootPart and jogadorHumanoidRootPart then
                local distancia = (npcHumanoidRootPart.Position - jogadorHumanoidRootPart.Position).Magnitude
                if distancia < distanciaMinima then
                    distanciaMinima = distancia
                    npcMaisProximo = npc
                end
            end
        end
    end

    if npcMaisProximo and npcMaisProximo:FindFirstChild("Humanoid") then
        local humanoid = npcMaisProximo.Humanoid
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("BasicCombat"):FireServer("Skill", humanoid)
        task.wait(0.1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("BasicCombat"):FireServer("Skill", humanoid)
    end
end

-- Coletando as habilidades do jogador
local skills = {}
for _, skill in pairs(game.Players.LocalPlayer.Data.Skills:GetChildren()) do
    if skill:IsA("StringValue") then
        table.insert(skills, skill.Value)
    end
end
local autoRelic = Tabs.Main:AddToggle("AutoRelicTp", {
    Title = "Auto Relic",
    Default = false,
})

local player = game.Players.LocalPlayer
local autoRelicConnection = nil
local initialPosition
local lastRelic = nil -- Armazena a última relíquia teleportada

-- Função para armazenar a posição inicial
local function saveInitialPosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        initialPosition = player.Character.HumanoidRootPart.Position
    end
end

-- Função para retornar à posição inicial
local function returnToInitialPosition()
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if rootPart and initialPosition then
        rootPart.CFrame = CFrame.new(initialPosition)
    end
end

-- Função para encontrar objetos no nil
local function getNil(name, class)
    for _, v in next, getnilinstances() do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

-- Função para pegar a Relic automaticamente
local function collectRelic(relic)
    if relic and (relic:IsA("MeshPart") or relic:IsA("Part") or relic:IsA("Model")) then
        local args = {
            [1] = "Accept",
            [2] = relic
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("Artifact"):FireServer(unpack(args))
    end
end

-- Função para teleportar para a relic e pegar automaticamente
local function teleportToObject(obj)
    if obj and player.Character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local targetPosition

            if obj:IsA("Model") and obj.PrimaryPart then
                targetPosition = obj.PrimaryPart.Position
            elseif obj:IsA("BasePart") then
                targetPosition = obj.Position
            end

            if targetPosition then
                -- Teleporta para a relic
                rootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
                lastRelic = obj -- Armazena a relíquia teleportada

                -- Tenta clicar no botão "Yes"
                local artifactGui = player.PlayerGui:FindFirstChild("Artifact")
                if artifactGui and artifactGui:FindFirstChild("Main") then
                    local yesButton = artifactGui.Main:FindFirstChild("yes")
                    if yesButton and yesButton:IsA("TextButton") and yesButton.Visible then
                        yesButton:FireServer()
                        print("Botão 'Yes' clicado automaticamente.")
                    end
                end

                -- Aguarda um pouco e tenta pegar a relic
                task.wait(3)
                collectRelic(lastRelic)

                -- Retorna à posição inicial
                returnToInitialPosition()
            end
        end
    end
end

-- Atualiza a posição inicial no respawn
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    saveInitialPosition()
end)

-- Configura o toggle
autoRelic:OnChanged(function(tprelic)
    if tprelic then
        saveInitialPosition()

        -- Desconecta a conexão anterior se existir
        if autoRelicConnection then
            autoRelicConnection:Disconnect()
        end

        -- Conecta ao evento para detectar novas relics
        autoRelicConnection = workspace.Game.Trinkets.Spawned.ChildAdded:Connect(function(child)
            if child:IsA("MeshPart") or child:IsA("Part") or child:IsA("Model") then
                teleportToObject(child)
            end
        end)

        -- Teleporta para todas as relics já spawnadas
        for _, child in ipairs(workspace.Game.Trinkets.Spawned:GetChildren()) do
            if child:IsA("MeshPart") or child:IsA("Part") or child:IsA("Model") then
                teleportToObject(child)
            end
        end
    else
        -- Desconecta o evento
        if autoRelicConnection then
            autoRelicConnection:Disconnect()
            autoRelicConnection = nil
        end
    end
end)


local warn = Tabs.Main:AddSection("Select Skill")
local warn = Tabs.Main:AddSection("I recommend using Boxing")

-- Dropdown para selecionar a habilidade
local SkillDropdown = Tabs.Main:AddDropdown("SkillDropdown", {
    Title = "",
    Values = skills,
    Multi = false,
    Default = #skills > 0 and skills[1] or nil,
})

local selectedSkill = nil

SkillDropdown:OnChanged(function(Value)
    selectedSkill = Value
    print("Skill selected:", selectedSkill)
end)

-- Função para atualizar o dropdown de habilidades
local function updateSkillDropdown()
    local updatedSkills = {}
    for _, skill in pairs(game.Players.LocalPlayer.Data.Skills:GetChildren()) do
        if skill:IsA("StringValue") then
            table.insert(updatedSkills, skill.Value)
        end
    end

    -- Atualiza o dropdown com as novas habilidades
    SkillDropdown:SetValues(updatedSkills)

    -- Se a habilidade selecionada não estiver mais na lista, redefine a seleção
    if not table.find(updatedSkills, selectedSkill) then
        selectedSkill = updatedSkills[1] -- Define a primeira habilidade disponível como selecionada
        SkillDropdown:SetValue(selectedSkill) -- Use SetValue instead of Set
    end
end

-- Loop para verificar mudanças no valor das skills e manter o dropdown atualizado
task.spawn(function()
    while true do
        updateSkillDropdown()
        task.wait(5) -- Aumentamos o intervalo para reduzir a carga
    end
end)

-- Toggle para Multi Attack (Instant kill)
local MultiAttackToggle = Tabs.Main:AddToggle("MultiAttack", { 
    Title = "Instant kill", 
    Default = false 
})

local running = false

MultiAttackToggle:OnChanged(function(enabled)
    running = enabled
    local raioDeAtaque = 50

    task.spawn(function()
        while running do
            if not selectedSkill then
                warn("No skill selected!")
                running = false
                MultiAttackToggle:Set(false)
                return
            end

            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            local function usarHabilidade()
                local ClientToServer = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer")
                ClientToServer:WaitForChild("Skill"):FireServer(selectedSkill)
                task.wait(0.1)
                ClientToServer:WaitForChild("Skill"):FireServer("PRESSED", selectedSkill, false)
                task.wait(0.1)
                ClientToServer:WaitForChild("Skill"):FireServer("RELEASED", selectedSkill)
            end

            local function atacarInimigo(raio)
                local npcMaisProximo = nil
                local distanciaMinima = raio

                for _, npc in pairs(workspace.Game.Players:GetChildren()) do
                    if npc:FindFirstChild("Humanoid") and npc.Name ~= player.Name then
                        local npcHumanoidRootPart = npc:FindFirstChild("HumanoidRootPart")
                        local jogadorHumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        
                        if npcHumanoidRootPart and jogadorHumanoidRootPart then
                            local distancia = (npcHumanoidRootPart.Position - jogadorHumanoidRootPart.Position).Magnitude
                            if distancia < distanciaMinima then
                                distanciaMinima = distancia
                                npcMaisProximo = npc
                            end
                        end
                    end
                end

                if npcMaisProximo and npcMaisProximo:FindFirstChild("Humanoid") then
                    local humanoid = npcMaisProximo.Humanoid
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("BasicCombat"):FireServer("Skill", humanoid)
                    task.wait(0.1)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("BasicCombat"):FireServer("Skill", humanoid)
                end
            end

            for i = 1, 20 do -- Reduzimos o número de execuções simultâneas
                task.spawn(function()
                    if not running then return end
                    usarHabilidade()
                    atacarInimigo(raioDeAtaque)
                end)
            end
            task.wait(0.5) -- Aumentamos o intervalo para reduzir a carga
        end
    end)
end)
