local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}

function Element:New(Config)
    local Toggle = {
        __type = "Toggle",
        Title = Config.Title or "Toggle",
        Desc = Config.Desc or nil,
        Value = Config.Value,
        Icon = Config.Icon or nil,
        Callback = Config.Callback or function() end,
        UIElements = {}
    }
    Toggle.ToggleFrame = require("../Components/Element")({
        Title = Toggle.Title,
        Desc = Toggle.Desc,
        Parent = Config.Parent,
        TextOffset = 44,
        Hover = true,
    })
    
    local CanCallback = true
    
    if Toggle.Value == nil then
        Toggle.Value = false
    end
    
    local ToggleIcon 
    if Toggle.Icon then
        ToggleIcon = New("ImageLabel", {
            Size = UDim2.new(1,-8,1,-8),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Image = Creator.Icon(Toggle.Icon)[1],
            ImageRectOffset = Creator.Icon(Toggle.Icon)[2].ImageRectPosition,
            ImageRectSize = Creator.Icon(Toggle.Icon)[2].ImageRectSize,
            ImageTransparency = 1,
            
            ThemeTag = {
                ImageColor3 = "Text"
            }
        })
    end
    
    Toggle.UIElements.Toggle = New("Frame",{
        BackgroundTransparency = .95,
        ThemeTag = {
            BackgroundColor3 = "Text"
        },
        Parent = Toggle.ToggleFrame.UIElements.Main,
        Size = UDim2.new(0,20*2.2,0,24),
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0)
    }, {
        New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Name = "Stroke"
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1,0)
            }),
            New("UIStroke", {
                ThemeTag = {
                    Color = "Text",
                },
                Transparency = 1, -- 0
                Thickness = 1.2,
            }),
        }),
        New("UICorner", {
            CornerRadius = UDim.new(1,0)
        }),
        New("UIStroke", {
            ThemeTag = {
                Color = "Text",
            },
            Transparency = .93,
            Thickness = 1.2,
        }),
        --bar
        New("Frame", {
            Size = UDim2.new(0,18,0,18),
            Position = UDim2.new(0,3,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 0.15,
            ThemeTag = {
                BackgroundColor3 = "Text"
            },
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1,0)
            }),
            New("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                ThemeTag = {
                    BackgroundColor3 = "Accent"
                },
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(1,0)
                }),
            }),
            ToggleIcon,
        })
    })

    function Toggle:Lock()
        CanCallback = false
        return Toggle.ToggleFrame:Lock()
    end
    function Toggle:Unlock()
        CanCallback = true
        return Toggle.ToggleFrame:Unlock()
    end
    
    if Toggle.Locked then
        Toggle:Lock()
    end

    local Toggled = Toggle.Value

    function Toggle:SetValue(newValue)
        Toggled = newValue or Toggled
        
        if Toggled then
            Tween(Toggle.UIElements.Toggle.Frame, 0.1, {
                Position = UDim2.new(1, -20 - 2, 0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0,20,0,20),
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            Tween(Toggle.UIElements.Toggle.Frame.Frame, 0.1, {
                BackgroundTransparency = 0.15,
            }):Play()
            Tween(Toggle.UIElements.Toggle, 0.1, {
                BackgroundTransparency = 0.15,
            }):Play()
            Tween(Toggle.UIElements.Toggle.Stroke.UIStroke, 0.1, {
                Transparency = 0,
            }):Play()
        
            if ToggleIcon then 
                Tween(ToggleIcon, 0.1, {
                    ImageTransparency = 0,
                }):Play()
            end
        else
            Tween(Toggle.UIElements.Toggle.Frame, 0.1, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundTransparency = 0.15,
                Size = UDim2.new(0,18,0,18),
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            Tween(Toggle.UIElements.Toggle.Frame.Frame, 0.1, {
                BackgroundTransparency = 1,
            }):Play()
            Tween(Toggle.UIElements.Toggle, 0.1, {
                BackgroundTransparency = 0.95,
            }):Play()
            Tween(Toggle.UIElements.Toggle.Stroke.UIStroke, 0.1, {
                Transparency = 1,
            }):Play()
        
            if ToggleIcon then 
                Tween(ToggleIcon, 0.1, {
                    ImageTransparency = 1,
                }):Play()
            end
        end

        task.spawn(function()
            Toggle.Callback(Toggled)
        end)
        
        Toggled = not Toggled
    end

    Toggle:SetValue(Toggled)

    Toggle.ToggleFrame.UIElements.Main.MouseButton1Click:Connect(function()
        if CanCallback then
            Toggle:SetValue(Toggled)
        end
    end)
    
    return Toggle.__type, Toggle
end

return Element