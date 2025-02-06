-- KeyAuth Integration with Fluent UI and Trainer
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Application Details
local Name = "Templos720's Application"
local Ownerid = "QDCNFnSkHu"
local APPVersion = "1.0"
local sessionid = ""

-- Initialize Application
local req = game:HttpGet('https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=init&ver=' .. APPVersion)
local data = HttpService:JSONDecode(req)

if not data.success then
    StarterGui:SetCore("SendNotification", {
        Title = "KeyAuth",
        Text = "Error: " .. data.message,
        Duration = 5
    })
    return
end

sessionid = data.sessionid

-- Load Fluent UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/fluent-ui.lua"))()
local Window = Library.CreateLib("Fluent Trainer - KeyAuth")

-- Create Tabs
local LoginTab = Window:NewTab("Login")
local MainSection = LoginTab:NewSection("Login")

local Username, Password = "Templo", "Templos@123"

MainSection:NewTextBox("Username", "Enter your username", function(value)
    Username = value
end)

MainSection:NewTextBox("Password", "Enter your password", function(value)
    Password = value
end)

MainSection:NewButton("Login", "Authenticate via KeyAuth", function()
    if Username == "" or Password == "" then
        StarterGui:SetCore("SendNotification", {
            Title = "KeyAuth",
            Text = "Error: Username or Password is empty.",
            Duration = 3
        })
        return
    end

    local loginReq = game:HttpGet('https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=login&username=' .. Username .. '&pass=' .. Password .. '&ver=' .. APPVersion .. '&sessionid=' .. sessionid)
    local loginData = HttpService:JSONDecode(loginReq)

    if not loginData.success then
        StarterGui:SetCore("SendNotification", {
            Title = "KeyAuth",
            Text = "Error: " .. loginData.message,
            Duration = 5
        })
        return
    end

    StarterGui:SetCore("SendNotification", {
        Title = "KeyAuth",
        Text = "Login Successful!",
        Duration = 5
    })

    -- Trainer UI after login
    local TrainerTab = Window:NewTab("Trainer")
    local TrainerSection = TrainerTab:NewSection("Trainer Options")

    TrainerSection:NewButton("Activate God Mode", "Become invincible", function()
        -- God Mode logic
    end)

    TrainerSection:NewButton("Unlock All Skills", "Gain access to all abilities", function()
        -- Unlock skills logic
    end)
end)
