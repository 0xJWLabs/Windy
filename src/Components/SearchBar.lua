local UserInputService = game:GetService("UserInputService")

local SearchBar = {
    Margin = 6,
    Padding = 9,
}


local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween


function SearchBar.new(Elements, Parent, TabName, OnClose, ClipFrame)
    local SearchBarModule = {
        IconSize = 18
    }
    
    local UIScale = New("UIScale", {
        Scale = .9 -- 1
    })

    local UIStroke = New("UIStroke", {
        Thickness = 1.3,
        ThemeTag = {
            Color = "Text",
        },
        Transparency = 1, -- .95
    })
    
    local SearchFrame = New("CanvasGroup", {
        Size = UDim2.new(0.3,0,0,52 -(SearchBar.Margin*2)),
        Position = UDim2.new(1,-SearchBar.Margin,0,(((52 -(SearchBar.Margin*2))/2) + SearchBar.Margin)+52),
        AnchorPoint = Vector2.new(1,0.5),
        AutomaticSize = "X",
        BackgroundTransparency = 0.95,
        ThemeTag = {
            BackgroundColor3 = "Text",
        },
        Parent = Parent,
        ZIndex = 99999,
        Active = true,
        GroupTransparency = 1, -- 0
        Visible = false -- true
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0,12),
        }),
        New("ImageLabel", {
            Size = UDim2.new(0,SearchBarModule.IconSize,0,SearchBarModule.IconSize),
            Position = UDim2.new(0,SearchBar.Padding,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 1,
            Image = Creator.Icon("search")[1],
            ImageRectOffset = Creator.Icon("search")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("search")[2].ImageRectSize,
            ThemeTag = {
                ImageColor3 = "PlaceholderText"
            },
        }),
        New("TextBox", {
            Size = UDim2.new(1,-((SearchBar.Padding*2)+SearchBarModule.IconSize+SearchBar.Padding),1,0),
            Position = UDim2.new(1,-SearchBar.Padding,0,0),
            AnchorPoint = Vector2.new(1,0),
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            TextSize = 17,
            BackgroundTransparency = 1,
            MultiLine = false,
            PlaceholderText = "Search in " .. TabName,
            ThemeTag = {
                TextColor3 = "Text",
                PlaceholderColor3 = "PlaceholderText",
            }
        }),
        --UIStroke,
        UIScale,
        New("UISizeConstraint", {
            MaxSize = Vector2.new(Parent.AbsoluteSize.X, math.huge)
        })
    })
    
    function SearchBarModule:Open()
        SearchFrame.Visible = true
        Tween(SearchFrame, 0.35, {
            GroupTransparency = 0,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIScale, 0.35, {
            Scale = 1,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIStroke, 0.35, {
            Transparency = 0.95,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    function SearchBarModule:Close()
        Tween(SearchFrame, 0.35, {
            GroupTransparency = 1,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIScale, 0.35, {
            Scale = .9,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIStroke, 0.35, {
            Transparency = 1,
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        task.wait(.35)
        SearchFrame.Visible = false
        SearchFrame:Destroy()
    end
    
    function SearchBarModule:Search(Text)
        for _, Element in next, Elements do
            local TitleMatch = string.find(string.lower(Element.Title or ""), string.lower(Text))
            local DescMatch = Element.Desc and string.find(string.lower(Element.Desc or ""), string.lower(Text))
    
            local ElementFrame = Element[Element.__type .. "Frame"]
            if ElementFrame then
                ElementFrame.UIElements.MainContainer.Visible = TitleMatch or DescMatch or false
            else
                Element.UIElements.Main.Visible = TitleMatch or DescMatch or false
            end
        end
    end
    
    SearchFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        SearchBarModule:Search(SearchFrame.TextBox.Text)
    end)
    
    local inputConnection

    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
    
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
    
            local inSearchFrame = mousePos.X >= SearchFrame.AbsolutePosition.X 
                and mousePos.X <= (SearchFrame.AbsolutePosition.X + SearchFrame.AbsoluteSize.X)
                and mousePos.Y >= SearchFrame.AbsolutePosition.Y 
                and mousePos.Y <= (SearchFrame.AbsolutePosition.Y + SearchFrame.AbsoluteSize.Y)
            
            local inClipFrame = ClipFrame 
                and mousePos.X >= ClipFrame.AbsolutePosition.X 
                and mousePos.X <= (ClipFrame.AbsolutePosition.X + ClipFrame.AbsoluteSize.X)
                and mousePos.Y >= ClipFrame.AbsolutePosition.Y 
                and mousePos.Y <= (ClipFrame.AbsolutePosition.Y + ClipFrame.AbsoluteSize.Y)
            
            if not inSearchFrame and not inClipFrame then
                for _, Element in pairs(Elements) do
                    local ElementFrame = Element[Element.__type .. "Frame"]
                    if ElementFrame then
                        ElementFrame.UIElements.MainContainer.Visible = true
                    else
                        Element.UIElements.Main.Visible = true
                    end
                end
    
                OnClose()
                SearchBarModule:Close()
    
                if inputConnection then
                    inputConnection:Disconnect()
                    inputConnection = nil
                end
            end
        end
    end)
    SearchBarModule:Open()
    
    
    return SearchBarModule
    -- Debug
    
    --print(game:GetService("HttpService"):JSONEncode(Elements, true))
end

return SearchBar