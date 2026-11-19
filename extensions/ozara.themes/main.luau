-- Ozara Themes: recolour Ozara with presets, random themes or your own colours.
-- Turning this extension off brings Ozara's normal look back.

-- accent: buttons and highlights (keep it light, button text is dark)
-- accent2: secondary highlights
-- backgroundTop / backgroundBottom: the gradient behind everything
local PRESETS = {
    { id = "midnight", name = "Midnight", accent = "#8EA8FF", accent2 = "#5EEAD4", backgroundTop = "#0B1026", backgroundBottom = "#24306B" },
    { id = "sunset", name = "Sunset", accent = "#FFC09F", accent2 = "#FFE38A", backgroundTop = "#FF5F6D", backgroundBottom = "#5B2A86" },
    { id = "ocean", name = "Ocean", accent = "#7DD3FC", accent2 = "#A7F3D0", backgroundTop = "#0EA5E9", backgroundBottom = "#1E3A8A" },
    { id = "forest", name = "Forest", accent = "#86EFAC", accent2 = "#FDE68A", backgroundTop = "#166534", backgroundBottom = "#1A2E05" },
    { id = "cherry", name = "Cherry", accent = "#F9A8D4", accent2 = "#FBCFE8", backgroundTop = "#BE185D", backgroundBottom = "#4A044E" },
    { id = "lava", name = "Lava", accent = "#FCA5A5", accent2 = "#FDBA74", backgroundTop = "#7F1D1D", backgroundBottom = "#EA580C" },
    { id = "mint", name = "Mint", accent = "#6EE7B7", accent2 = "#C4B5FD", backgroundTop = "#064E3B", backgroundBottom = "#0F766E" },
    { id = "mono", name = "Mono", accent = "#E5E7EB", accent2 = "#9CA3AF", backgroundTop = "#0A0A0A", backgroundBottom = "#2E2E2E" },
}

local FIELDS = {
    { key = "accent", label = "Accent" },
    { key = "accent2", label = "Second accent" },
    { key = "backgroundTop", label = "Background top" },
    { key = "backgroundBottom", label = "Background bottom" },
}

local function isHex(s)
    return type(s) == "string" and string.match(s, "^#?%x%x%x%x%x%x$") ~= nil
end

local function normalize(s)
    s = string.upper(s)
    if string.sub(s, 1, 1) ~= "#" then
        s = "#" .. s
    end
    return s
end

-- The theme in use: a table of the four colours plus a name, or nil for Ozara's own.
local current = ozara.storage.get("theme")

local function apply()
    if current then
        ozara.theme.set(current)
    else
        ozara.theme.reset()
    end
end

local function save()
    ozara.storage.set("theme", current)
end

-- HSL (0-360, 0-1, 0-1) to "#RRGGBB", for random themes.
local function hsl(h, s, l)
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = l - c / 2
    local r, g, b = 0, 0, 0
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    local function byte(v) return math.floor((v + m) * 255 + 0.5) end
    return string.format("#%02X%02X%02X", byte(r), byte(g), byte(b))
end

local function randomTheme()
    local h = math.random(0, 359)
    local h2 = (h + math.random(30, 150)) % 360
    return {
        name = "Random",
        accent = hsl(h, 0.85, 0.78),
        accent2 = hsl(h2, 0.8, 0.75),
        backgroundTop = hsl(h, 0.7, 0.32),
        backgroundBottom = hsl(h2, 0.65, 0.18),
    }
end

local function draw()
    ozara.ui.clear()
    ozara.ui.heading("Themes")
    ozara.ui.muted("Pick a look for Ozara. It stays until you change it or turn this extension off.")
    ozara.ui.text("Now using: " .. (current and current.name or "Ozara (default)"))

    ozara.ui.separator()
    ozara.ui.heading("Ready-made")
    ozara.ui.row(function()
        for i = 1, 4 do
            ozara.ui.button("preset:" .. PRESETS[i].id, PRESETS[i].name)
        end
    end)
    ozara.ui.row(function()
        for i = 5, #PRESETS do
            ozara.ui.button("preset:" .. PRESETS[i].id, PRESETS[i].name)
        end
    end)
    ozara.ui.row(function()
        ozara.ui.button("random", "Random theme")
        ozara.ui.button("default", "Back to Ozara's look")
    end)

    ozara.ui.separator()
    ozara.ui.heading("Mix your own")
    ozara.ui.muted("Type a colour like #FF66AA and press Enter. Light accents work best, since button text is dark.")
    for _, f in ipairs(FIELDS) do
        local now = current and current[f.key] or "Ozara's own"
        ozara.ui.text(f.label .. ": " .. now)
        ozara.ui.input(f.key, f.label .. " (e.g. #FF66AA)")
    end
    ozara.ui.show()
end

ozara.on("start", function()
    apply()
    draw()
end)

ozara.on("ui", function(id)
    if id == "random" then
        current = randomTheme()
    elseif id == "default" then
        current = nil
    else
        local presetId = string.match(id, "^preset:(.+)$")
        for _, p in ipairs(PRESETS) do
            if p.id == presetId then
                current = {
                    name = p.name,
                    accent = p.accent,
                    accent2 = p.accent2,
                    backgroundTop = p.backgroundTop,
                    backgroundBottom = p.backgroundBottom,
                }
            end
        end
    end
    save()
    apply()
    draw()
end)

ozara.on("input", function(key, value)
    value = string.gsub(value, "%s", "")
    if not isHex(value) then
        ozara.status("That's not a colour. Use six hex digits, like #FF66AA.")
        return
    end
    -- Start from the theme in use (or Ozara's colours) and change one part.
    local base = current or {
        accent = "#A78BFA",
        accent2 = "#67E8F9",
        backgroundTop = "#6A11FF",
        backgroundBottom = "#FF7BF0",
    }
    current = {
        name = "Custom",
        accent = base.accent,
        accent2 = base.accent2,
        backgroundTop = base.backgroundTop,
        backgroundBottom = base.backgroundBottom,
    }
    current[key] = normalize(value)
    save()
    apply()
    draw()
end)
