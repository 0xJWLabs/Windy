local UserInputService = game:GetService("UserInputService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local TabModule = {
    Window = nil,
    Windy = nil,
    Tabs = {}, 
    Containers = {},
    SelectedTab = nil,
    TabCount = 0,
    ToolTipParent = nil,
    TabHighlight = nil,
    
    OnChangeFunc = function(v) end
}

function TabModule.Init(Window, Windy, ToolTipParent, TabHighlight)
    TabModule.Window = Window
    TabModule.Windy = Windy
    TabModule.ToolTipParent = ToolTipParent
    TabModule.TabHighlight = TabHighlight
    return TabModule
end

function TabModule.New(Config)
    local Tab = {
        Title = Config.Title or "Tab",
        Desc = Config.Desc,
        Icon = Config.Icon,
        Selected = false,
        Index = nil,
        Parent = Config.Parent,
        UIElements = {},
        Elements = {},
        ContainerFrame = nil,
    }
    
    local Window = TabModule.Window
    local Windy = TabModule.Windy
    
    TabModule.TabCount = TabModule.TabCount + 1
  	local TabIndex = TabModule.TabCount
  	Tab.Index = TabIndex
  	
  	Tab.UIElements.Main = New("TextButton", {
  	    BackgroundTransparency = 1,
  	    Size = UDim2.new(1,0,0,0),
  	    AutomaticSize = "Y",
  	    Parent = Config.Parent
  	}, {
  	    New("UIListLayout", {
  	        SortOrder = "LayoutOrder",
  	        Padding = UDim.new(0,10),
  	        FillDirection = "Horizontal",
  	        VerticalAlignment = "Center",
  	    }),
  	    New("TextLabel", {
  	        Text = Tab.Title,
  	        ThemeTag = {
  	            TextColor3 = "Text"
  	        },
  	        TextTransparency = 0.4,
  	        TextSize = 15,
  	        Size = UDim2.new(1,0,0,0),
  	        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
  	        TextWrapped = true,
  	        RichText = true,
  	        --AutomaticSize = "Y",
  	        LayoutOrder = 2,
  	        TextXAlignment = "Left",
  	        BackgroundTransparency = 1,
  	    }),
  	    New("UIPadding", {
  	        PaddingTop = UDim.new(0,6),
  	        PaddingBottom = UDim.new(0,6),
  	    })
  	})
  	
  	local TextOffset = 0

--	Tab.UIElements.Main.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
--	    Tab.UIElements.Main.TextLabel.Size = UDim2.new(1,0,0,Tab.UIElements.Main.TextLabel.TextBounds.Y)
--	    Tab.UIElements.Main.Size = UDim2.new(1,TextOffset,0,Tab.UIElements.Main.TextLabel.TextBounds.Y+6+6)
--	end)
  	
  	if Tab.Icon and Creator.Icon(Tab.Icon) then
        local Icon = New("ImageLabel", {
            ImageTransparency = 0.4,
            Image = Creator.Icon(Tab.Icon)[1],
            ImageRectOffset = Creator.Icon(Tab.Icon)[2].ImageRectPosition,
            ImageRectSize = Creator.Icon(Tab.Icon)[2].ImageRectSize,
            Size = UDim2.new(0,18,0,18),
            LayoutOrder = 1,
            ThemeTag = {
                ImageColor3 = "Text"
            },
            BackgroundTransparency = 1,
            Parent = Tab.UIElements.Main,
        })
        Tab.UIElements.Main.TextLabel.Size = UDim2.new(1,-30,0,0)
        TextOffset = -30
    elseif Tab.Icon and string.find(Tab.Icon, "rbxassetid://") then
        local Icon = New("ImageLabel", {
            ImageTransparency = 0.4,
            Image = Tab.Icon,
            Size = UDim2.new(0,18,0,18),
            LayoutOrder = 1,
            ThemeTag = {
                ImageColor3 = "Text"
            },
            BackgroundTransparency = 1,
            Parent = Tab.UIElements.Main,
        })
        Tab.UIElements.Main.TextLabel.Size = UDim2.new(1,-30,0,0)
        TextOffset = -30
	end
	
	Tab.UIElements.ContainerFrame = New("ScrollingFrame", {
        Size = UDim2.new(1,-Window.UIPadding,1,0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ElasticBehavior = "Never",
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        --Visible = false,
        ScrollingDirection = "Y",
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0,Window.UIPadding),
            PaddingLeft = UDim.new(0,Window.UIPadding),
            PaddingRight = UDim.new(0,0),
            PaddingBottom = UDim.new(0,Window.UIPadding),
        }),
        New("UIListLayout", {
            SortOrder = "LayoutOrder",
            Padding = UDim.new(0,6)
        })
    })

    -- Tab.UIElements.ContainerFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    --     Tab.UIElements.ContainerFrame.CanvasSize = UDim2.new(0,0,0,Tab.UIElements.ContainerFrame.UIListLayout.AbsoluteContentSize.Y+Window.UIPadding*2)
    -- end)

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

    Tab.UIElements.ContainerFrameCanvas = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Window.UIElements.MainBar
    }, {
        Tab.UIElements.ContainerFrame,
        Slider 
    })

    TabModule.Containers[TabIndex] = Tab.UIElements.ContainerFrameCanvas
	TabModule.Tabs[TabIndex] = Tab
	
	Tab.ContainerFrame = ContainerFrameCanvas
	
	Tab.UIElements.Main.MouseButton1Click:Connect(function()
	    TabModule:SelectTab(TabIndex)
	end)
    
    local function updateSliderSize()
        local container = Tab.UIElements.ContainerFrame
        local visibleRatio = math.clamp(container.AbsoluteWindowSize.Y / container.AbsoluteCanvasSize.Y, 0, 1)
    
        Thumb.Size = UDim2.new(1, 0, visibleRatio, 0)
        Thumb.Visible = visibleRatio < 1
    end
        
    local function updateScrollingFramePosition()
        local thumbPosition = Thumb.Position.Y.Scale
        local canvasSize = math.max(Tab.UIElements.ContainerFrame.AbsoluteCanvasSize.Y - Tab.UIElements.ContainerFrame.AbsoluteWindowSize.Y, 1)
    
        Tab.UIElements.ContainerFrame.CanvasPosition = Vector2.new(
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
    
    
    Tab.UIElements.ContainerFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local canvasPosition = Tab.UIElements.ContainerFrame.CanvasPosition.Y
        local canvasSize = Tab.UIElements.ContainerFrame.AbsoluteCanvasSize.Y - Tab.UIElements.ContainerFrame.AbsoluteWindowSize.Y
        local newThumbPosition = canvasPosition / canvasSize
    
        Thumb.Position = UDim2.new(0, 0, newThumbPosition, 0)
    end)
    
    Thumb:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Slider.Size = UDim2.new(0, Slider.Size.X.Offset, 1, -Thumb.AbsoluteSize.Y - Window.UIPadding*2)
    end)
    Tab.UIElements.ContainerFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateSliderSize)
    Tab.UIElements.ContainerFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateSliderSize)
    
    updateSliderSize()
	
	
	-- ToolTip
	
    local ToolTip
    local hoverTimer
    local MouseConn
    local IsHovering = false
    
    local function removeToolTip()
        IsHovering = false
        if hoverTimer then
            task.cancel(hoverTimer)
            hoverTimer = nil
        end
        if MouseConn then
            MouseConn:Disconnect()
            MouseConn = nil
        end
        if ToolTip then
            ToolTip:Close()
            ToolTip = nil
        end
    end
    
    Tab.UIElements.Main.InputBegan:Connect(function()
        IsHovering = true
        hoverTimer = task.spawn(function()
            task.wait(0.35)
            if IsHovering and not ToolTip then
                ToolTip = Creator.ToolTip({
                    Title = Tab.Desc,
                    Parent = TabModule.ToolTipParent
                })
    
                local function updatePosition()
                    if ToolTip then
                        ToolTip.Container.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y - 20)
                    end
                end
    
                updatePosition()
                MouseConn = Mouse.Move:Connect(updatePosition)
                ToolTip:Open()
            end
        end)
    end)
    
    Tab.UIElements.Main.InputEnded:Connect(removeToolTip)

	-- WTF
	
    function Tab:Paragraph(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        ElementConfig.Window = Window
        ElementConfig.Hover = false
        ElementConfig.TextOffset = 0
        ElementConfig.IsButtons = ElementConfig.Buttons and #ElementConfig.Buttons > 0 and true or false
        
        local ParagraphModule = {
            __type = "Paragraph",
            Title = ElementConfig.Title or "Input",
            Desc = ElementConfig.Desc or nil,
            Locked = ElementConfig.Locked or false,
        }
        local Paragraph = require("../Components/Element")(ElementConfig)
        
        ParagraphModule.ParagraphFrame = Paragraph
        if ElementConfig.Buttons and #ElementConfig.Buttons > 0 then
            local ButtonsContainer = New("Frame", {
                Size = UDim2.new(1,0,0,0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0,0,0,ElementConfig.Image and Paragraph.ImageSize > Paragraph.UIElements.Main.Title.AbsoluteSize.Y and Paragraph.ImageSize+Paragraph.UIPadding or Paragraph.UIElements.Main.Title.AbsoluteSize.Y+Paragraph.UIPadding),
                AutomaticSize = "Y",
                Parent = Paragraph.UIElements.Main
            }, {
                New("UIListLayout", {
                    Padding = UDim.new(0,10),
                    FillDirection = "Horizontal",
                })
            })
            
            for _,ButtonData in next, ElementConfig.Buttons do
                local Button = New("TextButton", {
                    Text = ButtonData.Title,
                    TextSize = 16,
                    AutomaticSize = "Y",
                    ThemeTag = {
                        TextColor3 = "Accent",
                        BackgroundColor3 = "Text"
                    },
                    FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                    BackgroundTransparency = 0.1,
                    Size = UDim2.new(1 / #ElementConfig.Buttons, -(((#ElementConfig.Buttons - 1) * 10) / #ElementConfig.Buttons), 0, 32),
                    Parent = ButtonsContainer,
                }, {
                    New("UICorner", {
                        CornerRadius = UDim.new(0,8)
                    })
                })
                Button.MouseEnter:Connect(function()
                    Tween(Button, 0.1, {BackgroundTransparency = .3}):Play()
                end)
                Button.MouseLeave:Connect(function()
                    Tween(Button, 0.1, {BackgroundTransparency = .1}):Play()
                end)
                Button.MouseButton1Click:Connect(function()
                    ButtonData.Callback()
                end)
            end
        end
        
        function ParagraphModule:SetTitle(Title)
            ParagraphModule.ParagraphFrame:SetTitle(Title)
        end
        function ParagraphModule:SetDesc(Title)
            ParagraphModule.ParagraphFrame:SetDesc(Title)
        end
        
        table.insert(Tab.Elements, ParagraphModule)
        return ParagraphModule
    end
    function Tab:Button(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Button, Content = require("../Elements/Button"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.ButtonFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.ButtonFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Toggle(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Toggle, Content = require("../Elements/Toggle"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.ToggleFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.ToggleFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Slider(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Slider, Content = require("../Elements/Slider"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.SliderFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.SliderFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Keybind(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Keybind, Content = require("../Elements/Keybind"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.KeybindFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.KeybindFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Input(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Input, Content = require("../Elements/Input"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.InputFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.InputFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Dropdown(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        ElementConfig.Window = Window
        local Dropdown, Content = require("../Elements/Dropdown"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.DropdownFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.DropdownFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Code(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        ElementConfig.Window = Window
        ElementConfig.Windy = Windy
        local Code, Content = require("../Elements/Code"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.CodeFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.CodeFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Colorpicker(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        ElementConfig.Window = Window
        local Colorpicker, Content = require("../Elements/Colorpicker"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        
        function Content:SetTitle(Title)
            Content.ColorpickerFrame:SetTitle(Title)
        end
        function Content:SetDesc(Title)
            Content.ColorpickerFrame:SetDesc(Title)
        end
        
        return Content
    end
    function Tab:Section(ElementConfig)
        ElementConfig.Parent = Tab.UIElements.ContainerFrame
        local Section, Content = require("../Elements/Section"):New(ElementConfig)
        table.insert(Tab.Elements, Content)
        return Content
    end

	
	task.spawn(function()
        local Empty = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,-Window.UIElements.Main.Main.Topbar.AbsoluteSize.Y),
            Parent = Tab.UIElements.ContainerFrame
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0,8),
                SortOrder = "LayoutOrder",
                VerticalAlignment = "Center",
                HorizontalAlignment = "Center",
                FillDirection = "Vertical",
            }), 
            New("ImageLabel", {
                Size = UDim2.new(0,48,0,48),
                Image = Creator.Icon("frown")[1],
                ImageRectOffset = Creator.Icon("frown")[2].ImageRectPosition,
                ImageRectSize = Creator.Icon("frown")[2].ImageRectSize,
                ThemeTag = {
                    ImageColor3 = "Text"
                },
                BackgroundTransparency = 1,
                ImageTransparency = .4,
            }),
            New("TextLabel", {
                AutomaticSize = "XY",
                Text = "This tab is empty",
                ThemeTag = {
                    TextColor3 = "Text"
                },
                TextSize = 18,
                TextTransparency = .4,
                BackgroundTransparency = 1,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            })
        })
        
        -- Empty.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        --     Empty.TextLabel.Size = UDim2.new(0,Empty.TextLabel.TextBounds.X,0,Empty.TextLabel.TextBounds.Y)
        -- end)
        
        Tab.UIElements.ContainerFrame.ChildAdded:Connect(function()
            Empty.Visible = false
        end)
	end)
	
	return Tab
end

function TabModule:OnChange(func)
    TabModule.OnChangeFunc = func
end

function TabModule:SelectTab(TabIndex)
    TabModule.SelectedTab = TabIndex
    
    for _, TabObject in next, TabModule.Tabs do
        Tween(TabObject.UIElements.Main.TextLabel, 0.15, {TextTransparency = 0.4}):Play()
        if TabObject.Icon and Creator.Icon(TabObject.Icon) then
            Tween(TabObject.UIElements.Main.ImageLabel, 0.15, {ImageTransparency = 0.4}):Play()
        end
		TabObject.Selected = false
	end
    Tween(TabModule.Tabs[TabIndex].UIElements.Main.TextLabel, 0.15, {TextTransparency = 0}):Play()
    if TabModule.Tabs[TabIndex].Icon and Creator.Icon(TabModule.Tabs[TabIndex].Icon) then
        Tween(TabModule.Tabs[TabIndex].UIElements.Main.ImageLabel, 0.15, {ImageTransparency = 0}):Play()
    end
	TabModule.Tabs[TabIndex].Selected = true
	
	Tween(TabModule.TabHighlight, .25, {Position = UDim2.new(
	    0,
	    0,
	    0,
	    TabModule.Tabs[TabIndex].UIElements.Main.AbsolutePosition.Y - TabModule.Tabs[TabIndex].Parent.AbsolutePosition.Y
	), 
	Size = UDim2.new(1,-13,0,TabModule.Tabs[TabIndex].UIElements.Main.AbsoluteSize.Y)
	}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
	
	task.spawn(function()
	    for _, ContainerObject in next, TabModule.Containers do
	        ContainerObject.AnchorPoint = Vector2.new(0,0.05)
	        ContainerObject.Visible = false
	    end
	    TabModule.Containers[TabIndex].Visible = true
	    Tween(TabModule.Containers[TabIndex], 0.15, {AnchorPoint = Vector2.new(0,0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
	end)
	
	TabModule.OnChangeFunc(TabIndex)
end

return TabModule