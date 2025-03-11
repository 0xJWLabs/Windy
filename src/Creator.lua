--[[

Credits: dawid 

]]

local RunService = game:GetService("RunService")
local RenderStepped = RunService.Heartbeat
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Icons = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua"))()
Icons.SetIconsType("lucide")

local Creator = {
    Font = "rbxassetid://12187365364", -- Inter
    CanDraggable = true,
    Theme = nil,
    Objects = {},
    FontObjects = {},
    DefaultProperties = {
        ScreenGui = {
            ResetOnSpawn = false,
            ZIndexBehavior = "Sibling",
        },
        CanvasGroup = {
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.new(1,1,1),
        },
        Frame = {
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.new(1,1,1),
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            Text = "",
            RichText = true,
            TextColor3 = Color3.new(1,1,1),
            TextSize = 14,
        }, TextButton = {
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor= false,
            TextColor3 = Color3.new(1,1,1),
            TextSize = 14,
        },
        TextBox = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ClearTextOnFocus = false,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
        },
        ImageButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            AutoButtonColor = false,
        },
        UIListLayout = {
            SortOrder = "LayoutOrder",
        }
    },
}
            
function Creator.SetTheme(Theme)
    Creator.Theme = Theme
    Creator.UpdateTheme(nil, true)
end

function Creator.AddFontObject(Object)
    table.insert(Creator.FontObjects, Object)
    Creator.UpdateFont(Creator.Font)
end
function Creator.UpdateFont(FontId)
    Creator.Font = FontId
    for _,Obj in next, Creator.FontObjects do
        Obj.FontFace = Font.new(FontId, Obj.FontFace.Weight, Obj.FontFace.Style)
    end
end

function Creator.GetThemeProperty(Property, Theme)
    return Theme[Property]
end

function Creator.AddThemeObject(Object, Properties)
    Creator.Objects[Object] = { Object = Object, Properties = Properties }
    Creator.UpdateTheme(Object)
    return Object
end

function Creator.UpdateTheme(TargetObject, isTween)
    local function ApplyTheme(objData)
        for Property, ColorKey in pairs(objData.Properties or {}) do
            local Color = Creator.GetThemeProperty(ColorKey, Creator.Theme)
            if Color then
                if not isTween then
                    objData.Object[Property] = Color3.fromHex(Color)
                else
                    Creator.Tween(objData.Object, 0.08, { [Property] = Color3.fromHex(Color) }):Play()
                end
            end
        end
    end

    if TargetObject then
        local objData = Creator.Objects[TargetObject]
        if objData then
            ApplyTheme(objData)
        end
    else
        for _, objData in pairs(Creator.Objects) do
            ApplyTheme(objData)
        end
    end
end

function Creator.Icon(Icon)
    return Icons.Icon(Icon)
end

function Creator.New(Name, Properties, Children)
    local Object = Instance.new(Name)
    
    for Name, Value in next, Creator.DefaultProperties[Name] or {} do
        Object[Name] = Value
    end
    
    for Name, Value in next, Properties or {} do
        if Name ~= "ThemeTag" then
            Object[Name] = Value
        end
    end
    
    for _, Child in next, Children or {} do
        Child.Parent = Object
    end
    
    if Properties and Properties.ThemeTag then
        Creator.AddThemeObject(Object, Properties.ThemeTag)
    end
    if Properties and Properties.FontFace then
        Creator.AddFontObject(Object)
    end
    return Object
end

function Creator.Tween(Object, Time, Properties, ...)
    return TweenService:Create(Object, TweenInfo.new(Time, ...), Properties)
end

local New = Creator.New
local Tween = Creator.Tween

function Creator.SetDraggable(can)
    Creator.CanDraggable = can
end

function Creator.ToolTip(ToolTipConfig)
    local ToolTipModule = {
        Title = ToolTipConfig.Title or "ToolTip",
        --Icon = ToolTipConfig.Icon or nil,
        
        Container = nil,
        ToolTipSize = 16,
    }
    
    -- local ToolTipIcon
    -- if ToolTipModule.Icon then
    --     ToolTipIcon = New("ImageLabel", {
    --         Size = UDim2.new(0,20,0,20),
    --         Image = Creator.Icon(ToolTipModule.Icon)[1],
    --         ImageRectOffset = Creator.Icon(ToolTipModule.Icon)[2].ImageRectPosition,
    --         ImageRectSize = Creator.Icon(ToolTipModule.Icon)[2].ImageRectSize,
    --         BackgroundTransparency = 1,
    --         ThemeTag = {
    --             ImageColor3 = "Text"
    --         }
    --     })
    -- end
    
    local ToolTipTitle = New("TextLabel", {
        AutomaticSize = "XY",
        --Size = UDim2.new(0,0,0,0),
        TextWrapped = true,
        BackgroundTransparency = 1,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        Text = ToolTipModule.Title,
        TextSize = 17,
        ThemeTag = {
            TextColor3 = "Text",
        }
    })
    
    local UIScale = New("UIScale", {
        Scale = .9 -- 1
    })
    
    local Container = New("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5,0),
        AutomaticSize = "XY",
        BackgroundTransparency = 1,
        Parent = ToolTipConfig.Parent,
        GroupTransparency = 1, -- 0
        Visible = false -- true
    }, {
        New("UISizeConstraint", {
            MaxSize = Vector2.new(400, math.huge)
        }),
        New("Frame", {
            AutomaticSize = "XY",
            BackgroundTransparency = 1,
            LayoutOrder = 99,
            Visible = false
        }, {
            New("ImageLabel", {
                Size = UDim2.new(0,ToolTipModule.ToolTipSize,0,ToolTipModule.ToolTipSize/2),
                BackgroundTransparency = 1,
                Rotation = 180,
                Image = "rbxassetid://89524607682719",
                ThemeTag = {
                    ImageColor3 = "Accent",
                },
            }, {
                New("ImageLabel", {
                    Size = UDim2.new(0,ToolTipModule.ToolTipSize,0,ToolTipModule.ToolTipSize/2),
                    BackgroundTransparency = 1,
                    LayoutOrder = 99,
                    ImageTransparency = .9,
                    Image = "rbxassetid://89524607682719",
                    ThemeTag = {
                        ImageColor3 = "Text",
                    },
                }),
            }),
        }),
        New("Frame", {
            AutomaticSize = "XY",
            ThemeTag = {
                BackgroundColor3 = "Accent",
            },
            
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,16),
            }),
            New("Frame", {
                ThemeTag = {
                    BackgroundColor3 = "Text",
                },
                AutomaticSize = "XY",
                BackgroundTransparency = .9,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0,16),
                }),
                New("UIListLayout", {
                    Padding = UDim.new(0,12),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center"
                }),
                --ToolTipIcon, 
                ToolTipTitle,
                New("UIPadding", {
                    PaddingTop = UDim.new(0,12),
                    PaddingLeft = UDim.new(0,12),
                    PaddingRight = UDim.new(0,12),
                    PaddingBottom = UDim.new(0,12),
                }),
            })
        }),
        UIScale,
        New("UIListLayout", {
            Padding = UDim.new(0,0),
            FillDirection = "Vertical",
            VerticalAlignment = "Center",
            HorizontalAlignment = "Center",
        }),
    })
    ToolTipModule.Container = Container
    
    function ToolTipModule:Open() 
        Container.Visible = true
        
        Tween(Container, .25, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIScale, .25, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    end
    
    function ToolTipModule:Close() 
        Tween(Container, .25, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(UIScale, .25, { Scale = .9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        
        task.wait(.25)
        
        Container.Visible = false
        Container:Destroy()
    end
    
    return ToolTipModule
end

function Creator.Drag(UIElement, b)
    local dragging, dragInput, dragStart, startPos
    local DragModule = {
        CanDraggable = true
    }
    
    local function update(input)
        local delta = input.Position - dragStart
        -- UIElement.Position = UDim2.new(
        --     startPos.X.Scale, startPos.X.Offset + delta.X,
        --     startPos.Y.Scale, startPos.Y.Offset + delta.Y
        -- )
        Creator.Tween(UIElement, 0.08, {Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )}):Play()
    
    end
    
    UIElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = UIElement.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UIElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if b then
                if Creator.CanDraggable then
                    update(input)
                end
            elseif DragModule.CanDraggable then 
                update(input)
            end
        end
    end)
    
    
    function DragModule:Set(v)
        DragModule.CanDraggable = v
    end
    
    return DragModule
end


return Creator