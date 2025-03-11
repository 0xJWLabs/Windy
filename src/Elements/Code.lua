local Creator = require("../Creator")
local New = Creator.New

local Highlighter = require("../Highlighter")

local Element = {}

function Element:New(Config)
    local Code = {
        __type = "Code",
        Title = Config.Title,
        Code = Config.Code or nil,
        Locked = Config.Locked or false,
        UIElements = {}
    }
    
    local CanCallback = true
    
    Code.CodeFrame = require("../Components/Element")({
        Title = Code.Title,
        Desc = Code.Code,
        Parent = Config.Parent,
        TextOffset = 40,
        Hover = false,
    })
    
    Code.CodeFrame.UIElements.Main.Title.Desc:Destroy()
    
    local Divider = New("Frame", {
        Size = UDim2.new(1,Code.CodeFrame.UIPadding*2,0,1),
        -- Position = UDim2.new(0.5,0,0,0),
        -- AnchorPoint = Vector2.new(0.5,0),
        BackgroundTransparency = .94, 
        ThemeTag = {
            BackgroundColor3 = "Text"
        },
        Parent = Code.CodeFrame.UIElements.Main.Title,
        LayoutOrder = 1,
    })
    
    local CopyButton = New("ImageButton", {
        Image = Creator.Icon("clipboard")[1],
        ImageRectSize = Creator.Icon("clipboard")[2].ImageRectSize,
        ImageRectOffset = Creator.Icon("clipboard")[2].ImageRectPosition,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,14,0,14),
        Position = UDim2.new(1,40,0,0),
        AnchorPoint = Vector2.new(1,0),
        Parent = Code.CodeFrame.UIElements.Main.Title.Title
    })
    
    local TextLabel = New("TextLabel", {
        Text = "",
        TextColor3 = Color3.fromHex("#c9d1d9"),
        TextTransparency = 0,
        TextSize = 15,
        TextWrapped = false,
        LineHeight = 1.15,
        RichText = true,
        TextXAlignment = "Left",
        Size = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
    })
    
    TextLabel.FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium)
    
    local ScrollingFrame = New("ScrollingFrame", {
        Size = UDim2.new(1,0,0,0),
        BackgroundTransparency = 1,
        AutomaticCanvasSize = "X",
        ScrollingDirection = "X",
        ElasticBehavior = "Never",
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 0,
    }, {
        TextLabel
    })
    
    local ScrollingFrameContainer = New("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        BackgroundColor3 = Color3.fromRGB(13, 17, 23),
        BackgroundTransparency = .2,
        Parent = Code.CodeFrame.UIElements.Main.Title,
        LayoutOrder = 9999,
    }, {
        ScrollingFrame,
        New("UICorner", {
            CornerRadius = UDim.new(0,8),
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0,12),
            PaddingLeft = UDim.new(0,12),
            PaddingRight = UDim.new(0,12),
            PaddingBottom = UDim.new(0,12),
        })
    })
    
    TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        ScrollingFrame.Size = UDim2.new(1,0,0,TextLabel.TextBounds.Y)
    end)
    
    
    TextLabel.Text = Highlighter.run(Code.Code)

    function Code:Lock()
        CanCallback = false
        return Code.CodeFrame:Lock()
    end
    function Code:Unlock()
        CanCallback = true
        return Code.CodeFrame:Unlock()
    end
    function Code:SetCode(code)
        TextLabel.Text = Highlighter.run(code)
    end
    
    if Code.Locked then
        Code:Lock()
    end

    CopyButton.MouseButton1Click:Connect(function()
        if CanCallback then
            toclipboard(Code.Code)
            Config.Windy:Notify({
                Title = "Copied!",
                Content = "The '" .. Code.Title .. "' copied to your clipboard.",
                Icon = "clipboard-copy",
                Duration = 5,
            })
        end
    end)
    return Code.__type, Code
end

return Element