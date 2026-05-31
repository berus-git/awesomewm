-------------------------------------------------
-- Berus Awesome Catppuccin téma
-------------------------------------------------

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

theme.font = "JetBrainsMono Nerd Font 10"

-------------------------------------------------
-- Alapszínek
-------------------------------------------------

theme.bg_normal   = "#1e1e2e"
theme.bg_focus    = "#313244"
theme.bg_urgent   = "#f38ba8"
theme.bg_minimize = "#45475a"

theme.fg_normal   = "#cdd6f4"
theme.fg_focus    = "#ffffff"
theme.fg_urgent   = "#11111b"
theme.fg_minimize = "#6c7086"

-------------------------------------------------
-- Keretek
-------------------------------------------------

theme.useless_gap = dpi(8)

theme.border_width = dpi(2)

theme.border_normal = "#45475a"
theme.border_focus  = "#89b4fa"
theme.border_marked = "#fab387"

-------------------------------------------------
-- Workspace lista
-------------------------------------------------

theme.taglist_bg_focus = "#89b4fa"
theme.taglist_fg_focus = "#11111b"

theme.taglist_fg_empty = "#6c7086"
theme.taglist_fg_occupied = "#cdd6f4"

-------------------------------------------------
-- Programlista
-------------------------------------------------

theme.tasklist_bg_focus = "#313244"
theme.tasklist_fg_focus = "#89b4fa"

-------------------------------------------------
-- Menü
-------------------------------------------------

theme.menu_height = dpi(28)
theme.menu_width  = dpi(220)

theme.menu_bg_normal = "#181825"
theme.menu_fg_normal = "#cdd6f4"

theme.menu_bg_focus = "#89b4fa"
theme.menu_fg_focus = "#11111b"

-------------------------------------------------
-- Értesítések
-------------------------------------------------

theme.notification_bg = "#181825"
theme.notification_fg = "#cdd6f4"

theme.notification_border_width = dpi(2)
theme.notification_border_color = "#89b4fa"

return theme
