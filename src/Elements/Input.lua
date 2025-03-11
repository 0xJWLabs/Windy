local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {
    UICorner = 6,
    UIPadding = 8,
}

function Element:New(Config)
    local Input = {
        __type = "Input",
        Title = Config.Title or "Input",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        PlaceholderText = Config.PlaceholderText or "Enter Text...",
        Value = Config.Value or "",
        Callback = Config.Callback or function() end,
        ClearTextOnFocus = Config.ClearTextOnFocus or false,
        UIElements = {},
    }
    
    local CanCallback = true
    
    Input.InputFrame = require("../Components/Element")({
        Title = Input.Title,
        Desc = Input.Desc,
        Parent = Config.Parent,
        TextOffset = 160,
        Hover = false,
    })
    
    Input.UIElements.Input = New("Frame",{
        BackgroundTransparency = .95,
        Parent = Input.InputFrame.UIElements.Main,
        Size = UDim2.new(0,30*5,0,30),
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        ThemeTag = {
            BackgroundColor3 = "Text",
        },
        ZIndex = 2
    }, {
        New("TextBox", {
            MultiLine = false,
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            BackgroundTransparency = 1,
            Position = UDim2.new(0,0,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            ClearTextOnFocus = Input.ClearTextOnFocus,
            Text = Input.Value,
            TextSize = 15,
            ClipsDescendants = true,
            TextXAlignment = "Left",
            FontFace = Font.new(Creator.Font),
            PlaceholderText = Input.PlaceholderText,
            ThemeTag = {
                TextColor3 = "Text",
                PlaceholderColor3 = "PlaceholderText",
            }
        }),
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
    
    -- Input.UIElements.Input.TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --     Input.UIElements.Input.TextBox.Size = UDim2.new(1,0,0,Input.UIElements.Input.TextBox.TextBounds.Y)
    -- end)

    function Input:Lock()
        CanCallback = false
        return Input.InputFrame:Lock()
    end
    function Input:Unlock()
        CanCallback = true
        return Input.InputFrame:Unlock()
    end
    
    if Input.Locked then
        Input:Lock()
    end
    
    Input.UIElements.Input.TextBox.Focused:Connect(function()
        if not CanCallback then
            Input.UIElements.Input.TextBox:ReleaseFocus()
            return
        end
        Tween(Input.UIElements.Input.UIStroke, 0.1, {Transparency = .8}):Play()
    end)
    
    Input.UIElements.Input.TextBox.FocusLost:Connect(function()
        if CanCallback then
            Input.Callback(Input.UIElements.Input.TextBox.Text)
            Tween(Input.UIElements.Input.UIStroke, 0.1, {Transparency = .93}):Play()
        end
    end)

    return Input.__type, Input
end

return Element