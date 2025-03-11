local UserInputService = game:GetService("UserInputService")

local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {
    UICorner = 6,
    UIPadding = 8,
}

function Element:New(Config)
    local Keybind = {
        __type = "Keybind",
        Title = Config.Title or "Keybind",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        Value = Config.Value or "F",
        Callback = Config.Callback or function() end,
        CanChange = Config.CanChange or true,
        Picking = false,
        UIElements = {},
    }
    
    local CanCallback = true
    
    Keybind.KeybindFrame = require("../Components/Element")({
        Title = Keybind.Title,
        Desc = Keybind.Desc,
        Parent = Config.Parent,
        TextOffset = 85,
        Hover = Keybind.CanChange,
    })
    
    Keybind.UIElements.Keybind = New("TextLabel",{
        BackgroundTransparency = .95,
        Text = Keybind.Value,
        TextSize = 15,
        TextXAlignment = "Right",
        --AutomaticSize = "XY",
        FontFace = Font.new(Creator.Font),
        Parent = Keybind.KeybindFrame.UIElements.Main,
        Size = UDim2.new(0,0,0,0),
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        ThemeTag = {
            BackgroundColor3 = "Text",
            TextColor3 = "Text",
        },
        ZIndex = 2
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0,Element.UICorner)
        }),
        New("UIStroke", {
            ThemeTag = {
                Color = "Text",
            },
            Transparency = .93,
            ApplyStrokeMode = "Border",
            Thickness = 1,
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0,Element.UIPadding),
            PaddingLeft = UDim.new(0,Element.UIPadding),
            PaddingRight = UDim.new(0,Element.UIPadding),
            PaddingBottom = UDim.new(0,Element.UIPadding),
        })
    })
    
    Keybind.UIElements.Keybind:GetPropertyChangedSignal("TextBounds"):Connect(function()
        Keybind.UIElements.Keybind.Size = UDim2.new(0,Keybind.UIElements.Keybind.TextBounds.X+(Element.UIPadding*2),0,Keybind.UIElements.Keybind.TextBounds.Y+(Element.UIPadding*2))
    end)

    function Keybind:Lock()
        CanCallback = false
        return Keybind.KeybindFrame:Lock()
    end
    function Keybind:Unlock()
        CanCallback = true
        return Keybind.KeybindFrame:Unlock()
    end
    
    if Keybind.Locked then
        Keybind:Lock()
    end

    Keybind.KeybindFrame.UIElements.Main.MouseButton1Click:Connect(function()
        if CanCallback then
            if Keybind.CanChange then
                Keybind.Picking = true
                Keybind.UIElements.Keybind.Text = "..."
                
                task.wait(0.2)
                
                local Event
                Event = UserInputService.InputBegan:Connect(function(Input)
                    local Key
            
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
	                    Key = Input.KeyCode.Name
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
	                    Key = "MouseLeft"
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
	                    Key = "MouseRight"
                    end
            
                    local EndedEvent
                    EndedEvent = UserInputService.InputEnded:Connect(function(Input)
	                    if Input.KeyCode.Name == Key or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2 then
		                    Keybind.Picking = false
		    
		                    Keybind.UIElements.Keybind.Text = Key
		                    Keybind.Value = Key
		
		                    Event:Disconnect()
		                    EndedEvent:Disconnect()
	                    end
                    end)
                end)
            end
        end
    end) 
    UserInputService.InputBegan:Connect(function(input)
        if CanCallback then
            if input.KeyCode.Name == Keybind.Value then
                Keybind.Callback(input.KeyCode.Name)
            end
        end
    end)
    return Keybind.__type, Keybind
end

return Element