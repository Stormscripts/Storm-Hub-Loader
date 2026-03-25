-- =====================================================
--   STORM HUB | T-Titans Battlegrounds
--   Auto Farm + Bot Play — UI Customizada
--   By Storm Scripts
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ╔══════════════════════════════════════════════════╗
-- ║              STORM UI — LIBRARY                  ║
-- ╚══════════════════════════════════════════════════╝

local StormUI = {}
StormUI.__index = StormUI

-- Paleta de cores
local C = {
    bg = Color3.fromRGB(11, 11, 17),
    panel = Color3.fromRGB(20, 20, 30),
    panel2 = Color3.fromRGB(28, 28, 42),
    border = Color3.fromRGB(45, 45, 65),
    accent = Color3.fromRGB(220, 45, 45),
    accentD = Color3.fromRGB(160, 25, 25),
    accentL = Color3.fromRGB(255, 80, 80),
    text = Color3.fromRGB(228, 228, 240),
    textDim = Color3.fromRGB(120, 120, 145),
    on = Color3.fromRGB(55, 195, 95),
    off = Color3.fromRGB(65, 65, 90),
    white = Color3.fromRGB(255, 255, 255),
}

-- Helper: cria instância com propriedades
local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

-- Helper: arredondamento
local function Corner(parent, radius)
    local c = New("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
    c.Parent = parent
    return c
end

-- Helper: stroke
local function Stroke(parent, color, thick)
    local s = New("UIStroke", { Color = color or C.border, Thickness = thick or 1.5 })
    s.Parent = parent
    return s
end

-- ─── Arraste (mobile + PC) ───────────────────────────────────
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ─── Construtor da janela ─────────────────────────────────────
function StormUI.new()
    local self = setmetatable({}, StormUI)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Notifications = {}

    -- ScreenGui
    self.Gui = New("ScreenGui", {
        Name = "StormHubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    pcall(function() self.Gui.Parent = game:GetService("CoreGui") end)
    if not self.Gui.Parent then
        self.Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self:_BuildWindow()
    self:_BuildFloatingBall()
    return self
end

-- ─── Janela principal ─────────────────────────────────────────
function StormUI:_BuildWindow()
    -- Janela
    self.Window = New("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 374, 0, 320),
        Position = UDim2.new(0.5, -187, 0.5, -160),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = self.Gui,
    })
    Corner(self.Window, 10)
    Stroke(self.Window, C.border, 1.5)

    -- Titlebar
    local tb = New("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.Window,
    })
    -- cobre cantos inferiores do titlebar
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = tb,
    })
    Corner(tb, 10)

    -- Linha vermelha decorativa
    New("Frame", {
        Size = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = tb,
    })

    -- Título
    New("TextLabel", {
        Text = "⚡  Storm Hub | T-Titans Battlegrounds",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = C.text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 22, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = tb,
    })

    -- Subtítulo
    New("TextLabel", {
        Text = "By Storm Scripts",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = C.textDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, 14),
        Position = UDim2.new(0, 22, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = tb,
    })

    -- Botão fechar
    local closeBtn = New("TextButton", {
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.textDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 34, 1, 0),
        Position = UDim2.new(1, -36, 0, 0),
        ZIndex = 4,
        Parent = tb,
    })
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.accentL end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = C.textDim end)

    -- Drag pelo titlebar
    MakeDraggable(self.Window, tb)

    -- Barra de tabs
    self.TabBar = New("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.new(0, 8, 0, 46),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = self.Window,
    })
    local tabLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    tabLayout.Parent = self.TabBar

    -- Linha separadora abaixo das tabs
    New("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 79),
        BackgroundColor3 = C.border,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.Window,
    })

    -- Área de conteúdo
    self.ContentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -16, 1, -88),
        Position = UDim2.new(0, 8, 0, 84),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = self.Window,
    })
end

-- ─── Bolinha flutuante ────────────────────────────────────────
function StormUI:_BuildFloatingBall()
    self.Ball = New("TextButton", {
        Name = "FloatBall",
        Text = "⚡",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = C.white,
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0, 14, 0.5, -24),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = self.Gui,
    })
    Corner(self.Ball, 50)
    local ballStroke = Stroke(self.Ball, C.accentL, 2)

    -- Tooltip
    local tooltip = New("TextLabel", {
        Text = "Storm Hub",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.text,
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 72, 0, 22),
        Position = UDim2.new(1, 6, 0.5, -11),
        Visible = false,
        ZIndex = 21,
        Parent = self.Ball,
    })
    Corner(tooltip, 5)

    self.Ball.MouseEnter:Connect(function() tooltip.Visible = true end)
    self.Ball.MouseLeave:Connect(function() tooltip.Visible = false end)

    self.Ball.MouseButton1Click:Connect(function()
        self:Toggle(not self.Window.Visible)
    end)

    MakeDraggable(self.Ball)

    -- Animação pulsante
    task.spawn(function()
        while true do
            TweenService:Create(ballStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 4 }):Play()
            task.wait(0.9)
            TweenService:Create(ballStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 1 }):Play()
            task.wait(0.9)
        end
    end)
end

-- ─── Mostrar / esconder ───────────────────────────────────────
function StormUI:Toggle(state)
    if state == nil then state = not self.Window.Visible end
    if state then
        self.Window.Visible = true
        self.Window.BackgroundTransparency = 1
        TweenService:Create(self.Window, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
        self.Ball.Text = "X"
    else
        TweenService:Create(self.Window, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
        task.delay(0.2, function() self.Window.Visible = false end)
        self.Ball.Text = "⚡"
    end
end

-- ─── Criar aba ────────────────────────────────────────────────
function StormUI:CreateTab(name, icon)
    local tab = {}
    local idx = #self.Tabs + 1

    -- Botão da aba
    local btn = New("TextButton", {
        Text = (icon and (icon .. "  ") or "") .. name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = C.textDim,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
        LayoutOrder = idx,
        ZIndex = 3,
        Parent = self.TabBar,
    })
    Corner(btn, 6)
    local bpad = New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
    bpad.Parent = btn

    -- Frame do conteúdo
    local contentFrame = New("Frame", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 2,
        Parent = self.ContentArea,
    })

    local scroll = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = contentFrame,
    })

    local layout = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = scroll

    local pad = New("UIPadding", { PaddingBottom = UDim.new(0, 10) })
    pad.Parent = scroll

    tab._btn = btn
    tab._content = contentFrame
    tab._scroll = scroll
    tab._itemCount = 0

    btn.MouseButton1Click:Connect(function() self:_SelectTab(tab) end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:_SelectTab(tab) end

    -- ── Toggle ────────────────────────────────────────────────
    function tab:CreateToggle(cfg)
        local state = cfg.CurrentValue or false
        local item = self._itemCount

        local row = New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            LayoutOrder = item,
            ZIndex = 2,
            Parent = self._scroll,
        })
        Corner(row, 7)

        New("TextLabel", {
            Text = cfg.Name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = C.text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -66, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            Parent = row,
        })

        local track = New("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = state and C.on or C.off,
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = row,
        })
        Corner(track, 50)

        local knob = New("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = C.white,
            BorderSizePixel = 0,
            ZIndex = 4,
            Parent = track,
        })
        Corner(knob, 50)

        local hitBtn = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5,
            Parent = row,
        })

        hitBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(track, TweenInfo.new(0.15), {
                BackgroundColor3 = state and C.on or C.off
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            }):Play()
            if cfg.Callback then cfg.Callback(state) end
        end)

        self._itemCount = self._itemCount + 1
    end

    -- ── Botão ─────────────────────────────────────────────────
    function tab:CreateButton(cfg)
        local item = self._itemCount

        local btn2 = New("TextButton", {
            Text = cfg.Name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextColor3 = C.white,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = C.accentD,
            BorderSizePixel = 0,
            LayoutOrder = item,
            ZIndex = 3,
            Parent = self._scroll,
        })
        Corner(btn2, 7)

        btn2.MouseButton1Click:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.07), { BackgroundColor3 = C.accentL }):Play()
            task.delay(0.12, function()
                TweenService:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = C.accentD }):Play()
            end)
            if cfg.Callback then cfg.Callback() end
        end)
        btn2.MouseEnter:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = C.accent }):Play()
        end)
        btn2.MouseLeave:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.1), { BackgroundColor3 = C.accentD }):Play()
        end)

        self._itemCount = self._itemCount + 1
    end

    -- ── Dropdown ──────────────────────────────────────────────
    local gui = self.Gui  -- captura referência ao ScreenGui
    function tab:CreateDropdown(cfg)
        local selected = cfg.CurrentOption or cfg.Options[1]
        local open = false
        local item = self._itemCount

        local container = New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            LayoutOrder = item,
            ZIndex = 3,
            Parent = self._scroll,
        })
        Corner(container, 7)

        New("TextLabel", {
            Text = cfg.Name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = C.text,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4,
            Parent = container,
        })

        local valLabel = New("TextLabel", {
            Text = selected .. "  V",
            Font = Enum.Font.GothamSemibold,
            TextSize = 11,
            TextColor3 = C.accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.45, -10, 1, 0),
            Position = UDim2.new(0.55, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 4,
            Parent = container,
        })

        local dropH = #cfg.Options * 30 + 8
        local dropW = 0  -- será definido na abertura pela largura real do container

        -- Lista suspensa — filha do ScreenGui, flutua por cima de tudo
        local dropList = New("Frame", {
            Size = UDim2.new(0, 200, 0, dropH),  -- largura inicial, ajustada ao abrir
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = C.panel2,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 200,
            Parent = gui,
        })
        Corner(dropList, 7)
        Stroke(dropList, C.border, 1)

        local dLayout = New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
        dLayout.Parent = dropList
        local dPad = New("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        })
        dPad.Parent = dropList

        for _, opt in ipairs(cfg.Options) do
            local ob = New("TextButton", {
                Text = opt,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = C.text,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = C.panel,
                BorderSizePixel = 0,
                ZIndex = 201,
                Parent = dropList,
            })
            Corner(ob, 5)
            ob.MouseEnter:Connect(function()
                TweenService:Create(ob, TweenInfo.new(0.1), { BackgroundColor3 = C.border }):Play()
            end)
            ob.MouseLeave:Connect(function()
                TweenService:Create(ob, TweenInfo.new(0.1), { BackgroundColor3 = C.panel }):Play()
            end)
            ob.MouseButton1Click:Connect(function()
                selected = opt
                valLabel.Text = opt .. "  ^"
                dropList.Visible = false
                open = false
                if cfg.Callback then cfg.Callback({opt}) end
            end)
        end

        local hitBtn = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 5,
            Parent = container,
        })
        hitBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                -- Calcula posição absoluta do container e posiciona o dropList
                local abs = container.AbsolutePosition
                local sz = container.AbsoluteSize
                dropList.Size = UDim2.new(0, sz.X, 0, dropH)
                dropList.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
            end
            dropList.Visible = open
        end)

        self._itemCount = self._itemCount + 1
    end

    -- ── Label ─────────────────────────────────────────────────
    function tab:CreateLabel(text)
        New("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = C.textDim,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = self._itemCount,
            ZIndex = 2,
            Parent = self._scroll,
        })
        self._itemCount = self._itemCount + 1
    end

    -- ── Separador ─────────────────────────────────────────────
    function tab:CreateSeparator()
        New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = C.border,
            BorderSizePixel = 0,
            LayoutOrder = self._itemCount,
            ZIndex = 2,
            Parent = self._scroll,
        })
        self._itemCount = self._itemCount + 1
    end

    -- ── Slider ────────────────────────────────────────────────
    function tab:CreateSlider(cfg)
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local val = math.clamp(cfg.CurrentValue or min, min, max)
        local item = self._itemCount

        local row = New("Frame", {
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            LayoutOrder = item,
            ZIndex = 3,
            Parent = self._scroll,
        })
        Corner(row, 7)

        New("TextLabel", {
            Text = cfg.Name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = C.text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 0, 22),
            Position = UDim2.new(0, 12, 0, 4),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4,
            Parent = row,
        })

        local valLabel = New("TextLabel", {
            Text = tostring(val),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = C.accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 50, 0, 22),
            Position = UDim2.new(1, -58, 0, 4),
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 4,
            Parent = row,
        })

        -- trilho
        local track = New("Frame", {
            Size = UDim2.new(1, -24, 0, 4),
            Position = UDim2.new(0, 12, 0, 36),
            BackgroundColor3 = C.border,
            BorderSizePixel = 0,
            ZIndex = 4,
            Parent = row,
        })
        Corner(track, 50)

        -- preenchimento
        local fill = New("Frame", {
            Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = C.accent,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = track,
        })
        Corner(fill, 50)

        -- bolinha
        local knob = New("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6),
            BackgroundColor3 = C.white,
            BorderSizePixel = 0,
            ZIndex = 6,
            Parent = track,
        })
        Corner(knob, 50)

        -- área clicável sobre o trilho
        local slider = New("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, -9),
            ZIndex = 7,
            Parent = track,
        })

        local dragging = false

        local function UpdateSlider(input)
            local abs = track.AbsolutePosition
            local sz = track.AbsoluteSize
            local relX = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
            val = math.floor(min + relX * (max - min) + 0.5)
            valLabel.Text = tostring(val)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -6, 0.5, -6)
            if cfg.Callback then cfg.Callback(val) end
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement or
                input.UserInputType == Enum.UserInputType.Touch
            ) then
                UpdateSlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        self._itemCount = self._itemCount + 1
    end

    return tab
end

-- ─── Selecionar aba ───────────────────────────────────────────
function StormUI:_SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t._content.Visible = false
        t._btn.TextColor3 = C.textDim
        t._btn.BackgroundColor3 = C.panel2
    end
    tab._content.Visible = true
    tab._btn.TextColor3 = C.white
    tab._btn.BackgroundColor3 = C.accent
    self.ActiveTab = tab
end

-- ─── Notificação ──────────────────────────────────────────────
function StormUI:Notify(cfg)
    -- Empurra notificações existentes para cima
    for _, n in ipairs(self.Notifications) do
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.2), {
                Position = UDim2.new(
                    n.Position.X.Scale, n.Position.X.Offset,
                    n.Position.Y.Scale, n.Position.Y.Offset - 72
                )
            }):Play()
        end
    end

    local notif = New("Frame", {
        Size = UDim2.new(0, 240, 0, 62),
        Position = UDim2.new(1, 10, 1, -72),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = self.Gui,
    })
    Corner(notif, 8)
    Stroke(notif, C.accent, 1.5)

    New("Frame", {
        Size = UDim2.new(0, 3, 0.65, 0),
        Position = UDim2.new(0, 9, 0.175, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = notif,
    })

    New("TextLabel", {
        Text = cfg.Title or "Storm Hub",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -26, 0, 22),
        Position = UDim2.new(0, 19, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
        Parent = notif,
    })
    New("TextLabel", {
        Text = cfg.Content or "",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.textDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -26, 0, 22),
        Position = UDim2.new(0, 19, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 101,
        Parent = notif,
    })

    table.insert(self.Notifications, notif)

    TweenService:Create(notif, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -250, 1, -72)
    }):Play()

    task.delay(cfg.Duration or 3, function()
        TweenService:Create(notif, TweenInfo.new(0.2), {
            Position = UDim2.new(1, 10, notif.Position.Y.Scale, notif.Position.Y.Offset)
        }):Play()
        task.delay(0.25, function()
            notif:Destroy()
            for i, n in ipairs(self.Notifications) do
                if n == notif then table.remove(self.Notifications, i); break end
            end
        end)
    end)
end

-- ╔══════════════════════════════════════════════════╗
-- ║             INICIALIZAR INTERFACE                ║
-- ╚══════════════════════════════════════════════════╝

local UI = StormUI.new()
local TabAutoFarm = UI:CreateTab("Auto Farm", "💰")
local TabBotPlay = UI:CreateTab("Bot Play",  "🤖")
local TabVisuals = UI:CreateTab("Visuals",   "👁")

-- ╔══════════════════════════════════════════════════╗
-- ║                  AUTO FARM                       ║
-- ╚══════════════════════════════════════════════════╝

local AutoFarmEnabled = false
local AF_Connection = nil
local AF_AtkConnection = nil
local AF_Target = nil
local AF_LastChange = 0

local AF_HITBOX_HEIGHT = 8
local AF_MAX_Y = 2000
local AF_MIN_Y = -300
local AF_ROT = CFrame.Angles(math.rad(90), 0, 0)
local AF_ATK_COOLDOWN = 0.1
local AF_CHANGE_COOLDOWN = 2

local function AF_HasForcefield(player)
    if not player.Character then return false end
    for _, child in ipairs(player.Character:GetChildren()) do
        if child:IsA("ForceField") then return true end
    end
    local hum = player.Character:FindFirstChild("Humanoid")
    if hum and (hum:GetAttribute("ForceField") or hum:GetAttribute("Invincible")) then
        return true
    end
    return false
end

local function AF_DoReset()
    pcall(function()
        game.ReplicatedStorage.Remotes.OnCharacterSelectTouchedRF:InvokeServer("001")
    end)
end

local function AF_Unstick()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.Health = 0 end
end

local function AF_Spectate()
    if not AutoFarmEnabled or not AF_Target then return end
    if not AF_Target.Character then return end
    local head = AF_Target.Character:FindFirstChild("Head")
    if head then workspace.CurrentCamera.CameraSubject = head end
end

LocalPlayer.CharacterAdded:Connect(function()
    if AutoFarmEnabled then AF_DoReset() end
end)

local function AF_InBounds(hrp)
    return hrp.Position.Y >= AF_MIN_Y and hrp.Position.Y <= AF_MAX_Y
end

local function AF_FindNearest()
    local now = tick()

    if AF_Target and AF_Target.Character then
        local hrp = AF_Target.Character:FindFirstChild("HumanoidRootPart")
        local hum = AF_Target.Character:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 and not AF_HasForcefield(AF_Target) then
            if AF_InBounds(hrp) and (now - AF_LastChange < AF_CHANGE_COOLDOWN) then
                return AF_Target
            end
        end
    end

    if not LocalPlayer.Character then return nil end
    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local nearest, shortest = nil, 2000

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 and not AF_HasForcefield(p) and AF_InBounds(hrp) then
                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = p
                end
            end
        end
    end

    if nearest and nearest ~= AF_Target then AF_LastChange = now end
    return nearest
end

local function AF_AutoAttack()
    if not AutoFarmEnabled or not LocalPlayer.Character then return end
    local char = LocalPlayer.Character

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
            return
        end
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = char
                pcall(function() tool:Activate() end)
                return
            end
        end
    end
end

local function AF_Teleport()
    if not AutoFarmEnabled or not LocalPlayer.Character then return end

    AF_Target = AF_FindNearest()
    if not AF_Target or not AF_Target.Character then return end

    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local tgtHRP = AF_Target.Character:FindFirstChild("HumanoidRootPart")
    local tgtHum = AF_Target.Character:FindFirstChild("Humanoid")

    if not tgtHRP or not tgtHum or tgtHum.Health <= 0 or AF_HasForcefield(AF_Target) then
        AF_Target = nil; return
    end
    if not AF_InBounds(tgtHRP) then AF_Target = nil; return end

    AF_Spectate()
    myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    local safeY = math.max(tgtHRP.Position.Y - AF_HITBOX_HEIGHT, 4)
    local safePos = Vector3.new(tgtHRP.Position.X, safeY, tgtHRP.Position.Z)
    myHRP.CFrame = CFrame.new(safePos) * AF_ROT
end

-- ╔══════════════════════════════════════════════════╗
-- ║                  BOT PLAY                        ║
-- ╚══════════════════════════════════════════════════╝

local BotEnabled = false
local BotTarget = nil
local IsInLobby = false
local BP_Char, BP_Hum, BP_Root

local CharacterPaths = {
    Robin = { Vector3.new(6, 337, 23) },
    Mutano = { Vector3.new(7, 337, 46) },
    RedX = { Vector3.new(5, 338, -12), Vector3.new(20, 338, -12), Vector3.new(31, 337, 13) },
    KidFlash = { Vector3.new(1, 338, 61), Vector3.new(135, 338, 60), Vector3.new(147, 337, 44) },
}

local SelectedChar = "Robin"
local CurrentPath = CharacterPaths[SelectedChar]
local CurrentPathIdx = 1

local function BP_UpdateChar()
    BP_Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    BP_Hum = BP_Char:WaitForChild("Humanoid")
    BP_Root = BP_Char:WaitForChild("HumanoidRootPart")
    IsInLobby = BP_Root.Position.Y >= 337
end
BP_UpdateChar()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    BP_UpdateChar()
    if BotEnabled then
        IsInLobby = true
        CurrentPathIdx = 1
        UI:Notify({ Title = "Storm Hub", Content = "🔄 Respawn! Voltando a farmar...", Duration = 3 })
    end
end)

local function BP_HasGround(position)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {BP_Char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    return Workspace:Raycast(position, Vector3.new(0, -50, 0), params) ~= nil
end

local function BP_IsValidTarget(player)
    if not player.Character then return false end
    if player.Character:FindFirstChild("ForceField") then return false end
    local hum = player.Character:FindFirstChild("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    if hum.Health <= 0 then return false end
    if BP_Root and root.Position.Y > (BP_Root.Position.Y + 16) then return false end
    return true
end

local function BP_CheckLobby()
    if BP_Root then IsInLobby = BP_Root.Position.Y >= 337 end
end

local function BP_MovePath()
    if not BP_Root or not BP_Hum then return false end
    if CurrentPathIdx <= #CurrentPath then
        local tgt = CurrentPath[CurrentPathIdx]
        local dist = (BP_Root.Position - tgt).Magnitude
        if dist > 3 then
            BP_Hum:MoveTo(tgt)
        else
            CurrentPathIdx = CurrentPathIdx + 1
        end
        return false
    end
    return true
end

local function BP_BestTarget()
    if IsInLobby or CurrentPathIdx <= #CurrentPath then return nil end
    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and BP_IsValidTarget(player) then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local dist = (root.Position - BP_Root.Position).Magnitude
            if dist < bestDist then bestDist = dist; best = player end
        end
    end
    return best
end

local function BP_Attack()
    local tool = BP_Char:FindFirstChildOfClass("Tool")
    if not tool then
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then tool = v; break end
        end
        if tool then tool.Parent = BP_Char end
    end
    if tool then tool:Activate() end
end

local function BP_EquipActivate(name)
    if not LocalPlayer.Character then return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    local tool = BP_Char:FindFirstChild(name) or bp:FindFirstChild(name)
    if tool then
        tool.Parent = BP_Char
        task.wait()
        tool:Activate()
    end
end

-- Loop de habilidades especiais
task.spawn(function()
    while task.wait(0.15) do
        if not (not BotEnabled or not LocalPlayer.Character) then
        BP_Char = LocalPlayer.Character

        if SelectedChar == "KidFlash" then
            BP_EquipActivate("Deadly Vortex")
            BP_EquipActivate("Super Speed")
            if BotTarget and BotTarget.Character and BP_Root then
                local root = BotTarget.Character:FindFirstChild("HumanoidRootPart")
                if root and (BP_Root.Position - root.Position).Magnitude <= 12 then
                    BP_EquipActivate("Rapid Combat")
                end
            end
        end

        if SelectedChar == "Mutano" then
            BP_EquipActivate("Tiger Form")
        end
        end
    end
end)

-- Anti-stuck
local BP_LastPos = nil
local BP_LastMove = tick()

task.spawn(function()
    while task.wait(0.4) do
        if not (not BotEnabled or not BP_Root) then
        local pos = BP_Root.Position
        if BP_LastPos and (pos - BP_LastPos).Magnitude < 0.2 then
            if tick() - BP_LastMove > 1.4 then
                BP_Hum:MoveTo(pos - BP_Root.CFrame.LookVector * 3)
                if math.random(1, 2) == 1 then
                    BP_Hum:MoveTo(pos + BP_Root.CFrame.RightVector * 2)
                else
                    BP_Hum:MoveTo(pos - BP_Root.CFrame.RightVector * 2)
                end
                BP_Hum.Jump = true
                task.wait(0.1)
                BP_Hum.Jump = false
                BP_LastMove = tick()
            end
        else
            BP_LastMove = tick()
        end
        BP_LastPos = pos
        end
    end
end)

-- Loop principal do bot
RunService.Heartbeat:Connect(function()
    if not (BotEnabled and BP_Char and BP_Hum and BP_Root) then return end

    BP_CheckLobby()

    if IsInLobby then
        BP_MovePath()
        return
    end

    if CurrentPathIdx <= #CurrentPath then
        CurrentPathIdx = #CurrentPath + 1
    end

    BotTarget = BP_BestTarget()

    if BotTarget and BP_IsValidTarget(BotTarget) then
        local tgtRoot = BotTarget.Character:FindFirstChild("HumanoidRootPart")
        if not tgtRoot then return end
        if not BP_HasGround(tgtRoot.Position) then return end

        local dist = (tgtRoot.Position - BP_Root.Position).Magnitude
        if dist > 6 then
            BP_Hum:MoveTo(tgtRoot.Position)
        else
            BP_Attack()
        end
    end
end)

-- ╔══════════════════════════════════════════════════╗
-- ║              ELEMENTOS DA UI                     ║
-- ╚══════════════════════════════════════════════════╝

-- ── Aba Auto Farm ─────────────────────────────────────────────
TabAutoFarm:CreateLabel("Teleporta e ataca o alvo mais próximo")

TabAutoFarm:CreateToggle({
    Name = "Auto Farm Clássico",
    CurrentValue = false,
    Callback = function(v)
        AutoFarmEnabled = v
        if v then
            AF_Target = nil
            AF_LastChange = 0
            AF_DoReset()
            UI:Notify({ Title = "Storm Hub", Content = "💰 Auto Farm ativado!", Duration = 3 })

            AF_Connection = RunService.Heartbeat:Connect(AF_Teleport)
            AF_AtkConnection = RunService.Heartbeat:Connect(function()
                AF_AutoAttack()
                task.wait(AF_ATK_COOLDOWN)
            end)
        else
            AF_Unstick()
            if AF_Connection    then AF_Connection:Disconnect()    end
            if AF_AtkConnection then AF_AtkConnection:Disconnect() end
            AF_Target = nil
            UI:Notify({ Title = "Storm Hub", Content = "🛑 Auto Farm desativado!", Duration = 3 })
        end
    end
})

TabAutoFarm:CreateSeparator()

TabAutoFarm:CreateButton({
    Name = "Resetar Personagem",
    Callback = function()
        AF_Unstick()
        UI:Notify({ Title = "Storm Hub", Content = "💀 Personagem resetado!", Duration = 2 })
    end
})

-- ── Aba Bot Play ──────────────────────────────────────────────
TabBotPlay:CreateLabel("Selecione o personagem antes de ativar")

TabBotPlay:CreateDropdown({
    Name = "Personagem",
    Options = {"Robin", "Mutano", "RedX", "KidFlash"},
    CurrentOption = "Robin",
    Callback = function(Option)
        local chosen = Option[1]
        SelectedChar = chosen
        CurrentPath = CharacterPaths[chosen]
        CurrentPathIdx = 1
        UI:Notify({ Title = "Storm Hub", Content = "🎯 Personagem: " .. chosen, Duration = 3 })
    end
})

TabBotPlay:CreateToggle({
    Name = "Bot Play",
    CurrentValue = false,
    Callback = function(v)
        BotEnabled = v
        if v then
            CurrentPath = CharacterPaths[SelectedChar]
            CurrentPathIdx = 1
            IsInLobby = true
            UI:Notify({ Title = "Storm Hub", Content = "🤖 Bot iniciado!", Duration = 4 })
        else
            UI:Notify({ Title = "Storm Hub", Content = "🛑 Bot desligado!", Duration = 4 })
        end
    end
})

TabBotPlay:CreateSeparator()

TabBotPlay:CreateButton({
    Name = "Resetar Personagem",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

-- ── Notificação de boas-vindas ────────────────────────────────
task.delay(0.6, function()
    UI:Notify({
        Title = "⚡ Storm Hub",
        Content = "Script Carregado! By Storm Scripts",
        Duration = 5
    })
end)

-- ╔══════════════════════════════════════════════════╗
-- ║                    ESP                           ║
-- ╚══════════════════════════════════════════════════╝

local ESPEnabled = false
local ESPBillboards = {}

local function ESP_Remove(player)
    if ESPBillboards[player] then
        ESPBillboards[player]:Destroy()
        ESPBillboards[player] = nil
    end
end

local function ESP_Create(player)
    if ESPBillboards[player] then return end
    if player == LocalPlayer then return end

    local function TryAttach()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "StormESP"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 100, 0, 42)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.Adornee = hrp
        bb.Parent = hrp

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.Text = player.Name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.4
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = bb

        local hpLabel = Instance.new("TextLabel")
        hpLabel.BackgroundTransparency = 1
        hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
        hpLabel.Font = Enum.Font.Gotham
        hpLabel.TextSize = 11
        hpLabel.TextStrokeTransparency = 0.4
        hpLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        hpLabel.Parent = bb

        ESPBillboards[player] = bb

        RunService.Heartbeat:Connect(function()
            if not bb.Parent then return end
            -- esconde tudo se toggle desligado
            bb.Enabled = ESPEnabled
            if not ESPEnabled then return end

            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                hpLabel.Text = math.floor(hum.Health) .. " HP"
                hpLabel.TextColor3 = Color3.fromRGB(
                    math.floor(255 * (1 - pct)),
                    math.floor(200 * pct),
                    30
                )
            else
                hpLabel.Text = "? HP"
                hpLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
    end

    TryAttach()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        ESP_Remove(player)
        TryAttach()
    end)
end

local function ESP_EnableAll()
    for _, p in ipairs(Players:GetPlayers()) do
        ESP_Create(p)
    end
    Players.PlayerAdded:Connect(function(p)
        if ESPEnabled then ESP_Create(p) end
    end)
end

local function ESP_DisableAll()
    for player in pairs(ESPBillboards) do
        ESP_Remove(player)
    end
end

-- ╔══════════════════════════════════════════════════╗
-- ║                  AIMBOT                          ║
-- ╚══════════════════════════════════════════════════╝

local AimbotEnabled = false
local AimbotSmooth = 0.2
local AimbotFOV = 150

local function SmoothToLerp(v)
    return math.clamp(v / 100, 0.01, 1)
end

-- ─── Círculo de FOV na tela ───────────────────────────────────
local FOVCircleRadius = 150
local FOVCircle = New("Frame", {
    Name = "FOVCircle",
    Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
    Parent = UI.Gui,
})
New("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = FOVCircle
New("UIStroke", {
    Color = Color3.fromRGB(220, 45, 45),
    Thickness = 1.5,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}).Parent = FOVCircle

local function UpdateFOVCircle()
    FOVCircle.Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2)
end

local function Aimbot_GetTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, FOVCircleRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist2D < bestDist then
                        bestDist = dist2D
                        best = p
                    end
                end
            end
        end
    end

    return best
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local target = Aimbot_GetTarget()
    if not target or not target.Character then return end

    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cam = workspace.CurrentCamera
    local targetCF = CFrame.lookAt(cam.CFrame.Position, hrp.Position + Vector3.new(0, 1.5, 0))
    cam.CFrame = cam.CFrame:Lerp(targetCF, AimbotSmooth)
end)

-- ╔══════════════════════════════════════════════════╗
-- ║                  HITBOX                          ║
-- ╚══════════════════════════════════════════════════╝

local HitboxEnabled = false
local HitboxSize = 5
local HitboxTransparency = 1   -- 1 = invisível, 0 = opaco
local HitboxOriginals = {}  -- [hrp] = { size, canCollide, transparency }

local function Hitbox_Apply()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not HitboxOriginals[hrp] then
                    HitboxOriginals[hrp] = {
                        size = hrp.Size,
                        canCollide = hrp.CanCollide,
                        transparency = hrp.Transparency,
                    }
                end
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.CanCollide = false
                hrp.Massless = true
                hrp.Transparency = HitboxTransparency
            end
        end
    end
end

local function Hitbox_Restore()
    for hrp, orig in pairs(HitboxOriginals) do
        if hrp and hrp.Parent then
            hrp.Size = orig.size
            hrp.CanCollide = orig.canCollide
            hrp.Transparency = orig.transparency
            hrp.Massless = false
        end
    end
    HitboxOriginals = {}
end

RunService.Heartbeat:Connect(function()
    if HitboxEnabled then Hitbox_Apply() end
end)

-- ╔══════════════════════════════════════════════════╗
-- ║          ELEMENTOS DA UI — VISUALS               ║
-- ╚══════════════════════════════════════════════════╝

-- ── ESP ───────────────────────────────────────────────────────
TabVisuals:CreateLabel("— Radar —")

TabVisuals:CreateToggle({
    Name = "Radar (Nome + HP)",
    CurrentValue = false,
    Callback = function(v)
        ESPEnabled = v
        if v then
            ESP_EnableAll()
            UI:Notify({ Title = "Storm Hub", Content = "👁  Radar ativado!", Duration = 2 })
        else
            ESP_DisableAll()
            UI:Notify({ Title = "Storm Hub", Content = "🛑  Radar desativado!", Duration = 2 })
        end
    end
})

TabVisuals:CreateSeparator()

-- ── Aimbot ────────────────────────────────────────────────────
TabVisuals:CreateLabel("— Aimbot —")

TabVisuals:CreateToggle({
    Name = "Aimbot FOV",
    CurrentValue = false,
    Callback = function(v)
        AimbotEnabled = v
        FOVCircle.Visible = v
        UI:Notify({
            Title = "Storm Hub",
            Content = v and "🎯  Aimbot ativado!" or "🛑  Aimbot desativado!",
            Duration = 2
        })
    end
})

TabVisuals:CreateSlider({
    Name = "Tamanho do Círculo FOV",
    Min = 10,
    Max = 500,
    CurrentValue = 150,
    Callback = function(v)
        FOVCircleRadius = v
        AimbotFOV = v
        UpdateFOVCircle()
    end
})

TabVisuals:CreateSlider({
    Name = "Suavidade do FOV",
    Min = 1,
    Max = 100,
    CurrentValue = 20,
    Callback = function(v)
        AimbotSmooth = SmoothToLerp(v)
    end
})

TabVisuals:CreateSeparator()

-- ── Hitbox ────────────────────────────────────────────────────
TabVisuals:CreateLabel("— Hitbox —")

TabVisuals:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v)
        HitboxEnabled = v
        if not v then Hitbox_Restore() end
        UI:Notify({
            Title = "Storm Hub",
            Content = v and "📦  Hitbox ativada!" or "🛑  Hitbox desativada!",
            Duration = 2
        })
    end
})

TabVisuals:CreateSlider({
    Name = "Tamanho da Hitbox",
    Min = 1,
    Max = 1000,
    CurrentValue = 5,
    Callback = function(v)
        HitboxSize = v
    end
})

TabVisuals:CreateSlider({
    Name = "Transparência da Hitbox",
    Min = 0,
    Max = 100,
    CurrentValue = 100,
    Callback = function(v)
        -- 100 = invisível (1), 0 = opaco (0)
        HitboxTransparency = v / 100
    end
})
