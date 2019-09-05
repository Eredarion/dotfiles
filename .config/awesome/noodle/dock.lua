local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad



-- Margin
------------------------------------------------------------
local space = function(width, side)
  if (side == "left") then
    return {
        left = width,
        widget  = wibox.container.margin
    }
  elseif (side == "right") then
    return {
        right = width,
        widget  = wibox.container.margin
    }
  else
    return {
        widget  = wibox.container.margin
    }
  end
end
------------------------------------------------------------


-- Init tasklist buttons
------------------------------------------------------------
local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, 
                        function (c)
                            if c == client.focus then
                                c.minimized = true
                            else
                                -- Without this, the following
                                -- :isvisible() makes no sense
                                c.minimized = false
                                if not c:isvisible() and c.first_tag then
                                    c.first_tag:view_only()
                                end
                                -- This will also un-minimize
                                -- the client, if needed
                                client.focus = c
                                c:raise()
                            end
                        end),
                     -- Middle mouse button closes the window
                     awful.button({ }, 2, function (c) c:kill() end),
                     awful.button({ }, 3, function (c) c.minimized = true end),
                     awful.button({ }, 4, function (c)
                                              --awful.client.focus.byidx(-1)
                                              local clients = client.get()
                                              client.focus = gears.table.iterate_value(clients, clients[c], 1)
                                              c:raise()
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                    end)
)
------------------------------------------------------------


-- Shapes
------------------------------------------------------------
local dosk_bg_shape = function(cr, width, height)
  gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6)
end

local focus_bg_shape = function(cr, width, height)
   gears.shape.transform(gears.shape.rounded_rect) : translate(47, 30)
: rotate_at(35,35,math.pi) (cr,dpi(5),dpi(5))
end

local test_bg_shape = function(cr, width, height)
  gears.shape.rounded_bar (cr, width, height / 3)
end
------------------------------------------------------------


-- awful.widget.tasklist {
--         screen   = screen[1],
--         filter   = awful.widget.tasklist.filter.allscreen,
--         buttons  = tasklist_buttons,
--         style    = {
--               -- shape_border_width = 1,
--               -- shape_border_color = beautiful.xcolor8 .. "80",
--               align = "center",
--               shape = focus_bg_shape,
--         },
--         layout   = {
--             spacing = dpi(3), -- 13
--             -- spacing_widget = {
--             --   {
--             --     forced_width = dpi(3),
--             --     forced_height = dpi(20),
--             --     color         = beautiful.xcolor3 .. "CC",
--             --     shape        = gears.shape.rounded_bar,
--             --     widget       = wibox.widget.separator
--             --   },
--             --   valign = 'center',
--             --   halign = 'center',
--             --   widget = wibox.container.place,
--             -- },
--             layout = wibox.layout.fixed.horizontal
--         },
--         widget_template = {
--               {   
--                 {
--                   {
--                     id     = 'clienticon',
--                     widget = awful.widget.clienticon,
--                   },
--                     top = dpi(0),
--                     left = dpi(0),
--                     right = dpi(0),
--                 bottom = dpi(6),
--                 widget  = wibox.container.margin,
--                 },
--               valign = 'center',
--               halign = 'center',
--               widget = wibox.container.place,
--               },
--             id              = 'background_role',
--             forced_width    = dpi(40), -- 38
--             forced_height   = dpi(40),
--             widget          = wibox.container.background,
--             create_callback = function(self, c, index, objects) --luacheck: no unused
--                 self:get_children_by_id('clienticon')[1].client = c
--             end,
--         },
--     },

  --   top = dpi(5),
  --   bottom = dpi(1),
  --   left = dpi(8),
  --   right = dpi(8),
  --   widget  = wibox.container.margin
  -- },
  --

------------------------------------------------------------
-- Init dock and activator
------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)

-- Create the dock
------------------------------------------------------------
local tasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.allscreen,
        buttons  = tasklist_buttons,
        style    = {
            shape = gears.shape.rounded_rect,
        },
        layout   = {
            spacing = dpi(2), 
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
          {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = dpi(3),
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            forced_width    = dpi(40),
            forced_height   = dpi(40),
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id('clienticon')[1].client = c
            end,
          },
          top = dpi(5),
          bottom = dpi(5),
          widget  = wibox.container.margin
        },
}

dock = awful.popup {
    widget = {
          space(dpi(8), "left"),
          tasklist,
          space(dpi(8), "right"),
          layout = wibox.layout.fixed.horizontal
    },
    ontop        = true,
    visible      = false,
    bg           = beautiful.xbackgroundtp,
    placement    = awful.placement.bottom,
    shape        = dosk_bg_shape
}
------------------------------------------------------------


-- Create dock activator
------------------------------------------------------------
local tasklist_activator = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.allscreen,
        layout   = {
            spacing = dpi(2), 
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
              left    = dpi(3),
              right   = dpi(3),
              widget  = wibox.container.margin,
            },
            id              = 'background_role',
            forced_width    = dpi(40),
            forced_height   = dpi(5),
            widget          = wibox.container.background,
        },
}

dock_activator = awful.popup {
    widget = {
          space(dpi(8), "left"),
          tasklist_activator,
          space(dpi(8), "right"),
          layout = wibox.layout.fixed.horizontal
    },
    ontop        = true,
    visible      = true,
    opacity      = 0,
    bg           = beautiful.xbackgroundtp,
    placement    = awful.placement.bottom,
}
------------------------------------------------------------


end)
------------------------------------------------------------
-- End :) --------------------------------------------------
------------------------------------------------------------


-- Hide dock
dock:connect_signal("mouse::leave", function ()
                          dock.visible = false
                          dock_activator.ontop = true
end)


-- Show dock
dock_activator:connect_signal("mouse::enter", function ()
                                 dock.visible = true
                                 dock_activator.ontop = false
end)


-- Activator buttons
dock_activator:buttons(
  gears.table.join(
      awful.button({ }, 4, function ()
          awful.tag.viewprev()
      end),
      awful.button({ }, 5, function ()
          awful.tag.viewnext()
    end)
))
