-- Ozara Styles: whole-app looks built with ozara.style.
-- Turning this extension off brings Ozara's normal look back.

local STYLES = {
    {
        id = "roblox", name = "Roblox",
        theme = { accent = "#335FFF", accent2 = "#FFFFFF", backgroundTop = "#111216", backgroundBottom = "#232527" },
        style = {
            button = { fill = "#335FFF", text = "#FFFFFF", height = 36, roundness = 8 },
            secondary = { fill = "#393B3D", text = "#FFFFFF", roundness = 8 },
            chip = { on = "#FFFFFF", onText = "#111216", off = "#393B3D", offText = "#FFFFFF" },
            play = { kind = "roblox" },
            tile = { kind = "roblox", roundness = 8 },
            panel = { fill = "#191B1D", roundness = 10 },
            sidebar = { fill = "#111216", active = "#393B3D" },
            toggle = { on = "#335FFF" },
            selection = { color = "#335FFF" },
            popup = { fill = "#232527" },
        },
    },
    {
        id = "minimal", name = "Minimal",
        theme = { accent = "#E5E7EB", accent2 = "#9CA3AF", backgroundTop = "#0A0A0A", backgroundBottom = "#141414" },
        style = {
            button = { fill = "#FFFFFF", text = "#000000", height = 30, roundness = 6, textSize = 12 },
            secondary = { fill = "#00000000", text = "#FFFFFF", border = "#3F3F46", roundness = 6 },
            play = { kind = "icon", fill = "#FFFFFF", text = "#000000", roundness = 15 },
            panel = { fill = "#111111", border = "#27272A", roundness = 8, padding = 16 },
            heading = { size = 15 },
            sidebar = { fill = "#0A0A0A", active = "#27272A" },
        },
    },
    {
        id = "neon", name = "Neon",
        theme = { accent = "#22D3EE", accent2 = "#F0ABFC", backgroundTop = "#020617", backgroundBottom = "#1E1B4B" },
        style = {
            button = { fill = "#22D3EE", text = "#020617", border = "#A5F3FC", roundness = 4 },
            secondary = { fill = "#0F172A", text = "#F0ABFC", border = "#F0ABFC", roundness = 4 },
            play = { kind = "pill", fill = "#F0ABFC", text = "#020617" },
            tile = { labelFill = "#0F172A", labelText = "#22D3EE" },
            panel = { fill = "#020617E6", border = "#22D3EE", roundness = 6 },
            heading = { color = "#22D3EE" },
            sidebar = { active = "#22D3EE55", icon = "#A5F3FC" },
            toggle = { on = "#F0ABFC" },
        },
    },
    {
        id = "bubbly", name = "Bubbly",
        theme = { accent = "#FBCFE8", accent2 = "#C4B5FD", backgroundTop = "#F472B6", backgroundBottom = "#818CF8" },
        style = {
            button = { height = 40, padding = 24, roundness = 20, textSize = 14 },
            play = { kind = "pill", height = 40, roundness = 20 },
            tile = { roundness = 22 },
            panel = { roundness = 32 },
        },
    },
}

local current = ozara.storage.get("style")

local function find(id)
    for _, s in ipairs(STYLES) do
        if s.id == id then return s end
    end
    return nil
end

local function apply()
    local s = current and find(current)
    if s then
        ozara.theme.set(s.theme)
        ozara.style.set(s.style)
    else
        ozara.theme.reset()
        ozara.style.reset()
    end
end

local function draw()
    local s = current and find(current)
    ozara.ui.clear()
    ozara.ui.heading("Styles")
    ozara.ui.muted("Change how all of Ozara looks: buttons, Play buttons, game tiles, panels and more.")
    ozara.ui.text("Now using: " .. (s and s.name or "Ozara (default)"))
    ozara.ui.separator()
    ozara.ui.row(function()
        for _, st in ipairs(STYLES) do
            ozara.ui.button("style:" .. st.id, st.name)
        end
    end)
    ozara.ui.button("default", "Back to Ozara's look")
    ozara.ui.show()
end

ozara.on("start", function()
    apply()
    draw()
end)

ozara.on("ui", function(id)
    if id == "default" then
        current = nil
    else
        local picked = string.match(id, "^style:(.+)$")
        if picked then current = picked end
    end
    ozara.storage.set("style", current)
    apply()
    draw()
end)
