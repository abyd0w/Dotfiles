-----------------------
--------- MISC --------
-----------------------
local bg = "rgb(0f141d)"

local function apply(name, tbl)
    local ok, err = pcall(hl.config, tbl)
    if not ok then print("[misc] '" .. name .. "' failed: " .. tostring(err)) end
end

apply("misc", {
    misc = {
        background_color         = bg,    -- ink, not the default flash before the wallpaper loads
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },
})

-- vfr (don't redraw when nothing changes) moved from `misc` to `debug` in Hyprland 0.55.
-- Leaving it under `misc` gives an "unknown config key" error.
apply("vfr", {
    debug = { vfr = true },
})

apply("misc_motion", {
    misc = {
        animate_manual_resizes       = true,  -- smooth resizing with the mouse
        animate_mouse_windowdragging = true,
    },
})
