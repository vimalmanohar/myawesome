--[[                                     ]]--
--                                         -
--    Blackburn Awesome WM 3.5.+ config    --
--        github.com/copycat-killer        --
--                                         -
--[[                                     ]]--


-- Required Libraries

local gears           = require("gears")
local awful           = require("awful")
awful.rules           = require("awful.rules")
awful.autofocus       = require("awful.autofocus")
local wibox           = require("wibox")
local beautiful       = require("beautiful")
local naughty         = require("naughty")
local vicious         = require("vicious")
local scratch         = require("scratch")

-- Run once function

--function run_once(cmd)
--  findme = cmd
--  firstspace = cmd:find(" ")
--  if firstspace then
--     findme = cmd:sub(0, firstspace-1)
--  end
--  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
--end

function run_once(prg,arg_string,pname,screen)
  if not prg then
    do return nil end
  end

  if not pname then
    pname = prg
  end

  if not arg_string then 
    awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
  else
    awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
  end
end

-- autostart applications
run_once("xscreensaver","-nosplash")
run_once("urxvtd")
run_once("pulseaudio","--start")
run_once("thunderbird")

-- Localization

os.setlocale(os.getenv("LANG"))

-- Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        local in_error = false
    end)
end


-- Global variables

home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
-- active_theme = themes .. "/starwars-dark"
active_theme = themes .. "/itachi"
language = string.gsub(os.getenv("LANG"), ".utf8", "")

beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvt"
file_manager = terminal .. " -e ranger"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "gvim"
browser = "firefox"
-- mail = terminal .. " -e mutt "
mail = "thunderbird"
-- wifi = terminal .. " -e sudo wifi-menu "
musicplr = terminal .. " -e cmus"
-- musicplr = terminal .. " -g 130x34-320+16 -e ncmpcpp "
touchpad = {
  enable = "synclient TouchpadOff=0",
  disable = "synclient TouchpadOff=1"
}

modkey = "Mod4"
altkey = "Mod1"

layouts =
{
    awful.layout.suit.tile,                 -- 1
    awful.layout.suit.tile.left,            -- 2
    awful.layout.suit.tile.top,             -- 3
    awful.layout.suit.tile.bottom,          -- 4
    awful.layout.suit.floating,             -- 5
    awful.layout.suit.fair,                 -- 6
    awful.layout.suit.max                   -- 7  
}

-- Wallpaper

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags

tags = {
       names = { "Work", "Read", "Code", "Browse", "Play", "Office", "Study", "Mail", "Feat"},
       layout = { layouts[1], layouts[1], layouts[1], layouts[7], layouts[1], layouts[3], layouts[1], layouts[1], layouts[1] }
       }
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- Menu
myaccessories = {
   { "Terminal", "urxvt -T termimal" },
   { "Text editor", gui_editor },
}
myinternet = {
    { "Browser", browser },
    { "Chromium", "chromium" },
    { "Chrome", "google-chrome" },
    { "Mail", "thunderbird" },
}
myoffice = {
    { "Writer" , "lowriter" },
    { "Impress" , "loimpress" },
}
mysystem = {
    { "Appearance" , "lxappearance" },
    { "Cleaning" , "bleachbit" },
    { "Powertop" , terminal .. " -e sudo powertop " },
}
mymainmenu = awful.menu({ items = {
				    { "Accessories" , myaccessories },
				    { "Internet" , myinternet },
				    { "Office" , myoffice },
				    { "System" , mysystem },
            { "Log Out", '/home/vimal/bin/shutdown_dialog.sh'},
            { "Lock Screen", 'xscreensaver-command --lock'}
            }
            })
mylauncher = awful.widget.launcher({ menu = mymainmenu })


-- Wibox

-- Colours
coldef  = "</span>"
white  = "<span color='#d7d7d7'>"
gray = "<span color='#9e9c9a'>"

-- Textclock widget
mytextclock = awful.widget.textclock(white .. "%D/%Y %H:%M"  .. coldef)

-- attached calendar
local os = os
local string = string
local table = table
local util = awful.util

char_width = nil
text_color = theme.fg_normal or "#FFFFFF"
today_color = theme.taglist_fg_focus or "#FF7100"
calendar_width = 21

local calendar = nil
local offset = 0

local data = nil

local function pop_spaces(s1, s2, maxsize)
   local sps = ""
   for i = 1, maxsize - string.len(s1) - string.len(s2) do
      sps = sps .. " "
   end
   return s1 .. sps .. s2
end

local function create_calendar()
   offset = offset or 0

   local now = os.date("*t")
   local cal_month = now.month + offset
   local cal_year = now.year
   if cal_month > 12 then
      cal_month = (cal_month % 12)
      cal_year = cal_year + 1
   elseif cal_month < 1 then
      cal_month = (cal_month + 12)
      cal_year = cal_year - 1
   end

   local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
                                            month = cal_month + 1}) - 86400)

   local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
   local first_day_in_week = os.date("%w", first_day)

   local result = "do lu ma me gi ve sa\n" -- days of the week

   -- Italian localization
   -- can be a stub for your own localization
   if language:find("it_IT") == nil
   then
       result = "su mo tu we th fr sa\n"
   else
       result = "do lu ma me gi ve sa\n"
   end

   for i = 1, first_day_in_week do
      result = result .. "   "
   end

   local this_month = false
   for day = 1, last_day do
      local last_in_week = (day + first_day_in_week) % 7 == 0
      local day_str = pop_spaces("", day, 2) .. (last_in_week and "" or " ")
      if cal_month == now.month and cal_year == now.year and day == now.day then
         this_month = true
         result = result ..
            string.format('<span weight="bold" foreground = "%s">%s</span>',
                          today_color, day_str)
      else
         result = result .. day_str
      end
      if last_in_week and day ~= last_day then
         result = result .. "\n"
      end
   end

   local header
   if this_month then
      header = os.date("%a, %d %b %Y")
   else
      header = os.date("%B %Y", first_day)
   end
   return header, string.format('<span font="%s" foreground="%s">%s</span>',
                                theme.font, text_color, result)
end

local function calculate_char_width()
   return beautiful.get_font_height(theme.font) * 0.555
end

function remove_calendar()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function add_calendar(inc_offset)
   inc_offset = inc_offset or 0

   local save_offset = offset
   remove_calendar()
   offset = save_offset + inc_offset

   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = 0, hover_timeout = 0.5,
                               bg = "#060606"
                            })
end

function show_calendar(t_out)
   remove_calendar()
   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = t_out,
                               bg = "#060606"
                            })
end

mytextclock:connect_signal("mouse::enter", function() add_calendar(0) end)
mytextclock:connect_signal("mouse::leave", remove_calendar)
mytextclock:buttons(util.table.join( awful.button({ }, 1, function() add_calendar(-1) end),
                                     awful.button({ }, 3, function() add_calendar(1) end)))

-- GMail widget
mygmail = wibox.widget.textbox()
gmail_t = awful.tooltip({ objects = { mygmail },})
notify_shown = false
mailcount = 0
vicious.register(mygmail, vicious.widgets.gmail,
 function (widget, args)
  gmail_t:set_text(args["{subject}"])
  gmail_t:add_to_object(mygmail)
  notify_title = ""
  notify_text = ""
  mailcount = args["{count}"]
  if (args["{count}"] > 0 ) then
    if (notify_shown == false) then
      -- Italian localization
      -- can be a stub for your own localization
      if (args["{count}"] == 1) then
          if language:find("it_IT") ~= nil
          then
              notify_title = "Hai un nuovo messaggio"
          else
              notify_title = "You got a new mail"
          end
          notify_text = '"' .. args["{subject}"] .. '"'
      else
          if language:find("it_IT") ~= nil
          then
                notify_title = "Hai " .. args["{count}"] .. " nuovi messaggi"
                notify_text = 'Ultimo: "' .. args["{subject}"] .. '"'
          else
                notify_title = "You got " .. args["{count}"] .. " new mails"
                notify_text = 'Last one: "' .. args["{subject}"] .. '"'
          end
      end
      naughty.notify({
          title = notify_title,
          text = notify_text,
          timeout = 7,
          position = "top_left",
          icon = beautiful.widget_mail_notify,
          fg = beautiful.taglist_fg_focus,
          bg = "#060606"
      })
      notify_shown = true
    end
    return gray .. " Mail " .. coldef .. white .. args["{count}"] .. coldef .. " <span font='Tamsyn 5'> </span><span font='Tamsyn 3'> </span>"
  else
    notify_shown = false
    return ''
  end
end, 60)
mygmail:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail, false) end)))

-- Mpd widget
mpdwidget = wibox.widget.textbox()
mpdwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
curr_track = nil
vicious.register(mpdwidget, vicious.widgets.mpd,
function(widget, args)
	if args["{state}"] == "Play" then
    if args["{Title}"] ~= curr_track
     then
        curr_track = args["{Title}"]
        os.execute(scriptdir .. "mpdinfo")
        old_id = naughty.notify({
            title = "Now playing",
            text = args["{Artist}"] .. " (" .. args["{Album}"] .. ")\n" .. args["{Title}"],
            icon = "/tmp/mpdnotify_cover.png",
            bg = "#060606",
            timeout = 5,
            replaces_id = old_id
        }).id
    end
    if mailcount == 0 then return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. "<span font='Tamsyn 8'>  <span font ='Tamsyn 2'> </span></span>" .. coldef
    else return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. coldef .. "<span font='Tamsyn 8'> <span font='Tamsyn 2'> </span></span>" 
    end
	 elseif args["{state}"] == "Pause" then
    if mailcount == 0 then return gray .. "mpd " .. coldef .. white .. "in pausa<span font='Tamsyn 6'> </span> " .. coldef
    else return gray .. "mpd " .. coldef .. white .. "in pausa " .. coldef
    end
	else
    curr_track = nil
		return ''
	end
end, 1)

-- hhd status notification
local infos = nil

function remove_info()
    if infos ~= nil then
        naughty.destroy(infos)
        infos = nil
    end
end

function show_info(t_out)
    remove_info()
    local capi = {
		mouse = mouse,
		screen = screen
	  }
    local hdd = awful.util.pread(scriptdir .. "dfs")
    hdd = string.gsub(hdd, "          ^%s*(.-)%s*$", "%1")

    -- Italian localization
    -- can be a stub for your own localization
    if language:find("it_IT") ~= nil
    then
        hdd = string.gsub(hdd, "Used ", "Usato")
        hdd = string.gsub(hdd, "Free  ", "Libero")
        hdd = string.gsub(hdd, "Total ", "Totale")
    end

    infos = naughty.notify({
        text = hdd,
      	timeout = t_out,
        position = "top_right",
        margin = 10,
        height = 210,
        width = 680,
        bg = "#060606",
		    screen = capi.mouse.screen
    })
end

--fshwidget:connect_signal('mouse::enter', function () show_info(0) end)
--fshwidget:connect_signal('mouse::leave', function () remove_info() end)

-- Battery widget

statwidget = wibox.widget.textbox()

battery_critical_notified = false
battery_low_notified = false

function battery_state()
  local file1 = io.open("/sys/class/power_supply/BAT1/status", "r")
  local file0 = io.open("/sys/class/power_supply/BAT0/status", "r")
  if (file1 == nil and file0 == nil) then
    return "Cable plugged"
  end

  if (file1 == nil) then
    local batstate0 = file0:read("*line")
    batstate = batstate0
  else
    local batstate1 = file1:read("*line")
    batstate = batstate1
    file1:close()
  end

  file0:close()

  if (batstate == 'Discharging' or batstate == 'Charging') then
    return batstate
  elseif (batstate == 'Unknown') then
    return "Unknown"
  else
    return "Fully charged"
  end
end

function battery_status()
  local file1 = io.open("/sys/class/power_supply/BAT1/capacity", "r")
  local file0 = io.open("/sys/class/power_supply/BAT0/capacity", "r")
  
  local bat0 = file0:read("*line")
  bat = bat0 + 0;
  local bat1 = 0;

  if (file1 ~= nil) then
    bat1 = file1:read("*line")
    if (bat1 ~= nil) then
      bat = bat1 + 0
    else
      bat1 = 0
      bat = bat0 + 0
    end
    file1:close()
  end
  
  file0:close()

  -- plugged
  if (battery_state() == 'Cable plugged') then
    battery_critical_notified = false
    battery_low_notified = false
    return ''
    -- critical
  elseif (bat <= 20 and battery_state() == 'Discharging') then
    if (battery_critical_notified == false) then
      naughty.notify{
        text = "System will turn off soon...",
        title = "Battery Critical!",
        position = "top_right",
        timeout = 0,
        fg="#000000",
        bg="#ffffff",
        screen = 1,
        ontop = true,
      }
      battery_critical_notified = true
    end
    -- low
  elseif (bat <= 40 and battery_state() == 'Discharging') then
    if (battery_low_notified == false) then
      naughty.notify({
        text = "Connect the charger...",
        title = "Battery Low!",
        position = "top_right",
        timeout = 0,
        fg="#ffffff",
        bg="#262729",
        screen = 1,
        ontop = true,
      })
      battery_low_notified = true
    end
  end

  return gray .. "Bat0 " .. coldef .. white .. bat0 .. " " .. coldef .. gray .. "Bat1 " .. coldef .. white .. bat1 .. coldef
end

vicious.register(statwidget, battery_status, '$1', 10)

-- Volume widget
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,
function (widget, args)
  if (args[2] ~= "♩" ) then
     return gray .. "Vol " .. coldef .. white .. args[1] .. " " .. coldef
  else
     return gray .. "Vol " .. coldef .. white .. "mute " .. coldef
  end
end, 1, "Master")

-- Net checker widget
no_net_shown = true
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
    if args["{wlp3s0 carrier}"] == 0 then
       if no_net_shown == true then
         naughty.notify({ title = "wlp3s0", text = "No carrier",
         timeout = 7,
         position = "top_left",
         icon = beautiful.widget_no_net_notify,
         fg = "#ff5e5e",
         bg = "#060606" })
         no_net_shown = false
       end
       return gray .. " wlp3s0 " .. coldef .. "<span color='#e54c62'>Off " .. coldef
    elseif args["{enp0s20u1 carrier}"] == 0 then
       if no_net_shown == true then
         naughty.notify({ title = "enp0s20u1", text = "No carrier",
         timeout = 7,
         position = "top_left",
         icon = beautiful.widget_no_net_notify,
         fg = "#ff5e5e",
         bg = "#060606" })
         no_net_shown = false
       end
       return gray .. " enp0s20u1 " .. coldef .. "<span color='#e54c62'>Off " .. coldef
    else
       no_net_shown = true
       return ''
    end
end, 10)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(wifi) end)))

-- Get active outputs
local function outputs()
   local outputs = {}
   local xrandr = io.popen("xrandr -q")
   if xrandr then
     for line in xrandr:lines() do
       output = line:match("^([%w-]+) connected ")
       if output then
         outputs[#outputs + 1] = output
       end
     end
     xrandr:close()
   end
   return outputs
end

local function arrange(out)
  -- We need to enumerate all the way to combinate output. We assume
  -- we want only an horizontal layout.
  local choices  = {}
  local previous = { {} }
  for i = 1, #out do
    -- Find all permutation of length `i`: we take the permutation
    -- of length `i-1` and for each of them, we create new
    -- permutations by adding each output at the end of it if it is
    -- not already present.
    local new = {}
    for _, p in pairs(previous) do
      for _, o in pairs(out) do
        if not awful.util.table.hasitem(p, o) then
          new[#new + 1] = awful.util.table.join(p, {o})
        end
      end
    end
    choices = awful.util.table.join(choices, new)
    previous = new
  end

  return choices
end

-- Build available choices
local function menu()
  local menu = {}
  local out = outputs()
  local choices = arrange(out)

  for _, choice in pairs(choices) do
    local cmd = "xrandr"
    -- Enabled outputs
    for i, o in pairs(choice) do
      cmd = cmd .. " --output " .. o .. " --auto"
      if i > 1 then
        cmd = cmd .. " --right-of " .. choice[i-1]
      end
    end
    -- Disabled outputs
    for _, o in pairs(out) do
      if not awful.util.table.hasitem(choice, o) then
        cmd = cmd .. " --output " .. o .. " --off"
      end
    end

    local label = ""
    if #choice == 1 then
      label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
    else
      for i, o in pairs(choice) do
        if i > 1 then label = label .. " + " end
        label = label .. '<span weight="bold">' .. o .. '</span>'
      end
    end

    menu[#menu + 1] = { label,
    cmd,
    "/usr/share/icons/Tango/32x32/devices/display.png"}
  end

  return menu
end

-- Touchpad control
local function touchpad_toggle()
  local synclient = io.popen("synclient");
  if synclient then
    for line in synclient:lines() do
      output = line:match("^%s*TouchpadOff%s*=%s*([0-1])%s*")
      if output then
        touchpad_state = output
        break
      end
    end
    synclient:close()
  end

  local label
  if touchpad_state == "1" then 
    awful.util.spawn_with_shell(touchpad.enable)
    label = "Touchpad enabled!"
  else 
    awful.util.spawn_with_shell(touchpad.disable)
    label = "Touchpad disabled!"
  end
  naughty.notify({ text = label,
    timeout = 2,
    screen = mouse.screen, -- Important, not all screens may be visible
    font = "Free Sans 18"
    })
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
		timer = nil,
		cid = nil }
local function xrandr()
   -- Stop any previous timer
   if state.timer then
      state.timer:stop()
      state.timer = nil
   end

   -- Build the list of choices
   if not state.iterator then
      state.iterator = awful.util.table.iterate(menu(),
					function() return true end)
   end

   -- Select one and display the appropriate notification
   local next  = state.iterator()
   local label, action, icon
   if not next then
      label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
      state.iterator = nil
   else
      label, action, icon = unpack(next)
   end
   state.cid = naughty.notify({ text = label,
				icon = icon,
				timeout = 4,
				screen = mouse.screen, -- Important, not all screens may be visible
				font = "Free Sans 18",
				replaces_id = state.cid }).id

   -- Setup the timer
   state.timer = timer { timeout = 4 }
   state.timer:connect_signal("timeout",
			  function()
			     state.timer:stop()
			     state.timer = nil
			     state.iterator = nil
			     if action then
				awful.util.spawn(action, false)
			     end
			  end)
   state.timer:start()
end

-- Separators
spr = wibox.widget.textbox(' ')
first = wibox.widget.textbox('<span font="Tamsyn 4"> </span>')
arrl_pre = wibox.widget.imagebox()
arrl_pre:set_image(beautiful.arrl_lr_pre)
arrl_post = wibox.widget.imagebox()
arrl_post:set_image(beautiful.arrl_lr_post)

-- Layout

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              delay_raise()
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              delay_raise()
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    left_layout:add(arrl_pre)
    left_layout:add(mylayoutbox[s])
    left_layout:add(arrl_post)
    left_layout:add(mypromptbox[s])
    left_layout:add(first)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(first)
    -- right_layout:add(mpdwidget)
    -- right_layout:add(mygmail)
    --right_layout:add(fshwidget)
    right_layout:add(statwidget)
    right_layout:add(netwidget)
    right_layout:add(spr)
    right_layout:add(volumewidget)
    right_layout:add(spr)
    right_layout:add(mytextclock)
    right_layout:add(spr)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

end

-- Mouse Bindings

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))


-- Key bindings
globalkeys = awful.util.table.join(

    -- Capture a screenshot
    awful.key({ modkey, altkey }, "p", function() awful.util.spawn("screenshot",false) end),

    -- Move clients
    awful.key({ modkey,altkey }, "Next",  function () awful.client.moveresize( 1,  1, -2, -2) end),
    awful.key({ modkey,altkey }, "Prior", function () awful.client.moveresize(-1, -1,  2,  2) end),
    awful.key({ modkey,altkey }, "Down",  function () awful.client.moveresize(  0,  1,   0,   0) end),
    awful.key({ modkey,altkey }, "Up",    function () awful.client.moveresize(  0, -1,   0,   0) end),
    awful.key({ modkey,altkey }, "Left",  function () awful.client.moveresize(-1,   0,   0,   0) end),
    awful.key({ modkey,altkey }, "Right", function () awful.client.moveresize( 1,   0,   0,   0) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            delay_raise()
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            delay_raise()
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            delay_raise()
        end),

    -- Standard program
    awful.key({ modkey, "Shift", "Control" }, "l", function () awful.util.spawn("chromium /home/vimal/Desktop/Disappearing-likes.gif" ) end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(file_manager) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)
      naughty.notify({title='Master', text=tostring(awful.tag.getnmaster()), timeout = 1 }) end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)
      naughty.notify({title='Master', text=tostring(awful.tag.getnmaster()), timeout = 1 }) end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)
      naughty.notify({title='Columns', text=tostring(awful.tag.getncol()), timeout = 1 }) end),

    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)
      naughty.notify({title='Columns', text=tostring(awful.tag.getncol()), timeout = 1 }) end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1)
      naughty.notify({title='Layout', text=tostring(awful.layout.getname()), timeout = 1 }) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1)
      naughty.notify({title='Layout', text=tostring(awful.layout.getname()), timeout = 1 }) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",     function () scratch.drop(terminal) end),

    -- Widgets popups
    awful.key({ modkey, altkey }, "c",     function () show_calendar(7) end),
    --awful.key({ modkey, altkey }, "h",     function ()
    --                                            vicious.force({ fshwidget })
    --                                            show_info(7)
    --                                          end),
    
    -- Volume control
    awful.key({ altkey }, "Up", function ()
                                       awful.util.spawn("amixer set Master playback 1%+", false )
                                       vicious.force({ volumewidget })
                                   end),
    awful.key({ altkey }, "Down", function ()
                                       awful.util.spawn("amixer set Master playback 1%-", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ altkey }, "m", function ()
                                       awful.util.spawn("amixer set Master playback toggle", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ altkey, "Control" }, "m",
                                  function ()
                                      awful.util.spawn("amixer set Master playback 100%", false )
                                      vicious.force({ volumewidget })
                                  end),

    -- XF86 Volume control
    awful.key({ }, "XF86AudioRaiseVolume", function ()
                                       awful.util.spawn("amixer set Master playback 1%+", false )
                                       vicious.force({ volumewidget })
                                   end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
                                       awful.util.spawn("amixer set Master playback 1%-", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ }, "XF86AudioMute", function ()
                                       awful.util.spawn("amixer set Master playback toggle", false )
                                       vicious.force({ volumewidget })
                                     end),

    -- Music control
    --[[
    awful.key({ altkey, "Control" }, "Up", function ()
                                              awful.util.spawn( "mpc toggle", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function ()
                                                awful.util.spawn( "mpc stop", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                                awful.util.spawn( "mpc prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function ()
                                                awful.util.spawn( "mpc next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),
                                              ]]

    -- Music control
    --[[
    awful.key({ altkey, "Control" }, "Up", function ()
                                              awful.util.spawn( "cmus-remote --play", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function ()
                                                awful.util.spawn( "cmus-remote --pause", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                                awful.util.spawn( "cmus-remote --prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function ()
                                                awful.util.spawn( "cmus-remote --next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),
                                              ]]
    
    -- Music control (Spotify)
    awful.key({ altkey, "Control" }, "Up", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),
   
    -- Music control
    --[[
    awful.key({ }, "XF86AudioPlay", function ()
                                              awful.util.spawn( "cmus-remote --play", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey }, "XF86AudioPlay", function ()
                                              awful.util.spawn( "cmus-remote --pause", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ }, "XF86AudioStop", function ()
                                                awful.util.spawn( "cmus-remote --stop", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ }, "XF86AudioPrev", function ()
                                                awful.util.spawn( "cmus-remote --prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ }, "XF86AudioNext", function ()
                                                awful.util.spawn( "cmus-remote --next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),
                                                ]]

    -- Music control (Spotify)
    awful.key({ }, "XF86AudioPlay", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ }, "XF86AudioStop", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ }, "XF86AudioPrev", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ }, "XF86AudioNext", function ()
                                              awful.util.spawn( "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.util.spawn( "dwb", false ) end),
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Multiple Monitor control
    awful.key({ altkey, "Shift"}, "m", xrandr),

    -- Monitor brightness
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 5") end),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 5") end),

    -- Touchpad control
    awful.key({ modkey, "Shift"}, "t", touchpad_toggle)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)


-- Rules

awful.rules.rules = {
     -- All clients will match this rule.
     { rule = { },
       properties = { border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = awful.client.focus.filter,
                      keys = clientkeys,
                      buttons = clientbuttons,
	                    size_hints_honor = false
                     }
    },

    { rule = { class = "URxvt" },
      properties = { opacity = 0.95 } }, 

    { rule = { class = "URxvt", instance = "hnb" },
      properties = { opacity = 0.95, tag = tags[1][6] } }, 
    
    { rule = { class = "urxvt", instance = "hnb" },
      properties = { opacity = 0.95, tag = tags[1][6] } }, 

    { rule = { class = "MPlayer" },
      properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

	  { rule = { class = "Gimp" },
     	  properties = { tag = tags[1][5] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },

    { rule = { class = "Transmission-gtk" },
          properties = { tag = tags[1][5] } },

    { rule = { class = "Torrent-search" },
          properties = { tag = tags[1][5] } },
    
    { rule = { class = "Firefox" }, 
          properties = { tag = tags[1][4] } },
    { rule = { class = "Firefox", instance = "Dialog" }, 
          callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},
    
    { rule = { class = "Thunderbird" }, 
          properties = { tag = tags[1][8] } },
    { rule = { class = "Thunderbird", instance = "Dialog" }, 
          callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},
    
    { rule = { class = "Chromium" }, 
          properties = { tag = tags[1][5] } },
    { rule = { class = "Chromium", instance = "Dialog" }, 
          callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},
    
    { rule = { class = "Matlab" }, 
          properties = { tag = tags[1][7] } },
    
    { rule = { class = "Spotify" }, 
          properties = { tag = tags[1][5] } },
    
    { rule = { class = "*", instance = "Dialog" }, 
          callback = function(c) awful.client.movetotag(tags[mouse.screen][awful.tag.getidx()], c) end},

}


-- Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.under_mouse(c)
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

function delay_raise ()
   -- 5 ms ages in computer time, but I won't notice it.
   local raise_timer = timer { timeout = 0.005 }
   raise_timer:connect_signal("timeout",
			 function()
			    if client.focus then
			       client.focus:raise()
			    end
			    raise_timer:stop()
   end)
   raise_timer:start()
end
     
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

