local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local DialogModule = {
    UICorner = 14,
    UIPadding = 12,
    Holder = nil,
    Window = nil,
}

function DialogModule.Init(Window)
    DialogModule.Window = Window
    return DialogModule
end

function DialogModule.Create(Key)
    local Dialog = {
        UICorner = 16,
        UIPadding = 16,
        UIElements = {}
    }
    
    if Key then Dialog.UIPadding = 0 end -- 16
    if Key then Dialog.UICorner  = 22 end
    
    if not Key then
        Dialog.UIElements.FullScreen = New("Frame", {
            ZIndex = 999,
            BackgroundTransparency = 1, -- 0.5
            BackgroundColor3 = Color3.fromHex("#2a2a2a"),
            Size = UDim2.new(1,0,1,0),
            Active = false, -- true
            Visible = false, -- true
            Parent = Key and DialogModule.Window or DialogModule.Window.UIElements.Main.Main
        })
    end
    
    Dialog.UIElements.Main = New("Frame", {
        --Size = UDim2.new(1,0,1,0),
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
        AutomaticSize = "XY",
        BackgroundTransparency = .7,
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0, Dialog.UIPadding),
            PaddingLeft = UDim.new(0, Dialog.UIPadding),
            PaddingRight = UDim.new(0, Dialog.UIPadding),
            PaddingBottom = UDim.new(0, Dialog.UIPadding),
        })
    })
    
    Dialog.UIElements.MainContainer = New("CanvasGroup", {
        Visible = false, -- true
        GroupTransparency = 1, -- 0
        BackgroundTransparency = Key and 0.15 or 0, 
        Parent = Key and DialogModule.Window or Dialog.UIElements.FullScreen,
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        AutomaticSize = "XY",
        ThemeTag = {
            BackgroundColor3 = "Accent"
        },
    }, {
        Dialog.UIElements.Main,
        New("UIScale", {
            Scale = .9
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,Dialog.UICorner),
        }),
        New("UIStroke", {
            Thickness = 0.8,
            ThemeTag = {
                Color = "Outline",
            },
            Transparency = 1, -- .9
        }),
        
    })

    function Dialog:Open()
        if not Key then
            Dialog.UIElements.FullScreen.Visible = true
            Dialog.UIElements.FullScreen.Active = true
        end
        
        task.spawn(function()
            task.wait(.1)
            
            Dialog.UIElements.MainContainer.Visible = true
            
            if not Key then
                Tween(Dialog.UIElements.FullScreen, 0.1, {BackgroundTransparency = .5}):Play()
            end
            Tween(Dialog.UIElements.MainContainer, 0.1, {GroupTransparency = 0}):Play()
            Tween(Dialog.UIElements.MainContainer.UIScale, 0.1, {Scale = 1}):Play()
            Tween(Dialog.UIElements.MainContainer.UIStroke, 0.1, {Transparency = 1}):Play()
        end)
    end
    function Dialog:Close()
        if not Key then
            Tween(Dialog.UIElements.FullScreen, 0.1, {BackgroundTransparency = 1}):Play()
            Dialog.UIElements.FullScreen.Active = false
            task.spawn(function()
                task.wait(.1)
                Dialog.UIElements.FullScreen.Visible = false
            end)
        end
        
        Tween(Dialog.UIElements.MainContainer, 0.1, {GroupTransparency = 1}):Play()
        Tween(Dialog.UIElements.MainContainer.UIScale, 0.1, {Scale = .9}):Play()
        Tween(Dialog.UIElements.MainContainer.UIStroke, 0.1, {Transparency = 1}):Play()
        
        return function()
            task.spawn(function()
                task.wait(.1)
                if not Key then
                    Dialog.UIElements.FullScreen:Destroy()
                else
                    Dialog.UIElements.MainContainer:Destroy()
                end
            end)
        end
    end
    
    --Dialog:Open()
    return Dialog
end

return DialogModule