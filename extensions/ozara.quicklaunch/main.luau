-- Quick Launch: your favourite games as one-click Play buttons on Home.

local function draw()
    local favs = ozara.favorites.list()
    ozara.home.clear()
    ozara.home.heading("Quick launch")
    if #favs == 0 then
        ozara.home.muted("Favourite some games (the star on a game's page) and they'll show up here to launch in one click.")
    else
        ozara.home.muted("Jump straight into your favourites.")
        for _, g in ipairs(favs) do
            ozara.home.row(function()
                ozara.home.game(g.placeId, g.name)
                ozara.home.button("launch:" .. tostring(g.placeId), "\u{25B6} Play")
            end)
        end
    end
    ozara.home.show()
end

ozara.on("start", draw)

-- Redraw when favourites might have changed (Ozara ticks every few seconds).
ozara.on("tick", draw)

ozara.on("ui", function(id)
    local placeId = string.match(id, "^launch:(%d+)$")
    if placeId then
        ozara.join(placeId)
    end
end)
