local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

function Element:New(Config)
    local Section = {
        __type = "Section",
        Title = Config.Title or "Section",
        TextXAlignment = Config.TextXAlignment or "Left",
        TextSize = Config.TextSize or 17,
        UIElements = {},
    }
    
    Section.UIElements.Main = New("TextLabel", {
        BackgroundTransparency = 1,
        TextXAlignment = Section.TextXAlignment,
        AutomaticSize = "Y",
        TextSize = Section.TextSize,
        ThemeTag = {
            TextColor3 = "Text",
        },
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        Parent = Config.Parent,
        Size = UDim2.new(1,0,0,0),
        Text = Section.Title,
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0,4),
            PaddingBottom = UDim.new(0,2),
        })
    })

    -- Section.UIElements.Main:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --     Section.UIElements.Main.Size = UDim2.new(1,0,0,Section.UIElements.Main.TextBounds.Y)
    -- end)

    function Section:SetTitle(Title)
        Section.UIElements.Main.Text = Title
    end
    
    return Section.__type, Section
end

return Element