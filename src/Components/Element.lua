local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local UserInputService = game:GetService("UserInputService")

return function(Config)
    local Element = {
        Title = Config.Title,
        Desc = Config.Desc or nil,
        Hover = Config.Hover,
        Image = Config.Image,
        ImageSize = Config.ImageSize or 30,
        UIPadding = 12,
        UIElements = {}
    }
    
    local ImageSize = Element.ImageSize
    local CanHover = true
    local Hovering = false
    
    local ImageFrame
    if Element.Image then
        local ImageLabel = New("ImageLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            ThemeTag = Creator.Icon(Element.Image) and {
                ImageColor3 = "Text"
            } or nil
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,11)
            })
        })
        ImageFrame = New("Frame", {
            Size = UDim2.new(0,ImageSize,0,ImageSize),
            AutomaticSize = "XY",
            BackgroundTransparency = 1,
        }, {
            ImageLabel
        })
        if Creator.Icon(Element.Image) then
            ImageLabel.Image = Creator.Icon(Element.Image)[1]
            ImageLabel.ImageRectOffset = Creator.Icon(Element.Image)[2].ImageRectPosition
            ImageLabel.ImageRectSize = Creator.Icon(Element.Image)[2].ImageRectSize
        end
        if string.find(Element.Image,"http") then
            local success, response = pcall(function()
                if not isfile("Windy/" .. Config.Window.Folder .. "/Assets/" .. Element.Title .. ".png") then
                    local response = request({
                        Url = Element.Image,
                        Method = "GET",
                    }).Body
                    writefile("Windy/" .. Config.Window.Folder .. "/Assets/" .. Element.Title .. ".png", response)
                end
                ImageLabel.Image = getcustomasset("Windy/" .. Config.Window.Folder .. "/Assets/" .. Element.Title .. ".png")
            end)
            if not success then
                ImageLabel:Destroy()
                
                warn("[ Windy ]  '" .. identifyexecutor() .. "' doesnt support the URL Images. Error: " .. response)
            end
        elseif string.find(Element.Image,"rbxassetid") then
            ImageLabel.Image = Element.Image
        end
    end
    
    Element.UIElements.Main = New("TextButton", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        BackgroundTransparency = 0.95,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        ThemeTag = {
            BackgroundColor3 = "Text"
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0,8),
        }),
        New("UIScale", {
            Scale = 1,
        }),
        ImageFrame,
        New("Frame", {
            Size = UDim2.new(1,Element.Image and -(ImageSize+Element.UIPadding),0,0),
            AutomaticSize = "Y",
            AnchorPoint = Vector2.new(0,0),
            Position = UDim2.new(0,Element.Image and ImageSize+Element.UIPadding or 0,0,0),
            BackgroundTransparency = 1,
            Name = "Title"
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0,6),
                --VerticalAlignment = "Left",
            }),
            New("TextLabel", {
                Text = Element.Title,
                ThemeTag = {
                    TextColor3 = "Text"
                },
                TextSize = 15, 
                TextWrapped = true,
                RichText = true,
                LayoutOrder = 0,
                Name = "Title",
                TextXAlignment = "Left",
                Size = UDim2.new(1,-Config.TextOffset,0,0),
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = "Y"
            })
        }),
        -- New("ImageLabel", {
        --     Size = UDim2.new(1,Element.UIPadding*2,1,Element.UIPadding*2+6),
        --     Image = "rbxassetid://110049886226894",
        --     SliceCenter = Rect.new(512,512,512,512),
        --     ScaleType = "Slice",
        --     BackgroundTransparency = 1,
        --     ImageTransparency = .94,
        --     Position = UDim2.new(0.5,0,0.5,0),
        --     AnchorPoint = Vector2.new(0.5,0.5),
        -- }),
        New("UIStroke", {
            Thickness = 0.6,
            ThemeTag = {
                Color = "Text",
            },
            Transparency = 0.94,
            ApplyStrokeMode = "Border",
        }),
        New("Frame", {
            Size = UDim2.new(1,Element.UIPadding*2,1,Element.UIPadding*2+6),
            ThemeTag = {
                BackgroundColor3 = "Text"
            },
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Name = "Highlight"
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,11),
            }),
        }),
        New("Frame", {
            Size = UDim2.new(1,Element.UIPadding*2,1,Element.UIPadding*2+6),
            BackgroundColor3 = Color3.new(0,0,0),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            ZIndex = 999999,
            Name = "Lock"
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,8),
            }),
            New("ImageLabel", {
                Image = "rbxassetid://120011858138977",
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(0.5,0,0.5,0),
                Size = UDim2.new(0,26,0,26),
                ImageTransparency = 1,
                BackgroundTransparency = 1,
            })
        }),
        New("UIPadding", {
            PaddingTop = UDim.new(0,Element.UIPadding+3),
            PaddingLeft = UDim.new(0,Element.UIPadding),
            PaddingRight = UDim.new(0,Element.UIPadding),
            PaddingBottom = UDim.new(0,Element.UIPadding+3),
        }),
    })

    -- Element.UIElements.Main.Title.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --     Element.UIElements.Main.Title.Title.Size = UDim2.new(1,-Config.TextOffset,0,Element.UIElements.Main.Title.Title.TextBounds.Y)
    -- end)

    Element.UIElements.MainContainer = New("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Parent = Config.Parent,
    }, {
        Element.UIElements.Main,
        New("UIPadding", {
            PaddingTop = UDim.new(0,0),
            PaddingLeft = UDim.new(0,2),
            PaddingRight = UDim.new(0,2),
            PaddingBottom = UDim.new(0,2),
        })
    })
    
    -- Element.UIElements.Main.Title.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    --     Element.UIElements.Main.Size = UDim2.new(
    --         1,
    --         0,
    --         0,
    --         Element.UIElements.Main.Title.UIListLayout.AbsoluteContentSize.Y + (Element.UIPadding+3)*2
    --     )
    --     Element.UIElements.Main.Title.Size = UDim2.new(
    --         1,
    --         0,
    --         0,
    --         Element.UIElements.Main.Title.UIListLayout.AbsoluteContentSize.Y
    --     )
    --     Element.UIElements.MainContainer.Size = UDim2.new(
    --         1,
    --         0,
    --         0,
    --         Element.UIElements.Main.AbsoluteSize.Y
    --     )
    -- end)
    
    local Desc
    
    if Element.Desc then
        Desc = New("TextLabel", {
            Text = Element.Desc,
            ThemeTag = {
                TextColor3 = "Text"
            },
            TextTransparency = 0.4,
            TextSize = 15,
            TextWrapped = true,
            RichText = true,
            LayoutOrder = 9999,
            Name = "Desc",
            TextXAlignment = "Left",
            Size = UDim2.new(1,-Config.TextOffset,0,0),
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            AutomaticSize = "Y",
            Parent = Element.UIElements.Main.Title
        })
        -- Desc:GetPropertyChangedSignal("TextBounds"):Connect(function()
        --     Desc.Size = UDim2.new(1,-Config.TextOffset,0,Desc.TextBounds.Y)
        -- end)
    else
        Element.UIElements.Main.Title.AnchorPoint = Vector2.new(0,Config.IsButtons and 0 or 0.5)
        Element.UIElements.Main.Title.Size = UDim2.new(1,Element.Image and -(ImageSize+Element.UIPadding),0,0)
        Element.UIElements.Main.Title.Position = UDim2.new(0,Element.Image and ImageSize+Element.UIPadding or 0,Config.IsButtons and 0 or 0.5,0)
    end
    
    if Element.Hover then
        Element.UIElements.Main.MouseEnter:Connect(function()
            if CanHover then
                Tween(Element.UIElements.Main.Highlight, 0.066, {BackgroundTransparency = 0.97}):Play()
            end
        end)
        -- Element.UIElements.Main.MouseLeave:Connect(function()
        --     if CanHover then
        --     end
        -- end)
        
        Element.UIElements.Main.MouseButton1Down:Connect(function()
            if CanHover then
                Hovering = true
                Tween(Element.UIElements.Main.UIScale, 0.11, {Scale = .965}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
            end
        end)
        
        Element.UIElements.Main.InputEnded:Connect(function()
            if CanHover then
                Tween(Element.UIElements.Main.Highlight, 0.066, {BackgroundTransparency = 1}):Play()
                Tween(Element.UIElements.Main.UIScale, 0.175, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
                task.wait(.16)
                Hovering = false
            end
        end)
    end
    
    Element.UIElements.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not Hovering then
            Element.UIElements.MainContainer.Size = UDim2.new(1,0,0,Element.UIElements.Main.AbsoluteSize.Y)
        end
    end)
    
    function Element:SetTitle(Title)
        Element.UIElements.Main.Title.Title.Text = Title
    end
    function Element:SetDesc(Title)
        if Desc then
            Desc.Text = Title
        else
            Desc = New("TextLabel", {
                Text = Title,
                ThemeTag = {
                    TextColor3 = "Text"
                },
                TextTransparency = 0.4,
                TextSize = 15,
                TextWrapped = true,
                TextXAlignment = "Left",
                Size = UDim2.new(1,-Config.TextOffset,0,0),
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = "Y",
                Parent = Element.UIElements.Main.Title
            })
            -- Desc:GetPropertyChangedSignal("TextBounds"):Connect(function()
            --     Desc.Size = UDim2.new(1,-Config.TextOffset,0,Desc.TextBounds.Y)
            -- end)
        end
    end
    function Element:Lock()
        Tween(Element.UIElements.Main.Lock, .08, {BackgroundTransparency = .6}):Play()
        Tween(Element.UIElements.Main.Lock.ImageLabel, .08, {ImageTransparency = 0}):Play()
        Element.UIElements.Main.Lock.Active = true
        CanHover = false
    end
    function Element:Unlock()
        Tween(Element.UIElements.Main.Lock, .08, {BackgroundTransparency = 1}):Play()
        Tween(Element.UIElements.Main.Lock.ImageLabel, .08, {ImageTransparency = 1}):Play()
        Element.UIElements.Main.Lock.Active = false
        CanHover = true
    end
    
    return Element
end