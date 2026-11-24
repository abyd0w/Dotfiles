-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Caelestia-style look, in the Sumi-e Momiji palette.
-- Decorations + animations only. Behaviour, misc and rules live in
-- layout.lua, misc.lua and rules.lua.
--
-- Numbers below are Caelestia's own defaults (caelestia-dots/caelestia, hypr/variables.lua):
--   gaps 5 / 10 (20 for a lone window), workspace gap 20, rounding 15 (power 2),
--   1px border, window opacity 0.95, blur size 8 / 2 passes / xray off,
--   shadow range 15 / power 4 in a faint tint of the accent colour.
-- Caelestia derives its colours from the wallpaper (Material You), so here:
--   primary            -> bright crimson  d9534d  (active border, shadow tint)
--   onSurfaceVariant   -> washi paper     e5ddda  (inactive border, ~7% alpha)
--
-- Every section is applied separately. If a key doesn't exist on your Hyprland
-- version, only that section is skipped and logged. See: hyprctl configerrors

local accent_hi = "d9534d"   -- bright crimson
local paper     = "e5ddda"   -- washi paper

-- rgba(hex, alpha 0-255) -> "rgba(RRGGBBAA)"
local function rgba(hex, a) return string.format("rgba(%s%02x)", hex, a) end

local function apply(name, tbl)
    local ok, err = pcall(hl.config, tbl)
    if not ok then print("[look_and_feel] '" .. name .. "' failed: " .. tostring(err)) end
end

-----------------------
------- DECORATION ----
-----------------------
-- Refer to https://wiki.hypr.land/configuring/core/config-options/
apply("frame", {
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 1,
        col = {
            active_border   = rgba(accent_hi, 0xe6),   -- 90% crimson
            inactive_border = rgba(paper, 0x11),       -- ~7% paper: barely there
        },
    },
})

apply("workspace_gap", {
    general = { gaps_workspaces = 20 },   -- breathing room while sliding between workspaces
})

apply("decoration", {
    decoration = {
        rounding       = 15,
        rounding_power = 2.0,    -- true circle, as Caelestia

        active_opacity     = 0.95,
        inactive_opacity   = 0.95,
        fullscreen_opacity = 1.0,
    },
})

apply("shadow", {
    decoration = {
        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 4,
            color        = rgba(accent_hi, 0x14),   -- soft crimson halo rather than a black drop shadow
        },
    },
})

apply("blur", {
    decoration = {
        blur = {
            enabled        = true,
            size           = 8,
            passes         = 2,
            special        = false,   -- no blur behind the special workspace (expensive)
            popups         = true,
            input_methods  = true,
            -- xray = false lets panels and floating windows frost whatever is behind them,
            -- which is the Caelestia look. If you want it cheaper, set xray = true:
            -- blur then samples only the wallpaper.
            xray           = false,
            new_optimizations = true,
        },
    },
})

-----------------------
------- ANIMATIONS ----
-----------------------
-- Caelestia's own animation file wasn't readable, so this uses the Material 3 motion
-- curves that this family of rices is built on: emphasized for entrances and exits,
-- standard for everything that merely moves, one soft overshoot for window open.
apply("animations", { animations = { enabled = true } })

local function bezier(name, x0, y0, x1, y1)
    pcall(hl.curve, name, { type = "bezier", points = { { x0, y0 }, { x1, y1 } } })
end

-- Docs for different versions name the curve key `bezier` or plain `curve`.
local function anim(leaf, speed, name, style)
    for _, key in ipairs({ "bezier", "curve" }) do
        local a = { leaf = leaf, enabled = true, speed = speed, style = style }
        a[key] = name
        if pcall(hl.animation, a) then return end
    end
    print("[look_and_feel] animation '" .. leaf .. "' failed")
end

bezier("standard",          0.20, 0.00, 0.00, 1.00)
bezier("standardDecel",     0.00, 0.00, 0.00, 1.00)
bezier("emphasizedDecel",   0.05, 0.70, 0.10, 1.00)
bezier("emphasizedAccel",   0.30, 0.00, 0.80, 0.15)
bezier("expressiveDefault", 0.38, 1.21, 0.22, 1.00)   -- slight overshoot

anim("global",           5,   "standard")
anim("windowsIn",        4.5, "expressiveDefault", "popin 85%")
anim("windowsOut",       2.5, "emphasizedAccel",   "popin 85%")
anim("windowsMove",      5,   "standard")
anim("fade",             3,   "standard")
anim("fadeDim",          3,   "standard")
anim("border",           6,   "standard")
anim("layersIn",         4,   "emphasizedDecel",   "slide")
anim("layersOut",        2.5, "emphasizedAccel",   "slide")
anim("fadeLayers",       3.5, "standard")
anim("workspaces",       5,   "standardDecel",     "slide")
anim("specialWorkspace", 4,   "emphasizedDecel",   "slidefadevert 15%")

-- A looping gradient angle forces constant redraws (the wiki warns about it): keep it off.
pcall(hl.animation, { leaf = "borderangle", enabled = false })
