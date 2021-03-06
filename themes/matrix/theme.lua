-- matrix, awesome3 theme, by ShdB --

--{{{ Main
local awful = require("awful")
awful.util = require("awful.util")

theme = {}

home          = os.getenv("HOME")
config        = awful.util.getdir("config")
shared        = "/usr/share/awesome"
if not awful.util.file_readable(shared .. "/icons/awesome16.png") then
    shared    = "/usr/share/local/awesome"
end
sharedicons   = shared .. "/icons"
sharedthemes  = shared .. "/themes"
themes        = config .. "/themes"
themename     = "/matrix"
if not awful.util.file_readable(themes .. themename .. "/theme.lua") then
	themes = sharedthemes
end
themedir      = themes .. themename

wallpaper1    = themes .. "/ArchGreenMatrix.png"
wallpaper2    = themes .. "/ArchGreen.png"
wallpaper3    = themes .. "/MatrixGNU.png"
wallpaper4    = themedir .. "/background.jpg"
wallpaper5    = themedir .. "/background.png"
wallpaper6    = sharedthemes .. "/zenburn/zenburn-background.png"
wallpaper7    = sharedthemes .. "/default/background.png"
wpscript      = home .. "/.wallpaper"

if awful.util.file_readable(wallpaper1) then
	theme.wallpaper = wallpaper1
elseif awful.util.file_readable(wallpaper2) then
	theme.wallpaper = wallpaper2
elseif awful.util.file_readable(wpscript) then
	theme.wallpaper_cmd = { "sh " .. wpscript }
elseif awful.util.file_readable(wallpaper3) then
	theme.wallpaper = wallpaper3
else
	theme.wallpaper = wallpaper4
end

if awful.util.file_readable(config .. "/vain/init.lua") then
    theme.useless_gap_width  = "3"
end
--}}}

theme.font          = "Inconsolata 12"

theme.bg_normal     = "#171717"
theme.bg_focus      = "#474747"
theme.bg_urgent     = "#00ff00"
theme.bg_minimize   = "#ffffff"

theme.hilight       = "#ffcc44"

theme.fg_normal     = "#449900"
theme.fg_focus      = "#66FF00"
theme.fg_urgent     = "#ff0000"

theme.graph_bg      = "#333333"
theme.graph_center  = "#779900"
theme.graph_end     = "#ff9900"

theme.border_width  = "1"
theme.border_normal = "#338000"
theme.border_focus  = "#66FF00"
theme.border_marked = "#66FF00"

theme.menu_height   = "15"
theme.menu_width    = "120"

theme.battery = themes .. "/icons/him/battery.png"
theme.volume = themes .. "/icons/him/volume.png"
theme.muted = themes .. "/icons/him/muted.png"
theme.cpu = themes .. "/icons/him/cpu.png"
theme.temp = themes .. "/icons/him/temp.png"
theme.mail = themes .. "/icons/him/mail.png"
theme.mem = themes .. "/icons/him/mem.png"
theme.wireless = themes .. "/icons/him/wireless.png"
theme.network = themes .. "/icons/him/network.png"
theme.mpd_play = themes .. "/icons/him/mpd_play.png"
theme.mpd_pause = themes .. "/icons/him/mpd_pause.png"
theme.mpd_stop = themes .. "/icons/him/mpd_stop.png"

theme.layout_fairh = themedir .. "/layouts/fairh.png"
theme.layout_fairv = themedir .. "/layouts/fairv.png"
theme.layout_floating = themedir .. "/layouts/floating.png"
theme.layout_max = themedir .. "/layouts/max.png"
theme.layout_spiral = themedir .. "../default/layouts/spiralw.png"
theme.layout_tilebottom = themedir .. "/layouts/tilebottom.png"
theme.layout_tile = themedir .. "/layouts/tile.png"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
--theme.taglist_squares = "true"

theme.taglist_squares_sel   = sharedthemes .. "/default/taglist/squarefw.png"
theme.taglist_squares_unsel = sharedthemes .. "/default/taglist/squarew.png"

-- theme.tasklist_floating_icon = sharedthemes .. "/default/tasklist/floatingw.png"
theme.tasklist_floating_icon = themedir .. "/tasklist/floatingw.png"

-- Define the image to load
theme.titlebar_close_button_normal = sharedthemes .. "/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = sharedthemes .. "/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = sharedthemes .. "/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = sharedthemes .. "/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = sharedthemes .. "/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = sharedthemes .. "/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = sharedthemes .. "/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = sharedthemes .. "/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = sharedthemes .. "/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = sharedthemes .. "/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = sharedthemes .. "/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = sharedthemes .. "/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = sharedthemes .. "/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = sharedthemes .. "/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = sharedthemes .. "/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = sharedthemes .. "/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = sharedthemes .. "/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = sharedthemes .. "/default/titlebar/maximized_focus_active.png"

-- You can use your own layout icons like this:
theme.layout_fairh = sharedthemes .. "/default/layouts/fairhw.png"
theme.layout_fairv = sharedthemes .. "/default/layouts/fairvw.png"
theme.layout_floating  = sharedthemes .. "/default/layouts/floatingw.png"
theme.layout_magnifier = sharedthemes .. "/default/layouts/magnifierw.png"
theme.layout_max = sharedthemes .. "/default/layouts/maxw.png"
theme.layout_fullscreen = sharedthemes .. "/default/layouts/fullscreenw.png"
theme.layout_tilebottom = sharedthemes .. "/default/layouts/tilebottomw.png"
theme.layout_tileleft   = sharedthemes .. "/default/layouts/tileleftw.png"
theme.layout_tile = sharedthemes .. "/default/layouts/tilew.png"
theme.layout_tiletop = sharedthemes .. "/default/layouts/tiletopw.png"
theme.layout_spiral  = sharedthemes .. "/default/layouts/spiralw.png"
theme.layout_dwindle = sharedthemes .. "/default/layouts/dwindlew.png"

-- theme.awesome_icon = themedir .. "/awesome16.png"

return theme
