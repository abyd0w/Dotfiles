-----------------------
------- LAYOUT --------
-----------------------
-- Tiling behaviour and window groups. Colours match look_and_feel.lua.

local border     = "rgba(e5ddda11)"
local surface    = "rgb(151a24)"
local fg         = "rgb(e5ddda)"
local accent     = "rgb(932123)"
local accent_hi  = "rgb(d9534d)"

local function apply(name, tbl)
    local ok, err = pcall(hl.config, tbl)
    if not ok then print("[layout] '" .. name .. "' failed: " .. tostring(err)) end
end

apply("general", {
    general = {
        layout           = "dwindle",
        resize_on_border = true,   -- true = drag borders/gaps to resize
        allow_tearing    = false,   -- see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
    },
})

apply("dwindle", {
    dwindle = {
        preserve_split = true,
        force_split    = 2,         -- new windows open right / bottom
    },
})

-- Window groups (tabbed windows). Safe to delete if you never use them.
apply("group", {
    group = {
        col = {
            border_active   = "rgba(d9534de6)",
            border_inactive = border,
        },
        groupbar = {
            font_size        = 10,
            height           = 16,
            indicator_height = 2,
            text_color       = fg,
            col = { active = accent, inactive = surface },
        },
    },
})

----------------
---- LAYERS ----
----------------

hl.config({
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true, -- Set to false to make newly mapped top layers render below existing covering fullscreen window
    },
})
