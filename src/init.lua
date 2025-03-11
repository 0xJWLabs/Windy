local Windy = {
    Window = nil,
    Theme = nil,
    Themes = nil,
    Transparent = false,
    
    TransparencyValue = .25,
}
local RunService = game:GetService("RunService")

local Themes = require("./Themes/init")
local KeySystem = require("./Components/KeySystem")
local Creator = require("./Creator")

local New = Creator.New
local Tween = Creator.Tween

local LocalPlayer = game:GetService("Players") and game:GetService("Players").LocalPlayer or nil

Windy.Themes = Themes

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end


Windy.ScreenGui = New("ScreenGui", {
    Name = "Windy",
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or gethui and gethui() or game.CoreGui,
    IgnoreGuiInset = true,
}, {
    New("Folder", {
        Name = "Window"
    }),
    New("Folder", {
        Name = "Notifications"
    }),
    New("Folder", {
        Name = "Dropdowns"
    }),
    New("Folder", {
        Name = "KeySystem"
    }),
    New("Folder", {
        Name = "ToolTips"
    })
})
ProtectGui(Windy.ScreenGui)


local Notify = require("./Components/Notification")
local Holder = Notify.Init(Windy.ScreenGui.Notifications)

function Windy:Notify(Config)
    Config.Holder = Holder.Frame
    Config.Window = Windy.Window
    Config.Windy = Windy
    return Notify.New(Config)
end

function Windy:SetNotificationLower(Val)
    Holder.SetLower(Val)
end

function Windy:SetFont(FontId)
    Creator.UpdateFont(FontId)
end

function Windy:AddTheme(LTheme)
    Themes[LTheme.Name] = LTheme
    return LTheme
end

function Windy:SetTheme(Value)
if Themes[Value] then
    Windy.Theme = Themes[Value]
    Creator.SetTheme(Themes[Value])
    Creator.UpdateTheme()
    
    return Themes[Value]
end
return nil
end

function Windy:GetThemes()
    return Themes
end
function Windy:GetCurrentTheme()
    return Windy.Theme.Name
end
function Windy:GetTransparency()
    return Windy.Transparent or false
end
function Windy:GetWindowSize()
    return Window.UIElements.Main.Size
end



function Windy:CreateWindow(Config)
    local CreateWindow = require("./Components/Window")
    
    if not isfolder("Windy") then
        makefolder("Windy")
    end
    if Config.Folder then
        makefolder(Config.Folder)
    else
        makefolder(Config.Title)
    end
    
    Config.Windy = Windy
    Config.Parent = Windy.ScreenGui.Window
    
    if Windy.Window then
        warn("You cannot create more than one window")
        return
    end
    
    local CanLoadWindow = true
    
    local Theme = Themes[Config.Theme or "Dark"]
    
    Windy.Theme = Theme
    
    Creator.SetTheme(Theme)
    
    local Filename = LocalPlayer.Name or "Unknown"
    
    if Config.KeySystem then
        CanLoadWindow = false
        if Config.KeySystem.SaveKey and Config.Folder then
            if isfile(Config.Folder .. "/" .. Filename .. ".key") then
                local isKey = tostring(Config.KeySystem.Key) == tostring(readfile(Config.Folder .. "/" .. Filename .. ".key" ))
                if type(Config.KeySystem.Key) == "table" then
                    isKey = table.find(Config.KeySystem.Key, readfile(Config.Folder .. "/" .. Filename .. ".key" ))
                end
                if isKey then
                    CanLoadWindow = true
                end
            else
                KeySystem.new(Config, Filename, function(c) CanLoadWindow=c end)
            end
        else
            KeySystem.new(Config, Filename, function(c) CanLoadWindow=c end)
        end
		repeat task.wait() until CanLoadWindow
    end
    
    local Window = CreateWindow(Config)

    Windy.Transparent = Config.Transparent
    Windy.Window = Window
    
    
    function Window:ToggleTransparency(Value)
        Windy.Transparent = Value
        Windy.Window.Transparent = Value
        
        Window.UIElements.Main.Background.BackgroundTransparency = Value and Windy.TransparencyValue or 0
        Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and Windy.TransparencyValue or 0
        Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1), 
            NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
        }
    end
    
    return Window
end

return Windy