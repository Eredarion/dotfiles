local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Configuration
------------------------------------------------------------
local update_interval = 7200 -- in seconds (default = 2 hour)
local show_notification = true
------------------------------------------------------------


-- Notification
------------------------------------------------------------
local last_notification_id
local function send_notification(title, text)
  notification = naughty.notify({
      title =  title,
      text = text,
      icon = beautiful.update_icon,
      timeout = 3,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end
------------------------------------------------------------


-- Create widget
local updates = wibox.widget {
    -- align  = 'center',
    -- valign = 'center',
    text   = 'Update...',
    widget = wibox.widget.textbox
}

-- Update widget text
local function update_widget(upd_pkg)
  updates.markup = upd_pkg
end


-- Main script 
------------------------------------------------------------
local upd_script = [[ bash -c '
# wget -q --spider http://google.com
ping -q -c 1 -W 1 google.com >/dev/null

if [ $? -eq 0 ]; then
  if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
      updates_arch=0
  fi

  if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
  # if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
  # if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
  # if ! updates_aur=$(pikaur -Qua 2> /dev/null | wc -l); then
      updates_aur=0
  fi

  updates=$(("$updates_arch" + "$updates_aur"))
  echo $updates
else
    echo "Offline"
fi
']]
------------------------------------------------------------


-- Main loop
------------------------------------------------------------
awful.widget.watch(upd_script, update_interval, function(widget, stdout)
          local upd_pkg = stdout:gsub("%s+", "")

          if upd_pkg == "0" then
            upd_pkg = "All sync"
          elseif upd_pkg == "Offline" then
            upd_pkg = "Network error"
          else
            if show_notification then
              send_notification("Pacman   ",
                                "New " .. "<span color=\"" .. beautiful.xcolor3 .. "\">" .. upd_pkg .. "</span> pkg   ")
            end
            upd_pkg = "New <span color=\"" .. beautiful.xcolor3 .. "\">".. upd_pkg  .. "</span> pkg"
          end
                     
          update_widget(upd_pkg)
end)
------------------------------------------------------------


-- Refresh widget after updates
------------------------------------------------------------
local function update_pacman_data()
    awful.spawn.easy_async_with_shell(upd_script, function(stdout)
      local upd_pkg = stdout:gsub("%s+", "")

      if upd_pkg == "0" then
        upd_pkg = "All sync"
      elseif upd_pkg == "Offline" then
        upd_pkg = "Network error"
      else
        upd_pkg = "New pkg: <span color=\"" .. beautiful.xcolor3 .. "\">".. upd_pkg  .. "</span>"
      end

        update_widget(upd_pkg)
    end)
end

awesome.connect_signal("pacman_upd", function ()
  updates.markup = "Update..."
  update_pacman_data()
end)
------------------------------------------------------------

return updates
