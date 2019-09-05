local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local notify = require("noodle.central_notification")
local dpi = xresources.apply_dpi

local helpers = require("helpers")

local keys = {}

-- Mod keys
superkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"
shiftkey = "Shift"

local last_notification_id
local function send_notification(title, text, icon)
  notification = naughty.notify({
      title =  title,
      text = text,
      icon = icon,
      width = dpi(185),
      timeout = 2,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end


local function toggle_titlebars(c)
    awful.titlebar.toggle(c, "top")
    awful.titlebar.toggle(c, "left")
    awful.titlebar.toggle(c, "right")
    awful.titlebar.toggle(c, "bottom")
end

-- {{{ Mouse bindings on desktop
keys.desktopbuttons = gears.table.join(
    awful.button({ }, 1, function ()
        mymainmenu:hide()
        sidebar.visible = false
        naughty.destroy_all_notifications()

        local function double_tap()
          uc = awful.client.urgent.get()
          -- If there is no urgent client, go back to last tag
          if uc == nil then
            awful.tag.history.restore()
          else
            awful.client.urgent.jumpto()
          end
        end
        helpers.single_double_tap(function() end, double_tap)
    end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),

    -- Middle button - Toggle start scren
    awful.button({ }, 2, function ()
        start_screen_show()
        -- sidebar.visible = not sidebar.visible
    end),

    -- Scrolling - Switch tags
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),

    -- Side buttons - Control volume
    awful.button({ }, 9, function () awful.spawn.with_shell("pamixer -i 5") end),
    awful.button({ }, 8, function () awful.spawn.with_shell("pamixer -d 5") end)

    -- Side buttons - Minimize and restore minimized client
    -- awful.button({ }, 8, function()
    --     if client.focus ~= nil then
    --         client.focus.minimized = true
    --     end
    -- end),
    -- awful.button({ }, 9, function()
    --       local c = awful.client.restore()
    --       -- Focus restored client
    --       if c then
    --           client.focus = c
    --           c:raise()
    --       end
    -- end)
)
-- }}}

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
    --awful.key({ superkey,           }, "s",      hotkeys_popup.show_help,
              --{description="show help", group="awesome"}),
    awful.key({ superkey, shiftkey }, "a",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ superkey,          }, "a",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),

    -- Focus client by direction
    awful.key({ superkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ superkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ superkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ superkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),
    -- Focus client by index (cycle through clients)
    awful.key({ superkey }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ superkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -- Focus client by index (cycle through clients)
    -- awful.key({ superkey }, "Tab",
    --   function() awful.client.focus.byidx(1) end,
    --   {description = "focus next by index", group = "client"}),
    
    -- awful.key({ superkey, shiftkey }, "Tab",
    --   function ()
    --     awful.client.focus.byidx(-1)
    --   end,
    --   {description = "focus previous by index", group = "client"}
    -- ),
    awful.key({ superkey, shiftkey }, "minus",
        function ()
            awful.tag.incgap(5, nil)
        end,
        {description = "increment gaps size for the current tag", group = "gaps"}
    ),
    awful.key({ superkey }, "minus",
        function ()
            awful.tag.incgap(-5, nil)
        end,
        {description = "decrement gap size for the current tag", group = "gaps"}
    ),
    -- Kill all visible clients for the current tag
    awful.key({ superkey, altkey }, "q",
        function ()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
               c:kill()
            end
        end,
        {description = "kill all visible clients for the current tag", group = "gaps"}
    ),
    -- Main menu
    awful.key({ superkey, shiftkey  }, "v", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Logout, Shutdown, Restart, Suspend, Lock
    awful.key({ superkey,           }, "Escape",
      function ()
        exit_screen_show()
      end,
      {description = "exit", group = "awesome"}),

    -- Layout manipulation
    awful.key({ superkey, shiftkey   }, "j", function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
            --c:relative_move(  0,  40,   0,   0)
            helpers.move_to_edge(c, "down")
        else
            --awful.client.swap.byidx(  1)
            awful.client.swap.bydirection("down", c, nil)

        end
    end,
    --{description = "swap with next client by index", group = "client"}),
    {description = "swap with direction down", group = "client"}),
    awful.key({ superkey, shiftkey   }, "Down", function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
          helpers.move_to_edge(c, "down")
        else
          awful.client.swap.bydirection("down", c, nil)

        end
                                           end,
      {description = "swap with direction down", group = "client"}),
    awful.key({ superkey, shiftkey   }, "k", function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
            --c:relative_move(  0,  -40,   0,   0)
            helpers.move_to_edge(c, "up")
        else
            --awful.client.swap.byidx( -1)
            awful.client.swap.bydirection("up", c, nil)
        end
    end,
    {description = "swap with direction up", group = "client"}),
    awful.key({ superkey, shiftkey   }, "Up", function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
          --c:relative_move(  0,  -40,   0,   0)
          helpers.move_to_edge(c, "up")
        else
          --awful.client.swap.byidx( -1)
          awful.client.swap.bydirection("up", c, nil)
        end
                                           end,
      {description = "swap with direction up", group = "client"}),
    -- No need for these (single screen setup)
    --awful.key({ superkey, ctrlkey }, "j", function () awful.screen.focus_relative( 1) end,
              --{description = "focus the next screen", group = "screen"}),
    --awful.key({ superkey, ctrlkey }, "k", function () awful.screen.focus_relative(-1) end,
              --{description = "focus the previous screen", group = "screen"}),
    awful.key({ superkey,           }, "u",
        function ()
            uc = awful.client.urgent.get()
            -- If there is no urgent client, go back to last tag
            if uc == nil then
                awful.tag.history.restore()
            else
                awful.client.urgent.jumpto()
            end
        end,
          {description = "jump to urgent client", group = "client"}),
    awful.key({ superkey,           }, "z",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ superkey,           }, "x",
        function ()
            awful.tag.history.restore()
        end,
        {description = "go back", group = "tag"}),
    -- Standard program
    awful.key({ superkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),

    -- Spawn floating terminal
    awful.key({ superkey, shiftkey }, "Return", function()
        awful.spawn(floating_terminal, {floating = true})
        -- awful.spawn(terminal, {floating = true})
    end, {description = "spawn floating terminal", group = "launcher"}),

    -- Draw terminal
    awful.key({ superkey,          }, "e", function()
        awful.spawn.easy_async_with_shell(
                [[bash -c '
                    read -r X Y W H < <(slop -f "%x %y %w %h" -t 0 -q)

                    # Depends on font width & height
                    (( W /= ]] .. terminal_font_width .. [[ ))
                    (( H /= ]] .. terminal_font_height .. [[ ))

                    g=${W}x${H}+${X}+${Y}
                    echo $X@@$Y@ "##"$g"##"
                ']], function(stdout)

                local X = stdout:match('(.*)@@')
                local Y = stdout:match('@@(.*)@')
                local geometry = stdout:match('##(.*)##')

                awful.spawn(terminal .. " -g " .. geometry, {floating = true}, function(c)
                    -- awful.placement.next_to_mouse(c)
                    gears.timer.delayed_call(function()
                        c.x = X
                        c.y = Y
                    end)
                end)

                collectgarbage()
        end)
    end, {description = "draw terminal", group = "launcher"}),

    awful.key({ superkey, shiftkey }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- awful.key({ superkey, shiftkey   }, "x", awesome.quit,
              -- {description = "quit awesome", group = "awesome"}),
    awful.key({ superkey, ctrlkey }, "h",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: resize client
        if current_layout == "floating" or c.floating == true then
            c:relative_move(  0,  0, dpi(-20), 0)
        else
            awful.tag.incmwfact(-0.05)
        end
    end,
      {description = "decrease master width factor", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Left",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: resize client
        if current_layout == "floating" or c.floating == true then
          c:relative_move(  0,  0, dpi(-20), 0)
        else
          awful.tag.incmwfact(-0.05)
        end
                                            end,
      {description = "decrease master width factor", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "l",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: resize client
        if current_layout == "floating" or c.floating == true then
            c:relative_move(  0,  0,  dpi(20), 0)
        else
            awful.tag.incmwfact( 0.05)
        end
    end,
      {description = "increase master width factor", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Right",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: resize client
        if current_layout == "floating" or c.floating == true then
          c:relative_move(  0,  0,  dpi(20), 0)
        else
          awful.tag.incmwfact( 0.05)
        end
                                            end,
      {description = "increase master width factor", group = "layout"}),
    awful.key({ superkey, shiftkey   }, "h",
      function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
          --c:relative_move( -40,  0,   0,   0)
          helpers.move_to_edge(c, "left")
        else
          awful.client.swap.bydirection("left", c, nil)
        end
      end,
      {description = "swap with direction left", group = "client"}),
    awful.key({ superkey, shiftkey   }, "Left",
    function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
            --c:relative_move( -40,  0,   0,   0)
            helpers.move_to_edge(c, "left")
        else
            awful.client.swap.bydirection("left", c, nil)
        end
    end,
    {description = "swap with direction left", group = "client"}),
    awful.key({ superkey, shiftkey   }, "l",
    function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
            --c:relative_move(  40,  0,   0,   0)
            helpers.move_to_edge(c, "right")
        else
            awful.client.swap.bydirection("right", c, nil)
        end
    end,
    {description = "swap with direction right", group = "client"}),
    awful.key({ superkey, shiftkey   }, "Right",
      function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client to edge
        if c ~= nil and (current_layout == "floating" or c.floating) then
          --c:relative_move(  40,  0,   0,   0)
          helpers.move_to_edge(c, "right")
        else
          awful.client.swap.bydirection("right", c, nil)
        end
      end,
      {description = "swap with direction right", group = "client"}),
    awful.key({ superkey }, "h",   
    function () 
        awful.tag.incnmaster( 1, nil, true) 
    end,
    {description = "increase the number of master clients", group = "layout"}),
    awful.key({ superkey }, "l",   
    function () 
        awful.tag.incnmaster(-1, nil, true) 
    end,
    {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ superkey, shiftkey, ctrlkey }, "h",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client
        if c ~= nil and (current_layout == "floating" or c.floating) then
          c:relative_move( dpi(-20),  0,  0,   0)
        else
          awful.tag.incncol( 1, nil, true)
        end
                                                      end,
      {description = "increase the number of columns", group = "layout"}),
    awful.key({ superkey, shiftkey, ctrlkey }, "Left",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client
        if c ~= nil and (current_layout == "floating" or c.floating) then
            c:relative_move( dpi(-20),  0,  0,   0)
        else
            awful.tag.incncol( 1, nil, true)
        end
    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ superkey, shiftkey, ctrlkey }, "l",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client
        if c ~= nil and (current_layout == "floating" or c.floating) then
          c:relative_move(  dpi(20),  0,  0,   0)
        else
          awful.tag.incncol(-1, nil, true)
        end
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Right",     function ()
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        local c = client.focus
        -- Floating: move client
        if c ~= nil and (current_layout == "floating" or c.floating) then
            c:relative_move(  dpi(20),  0,  0,   0)
        else
            awful.tag.incncol(-1, nil, true)
        end
    end),
    --awful.key({ superkey,           }, "space", function () awful.layout.inc( 1)                end,
              --{description = "select next", group = "layout"}),
    --awful.key({ superkey, shiftkey   }, "space", function () awful.layout.inc(-1)                end,
              --{description = "select previous", group = "layout"}),

    awful.key({ superkey, shiftkey }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    --awful.key({ superkey },            "d",     function () awful.screen.focused().mypromptbox:run() end,
              --{description = "run prompt", group = "launcher"}),
    -- Run program (d for dmenu ;)
    awful.key({ superkey }, "d",
      function()
        awful.spawn.with_shell(rofi_script)
      end,
      {description = "rofi launcher", group = "launcher"}),

    -- Run rofi system menu
    awful.key({ superkey, shiftkey }, "q",
      function()
        exit_screen_show()
      end,
      {description = "exit screen", group = "launcher"}),

    -- Run dmenu
    awful.key({ superkey }, "r",
      function()
        awful.spawn.with_shell(dmenu_script)
      end,
      {description = "dmenu launcher", group = "launcher"}),
    
    -- Run lua code
    --awful.key({ superkey }, "r",
              --function ()
                  --awful.prompt.run {
                    --prompt       = " Lua: ",
                    --textbox      = awful.screen.focused().mypromptbox.widget,
                    --exe_callback = awful.util.eval,
                    --history_path = awful.util.get_cache_dir() .. "/history_eval"
                  --}
              --end,
              --{description = "lua execute prompt", group = "awesome"}),

    -- Dismiss notifications
    awful.key( { ctrlkey }, "space", function()
        naughty.destroy_all_notifications()
    end,
              {description = "dismiss notification", group = "notifications"}),

    -- Menubar
    --awful.key({ superkey, ctrlkey }, "b", function() menubar.show() end,
              --{description = "show the menubar", group = "launcher"}),

    -- Brightness
    awful.key( { }, "XF86MonBrightnessDown",
      function()
        awful.spawn.easy_async_with_shell("xbacklight -dec 10 ; xbacklight -get", function(stdout)
            awesome.emit_signal("brightness_changed")
            local light = stdout:match'[^.]*'
            notify.show(beautiful.redshift_icon, tonumber(light), "#FDC198")
            -- send_notification("Brightness   ",
            --                   "Level: <span color=\"" .. "#FDC198" .. "\">" .. stdout:match'[^.]*' .. "%</span>   ",
            --                   beautiful.redshift_icon)
            collectgarbage()
        end)

      end,  {description = "decrease brightness", group = "brightness"}),

    awful.key( { }, "XF86MonBrightnessUp", function()
        awful.spawn.easy_async_with_shell("xbacklight -inc 10 ; xbacklight -get", function(stdout)
            awesome.emit_signal("brightness_changed")
            local light = stdout:match'[^.]*'
            notify.show(beautiful.redshift_icon, tonumber(light), "#FDC198")
            -- send_notification("Brightness   ",
            --                   "Level: <span color=\"" .. "#FDC198" .. "\">" .. stdout:match'[^.]*' .. "%</span>   ",
            --                   beautiful.redshift_icon)
            collectgarbage()
        end)
    end,  {description = "increase brightness", group = "brightness"}),

    -- Volume Control
    awful.key( { }, "XF86AudioMute", function()
        awful.spawn.with_shell("pamixer -t")
        notify.show(beautiful.volume_icon, 0, "#83E9FD")
    end, {description = "(un)mute volume", group = "volume"}),

    awful.key( { }, "XF86AudioLowerVolume", function()
        awful.spawn.easy_async_with_shell("pamixer -d 5 --get-volume", function(stdout)
            local vol = stdout:gsub("%s+", "")
            if ( vol == "0" ) then
                notify.show(beautiful.muted_icon, tonumber(vol), "#83E9FD")
            else
                notify.show(beautiful.volume_icon, tonumber(vol), "#83E9FD")
            end
            collectgarbage()
        end)  
    end,    {description = "lower volume", group = "volume"}),

    awful.key( { }, "XF86AudioRaiseVolume", function()
        awful.spawn.easy_async_with_shell("pamixer -i 5 --get-volume", function(stdout)
            local vol = stdout:gsub("%s+", "")
            notify.show(beautiful.volume_icon, tonumber(vol), "#83E9FD")
            -- send_notification("Volume",
            --                   "Level: <span color=\"" .. "#83E9FD" .. "\">" .. stdout:gsub("%s+", "") .. "%</span>",
            --                   beautiful.volume_icon)
            collectgarbage()
        end) 
    end,    {description = "raise volume", group = "volume"}),

    -- Screenshots
    awful.key( { }, "Print", function() awful.spawn.with_shell("screenshot") end,
              {description = "take full screenshot", group = "screenshots"}),
    awful.key( { superkey }, "Print", function() awful.spawn.with_shell("screenshot -s") end,
              {description = "select area to capture", group = "screenshots"}),
    awful.key( { superkey, shiftkey }, "Print", function() awful.spawn.with_shell("screenshot -c") end,
              {description = "select area to copy to clipboard", group = "screenshots"}),

    -- Recording
    awful.key( { superkey, shiftkey }, "F12", function() awful.spawn.with_shell("record --toggle") end,
              {description = "toggle recording video", group = "recording"}),

    -- Toggle compton
    awful.key( { superkey, shiftkey }, "F10", function() awful.spawn.with_shell("compot -t") end,
              {description = "toggle compton", group = "awesome"}),

    -- Toggle tray visibility
    awful.key({ superkey }, "=", function ()
        awful.screen.focused().traybox.visible = not awful.screen.focused().traybox.visible
    end,
    {description = "toggle tray visibility", group = "awesome"}),

    -- Media keys
    awful.key({ superkey }, "period", function() awful.spawn.with_shell("mpc next") end,
    {description = "next song", group = "media"}),
    awful.key({ superkey }, "comma", function() awful.spawn.with_shell("mpc prev") end,
    {description = "previous song", group = "media"}),
    awful.key({ superkey }, "space", function() awful.spawn.with_shell("mpc toggle") end,
    {description = "toggle pause/play", group = "media"}),
    awful.key({ superkey, shiftkey }, "period", function() awful.spawn.with_shell("mpvc next") end,
    {description = "mpv next song", group = "media"}),
    awful.key({ superkey, shiftkey }, "comma", function() awful.spawn.with_shell("mpvc prev") end,
    {description = "mpv previous song", group = "media"}),
    awful.key({ superkey, shiftkey}, "space", function() awful.spawn.with_shell("mpvc toggle") end,
    {description = "mpv toggle pause/play", group = "media"}),

    -- Set max layout
    awful.key({ superkey }, "w", function()
        awful.layout.set(awful.layout.suit.max)
    end,
              {description = "set max layout", group = "tag"}),

    -- Set tiled layout
    awful.key({ superkey }, "s", function()
        awful.layout.set(awful.layout.suit.tile)
    end,
              {description = "set tiled layout", group = "tag"}),

    -- Set floating layout
    awful.key({ superkey, shiftkey }, "s", function()
        awful.layout.set(awful.layout.suit.floating)
    end,
              {description = "set floating layout", group = "tag"}),

    -- Start screen
    awful.key({ superkey }, "F4", function()
        start_screen_show()
    end,
              {description = "show start screen", group = "awesome"}),

    -- Pomodoro timer
    awful.key({ superkey }, "slash", function()
        awful.spawn.with_shell("pomodoro")
    end,
              {description = "pomodoro", group = "launcher"}),

    -- Spawn editor
    awful.key({ superkey }, "F2", function() awful.spawn(editor) end,
              {description = "editor", group = "launcher"}),

    -- Spawn filemanager
    awful.key({ superkey }, "F3", function() awful.spawn(filemanager) end,
              {description = "filemanager", group = "launcher"}),

    -- Spawn browser 
    awful.key({ superkey }, "F1", function() awful.spawn(browser) end,
              {description = "browser", group = "launcher"}),

    -- Spawn ncmpcpp in a terminal
    awful.key({ superkey }, "F5", function() awful.spawn(terminal .. " " .. terminal_geometry .. " -e ncmpcpp") end,
              {description = "ncmpcpp", group = "launcher"}),

    -- Spawn ranger in a terminal
    awful.key({ superkey }, "F6", function() awful.spawn(terminal .. " " .. terminal_geometry .. " -e ranger") end,
              {description = "ranger", group = "launcher"}),

    -- Spawn htop in a terminal
    awful.key({ superkey }, "F7", function() awful.spawn(terminal .. " " .. terminal_geometry .. " -e htop") end,
              {description = "htop", group = "launcher"}),

    -- Spawn gotop in a terminal
    awful.key({ superkey }, "F8", function() awful.spawn(terminal .. " " .. terminal_geometry .. " -e gotop") end,
              {description = "gotop", group = "launcher"}),

    -- Toggle sidebar
    awful.key({ superkey }, "grave", function() 
            sidebar.visible = not sidebar.visible
            check_text_bars_visible()
            --awesome.emit_signal("hide_bar_hover")
        end,
              {description = "show or hide sidebar", group = "awesome"}),

    -- Toggle dock
    awful.key({ altkey }, "d", function() dock.visible = not dock.visible end,
              {description = "show or hide dock", group = "awesome"}),

    -- Toggle wibar
    awful.key({ superkey, shiftkey }, "b",
      function()
        local s = awful.screen.focused()
        s.mywibox.visible = not s.mywibox.visible
        if beautiful.wibar_detached then
          s.useless_wibar.visible = not s.useless_wibar.visible
        end
      end,
      {description = "show or hide wibar", group = "awesome"}),

    -- Editor
    awful.key({ superkey, shiftkey }, "e",
        function()
            awful.spawn(editor_cmd)
        end,
      {description = "editor in terminal", group = "launcher"}),

    -- mpvtube
    awful.key({ superkey }, "y", function() awful.spawn.with_shell("~/scr/Rofi/rofi_mpvtube") end,
              {description = "mpvtube", group = "launcher"}),

    -- mpvtube song
    awful.key({ superkey, shiftkey }, "y", function() awful.spawn.with_shell("~/scr/info/mpv-query.sh") end,
              {description = "show mpv media title", group = "launcher"}),

    -- Spawn file manager
    awful.key({ superkey, shiftkey }, "f", function() awful.spawn(filemanager, {floating = true}) end,
      {description = "file manager", group = "launcher"}),

    -- Spawn htop in a terminal
    awful.key({ superkey }, "p", function() awful.spawn(terminal .. " -e htop") end,
              {description = "htop", group = "launcher"})
)

keys.clientkeys = gears.table.join(
    -- Move floating client (relative)
    awful.key({ superkey, shiftkey   }, "Down",   function (c) c:relative_move(  0,  40,   0,   0) end),
    awful.key({ superkey, shiftkey   }, "Up",     function (c) c:relative_move(  0, -40,   0,   0) end),
    awful.key({ superkey, shiftkey   }, "Left",   function (c) c:relative_move(-40,   0,   0,   0) end),
    awful.key({ superkey, shiftkey   }, "Right",  function (c) c:relative_move( 40,   0,   0,   0) end),
    -- Center client
    awful.key({ superkey }, "c",  function (c)
        awful.placement.centered(c,{honor_workarea=true})
        --awful.placement.centered(c,nil)
    end),
    -- Resize client
    awful.key({ superkey, ctrlkey }, "j",     function (c)
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        if current_layout == "floating" or c.floating == true then
            c:relative_move(  0,  0,  0, dpi(20))
        else
            awful.client.incwfact(0.05)
        end
    end),
    awful.key({ superkey, ctrlkey }, "Down",     function (c)
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        if current_layout == "floating" or c.floating == true then
          c:relative_move(  0,  0,  0, dpi(20))
        else
          awful.client.incwfact(0.05)
        end
    end),
    awful.key({ superkey, ctrlkey }, "k",     function (c)
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        if current_layout == "floating" or c.floating == true then
          c:relative_move(  0,  0,  0, dpi(-20))
        else
          awful.client.incwfact(-0.05)
        end
    end),
    awful.key({ superkey, ctrlkey }, "Up",     function (c)
        local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
        if current_layout == "floating" or c.floating == true then
            c:relative_move(  0,  0,  0, dpi(-20))
        else
            awful.client.incwfact(-0.05)
        end
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "j", function (c)
        -- Relative move
        c:relative_move(0,  dpi(20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Down", function (c)
        -- Relative move
        c:relative_move(0,  dpi(20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "k", function (c)
        -- Relative move
        c:relative_move(0, dpi(-20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Up", function (c)
        -- Relative move
        c:relative_move(0, dpi(-20), 0, 0)
    end),
    -- Toggle titlebar (for focused client only)
    awful.key({ superkey,           }, "t",
        function (c)
            -- Don't toggle if titlebars are used as borders
            if not beautiful.titlebars_imitate_borders then
                toggle_titlebars(c)
            end
        end,
        {description = "toggle titlebar", group = "client"}),
    -- Toggle titlebar (for all visible clients in selected tag)
    awful.key({ superkey, shiftkey }, "t",
        function (c)
            --local s = awful.screen.focused()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                -- Don't toggle if titlebars are used as borders
                if not beautiful.titlebars_imitate_borders then
                    toggle_titlebars(c)
                end
            end
        end,
        {description = "toggle titlebar", group = "client"}),
    -- Toggle fullscreen
    awful.key({ superkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    -- Resize and set floating - Predetermined size according to screen
    -- F for focused view
    awful.key({ superkey, ctrlkey  }, "f",
        function (c)
          c.width = screen_width * 0.7
          c.height = screen_height * 0.75
          c.floating = true
          awful.placement.centered(c,{honor_workarea=true})
          c:raise()
        end,
        {description = "focus mode", group = "client"}),
    -- V for vertical view
    awful.key({ superkey, ctrlkey  }, "v",
      function (c)
        c.width = screen_width * 0.45
        c.height = screen_height * 0.90
        c.floating = true
        awful.placement.centered(c,{honor_workarea=true})
        c:raise()
      end,
      {description = "focus mode", group = "client"}),
    -- T for tiny window
    awful.key({ superkey, ctrlkey  }, "t",
        function (c)
          c.width = screen_width * 0.3
          c.height = screen_height * 0.35
          c.floating = true
          awful.placement.centered(c,{honor_workarea=true})
          c:raise()
        end,
        {description = "tiny mode", group = "client"}),
    -- N for normal window
    awful.key({ superkey, ctrlkey  }, "n",
        function (c)
          c.width = screen_width * 0.45
          c.height = screen_height * 0.5
          c.floating = true
          awful.placement.centered(c,{honor_workarea=true})
          c:raise()
        end,
        {description = "normal mode", group = "client"}),
    awful.key({ superkey }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    --awful.key({ superkey, ctrlkey }, "space",  awful.client.floating.toggle                     ,
    -- Toggle floating
    awful.key({ superkey, ctrlkey }, "space",
        function(c)
            local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
            if current_layout ~= "floating" then
                awful.client.floating.toggle()
            end
            --c:raise()
        end,
        {description = "toggle floating", group = "client"}),
    awful.key({ superkey, ctrlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ superkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    -- P for pin: keep on top OR sticky
    -- On top
    awful.key({ superkey, shiftkey }, "p",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    -- Sticky
    awful.key({ superkey, ctrlkey }, "p",      function (c) c.sticky = not c.sticky            end,
              {description = "toggle sticky", group = "client"}),
    -- Minimize
    awful.key({ superkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ superkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ superkey, ctrlkey }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ superkey, shiftkey   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local ntags = 10
for i = 1, ntags do
    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- View tag only.
        awful.key({ superkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        local current_tag = screen.selected_tag
                        -- Tag back and forth:
                        -- If you try to focus the same tag you are at,
                        -- go back to the previous tag.
                        -- Useful for quick switching after for example
                        -- checking an incoming chat message at tag 2
                        -- and coming back to your work at tag 1
                        if tag then
                           if tag == current_tag then
                               awful.tag.history.restore()
                           else
                               tag:view_only()
                           end
                        end
                        -- Simple tag view
                        --if tag then
                           --tag:view_only()
                        --end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ superkey, ctrlkey }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ superkey, shiftkey }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
        {description = "move focused client to tag #"..i, group = "tag"}),
        -- Move all visible clients to tag and focus that tag
        awful.key({ superkey, altkey }, "#" .. i + 9,
                  function ()
                    local tag = client.focus.screen.tags[i]
                    local clients = awful.screen.focused().clients
                    if tag then
                        for _, c in pairs(clients) do
                           c:move_to_tag(tag)
                        end
                        tag:view_only()
                    end
                  end,
        {description = "move all visible clients to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ superkey, ctrlkey, shiftkey }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Mouse buttons on the client (whole window, not just titlebar)
keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ superkey }, 1, function (c) 
                    awful.mouse.client.move(c)
            end),
    awful.button({ superkey }, 2, function (c) c:kill() end),
    awful.button({ superkey }, 3, function(c)
        awful.mouse.client.resize(c)
    end)
)
-- }}}

-- Set keys
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

return keys
