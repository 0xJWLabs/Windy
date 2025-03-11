
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Notified = false

return function(Config)
    local Window = {
        Title = Config.Title or "UI Library",
        Author = Config.Author,
        Icon = Config.Icon,
        Folder = Config.Folder,
        Background = Config.Background,
        Size = Config.Size and UDim2.new(
                    0, math.clamp(Config.Size.X.Offset, 480, 700),
                    0, math.clamp(Config.Size.Y.Offset, 350, 520)) or UDim2.new(0,580,0,460),
        ToggleKey = Config.ToggleKey or Enum.KeyCode.G,
        Transparent = Config.Transparent or false,
        Position = Config.Position or UDim2.new(
			0.5, 0,
			0.5, 0
		),
		UICorner = Config.Corner or 16,
		UIPadding = Config.Padding or 14,
		SideBarWidth = Config.SideBarWidth or 200,
		UIElements = {},
		CanDropdown = true,
		Closed = false,
		HasOutline = Config.HasOutline or false,
		SuperParent = Config.Parent,
		Destroyed = false,
		IsFullscreen = false,
		IsOpenButtonEnabled = true,
		
		CurrentTab = nil,
    } -- wtf 
    
    if Window.Folder then
        makefolder("Windy/" .. Window.Folder)
    end
    
    local UICorner = New("UICorner", {
        CornerRadius = UDim.new(0,Window.UICorner)
    })
    local UIStroke
    -- local UIStroke = New("UIStroke", {
    --     Thickness = 0.6,
    --     ThemeTag = {
    --         Color = "Outline",
    --     },
    --     Transparency = 1, -- 0.8
    -- })

    local ResizeHandle = New("Frame", {
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        ZIndex = 99,
        Active = true
    }, {
        -- New("Frame", {
        --     Size = UDim2.new(1,0,1,0),
        --     Position = UDim2.new(0,3,0,3),
        --     AnchorPoint = Vector2.new(0.5,0.5),
        --     BackgroundTransparency = 1,
        -- }, {
        --     New("UIStroke", {
        --         Thickness = 1.2,
        --         ThemeTag = {
        --             Color = "Text",
        --         },
        --         Transparency = .6,
        --     }),
        --     New("UICorner", {
        --         CornerRadius = UDim.new(0,Window.UICorner+6)
        --     })
        -- })
    })
    local FullScreenIcon = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, -- .85
        BackgroundColor3 = Color3.new(0,0,0),
        ZIndex = 98,
        Active = false,
    }, {
        New("ImageLabel", {
            Size = UDim2.new(0,70,0,70),
            Image = Creator.Icon("expand")[1],
            ImageRectOffset = Creator.Icon("expand")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("expand")[2].ImageRectSize,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = 1,
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,Window.UICorner)
        })
    })

    
    local Slider = New("Frame", {
        Size = UDim2.new(0,2,1,-Window.UIPadding*2),
        BackgroundTransparency = 1,
        Position = UDim2.new(1,-Window.UIPadding/3,0,Window.UIPadding),
        AnchorPoint = Vector2.new(1,0),
    })
    
    local Hitbox = New("Frame", {
        Size = UDim2.new(1,12,1,12),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        Active = true,
    })

    local Thumb = New("ImageLabel", {
        Size = UDim2.new(1,0,0,0),
        --Image = "rbxassetid://18747052224",
        --ScaleType = "Crop",
        BackgroundTransparency = .85,
        --ImageTransparency = .65,
        ThemeTag = {
            BackgroundColor3 = "Text"
        },
        Parent = Slider
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(1,0)
        }),
        Hitbox
    })

    local TabHighlight = New("Frame", {
        Size = UDim2.new(1,0,0,0),
        BackgroundTransparency = .95,
        ThemeTag = {
            BackgroundColor3 = "Text",
        }
    }, {
        New("UICorner", {
            CornerRadius = UDim.new(0,9)
        })
    })

    Window.UIElements.SideBar = New("ScrollingFrame", {
        Size = UDim2.new(1,-Window.UIPadding+2,1,0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ElasticBehavior = "Never",
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
    }, {
        New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,0)
        }, {
            New("UIPadding", {
                PaddingTop = UDim.new(0,4),
                PaddingLeft = UDim.new(0,4+3),
                --PaddingRight = UDim.new(0,Window.UIPadding+4),
                PaddingBottom = UDim.new(0,Window.UIPadding),
            }),
            New("UIListLayout", {
                SortOrder = "LayoutOrder",
                Padding = UDim.new(0,8)
            })
        }),
        New("UIPadding", {
            --PaddingTop = UDim.new(0,4),
            PaddingLeft = UDim.new(0,Window.UIPadding-3),
            PaddingRight = UDim.new(0,Window.UIPadding-3),
            --PaddingBottom = UDim.new(0,Window.UIPadding),
        }),
        TabHighlight
    })
    
    Window.UIElements.SideBarContainer = New("CanvasGroup", {
        Size = UDim2.new(0,Window.SideBarWidth-Window.UIPadding+4,1,-52),
        Position = UDim2.new(0,0,0,52),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
    }, {
        Window.UIElements.SideBar,
        Slider,
    })

    
    local function updateSliderSize()
        local container = Window.UIElements.SideBar
        local visibleRatio = math.clamp(container.AbsoluteWindowSize.Y / container.AbsoluteCanvasSize.Y, 0, 1)
    
        Thumb.Size = UDim2.new(1, 0, visibleRatio, 0)
        Thumb.Visible = visibleRatio < 1
    end
        
    local function updateScrollingFramePosition()
        local thumbPosition = Thumb.Position.Y.Scale
        local canvasSize = math.max(Window.UIElements.SideBar.AbsoluteCanvasSize.Y - Window.UIElements.SideBar.AbsoluteWindowSize.Y, 1)
    
        Window.UIElements.SideBar.CanvasPosition = Vector2.new(
            0,
            thumbPosition * canvasSize
        )
    end
    
    local offset = 0

    local function onInputChanged(input)
        local sliderSize = Slider.AbsoluteSize.Y
        local sliderPosition = Slider.AbsolutePosition.Y
    
        local newThumbPosition = (input.Position.Y - sliderPosition - offset) / sliderSize
        newThumbPosition = math.clamp(newThumbPosition, 0, 1) 
    
        Thumb.Position = UDim2.new(0, 0, newThumbPosition, 0)
        updateScrollingFramePosition()
    end
    
    Hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local offset = input.Position.Y - Thumb.AbsolutePosition.Y
            local connection
    
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local sliderSize = Slider.AbsoluteSize.Y
                    local sliderPosition = Slider.AbsolutePosition.Y
    
                    local newThumbPosition = (input.Position.Y - sliderPosition - offset) / sliderSize
                    newThumbPosition = math.clamp(newThumbPosition, 0, 1)
    
                    Thumb.Position = UDim2.new(0, 0, newThumbPosition, 0)
                    updateScrollingFramePosition()
                end
            end)
    
            local releaseConnection
            releaseConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                    releaseConnection:Disconnect()
                end
            end)
        end
    end)
    
    Window.UIElements.SideBar:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local canvasPosition = Window.UIElements.SideBar.CanvasPosition.Y
        local canvasSize = Window.UIElements.SideBar.AbsoluteCanvasSize.Y - Window.UIElements.SideBar.AbsoluteWindowSize.Y
        local newThumbPosition = canvasPosition / canvasSize
    
        Thumb.Position = UDim2.new(0, 0, newThumbPosition, 0)
    end)
    
    Thumb:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Slider.Size = UDim2.new(0, Slider.Size.X.Offset, 1, -Thumb.AbsoluteSize.Y - Window.UIPadding*2)
    end)
    Window.UIElements.SideBar:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateSliderSize)
    Window.UIElements.SideBar:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateSliderSize)
    
    updateSliderSize()

    Window.UIElements.MainBar = New("Frame", {
        Size = UDim2.new(1,-Window.UIElements.SideBarContainer.AbsoluteSize.X,1,-52),
        Position = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(1,1),
        BackgroundTransparency = 1,
    })
    
    local Gradient = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, -- Window.Transparent and 0.25 or 0
        ZIndex = 3,
        Name = "Gradient",
        Visible = false
    }, {
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0)),
            Rotation = 90,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1), 
                NumberSequenceKeypoint.new(1, Window.Transparent and 0.85 or 0.7),
            }
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,Window.UICorner)
        })
    })
    
    local Blur = New("ImageLabel", {
        Image = "rbxassetid://8992230677",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 1, -- 0.7
        Size = UDim2.new(1,120,1,116),
        Position = UDim2.new(0,-120/2,0,-116/2),
        ScaleType = "Slice",
        SliceCenter = Rect.new(99,99,99,99),
        BackgroundTransparency = 1,
    })

    local IsPC

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        IsPC = false
    elseif UserInputService.KeyboardEnabled then
        IsPC = true
    else
        IsPC = nil
    end
    
    local OpenButtonContainer = nil
    local OpenButton = nil
    local OpenButtonIcon = nil
    local Glow = nil
    
    if not IsPC then
        OpenButtonIcon = New("ImageLabel", {
            Image = "",
            Size = UDim2.new(0,22,0,22),
            Position = UDim2.new(0.5,0,0.5,0),
            LayoutOrder = -1,
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Name = "Icon"
        })
    
        OpenButtonTitle = New("TextLabel", {
            Text = Window.Title,
            TextSize = 17,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            AutomaticSize = "XY",
        })
    
        OpenButtonDrag = New("ImageLabel", {
            Image = Creator.Icon("grab")[1],
            ImageRectOffset = Creator.Icon("grab")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("grab")[2].ImageRectSize,
            Size = UDim2.new(0,20,0,20),
            BackgroundTransparency = 1,
            Position = UDim2.new(0,0,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
        })
        OpenButtonDivider = New("Frame", {
            Size = UDim2.new(0,1,1,-16),
            Position = UDim2.new(0,20+16,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = .86,
        })
    
        OpenButtonContainer = New("Frame", {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0.5,0,0,6+44/2),
            AnchorPoint = Vector2.new(0.5,0.5),
            Parent = Config.Parent,
            BackgroundTransparency = 1,
            Active = true,
            Visible = false,
        })
        OpenButton = New("TextButton", {
            Size = UDim2.new(0,0,0,44),
            AutomaticSize = "X",
            Parent = OpenButtonContainer,
            Active = false,
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = .3,
            ZIndex = 99,
        }, {
            New("UIScale", {
                Scale = 1.05,
            }),
		    New("UICorner", {
                CornerRadius = UDim.new(1,0)
            }),
            New("UIStroke", {
                Thickness = 1,
                ApplyStrokeMode = "Border",
                Color = Color3.new(1,1,1),
                Transparency = 0,
            }, {
                New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
                })
            }),
            OpenButtonDrag,
            OpenButtonDivider,
            
            New("UIListLayout", {
                Padding = UDim.new(0, Window.UIPadding),
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
            }),
            
            New("TextButton",{
                AutomaticSize = "XY",
                Active = true,
                BackgroundTransparency = 1,
                Size = UDim2.new(0,0,1,0),
                Position = UDim2.new(0,20+16+16+1,0,0)
            }, {
                OpenButtonIcon,
                New("UIListLayout", {
                    Padding = UDim.new(0, Window.UIPadding),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                }),
                OpenButtonTitle,
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0,0),
                PaddingLeft = UDim.new(0,16),
                PaddingRight = UDim.new(0,16),
                PaddingBottom = UDim.new(0,0),
            })
        })
        
        local uiGradient = OpenButton and OpenButton.UIStroke.UIGradient or nil
    
        -- Glow = New("ImageLabel", {
        --     Image = "rbxassetid://93831937596979", -- UICircle Glow
        --     ScaleType = "Slice",
        --     SliceCenter = Rect.new(375,375,375,375),
        --     BackgroundTransparency = 1,
        --     Size = UDim2.new(1,21,1,21),
        --     Position = UDim2.new(0.5,0,0.5,0),
        --     AnchorPoint = Vector2.new(0.5,0.5),
        --     ImageTransparency = .5,
        --     Parent = OpenButtonContainer,
        -- }, {
        --     New("UIGradient", {
        --         Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
        --     })
        -- })
        
        RunService.RenderStepped:Connect(function(deltaTime)
            if Window.UIElements.Main and OpenButtonContainer and OpenButtonContainer.Parent ~= nil then
                if uiGradient then
                    uiGradient.Rotation = (uiGradient.Rotation + 1) % 360
                end
                if Glow and Glow.Parent ~= nil and Glow.UIGradient then
                    Glow.UIGradient.Rotation = (Glow.UIGradient.Rotation + 1) % 360
                end
            end
        end)
        
        OpenButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            OpenButtonContainer.Size = UDim2.new(
                0, OpenButton.AbsoluteSize.X,
                0, OpenButton.AbsoluteSize.Y
            )
        end)
        
        OpenButton.TextButton.MouseEnter:Connect(function()
            Tween(OpenButton.UIScale, .1, {Scale = .99}):Play()
        end)
        OpenButton.TextButton.MouseLeave:Connect(function()
            Tween(OpenButton.UIScale, .1, {Scale = 1.05}):Play()
        end)
    end
    
    local Outline1
    local Outline2
    if Window.HasOutline then
        Outline1 = New("Frame", {
            Name = "Outline",
            Size = UDim2.new(1,Window.UIPadding*2,0,1),
            Position = UDim2.new(0.5,0,1,Window.UIPadding),
            BackgroundTransparency= .9,
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                BackgroundColor3 = "Outline"
            },
        })
        Outline2 = New("Frame", {
            Name = "Outline",
            Size = UDim2.new(0,1,1,-52),
            Position = UDim2.new(0,Window.SideBarWidth -Window.UIPadding/2,0,52),
            BackgroundTransparency= .9,
            AnchorPoint = Vector2.new(0.5,0),
            ThemeTag = {
                BackgroundColor3 = "Outline"
            },
        })
    end
    
    local WindowTitle = New("TextLabel", {
        Text = Window.Title,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
        Name = "Title",
        TextXAlignment = "Left",
        TextSize = 16,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })
    
    Window.UIElements.Main = New("Frame", {
        Size = Window.Size,
        Position = Window.Position,
        BackgroundTransparency = 1,
        Parent = Config.Parent,
        AnchorPoint = Vector2.new(0.5,0.5),
        Active = true,
    }, {
        Blur,
        Gradient,
        New("Frame", {
            BackgroundTransparency = 1, -- Window.Transparent and 0.25 or 0
            Size = UDim2.new(1,0,1,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Name = "Background",
            ThemeTag = {
                BackgroundColor3 = "Accent"
            },
            ZIndex = 2,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,Window.UICorner)
            }),
            New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Image = Window.Background,
                -- ImageTransparency = 0,
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0,Window.UICorner)
                }),
            }),
            New("UIScale", {
                Scale = 0.95,
            }),
        }),
        UIStroke,
        UICorner,
        ResizeHandle,
        FullScreenIcon,
        New("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Name = "Main",
            --GroupTransparency = 1,
            Visible = false,
            ZIndex = 97,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,Window.UICorner)
            }),
            Window.UIElements.SideBarContainer,
            Window.UIElements.MainBar,
            Outline2,
            New("Frame", { -- Topbar
                Size = UDim2.new(1,0,0,52),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(50,50,50),
                Name = "Topbar"
            }, {
                Outline1,
                --[[New("Frame", { -- Outline
                    Size = UDim2.new(1,Window.UIPadding*2, 0, 1),
                    Position = UDim2.new(0,-Window.UIPadding, 1,Window.UIPadding-2),
                    BackgroundTransparency = 0.9,
                    BackgroundColor3 = Color3.fromHex(Config.Theme.Outline),
                }),]]
                New("Frame", { -- Topbar Left Side
                    AutomaticSize = "X",
                    Size = UDim2.new(0,0,1,0),
                    BackgroundTransparency = 1,
                    Name = "Left"
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,10),
                        SortOrder = "LayoutOrder",
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    }),
                    New("Frame", {
                        AutomaticSize = "XY",
                        BackgroundTransparency = 1,
                        Name = "Title",
                        Size = UDim2.new(0,0,1,0),
                        LayoutOrder= 2,
                    }, {
                        New("UIListLayout", {
                            Padding = UDim.new(0,0),
                            SortOrder = "LayoutOrder",
                            FillDirection = "Vertical",
                            VerticalAlignment = "Top",
                        }),
                        WindowTitle,
                    }),
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0,4)
                    })
                }),
                New("Frame", { -- Topbar Right Side -- Window.UIElements.Main.Main.Topbar.Right
                    AutomaticSize = "XY",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1,0,0.5,0),
                    AnchorPoint = Vector2.new(1,0.5),
                    Name = "Right",
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,20),
                        FillDirection = "Horizontal",
                        SortOrder = "LayoutOrder",
                    }),
                    
                    
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0,Window.UIPadding),
                    PaddingLeft = UDim.new(0,Window.UIPadding),
                    PaddingRight = UDim.new(0,Window.UIPadding),
                    PaddingBottom = UDim.new(0,Window.UIPadding),
                })
            })
        })
    })

    
    function Window:CreateTopbarButton(Icon, Callback, LayoutOrder)
        local Button = New("TextButton", {
            Size = UDim2.new(0,24,0,24),
            BackgroundTransparency = 1,
            LayoutOrder = LayoutOrder or 999,
            Parent = Window.UIElements.Main.Main.Topbar.Right,
            --Active = true,
            ZIndex = 9999,
        }, {
            New("ImageLabel", {
                Image = Creator.Icon(Icon)[1],
                ImageRectOffset = Creator.Icon(Icon)[2].ImageRectPosition,
                ImageRectSize = Creator.Icon(Icon)[2].ImageRectSize,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,-6,1,-6),
                ThemeTag = {
                    ImageColor3 = "Text"
                },
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(0.5,0,0.5,0),
                Active = false
            }),
        })
        
        Button.MouseButton1Click:Connect(function()
            Callback()
        end)
        
        return Button
    end

    -- local Dragged = false

    Creator.Drag(Window.UIElements.Main, true)
    
    --Creator.Blur(Window.UIElements.Main.Background)
    local OpenButtonDragModule
    
    if not IsPC then
        OpenButtonDragModule = Creator.Drag(OpenButtonContainer)
    end
    
    if Window.Author then
        local Author = New("TextLabel", {
            Text = Window.Author,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            TextTransparency = 0.4,
            AutomaticSize = "XY",
            Parent = Window.UIElements.Main.Main.Topbar.Left.Title,
            TextXAlignment = "Left",
            TextSize = 14,
            LayoutOrder = 2,
            ThemeTag = {
                TextColor3 = "Text"
            }
        })
        -- Author:GetPropertyChangedSignal("TextBounds"):Connect(function()
        --     Author.Size = UDim2.new(0,Author.TextBounds.X,0,Author.TextBounds.Y)
        -- end)
    end
    -- WindowTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --     WindowTitle.Size = UDim2.new(0,WindowTitle.TextBounds.X,0,WindowTitle.TextBounds.Y)
    -- end)
    -- Window.UIElements.Main.Main.Topbar.Frame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    --     Window.UIElements.Main.Main.Topbar.Frame.Size = UDim2.new(0,Window.UIElements.Main.Main.Topbar.Frame.UIListLayout.AbsoluteContentSize.X,0,Window.UIElements.Main.Main.Topbar.Frame.UIListLayout.AbsoluteContentSize.Y)
    -- end)
    -- Window.UIElements.Main.Main.Topbar.Left.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    --     Window.UIElements.Main.Main.Topbar.Left.Size = UDim2.new(0,Window.UIElements.Main.Main.Topbar.Left.UIListLayout.AbsoluteContentSize.X,1,0)
    -- end)
    
    task.spawn(function()
        if Window.Icon then
            local themetag = { ImageColor3 = "Text" }
            
            if string.find(Window.Icon, "rbxassetid://") or not Creator.Icon(tostring(Window.Icon))[1] then
                themetag = nil
            end
            local ImageLabel = New("ImageLabel", {
                Parent = Window.UIElements.Main.Main.Topbar.Left,
                Size = UDim2.new(0,24,0,24),
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ThemeTag = themetag
            })
            if string.find(Window.Icon, "rbxassetid://") or string.find(Window.Icon, "http://www.roblox.com/asset/?id=") then
                ImageLabel.Image = Window.Icon
                OpenButtonIcon.Image = Window.Icon
            elseif string.find(Window.Icon,"http") then
                local success, response = pcall(function()
                    if not isfile("Windy/" .. Window.Folder .. "/Assets/Icon.png") then
                        local response = request({
                            Url = Window.Icon,
                            Method = "GET",
                        }).Body
                        writefile("Windy/" .. Window.Folder .. "/Assets/Icon.png", response)
                    end
                    ImageLabel.Image = getcustomasset("Windy/" .. Window.Folder .. "/Assets/Icon.png")
                    OpenButtonIcon.Image = getcustomasset("Windy/" .. Window.Folder .. "/Assets/Icon.png")
                end)
                if not success then
                    ImageLabel:Destroy()
                    
                    warn("[ Windy ]  '" .. identifyexecutor() .. "' doesnt support the URL Images. Error: " .. response)
                end
            else
                if Creator.Icon(tostring(Window.Icon))[1] then
                    ImageLabel.Image = Creator.Icon(Window.Icon)[1]
                    ImageLabel.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
                    ImageLabel.ImageRectSize = Creator.Icon(Window.Icon)[2].ImageRectSize
                    OpenButtonIcon.Image = Creator.Icon(Window.Icon)[1]
                    OpenButtonIcon.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
                    OpenButtonIcon.ImageRectSize = Creator.Icon(Window.Icon)[2].ImageRectSize
                end
            end
        else
            OpenButtonIcon.Visible = false
        end
    end)
    
    function Window:Open()
        Window.Closed = false
        
        Tween(Window.UIElements.Main.Background, 0.25, {BackgroundTransparency = Config.Transparent and Config.Windy.TransparencyValue or 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        --Tween(Window.UIElements.Main.Main, 0.25, {BackgroundTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.Background.UIScale, 0.2, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Gradient, 0.25, {BackgroundTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Blur, 0.25, {ImageTransparency = .7}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        if UIStroke then
            Tween(UIStroke, 0.25, {Transparency = .8}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
        
        Window.CanDropdown = true
        
        Window.UIElements.Main.Visible = true
        task.wait(.08)
        Window.UIElements.Main.Main.Visible = true
    end
    function Window:Close()
        local Close = {}
        
        Window.UIElements.Main.Main.Visible = false
        Window.CanDropdown = false
        Window.Closed = true
        
        Tween(Window.UIElements.Main.Background, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        --Tween(Window.UIElements.Main.Main, 0.25, {BackgroundTransparency= 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.Background.UIScale, 0.19, {Scale = .95}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Gradient, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        Tween(Blur, 0.25, {ImageTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        if UIStroke then
            Tween(UIStroke, 0.25, {Transparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end
        
        task.spawn(function()
            task.wait(0.25)
            Window.UIElements.Main.Visible = false
        end)
        
        function Close:Destroy()
            Window.Destroyed = true
            task.wait(0.25)
            Config.Parent.Parent:Destroy()
        end
        
        return Close
    end
    
    local CurrentPos
    local CurrentSize
    local iconCopy = Creator.Icon("minimize")
    local iconSquare = Creator.Icon("maximize")
    
    
    local FullscreenButton
    
    FullscreenButton = Window:CreateTopbarButton("maximize", function() 
        local isFullscreen = Window.IsFullscreen
        Creator.SetDraggable(isFullscreen)
    
        if not isFullscreen then
            CurrentPos = Window.UIElements.Main.Position
            CurrentSize = Window.UIElements.Main.Size
            FullscreenButton.ImageLabel.Image = iconCopy[1]
            FullscreenButton.ImageLabel.ImageRectOffset = iconCopy[2].ImageRectPosition
            FullscreenButton.ImageLabel.ImageRectSize = iconCopy[2].ImageRectSize
        else
            FullscreenButton.ImageLabel.Image = iconSquare[1]
            FullscreenButton.ImageLabel.ImageRectOffset = iconSquare[2].ImageRectPosition
            FullscreenButton.ImageLabel.ImageRectSize = iconSquare[2].ImageRectSize
        end
        
        Tween(Window.UIElements.Main, 0.45, {Size = isFullscreen and CurrentSize or UDim2.new(1,-20,1,-20-52)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    
        delay(0, function()
            Tween(Window.UIElements.Main, 0.45, {Position = isFullscreen and CurrentPos or UDim2.new(0.5,0,0.5,52/2)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        end)
        
        Window.IsFullscreen = not isFullscreen
    end, 998)
    Window:CreateTopbarButton("minus", function() 
        Window:Close()
        task.spawn(function()
            task.wait(.3)
            if not IsPC and Window.IsOpenButtonEnabled then
                OpenButtonContainer.Visible = true
            end
        end)
        
        local NotifiedText = IsPC and "Press " .. Window.ToggleKey.Name .. " to open the Window" or "Click the Button to open the Window"
        
        if not Window.IsOpenButtonEnabled then
            Notified = true
        end
        if not Notified then
            Notified = not Notified
            Config.Windy:Notify({
                Title = "Minimize",
                Content = "You've closed the Window. " .. NotifiedText,
                Icon = "eye-off",
                Duration = 5,
            })
        end
    end, 997)

    if not IsPC and Window.IsOpenButtonEnabled then
        OpenButton.TextButton.MouseButton1Click:Connect(function()
            Window:Open()
            OpenButtonContainer.Visible = false
        end)
    end
    
    UserInputService.InputBegan:Connect(function(input, isProcessed)
        if isProcessed then return end
        
        if input.KeyCode == Window.ToggleKey then
            if Window.Closed then
                Window:Open()
            else
                Window:Close()
            end
        end
    end)
    
    task.spawn(function()
        --task.wait(1.38583)
        Window:Open()
    end)
    
    function Window:EditOpenButton(OpenButtonConfig)
        task.wait()
        if OpenButton and OpenButton.Parent ~= nil then
            local OpenButtonModule = {
                Title = OpenButtonConfig.Title,
                Icon = OpenButtonConfig.Icon or Window.Icon,
                Enabled = OpenButtonConfig.Enabled,
                Position = OpenButtonConfig.Position,
                Draggable = OpenButtonConfig.Draggable,
                OnlyMobile = OpenButtonConfig.OnlyMobile,
                CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(1, 0),
                StrokeThickness = OpenButtonConfig.StrokeThickness or 2,
                Color = OpenButtonConfig.Color 
                    or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
            }
            
            -- wtf lol
            
            if OpenButtonModule.Enabled == false then
                Window.IsOpenButtonEnabled = false
            end
            if OpenButtonModule.Draggable == false and OpenButtonDrag and OpenButtonDivider then
                OpenButtonDrag.Visible = OpenButtonModule.Draggable
                OpenButtonDivider.Visible = OpenButtonModule.Draggable
                
                if OpenButtonDragModule then
                    OpenButtonDragModule:Set(OpenButtonModule.Draggable)
                end
            end
            if OpenButtonModule.Position and OpenButtonContainer then
                OpenButtonContainer.Position = OpenButtonModule.Position
                --OpenButtonContainer.AnchorPoint = Vector2.new(0,0)
            end
            
            local IsPC = UserInputService.KeyboardEnabled or not UserInputService.TouchEnabled
            OpenButton.Visible = not OpenButtonModule.OnlyMobile or not IsPC
            
            if not OpenButton.Visible then return end
            
            if OpenButtonTitle then
                if OpenButtonModule.Title then
                    OpenButtonTitle.Text = OpenButtonModule.Title
                elseif OpenButtonModule.Title == nil then
                    --OpenButtonTitle.Visible = false
                end
            end
            
            if Creator.Icon(OpenButtonModule.Icon) and OpenButtonIcon then
                OpenButtonIcon.Image = Creator.Icon(OpenButtonModule.Icon)[1]
                OpenButtonIcon.ImageRectOffset = Creator.Icon(OpenButtonModule.Icon)[2].ImageRectPosition
                OpenButtonIcon.ImageRectSize = Creator.Icon(OpenButtonModule.Icon)[2].ImageRectSize
            end
    
            OpenButton.UIStroke.UIGradient.Color = OpenButtonModule.Color
            if Glow then
                Glow.UIGradient.Color = OpenButtonModule.Color
            end
    
            OpenButton.UICorner.CornerRadius = OpenButtonModule.CornerRadius
            OpenButton.UIStroke.Thickness = OpenButtonModule.StrokeThickness
        end
    end
    
    
    local TabModule = require("./Tab").Init(Window, Config.Windy, Config.Parent.Parent.ToolTips, TabHighlight)
    
    TabModule:OnChange(function(t) Window.CurrentTab = t end)
    function Window:Tab(TabConfig)
        return TabModule.New({ Title = TabConfig.Title, Icon = TabConfig.Icon, Parent = Window.UIElements.SideBar.Frame, Desc = TabConfig.Desc })
    end
    
    function Window:SelectTab(Tab)
        TabModule:SelectTab(Tab)
    end
    
    
    function Window:Divider()
        local Divider = New("Frame", {
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0.5,0,0,0),
            AnchorPoint = Vector2.new(0.5,0),
            BackgroundTransparency = .8,
            ThemeTag = {
                BackgroundColor3 = "Text"
            }
        })
        New("Frame", {
            Parent = Window.UIElements.SideBar.Frame,
            --AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,1),
            BackgroundTransparency = 1,
        }, {
            Divider
        })
    end
    
    local DialogModule = require("./Dialog").Init(Window)
    function Window:Dialog(DialogConfig)
        local DialogTable = {
            Title = DialogConfig.Title or "Dialog",
            Content = DialogConfig.Content,
            Buttons = DialogConfig.Buttons or {},
        }
        local Dialog = DialogModule.Create()
        
        local DialogTopFrame = New("Frame", {
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main
        }, {
            New("UIListLayout", {
                FillDirection = "Horizontal",
                Padding = UDim.new(0,Dialog.UIPadding),
                VerticalAlignment = "Center"
            })
        })
        
        local p
        if DialogConfig.Icon and Creator.Icon(DialogConfig.Icon)[2] then
            p = New("ImageLabel", {
                Image = Creator.Icon(DialogConfig.Icon)[1],
                ImageRectSize = Creator.Icon(DialogConfig.Icon)[2].ImageRectSize,
                ImageRectOffset = Creator.Icon(DialogConfig.Icon)[2].ImageRectPosition,
                ThemeTag = {
                    ImageColor3 = "Text",
                },
                Size = UDim2.new(0,26,0,26),
                BackgroundTransparency = 1,
                Parent = DialogTopFrame
            })
        end
        
        Dialog.UIElements.UIListLayout = New("UIListLayout", {
            Padding = UDim.new(0,8*2.3),
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            Parent = Dialog.UIElements.Main
        })
    
        New("UISizeConstraint", {
			MinSize = Vector2.new(180, 20),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.UIElements.Main,
		})
        
        Dialog.UIElements.Title = New("TextLabel", {
            Text = DialogTable.Title,
            TextSize = 19,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
            TextXAlignment = "Left",
            TextWrapped = true,
            RichText = true,
            Size = UDim2.new(1,p and -26-Dialog.UIPadding or 0,0,0),
            AutomaticSize = "Y",
            ThemeTag = {
                TextColor3 = "Text"
            },
            BackgroundTransparency = 1,
            Parent = DialogTopFrame
        })
        if DialogTable.Content then
            local Content = New("TextLabel", {
                Text = DialogTable.Content,
                TextSize = 17,
                TextTransparency = .4,
                TextWrapped = true,
                RichText = true,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                TextXAlignment = "Left",
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = "Y",
                LayoutOrder = 2,
                ThemeTag = {
                    TextColor3 = "Text"
                },
                BackgroundTransparency = 1,
                Parent = Dialog.UIElements.Main
            })
        end
        
        -- Dialog.UIElements.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        --     Dialog.UIElements.Main.Size = UDim2.new(0,Dialog.UIElements.UIListLayout.AbsoluteContentSize.X,0,Dialog.UIElements.UIListLayout.AbsoluteContentSize.Y+Dialog.UIPadding*2)
        -- end)
        -- Dialog.UIElements.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
        --     Dialog.UIElements.Title.Size = UDim2.new(1,0,0,Dialog.UIElements.Title.TextBounds.Y)
        -- end)
        
        -- New("Frame", {
        --     Name = "Line",
        --     Size = UDim2.new(1, Dialog.UIPadding*2, 0, 1),
        --     Parent = Dialog.UIElements.Main,
        --     LayoutOrder = 3,
        --     BackgroundTransparency = 1,
        --     ThemeTag = {
        --         BackgroundColor3 = "Text",
        --     }
        -- })
        
        local ButtonsContent = New("Frame", {
            Size = UDim2.new(1,0,0,32),
            AutomaticSize = "None",
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main,
            LayoutOrder = 4,
        }, {
            New("UIListLayout", {
			    Padding = UDim.new(0, 10),
			    FillDirection = "Horizontal",
			    HorizontalAlignment = "Center",
		    }),
        })
        
        for _,Button in next, DialogTable.Buttons do
            if Button.Variant == nil or Button.Variant == "" then
                Button.Variant = "Secondary"
            end
            local ButtonFrame = New("TextButton", {
                Text = Button.Title or "Button",
                TextSize = 16,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                ThemeTag = {
                    TextColor3 = Button.Variant == "Secondary" and "Text" or "Accent",
                    BackgroundColor3 = "Text",
                },
                BackgroundTransparency = Button.Variant == "Secondary" and .93 or .1 ,
                Parent = ButtonsContent,
                Size = UDim2.new(1 / #DialogTable.Buttons, -(((#DialogTable.Buttons - 1) * 10) / #DialogTable.Buttons), 1, 0),
                --AutomaticSize = "X",
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, Dialog.UICorner-5),
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 0),
                    PaddingLeft = UDim.new(0, Dialog.UIPadding/1.85),
                    PaddingRight = UDim.new(0, Dialog.UIPadding/1.85),
                    PaddingBottom = UDim.new(0, 0),
                }),
                New("Frame", {
                    Size = UDim2.new(1,(Dialog.UIPadding/1.85)*2,1,0),
                    Position = UDim2.new(0.5,0,0.5,0),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    ThemeTag = {
                        BackgroundColor3 = Button.Variant == "Secondary" and "Text" or "Accent"
                    },
                    BackgroundTransparency = 1, -- .9
                }, {
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Dialog.UICorner-5),
                    }),
                }),
                New("UIStroke", {
                    ThemeTag = {
                        Color = "Text",
                    },
                    Thickness = 1.2,
                    Transparency = Button.Variant == "Secondary" and .9 or .1,
                    ApplyStrokeMode = "Border",
                })
            })
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = .9}):Play()
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = 1}):Play()
            end)
            ButtonFrame.MouseButton1Click:Connect(function()
                Dialog:Close()
                task.spawn(function()
                    Button.Callback()
                end)
            end)
        end
        
        --Dialog:Open()
        
        return Dialog
    end
    
    
    local CloseDialog = Window:Dialog({
        Icon = "trash-2",
        Title = "Close Window",
        Content = "Do you want to close this window? You will not be able to open it again.",
        Buttons = {
            {
                Title = "Cancel",
                Callback = function() end,
                Variant = "Secondary",
            },
            {
                Title = "Close Window",
                Callback = function() Window:Close():Destroy() end,
                Variant = "Primary",
            }
        }
    })
    
    Window:CreateTopbarButton("x", function()
        Tween(Window.UIElements.Main, 0.35, {Position = UDim2.new(0.5,0,0.5,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
        CloseDialog:Open()
    end, 999)
    

    local function startResizing(input)
        if not isFullscreen then
            isResizing = true
            FullScreenIcon.Active = true
            initialSize = Window.UIElements.Main.Size
            initialInputPosition = input.Position
            Tween(FullScreenIcon, 0.2, {BackgroundTransparency = .65}):Play()
            Tween(FullScreenIcon.ImageLabel, 0.2, {ImageTransparency = 0}):Play()
        
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                    FullScreenIcon.Active = false
                    Tween(FullScreenIcon, 0.2, {BackgroundTransparency = 1}):Play()
                    Tween(FullScreenIcon.ImageLabel, 0.2, {ImageTransparency = 1}):Play()
                end
            end)
        end
    end
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startResizing(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and not isFullscreen then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - initialInputPosition
                local newSize = UDim2.new(0, initialSize.X.Offset + delta.X*2, 0, initialSize.Y.Offset + delta.Y*2)
                
                Tween(Window.UIElements.Main, 0.06, {
                    Size = UDim2.new(
                    0, math.clamp(newSize.X.Offset, 480, 700),
                    0, math.clamp(newSize.Y.Offset, 350, 520)
                )}):Play()
            end
        end
    end)
    
    
    -- / Search Bar /
    
    local SearchBar = require("./SearchBar")
    local CanOpen = true
    local IsOpen = false
    local CurrentSearchBar
    
    local SearchButton
    SearchButton = Window:CreateTopbarButton("search", function() 
        if not CanOpen and not IsOpen then return end
        if not Window.CurrentTab then return end
        
        local function closeSearchbar()
            CanOpen = true
            IsOpen = false
            
            Window.UIElements.SideBarContainer.Visible = true
            Tween(Window.UIElements.MainBar, .25, {
                Size = UDim2.new(
                    1,
                    -Window.UIElements.SideBarContainer.AbsoluteSize.X,
                    Window.UIElements.SideBarContainer.Size.Y.Scale,
                    Window.UIElements.SideBarContainer.Size.Y.Offset
                )
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            Tween(Window.UIElements.SideBarContainer, .1, {
                GroupTransparency = 0
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            
            Tween(SearchButton.ImageLabel, .15, {ImageTransparency = 0}):Play()
        end
        
        if not IsOpen then
            CanOpen = false
            IsOpen = true
            
            Tween(Window.UIElements.MainBar, .25, {
                Size = UDim2.new(
                    1,
                    0,
                    Window.UIElements.SideBarContainer.Size.Y.Scale,
                    Window.UIElements.SideBarContainer.Size.Y.Offset-52
                )
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            Tween(Window.UIElements.SideBarContainer, .1, {
                GroupTransparency = 1
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
            
            Tween(SearchButton.ImageLabel, .15, {ImageTransparency = .4}):Play()
            
            CurrentSearchBar = SearchBar.new(
                TabModule.Tabs[Window.CurrentTab].Elements, 
                Window.UIElements.Main, 
                TabModule.Tabs[Window.CurrentTab].Title, 
                closeSearchbar,
                TabModule.Tabs[Window.CurrentTab].ContainerFrame 
            )
        else
            closeSearchbar()
            
            if CurrentSearchBar then
                CurrentSearchBar:Close()
                CurrentSearchBar:Search("")
                CurrentSearchBar = nil
            end
        end
        
        task.wait(.25)
        Window.UIElements.SideBarContainer.Visible = not IsOpen
    end, 996)

    return Window
end