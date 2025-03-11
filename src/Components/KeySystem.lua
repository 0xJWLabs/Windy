local KeySystem = {}


local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween


function KeySystem.new(Config, Filename, func)
    local KeyDialogInit = require("./Dialog").Init(Config.Windy.ScreenGui.KeySystem)
    local KeyDialog = KeyDialogInit.Create(true)
    
    local ThumbnailSize = 200
    
    local UISize = 430
    if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
        UISize = 430+(ThumbnailSize/2)
    end
    
    KeyDialog.UIElements.Main.AutomaticSize = "Y"
    KeyDialog.UIElements.Main.Size = UDim2.new(0,UISize,0,0)
    
    local IconFrame
    
    if Config.Icon then
        local themetag = { ImageColor3 = "Text" }
        
        if string.find(Config.Icon, "rbxassetid://") or not Creator.Icon(tostring(Config.Icon))[1] then
            themetag = nil
        end
        IconFrame = New("ImageLabel", {
            Size = UDim2.new(0,24,0,24),
            BackgroundTransparency = 1,
            LayoutOrder = -1,
            ThemeTag = themetag
        })
        if string.find(Config.Icon, "rbxassetid://") or string.find(Config.Icon, "http://www.roblox.com/asset/?id=") then
            IconFrame.Image = Config.Icon
        elseif string.find(Config.Icon,"http") then
            local success, response = pcall(function()
                if not isfile("Windy/" .. Window.Folder .. "/Assets/Icon.png") then
                    local response = request({
                        Url = Config.Icon,
                        Method = "GET",
                    }).Body
                    writefile("Windy/" .. Window.Folder .. "/Assets/Icon.png", response)
                end
                IconFrame.Image = getcustomasset("Windy/" .. Window.Folder .. "/Assets/Icon.png")
            end)
            if not success then
                IconFrame:Destroy()
                
                warn("[ Windy ]  '" .. identifyexecutor() .. "' doesnt support the URL Images. Error: " .. response)
            end
        else
            if Creator.Icon(tostring(Config.Icon))[1] then
                IconFrame.Image = Creator.Icon(Config.Icon)[1]
                IconFrame.ImageRectOffset = Creator.Icon(Config.Icon)[2].ImageRectPosition
                IconFrame.ImageRectSize = Creator.Icon(Config.Icon)[2].ImageRectSize
            end
        end
    end
    
    local Title = New("TextLabel", {
        AutomaticSize = "XY",
        BackgroundTransparency = 1,
        Text = Config.Title,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        ThemeTag = {
            TextColor3 = "Text",
        },
        TextSize = 20
    })
    local KeySystemTitle = New("TextLabel", {
        AutomaticSize = "XY",
        BackgroundTransparency = 1,
        Text = "Key System",
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        TextTransparency = 1, -- .4 -- hidden
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        ThemeTag = {
            TextColor3 = "Text",
        },
        TextSize = 16
    })
    
    local IconAndTitleContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0,14),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center"
        }),
        IconFrame, Title
    })
    
    local TitleContainer = New("Frame", {
        AutomaticSize = "Y",
        Size = UDim2.new(1,0,0,0),
        BackgroundTransparency = 1,
    }, {
        -- New("UIListLayout", {
        --     Padding = UDim.new(0,9),
        --     FillDirection = "Horizontal",
        --     VerticalAlignment = "Bottom"
        -- }),
        IconAndTitleContainer, KeySystemTitle,
    })
    
    -- local CloseButton = New("TextButton", {
    --     Size = UDim2.new(0,24,0,24),
    --     BackgroundTransparency = 1,
    --     AnchorPoint = Vector2.new(1,0),
    --     Position = UDim2.new(1,0,0,0),
    -- }, {
    --     New("ImageLabel", {
    --         Image = Creator.Icon("x")[1],
    --         ImageRectOffset = Creator.Icon("x")[2].ImageRectPosition,
    --         ImageRectSize = Creator.Icon("x")[2].ImageRectSize,
    --         ThemeTag = {
    --             ImageColor3 = "Text",
    --         },
    --         BackgroundTransparency = 1,
    --         Size = UDim2.new(1,-3,1,-3),
    --     })
    -- })
    -- CloseButton.MouseButton1Up:Connect(function()
    --     KeyDialog:Close()()
    -- end)

    local TextBox = New("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        TextXAlignment = "Left",
        PlaceholderText = "Enter Key...",
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        ThemeTag = {
            TextColor3 = "Text",
            PlaceholderColor3 = "PlaceholderText"
        },
        TextSize = 18
    })
    
    local TextBoxHolder = New("Frame", {
        BackgroundTransparency = .95,
        Size = UDim2.new(1,0,0,42),
        ThemeTag = {
            BackgroundColor3 = "Text",
        },
    }, {
        New("UIStroke", {
            Thickness = 1.3,
            ThemeTag = {
                Color = "Text",
            },
            Transparency = .9,
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,12)
        }),
        TextBox,
        New("UIPadding", {
            PaddingLeft = UDim.new(0,12),
            PaddingRight = UDim.new(0,12),
        })
    })
    
    local NoteText
    if Config.KeySystem.Note and Config.KeySystem.Note ~= "" then
        NoteText = New("TextLabel", {
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            TextXAlignment = "Left",
            Text = Config.KeySystem.Note,
            TextSize = 18,
            TextTransparency = .4,
            ThemeTag = {
                TextColor3 = "Text",
            },
            BackgroundTransparency = 1,
            RichText = true
        })
    end

    local ButtonsContainer = New("Frame", {
        Size = UDim2.new(1,0,0,42),
        BackgroundTransparency = 1,
    }, {
        New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = "X",
            Size = UDim2.new(0,0,1,0),
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0,18/2),
                FillDirection = "Horizontal",
            })
        })
    })
    
    local function CreateButton(Title, Icon, Callback, Variant, Parent)
        local themetagbg = "Text"
        local ButtonFrame = New("TextButton", {
            -- Size = UDim2.new(
            --     (1 / #KeySystemButtons), 
            --     -(((#KeySystemButtons - 1) * 9) / #KeySystemButtons), 
            --     1, 
            --     0
            -- ),
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = "XY",
            -- Parent = ButtonsContainer,
            Parent = Parent,
            ThemeTag = {
                BackgroundColor3 = themetagbg,
            },
            BackgroundTransparency = Variant == "Primary" and .1 or Variant == "Secondary" and .85 or .95
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,12),
            }),
            
            New("Frame", {
                Size = UDim2.new(1,0,1,0),
                ThemeTag = {
                    BackgroundColor3 = Variant == "Primary" and "Accent" or themetagbg
                },
                BackgroundTransparency = 1 -- .9
            }, {
                New("UIStroke", {
                    Thickness = 1.3,
                    ThemeTag = {
                        Color = "Text",
                    },
                    Transparency = Variant == "Tertiary" and .9 or 1,
                }),
                New("UIPadding", {
                    PaddingLeft = UDim.new(0,12),
                    PaddingRight = UDim.new(0,12),
                }),
                New("UICorner", {
                    CornerRadius = UDim.new(0,12),
                }),
                New("UIListLayout", {
                    FillDirection = "Horizontal",
                    Padding = UDim.new(0,12),
                    VerticalAlignment = "Center",
                    HorizontalAlignment = "Center",
                }),
                New("ImageLabel", {
                    Image = Creator.Icon(Icon)[1],
                    ImageRectSize = Creator.Icon(Icon)[2].ImageRectSize,
                    ImageRectOffset = Creator.Icon(Icon)[2].ImageRectPosition,
                    Size = UDim2.new(0,24-3,0,24-3),
                    BackgroundTransparency = 1,
                    ThemeTag = {
                        ImageColor3 = Variant ~= "Primary" and themetagbg or "Accent",
                    }
                }),
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                    Text = Title,
                    ThemeTag = {
                        TextColor3 = Variant ~= "Primary" and themetagbg or "Accent",
                    },
                    AutomaticSize = "XY",
                    TextSize = 18,
                })
            })
        })
        
        ButtonFrame.MouseEnter:Connect(function()
            Tween(ButtonFrame.Frame, .067, {BackgroundTransparency = .9}):Play()
        end)
        ButtonFrame.MouseLeave:Connect(function()
            Tween(ButtonFrame.Frame, .067, {BackgroundTransparency = 1}):Play()
        end)
        ButtonFrame.MouseButton1Up:Connect(function()
            Callback()
        end)
        
        return ButtonFrame
    end
    
    local ThumbnailFrame
    if Config.KeySystem.Thumbnail and Config.KeySystem.Thumbnail.Image then
        local ThumbnailTitle
        if Config.KeySystem.Thumbnail.Title then
            ThumbnailTitle = New("TextLabel", {
                Text = Config.KeySystem.Thumbnail.Title,
                ThemeTag = {
                    TextColor3 = "Text",
                },
                TextSize = 18,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                BackgroundTransparency = 1,
                AutomaticSize = "XY",
                AnchorPoint = Vector2.new(0.5,0.5),
                Position = UDim2.new(0.5,0,0.5,0),
            })
        end
        ThumbnailFrame = New("ImageLabel", {
            Image = Config.KeySystem.Thumbnail.Image,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,ThumbnailSize,1,0),
            Parent = KeyDialog.UIElements.Main,
            ScaleType = "Crop"
        }, {
            ThumbnailTitle,
            New("UICorner", {
                CornerRadius = UDim.new(0,0),
            })
        })
    end
    
    local MainFrame = New("Frame", {
        --AutomaticSize = "XY",
        Size = UDim2.new(1, ThumbnailFrame and -ThumbnailSize or 0,1,0),
        Position = UDim2.new(0, ThumbnailFrame and ThumbnailSize or 0,0,0),
        BackgroundTransparency = 1,
        Parent = KeyDialog.UIElements.Main
    }, {
        New("Frame", {
            --AutomaticSize = "XY",
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0,18),
                FillDirection = "Vertical",
            }),
            TitleContainer,
            NoteText,
            TextBoxHolder,
            ButtonsContainer,
            New("UIPadding", {
                PaddingTop = UDim.new(0,16),
                PaddingLeft = UDim.new(0,16),
                PaddingRight = UDim.new(0,16),
                PaddingBottom = UDim.new(0,16),
            })
        }),
        CloseButton
    })
    
    -- for _, values in next, KeySystemButtons do
    --     CreateButton(values.Title, values.Icon, values.Callback, values.Variant)
    -- end
    
    local ExitButton = CreateButton("Exit", "log-out", function()
        KeyDialog:Close()()
    end, "Tertiary", ButtonsContainer.Frame)
    
    if ThumbnailFrame then
        ExitButton.Parent = ThumbnailFrame
        ExitButton.Size = UDim2.new(0,0,0,42)
        ExitButton.Position = UDim2.new(0,16,1,-16)
        ExitButton.AnchorPoint = Vector2.new(0,1)
    end
    
    if Config.KeySystem.URL then
        CreateButton("Get key", "key", function()
            setclipboard(Config.KeySystem.URL)
        end, "Secondary", ButtonsContainer.Frame)
    end
    
    local SubmitButton = CreateButton("Submit", "arrow-right", function()
        local Key = TextBox.Text
        local isKey = tostring(Config.KeySystem.Key) == tostring(Key)
        if type(Config.KeySystem.Key) == "table" then
            isKey = table.find(Config.KeySystem.Key, tostring(Key))
        end
        
        if isKey then
            KeyDialog:Close()()
            
            if Config.KeySystem.SaveKey then
                local folder = Config.Folder or Config.Title
                writefile(folder .. "/" .. Filename .. ".key", tostring(Key))
            end
            
            task.wait(.4)
            func(true)
        else
            local OldColor = TextBoxHolder.UIStroke.Color
            local OldBGColor = TextBoxHolder.BackgroundColor3
            Tween(TextBoxHolder.UIStroke, 0.1, {Color = Color3.fromHex("#ff1e1e"), Transparency= .65}):Play()
            Tween(TextBoxHolder, 0.1, {BackgroundColor3= Color3.fromHex("#ff1e1e"), Transparency= .8}):Play()
            
            task.wait(.5)
            
            Tween(TextBoxHolder.UIStroke, 0.15, {Color = OldColor, Transparency = .9}):Play()
            Tween(TextBoxHolder, 0.15, {BackgroundColor3 = OldBGColor, Transparency = .95}):Play()
        end
    end, "Primary", ButtonsContainer)
    
    SubmitButton.AnchorPoint = Vector2.new(1,0.5)
    SubmitButton.Position = UDim2.new(1,0,0.5,0)
    
    -- TitleContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    --     KeyDialog.UIElements.Main.Size = UDim2.new(
    --         0,
    --         TitleContainer.AbsoluteSize.X +24+24+24+24+9,
    --         0,
    --         0
    --     )
    -- end)
    
    KeyDialog:Open()
end

return KeySystem