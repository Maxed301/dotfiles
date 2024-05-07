#!/usr/bin/env bash
#
# shellcheck disable=SC2005
plugin_datetime_icon=$(get_tmux_option "@theme_plugin_datetime_icon" "  ")
plugin_datetime_accent_color=$(get_tmux_option "@theme_plugin_datetime_accent_color" "time")
plugin_datetime_accent_color_icon=$(get_tmux_option "@theme_plugin_datetime_accent_color_icon" "icon")

#date
plugin_datetime_accent_color_date=$(get_tmux_option "@theme_plugin_datetime_accent_color" "date")

# https://man7.org/linux/man-pages/man1/date.1.html
plugin_time_format=$(get_tmux_option "@theme_plugin_datetime_format" " %R %A ")
plugin_date_format=$(get_tmux_option "@theme_plugin_datetime_format" " %d %b %Y ")

function load_date_plugin() {
  echo "${plugin_date_format}"
} 
function load_time_plugin() {
  echo "${plugin_time_format}"
} 

export plugin_datetime_icon plugin_datetime_accent_color plugin_datetime_accent_color_icon plugin_datetime_accent_color_date
