local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()


local Element = {
    UICorner = 6,
    UIPadding = 8
}

function Element:Colorpicker(Config, OnApply)
    local Colorpicker = {
        __type = "Colorpicker",
        Title = Config.Title,
        Desc = Config.Desc,
        Default = Config.Default,
        Callback = Config.Callback,
        Transparency = Config.Transparency,
        UIElements = Config.UIElements,
    }
    
    function Colorpicker:SetHSVFromRGB(Color)
		local H, S, V = Color3.toHSV(Color)
		Colorpicker.Hue = H
		Colorpicker.Sat = S
		Colorpicker.Vib = V
	end

	Colorpicker:SetHSVFromRGB(Colorpicker.Default)
    
    local ColorpickerModule = require("../Components/Dialog").Init(Config.Window)
    local ColorpickerFrame = ColorpickerModule.Create()
    
    Colorpicker.ColorpickerFrame = ColorpickerFrame
    
    ColorpickerFrame:Close()
    
    local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib

    Colorpicker.UIElements.Title = New("TextLabel", {
        Text = "Colorpicker",
        TextSize = 20,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
        TextXAlignment = "Left",
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = "Y",
        ThemeTag = {
            TextColor3 = "Text"
        },
        BackgroundTransparency = 1,
        Parent = ColorpickerFrame.UIElements.Main
    })
    
    -- Colorpicker.UIElements.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --     Colorpicker.UIElements.Title.Size = UDim2.new(1,0,0,Colorpicker.UIElements.Title.TextBounds.Y)
    -- end)

    local SatCursor = New("ImageLabel", {
		Size = UDim2.new(0, 18, 0, 18),
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=4805639000",
	})

    Colorpicker.UIElements.SatVibMap = New("ImageLabel", {
  		Size = UDim2.fromOffset(160, 182-24),
  		Position = UDim2.fromOffset(0, 40),
  		Image = "rbxassetid://4155801252",
  		BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
  		BackgroundTransparency = 0,
  		Parent = ColorpickerFrame.UIElements.Main,
  	}, {
  		New("UICorner", {
  			CornerRadius = UDim.new(0, 6),
  		}),
  		New("UIStroke", {
  			Thickness = .6,
  			ThemeTag = {
  			    Color = "Text"
  			},
  			Transparency = .8,
  		}),
  		SatCursor,
  	})
  	
  	Colorpicker.UIElements.Inputs = New("Frame", {
  	    AutomaticSize = "XY",
  	    Position = UDim2.fromOffset(Colorpicker.Transparency and 160+10+10+20+20+10 or 160+10+10+20, 40),
  	    BackgroundTransparency = 1,
  	    Parent = ColorpickerFrame.UIElements.Main
  	}, {
  	    New("UIListLayout", {
  		    Padding = UDim.new(0, 8),
  		    FillDirection = "Vertical",
  	    })
  	})
  	
--	Colorpicker.UIElements.Inputs.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
--         Colorpicker.UIElements.Inputs.Size = UDim2.new(0,Colorpicker.UIElements.Inputs.UIListLayout.AbsoluteContentSize.X,0,Colorpicker.UIElements.Inputs.UIListLayout.AbsoluteContentSize.Y)
--     end)
	
	local OldColorFrame = New("Frame", {
		BackgroundColor3 = Colorpicker.Default,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = Colorpicker.Transparency,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})

	local OldColorFrameChecker = New("ImageLabel", {
		Image = "http://www.roblox.com/asset/?id=14204231522",
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(40, 40),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(75+10, 40+182-24+10),
		Size = UDim2.fromOffset(75, 24),
		Parent = ColorpickerFrame.UIElements.Main,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("UIStroke", {
			Thickness = .6,
			Transparency = 0.8,
			ThemeTag = {
			    Color = "Text"
			}
		}),
		OldColorFrame,
	})

	local NewDisplayFrame = New("Frame", {
		BackgroundColor3 = Colorpicker.Default,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		ZIndex = 9,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	local NewDisplayFrameChecker = New("ImageLabel", {
		Image = "http://www.roblox.com/asset/?id=14204231522",
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(40, 40),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 40+182-24+10),
		Size = UDim2.fromOffset(75, 24),
		Parent = ColorpickerFrame.UIElements.Main,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		New("UIStroke", {
			Thickness = .6,
			Transparency = 0.8,
			ThemeTag = {
			    Color = "Text"
			}
		}),
		NewDisplayFrame,
	})
	
	local SequenceTable = {}

	for Color = 0, 1, 0.1 do
		table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
	end

	local HueSliderGradient = New("UIGradient", {
		Color = ColorSequence.new(SequenceTable),
		Rotation = 90,
	})
	
	local HueDragHolder = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0,0,0,0),
		BackgroundTransparency = 1,
	})

	local HueDrag = New("ImageLabel", {
		Size = UDim2.new(1,0,0,3),
		Image = "rbxassetid://18747052224",
		AnchorPoint = Vector2.new(0,0.5),
		Parent = HueDragHolder,
		ScaleType = "Crop",
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	local HueSlider = New("Frame", {
		Size = UDim2.fromOffset(20, 182+10),
		Position = UDim2.fromOffset(160+10, 40),
		Parent = ColorpickerFrame.UIElements.Main,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		HueSliderGradient,
		HueDragHolder,
	})
	
	
	function CreateInput(Title, Value)
	    local Container = New("Frame", {
	        Size = UDim2.new(0,120,0,28),
	        AutomaticSize = "Y",
	        BackgroundTransparency = 1,
	        Parent = Colorpicker.UIElements.Inputs
	    }, {
	        New("UIListLayout", {
		        Padding = UDim.new(0,10),
		        FillDirection = "Vertical",
	        }),
	        New("Frame",{
                BackgroundTransparency = .95,
                Size = UDim2.new(1,0,0,30),
                AnchorPoint = Vector2.new(1,0.5),
                Position = UDim2.new(1,0,0.5,0),
                ThemeTag = {
                    BackgroundColor3 = "Text",
                },
                ZIndex = 2
            }, {
                New("TextBox", {
                    MultiLine = false,
                    Size = UDim2.new(1,-40,0,0),
                    AutomaticSize = "Y",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,0,0.5,0),
                    AnchorPoint = Vector2.new(0,0.5),
                    ClearTextOnFocus = false,
                    Text = Value,
                    TextSize = 15,
                    ClipsDescendants = true,
                    TextXAlignment = "Left",
                    FontFace = Font.new(Creator.Font),
                    PlaceholderText = "",
                    ThemeTag = {
                        TextColor3 = "Text",
                    }
                }),
                New("TextLabel", {
	                Text = Title,
	                TextSize = 16,
	                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
	                ThemeTag = {
	                    TextColor3 = "Text"
	                },
	                BackgroundTransparency = 1,
	                TextXAlignment = "Right",
	                Position = UDim2.new(1,0,0.5,0),
	                AnchorPoint = Vector2.new(1,0.5),
	                Size = UDim2.new(0,0,0,0),
	                TextTransparency = .4,
	                AutomaticSize = "XY",
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
	    })
	
	   -- Container.Frame.TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --         Container.Frame.TextBox.Size = UDim2.new(1,-40,0,Container.Frame.TextBox.TextBounds.Y)
    --     end)
	   -- Container.Frame.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
    --         Container.Frame.TextLabel.Size = UDim2.new(0,Container.Frame.TextLabel.TextBounds.X,0,Container.Frame.TextLabel.TextBounds.Y)
    --     end)
	    
	    return Container
	end
	
	local function ToRGB(color)
        return {
            R = math.floor(color.R * 255),
            G = math.floor(color.G * 255),
            B = math.floor(color.B * 255)
        }
    end
	
	local HexInput = CreateInput("Hex", "#" .. Colorpicker.Default:ToHex())
	
	local RedInput = CreateInput("Red", ToRGB(Colorpicker.Default)["R"])
	local GreenInput = CreateInput("Green", ToRGB(Colorpicker.Default)["G"])
	local BlueInput = CreateInput("Blue", ToRGB(Colorpicker.Default)["B"])
	local AlphaInput
	if Colorpicker.Transparency then
	    AlphaInput = CreateInput("Alpha", ((1 - Colorpicker.Transparency) * 100) .. "%")
	end
	
	local ButtonsContent = New("Frame", {
        Size = UDim2.new(1,0,0,32),
        AutomaticSize = "Y",
        Position = UDim2.new(0,0,0,40+8+182+24),
        BackgroundTransparency = 1,
        Parent = ColorpickerFrame.UIElements.Main,
        LayoutOrder = 4,
    }, {
        New("UIListLayout", {
		    Padding = UDim.new(0, 8),
		    FillDirection = "Horizontal",
		    HorizontalAlignment = "Center",
	    }),
    })
	
	local Buttons = {
	    {
	        Title = "Cancel",
	        Callback = function() end
	    },
	    {
	        Title = "Apply",
	        Variant = "Primary",
	        Callback = function() OnApply(Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib), Colorpicker.Transparency) end
	    }
	}
	
	for _,Button in next, Buttons do
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
            Size = UDim2.new(1 / #Buttons, -(((#Buttons - 1) * 10) / #Buttons), 1, 0),
            --AutomaticSize = "X",
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, ColorpickerFrame.UICorner-5),
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, ColorpickerFrame.UIPadding/1.85),
                PaddingRight = UDim.new(0, ColorpickerFrame.UIPadding/1.85),
                PaddingBottom = UDim.new(0, 0),
            }),
            New("Frame", {
                Size = UDim2.new(1,(ColorpickerFrame.UIPadding/1.85)*2,1,0),
                Position = UDim2.new(0.5,0,0.5,0),
                AnchorPoint = Vector2.new(0.5,0.5),
                ThemeTag = {
                    BackgroundColor3 = Button.Variant == "Secondary" and "Text" or "Accent"
                },
                BackgroundTransparency = 1, -- .9
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, ColorpickerFrame.UICorner-5),
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
            ColorpickerFrame:Close()
            task.spawn(function()
                Button.Callback()
            end)
        end)
    end
        
  	
--	for _,Button in next, Buttons do
--         local ButtonFrame = New("TextButton", {
--             Text = Button.Title or "Button",
--             TextSize = 14,
--             FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
--             ThemeTag = {
--                 TextColor3 = "Text",
--                 BackgroundColor3 = "Text",
--             },
--             BackgroundTransparency = .9,
--             ZIndex = 999999,
--             Parent = ButtonsContent,
--             Size = UDim2.new(1 / #Buttons, -(((#Buttons - 1) * 8) / #Buttons), 0, 0),
--             AutomaticSize = "Y",
--         }, {
--             New("UICorner", {
--                 CornerRadius = UDim.new(0, ColorpickerFrame.UICorner-7),
--             }),
--             New("UIPadding", {
--                 PaddingTop = UDim.new(0, ColorpickerFrame.UIPadding/1.6),
--                 PaddingLeft = UDim.new(0, ColorpickerFrame.UIPadding/1.6),
--                 PaddingRight = UDim.new(0, ColorpickerFrame.UIPadding/1.6),
--                 PaddingBottom = UDim.new(0, ColorpickerFrame.UIPadding/1.6),
--             }),
--             New("Frame", {
--                 Size = UDim2.new(1,(ColorpickerFrame.UIPadding/1.6)*2,1,(ColorpickerFrame.UIPadding/1.6)*2),
--                 Position = UDim2.new(0.5,0,0.5,0),
--                 AnchorPoint = Vector2.new(0.5,0.5),
--                 ThemeTag = {
--                     BackgroundColor3 = "Text"
--                 },
--                 BackgroundTransparency = 1, -- .9
--             }, {
--                 New("UICorner", {
--                     CornerRadius = UDim.new(0, ColorpickerFrame.UICorner-7),
--                 }),
--             })
--         })
    
        
        
--         ButtonFrame.MouseEnter:Connect(function()
--             Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = .9}):Play()
--         end)
--         ButtonFrame.MouseLeave:Connect(function()
--             Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = 1}):Play()
--         end)
--         ButtonFrame.MouseButton1Click:Connect(function()
--             ColorpickerFrame:Close()
--             task.spawn(function()
--                 Button.Callback()
--             end)
--         end)
--	end
  	
  	
  	local TransparencySlider, TransparencyDrag, TransparencyColor
  	if Colorpicker.Transparency then
  		local TransparencyDragHolder = New("Frame", {
  			Size = UDim2.new(1, 0, 1, 0),
  			Position = UDim2.fromOffset(0, 0),
  			BackgroundTransparency = 1,
  		})

		TransparencyDrag = New("ImageLabel", {
			Size = UDim2.new(1,0,0,3),
			AnchorPoint = Vector2.new(0,0.5),
			Image = "rbxassetid://18747052224",
			ScaleType = "Crop",
			Parent = TransparencyDragHolder,
			ThemeTag = {
				ImageColor3 = "Text",
			},
		})

		TransparencyColor = New("Frame", {
			Size = UDim2.fromScale(1, 1),
		}, {
			New("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Rotation = 270,
			}),
			New("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
		})

		TransparencySlider = New("Frame", {
			Size = UDim2.fromOffset(20, 182+10),
			Position = UDim2.fromOffset(160+10+20+10, 40),
			Parent = ColorpickerFrame.UIElements.Main,
			BackgroundTransparency = 1,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			New("ImageLabel", {
				Image = "rbxassetid://14204231522",
				ImageTransparency = 0.45,
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.fromOffset(40, 40),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			}),
			TransparencyColor,
			TransparencyDragHolder,
		})
	end
	
    function Colorpicker:Round(Number, Factor)
	    if Factor == 0 then
		    return math.floor(Number)
	    end
	    Number = tostring(Number)
	    return Number:find("%.") and tonumber(Number:sub(1, Number:find("%.") + Factor)) or Number
    end
	
	
    function Colorpicker:Update(color, transparency)
        if color then Hue, Sat, Vib = Color3.toHSV(color) else Hue, Sat, Vib = Colorpicker.Hue,Colorpicker.Sat,Colorpicker.Vib end
            
        Colorpicker.UIElements.SatVibMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
        SatCursor.Position = UDim2.new(Sat, 0, 1 - Vib, 0)
        NewDisplayFrame.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
        HueDrag.Position = UDim2.new(0, 0, Hue, 0)
        
        HexInput.Frame.TextBox.Text = "#" .. Color3.fromHSV(Hue, Sat, Vib):ToHex()
        RedInput.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["R"]
		GreenInput.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["G"]
		BlueInput.Frame.TextBox.Text = ToRGB(Color3.fromHSV(Hue, Sat, Vib))["B"]
        
        if transparency or Colorpicker.Transparency then
            TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
			NewDisplayFrame.BackgroundTransparency =  Colorpicker.Transparency or transparency
			TransparencyDrag.Position = UDim2.new(0, 0, 1 -  Colorpicker.Transparency or transparency, 0)
			AlphaInput.Frame.TextBox.Text = Colorpicker:Round((1 - Colorpicker.Transparency or transparency) * 100, 0) .. "%"
        end
    end

    Colorpicker:Update(Colorpicker.Default, Colorpicker.Transparency)
    
    
    
    
    local function GetRGB()
		local Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
		return { R = math.floor(Value.r * 255), G = math.floor(Value.g * 255), B = math.floor(Value.b * 255) }
	end
    
    -- oh no!
    
    HexInput.Frame.TextBox.FocusLost:Connect(function(Enter)
        if Enter then
            local hex = HexInput.Frame.TextBox.Text:gsub("#", "")
            local Success, Result = pcall(Color3.fromHex, hex)
            if Success and typeof(Result) == "Color3" then
                Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                Colorpicker:Update()
                Colorpicker.Default = Result
            end
        end
    end)

    RedInput.Frame.TextBox.FocusLost:Connect(function(Enter)
        if Enter then
            local CurrentColor = GetRGB()
            local Success, Result = pcall(Color3.fromRGB, tonumber(RedInput.Frame.TextBox.Text), CurrentColor["G"], CurrentColor["B"])
            if Success and typeof(Result) == "Color3" then
                if tonumber(RedInput.Frame.TextBox.Text) <= 255 then
                    Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                    Colorpicker:Update()
                end
            end
        end
    end)
    
    GreenInput.Frame.TextBox.FocusLost:Connect(function(Enter)
        if Enter then
            local CurrentColor = GetRGB()
            local Success, Result = pcall(Color3.fromRGB, CurrentColor["R"], tonumber(GreenInput.Frame.TextBox.Text), CurrentColor["B"])
            if Success and typeof(Result) == "Color3" then
                if tonumber(GreenInput.Frame.TextBox.Text) <= 255 then
                    Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                    Colorpicker:Update()
                end
            end
        end
    end)
    
    BlueInput.Frame.TextBox.FocusLost:Connect(function(Enter)
        if Enter then
            local CurrentColor = GetRGB()
            local Success, Result = pcall(Color3.fromRGB, CurrentColor["R"], CurrentColor["G"], tonumber(BlueInput.Frame.TextBox.Text))
            if Success and typeof(Result) == "Color3" then
                if tonumber(BlueInput.Frame.TextBox.Text) <= 255 then
                    Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
                    Colorpicker:Update()
                end
            end
        end
    end)
    
    if Colorpicker.Transparency then
		AlphaInput.Frame.TextBox.FocusLost:Connect(function(Enter)
			if Enter then
				pcall(function()
					local Value = tonumber(AlphaInput.Frame.TextBox.Text)
					if Value >= 0 and Value <= 100 then
						Colorpicker.Transparency = 1 - Value * 0.01
			            Colorpicker:Update(nil, Colorpicker.Transparency)
					end
				end)
			end
		end)
    end

    -- fu
    
    local SatVibMap = Colorpicker.UIElements.SatVibMap
    SatVibMap.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				local MinX = SatVibMap.AbsolutePosition.X
				local MaxX = MinX + SatVibMap.AbsoluteSize.X
				local MouseX = math.clamp(Mouse.X, MinX, MaxX)

				local MinY = SatVibMap.AbsolutePosition.Y
				local MaxY = MinY + SatVibMap.AbsoluteSize.Y
				local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

				Colorpicker.Sat = (MouseX - MinX) / (MaxX - MinX)
				Colorpicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
				Colorpicker:Update()

				RenderStepped:Wait()
			end
		end
    end)

    HueSlider.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				local MinY = HueSlider.AbsolutePosition.Y
				local MaxY = MinY + HueSlider.AbsoluteSize.Y
				local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

				Colorpicker.Hue = ((MouseY - MinY) / (MaxY - MinY))
				Colorpicker:Update()

				RenderStepped:Wait()
			end
		end
    end)
    
    if Colorpicker.Transparency then
		TransparencySlider.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinY = TransparencySlider.AbsolutePosition.Y
					local MaxY = MinY + TransparencySlider.AbsoluteSize.Y
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

					Colorpicker.Transparency = 1 - ((MouseY - MinY) / (MaxY - MinY))
					Colorpicker:Update()

					RenderStepped:Wait()
				end
			end
		end)
    end
	
    return Colorpicker
end

function Element:New(Config) 
    local Colorpicker = {
        __type = "Colorpicker",
        Title = Config.Title or "Colorpicker",
        Desc = Config.Desc or nil,
        Locked = Config.Locked or false,
        Default = Config.Default or Color3.new(1,1,1),
        Callback = Config.Callback or function() end,
        Window = Config.Window,
        Transparency = Config.Transparency,
        UIElements = {}
    }
    
    local CanCallback = true
    
    
    Colorpicker.ColorpickerFrame = require("../Components/Element")({
        Title = Colorpicker.Title,
        Desc = Colorpicker.Desc,
        Parent = Config.Parent,
        TextOffset = 40,
        Hover = false,
    })
    
    Colorpicker.UIElements.Colorpicker = New("TextButton",{
        BackgroundTransparency = 0,
        Text = "",
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        TextSize = 15,
        TextTransparency = .4,
        Active = false,
        TextXAlignment = "Left",
        BackgroundColor3 = Colorpicker.Default,
        Parent = Colorpicker.ColorpickerFrame.UIElements.Main,
        Size = UDim2.new(0,30,0,30),
        AnchorPoint = Vector2.new(1,0.5),
        TextTruncate = "AtEnd",
        Position = UDim2.new(1,0,0.5,0),
        ThemeTag = {
            TextColor3 = "Text"
        },
        ZIndex = 2
    }, {
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
    })
    
    
    function Colorpicker:Lock()
        CanCallback = false
        return Colorpicker.ColorpickerFrame:Lock()
    end
    function Colorpicker:Unlock()
        CanCallback = true
        return Colorpicker.ColorpickerFrame:Unlock()
    end
    
    if Colorpicker.Locked then
        Colorpicker:Lock()
    end

    
    function Colorpicker:Update(Color,Transparency)
        Colorpicker.UIElements.Colorpicker.BackgroundTransparency = Transparency or 0
        Colorpicker.UIElements.Colorpicker.BackgroundColor3 = Color
        Colorpicker.Default = Color
        if Transparency then
            Colorpicker.Transparency = Transparency
        end
    end
    
    local clrpckr = Element:Colorpicker(Colorpicker, function(color, transparency)
        if CanCallback then
            Colorpicker:Update(color, transparency)
            Colorpicker.Default = color
            Colorpicker.Transparency = transparency
            Colorpicker.Callback(color, transparency)
        end
    end)
    
    Colorpicker:Update(Colorpicker.Default, Colorpicker.Transparency)

    
    Colorpicker.UIElements.Colorpicker.MouseButton1Click:Connect(function()
        if CanCallback then
            clrpckr.ColorpickerFrame:Open()
        end
    end)
    
    return Colorpicker.__type, Colorpicker
end

return Element