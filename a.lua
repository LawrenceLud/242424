local name = "Templos720's Application" -- Nome da Aplicação no KeyAuth
local ownerid = "QDCNFnSkHu" -- ID do dono da aplicação
local version = "1.0" -- Versão da aplicação
local key = "KEYAUTH-JtugKZ-MWJX6d-PIvZ7f-DYshNw-89GjUC-VZhMQl" -- Chave do usuário

-- Carregar a biblioteca KeyAuth
local KeyAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/KeyAuth/KeyAuth-Lua/main/source.lua"))()

-- Inicializar a API
local Auth = KeyAuth:Create(name, ownerid, version)

-- Tentar fazer login com a chave
if Auth:Login(key) then
    print("✅ Autenticação bem-sucedida! Iniciando script...")

    -- Carregar Fluent apenas se a autenticação for válida
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    -- Criando a janela principal do Fluent
    local Window = Fluent:CreateWindow({
        Title = "Templo Hub " .. Fluent.Version,
        SubTitle = "Project Baki 3",
        TabWidth = 100,
        Size = UDim2.fromOffset(320, 320),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local Options = Fluent.Options
    local warn = Tabs.Main:AddSection("Not all of them will work")

    -- Coletando os nomes dos trainers que possuem algo relacionado a 'Style' em seus descendentes
    local trainers = {}
    for _, trainer in pairs(workspace:WaitForChild("Game"):WaitForChild("Trainers"):GetChildren()) do
        if trainer:IsA("Model") then
            for _, descendant in pairs(trainer:GetDescendants()) do
                if descendant:IsA("StringValue") and string.find(descendant.Name, "Style") then
                    table.insert(trainers, trainer.Name) -- Adicionando os nomes dos trainers que possuem 'Style'
                    break
                end
            end
        end
    end

    -- Criando o Dropdown para selecionar o Trainer
    local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
        Title = "",
        Values = trainers,
        Multi = false,
        Default = 1,
    })

    if #trainers > 0 then
        Dropdown:SetValue(trainers[1]) -- Definindo o valor inicial como o primeiro trainer
    end

    Dropdown:OnChanged(function(Value)
        print("Dropdown changed:", Value)

        -- Invocando o comando de Quest para o trainer selecionado
        local args = {
            [1] = Value -- Nome do trainer selecionado
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientToServer"):WaitForChild("Quest"):InvokeServer(unpack(args))
    end)

else
    print("❌ Falha na autenticação! O script não será executado.")
    return -- Impede a execução do restante do código
end
