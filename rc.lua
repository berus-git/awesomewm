-- -----------------------
-- Berus AwesomeWM rc.lua
-- -----------------------

-- Ha a LuaRocks telepítve van, gondoskodjon róla, hogy az általa telepített csomagok (pl. lgi) megtalálhatók legyenek.
-- Ha a LuaRocks nincs telepítve, ne tegyen semmit.
pcall(require, "luarocks.loader")

-- Standard AwesomeWM könyvtárak
-- Ezek a könyvtárak alapvető funkciókat biztosítanak, mint a menedzsment (awful),
-- a widgetek (wibox) és a témák (beautiful).
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- A billentyűparancsok súgó widgetjének engedélyezése
require("awful.hotkeys_popup.keys")

-- Debian menü bejegyzések betöltése
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Hiba kezelés (Error handling)
-- Ez a rész kezeli a program indításakor és futás közben felmerülő hibákat.
-- A naughty modult használja a kritikus üzenetek (értesítések) megjelenítésére.
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Hiba történt az indítás során!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Hiba történt!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Változó definíciók (Variable definitions)
-- Témák, színek, ikonok és háttérképek definíciója.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Az alapértelmezett terminál és szerkesztő, amit a konfiguráció használ.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Az alapértelmezett módosító billentyű.
-- A Mod4 (Super/Windows) billentyű a standard.
modkey = "Mod4"

-- A layout-ok (elrendezések) táblázata, amelyeket a modkey + space kombinációval lehet váltogatni.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menü (Menu)
-- Menüpontok és a programindító (launcher) widget definíciója.
myawesomemenu = {
   { "Suspend System",   "systemctl suspend" },
   { "Reboot System",   "systemctl reboot" },
   { "Shutdown System", "systemctl poweroff" },
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "Awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

-- Ha a freedesktop szabványt támogató menü van jelen, azt használja.
-- Ellenkező esetben a Debian menüt használja.
if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

menubar.utils.terminal = terminal
-- }}}

-- {{{ Wibar (Panel)
-- Itt történik a panel (Wibar) és a rajta lévő widgetek beállítása minden képernyőre.
-- Óra lokalizáció.
os.setlocale(os.getenv("LANG")) 
mytextclock = wibox.widget.textclock()

-- A virtuális asztalok (taglist) gombjainak beállításai
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

-- A futó alkalmazások listájának (tasklist) gombjainak beállításai
local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

-- Háttérkép beállítása a képernyőre
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

-- Wibar és widgetek létrehozása minden képernyőre
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Tag-ek létrehozása (1-9) minden képernyőre.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Különböző widgetek létrehozása a Wibar-hoz
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- A Wibar elrendezése a bal, középső és jobb oldali widgetekkel.
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Bal oldali widgetek
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Középső widget
        { -- Jobb oldali widgetek
            layout = wibox.layout.fixed.horizontal,
            --mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Egér parancsok (Mouse bindings)
-- Egér parancsok a "gyökér" (root) ablakra. Például az asztalra kattintva a menü jelenik meg.
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Billentyű parancsok (Key bindings)
-- Itt történik a globális és kliens-specifikus billentyűparancsok definiálása.

-- Globális billentyűparancsok (bárhonnan elérhetők)
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="súgó", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "előző tag", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "következő tag", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "vissza", group = "tag"}),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "következő ablakra fókuszál", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "előző ablakra fókuszál", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "főmenü megjelenítése", group = "awesome"}),
    -- A layout-ok manipulálása
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "ablak cseréje a következővel", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "ablak cseréje az előzővel", group = "client"}),
    -- Képernyő váltás
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "következő képernyőre fókuszál", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "előző képernyőre fókuszál", group = "screen"}),
    -- Terminál és AwesomeWM parancsok
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "terminál megnyitása", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "AwesomeWM újraindítása", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "e", awesome.quit,
              {description = "AwesomeWM bezárása", group = "awesome"}),
    -- Layout váltása és manipulálása
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "fő ablak szélességének növelése", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "fő ablak szélességének csökkentése", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "következő layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "előző layout", group = "layout"}),
    -- Prompt és Menubar
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "prompt indítása", group = "launcher"}),
    awful.key({ modkey }, "d", function () awful.util.spawn( "dmenu_run -i -b -fn '--dina-medium-r-normal--12-------*'" ) end,
              {description = "dmenu" , group = "hotkeys" }),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "menubar megjelenítése", group = "launcher"})
)

-- Kliens-specifikus billentyűparancsok (csak a fókuszban lévő ablakra hatnak)
clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "teljes képernyő", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "bezárás", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "lebegő ablak ki/be", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "áthelyezés a master zónába", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "ablak minimalizálása", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "ablak maximalizálása (ki/be)", group = "client"})
)

-- A tag-ekhez rendelt billentyűk beállítása
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "tag #"..i.." megtekintése", group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "fókuszált ablak áthelyezése a tag #"..i.."re", group = "tag"})
    )
end

-- Egér parancsok a kliensekhez (ablakokhoz)
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Billentyűparancsok beállítása
root.keys(globalkeys)
-- }}}

-- {{{ Szabályok (Rules)
-- Szabályok az új kliensekre (ablakokra).
awful.rules.rules = {
    -- Minden kliensre vonatkozó alapértelmezett szabályok
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Lebegő (floating) ablakok szabályai
    { rule_any = {
        instance = {
          "DTA",
          "copyq",
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",
          "Sxiv",
          "Tor Browser",
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},
        name = {
          "Event Tester",
        },
        role = {
          "AlarmWindow",
          "ConfigManager",
          "pop-up",
        }
      }, properties = { floating = true }},

    -- Címsorok hozzáadása a "normal" és "dialog" típusú ablakokhoz
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Példa egy alkalmazás szabályára: a Firefox mindig a 2-es tag-re kerül
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Jelek (Signals)
-- A jelek lehetővé teszik a konfiguráció számára, hogy reagáljon bizonyos eseményekre.
client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Címsor hozzáadása
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Bal
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Középső
            { -- Címsor
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Jobb
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- "Sloppy focus" engedélyezése (az egér mozgása követi a fókuszt)
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- A fókuszban lévő és fókuszból kikerülő ablak szegélyszínének megváltoztatása.
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Egyéb beállítások

-- Gaps
beautiful.useless_gap = 5

-- Autostart
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
--awful.spawn.with_shell("picom &")
awful.spawn("picom -b")

-- Smart Borders
--require('smart_borders'){ show_button_tooltips = true }
