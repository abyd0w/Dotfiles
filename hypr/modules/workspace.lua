--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- Ref https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- See https://wiki.hypr.land/configuring/core/rules/
-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

--------------------------------
------ LOOK AND FEEL RULES -----
--------------------------------
-- Everything below goes with look_and_feel.lua (Caelestia-style glass).
-- Find class names with `hyprctl clients` and layer namespaces with `hyprctl layers`.
-- Each block is wrapped in try(): if one key isn't known on your version, that block
-- is skipped and logged, and everything else still loads. See: hyprctl configerrors

local function try(name, fn)
    local ok, err = pcall(fn)
    if not ok then print("[rules] '" .. name .. "' failed: " .. tostring(err)) end
end

-- Single-window gap -----------------------------------------------------------
-- Caelestia gives a lone window a roomier 20px outer gap (normally 10) so it
-- doesn't hug the screen edge. w[tv1] = exactly one visible tiled window,
-- s[false] = ignore special workspaces.
-- Don't enable this together with the "smart gaps" block at the top.
try("single-window-gap", function()
    hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 20 })
end)

-- Opacity ---------------------------------------------------------------------
-- Windows are 95% opaque by default. Media and image viewers stay fully opaque so
-- colours aren't washed out. Add anything you want solid, e.g. "firefox", "zen",
-- "chromium", "obsidian". Format: "active override inactive override fullscreen override".
try("opaque-media", function()
    local opaque = { "mpv", "vlc", "imv", "swayimg", "org\\.gnome\\.Loupe" }
    hl.window_rule({
        name    = "opaque-media",
        match   = { class = "^(" .. table.concat(opaque, "|") .. ")$" },
        opacity = "1.0 override 1.0 override 1.0 override",
    })
end)

-- Floating utilities ----------------------------------------------------------
-- Small settings/auth windows open centred and floating instead of tiling.
try("float-utilities", function()
    local utilities = {
        "pwvucontrol", "pavucontrol", "org\\.pulseaudio\\.pavucontrol",
        "blueman-manager", "nm-connection-editor", "nm-applet",
        "hyprpolkitagent", "polkit-gnome-authentication-agent-1",
        "xdg-desktop-portal-gtk", "org\\.freedesktop\\.impl\\.portal\\.desktop\\.gtk",
        "qt6ct", "qt5ct", "nwg-look", "kvantummanager",
    }
    hl.window_rule({
        name   = "float-utilities",
        match  = { class = "^(" .. table.concat(utilities, "|") .. ")$" },
        float  = true,
        center = true,
    })
end)

-- Picture-in-picture (Firefox and friends): float and stay on top of every workspace.
try("picture-in-picture", function()
    hl.window_rule({
        name  = "picture-in-picture",
        match = { title = "^(Picture-in-Picture|Picture in picture)$" },
        float = true,
        pin   = true,
    })
end)

-- Layer surfaces (your bar, launcher, notifications, ...) ---------------------
-- Namespaces are regexes matched against the surface's layer-shell namespace.
-- Find your own with `hyprctl layers` while the surface is on screen, then add it
-- to the list. Blur only shows if the surface's own background is translucent
-- (an rgba() in its CSS / QML / theme). ignore_alpha keeps the blur from bleeding
-- into fully transparent pixels around rounded corners.
local shell_surfaces = {
    "waybar", "bar", "rofi", "wofi", "fuzzel", "launcher",
    "notifications", "swaync-control-center", "swaync-notification-window",
    "logout_dialog",
    -- "my-bar", "my-launcher", "my-osd",      -- <- your own shell goes here
}

try("blur-shell", function()
    hl.layer_rule({
        name         = "blur-shell",
        match        = { namespace = "^(" .. table.concat(shell_surfaces, "|") .. ")$" },
        blur         = true,
        ignore_alpha = 0.3,
    })
end)

-- If your shell animates its own panels, switch Hyprland's layer animation off for
-- them so the two don't fight. Uncomment and edit the namespaces.
-- try("shell-no-anim", function()
--     hl.layer_rule({
--         name    = "shell-no-anim",
--         match   = { namespace = "^(my-launcher|my-osd)$" },
--         no_anim = true,
--     })
-- end)

-- Screenshot / colour-picker overlays should appear instantly, not fade in.
try("no-anim-overlays", function()
    hl.layer_rule({
        name    = "no-anim-overlays",
        match   = { namespace = "^(selection|slurp|hyprpicker|wayfreeze)$" },
        no_anim = true,
    })
end)
