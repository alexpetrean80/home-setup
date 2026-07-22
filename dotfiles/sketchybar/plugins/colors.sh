#!/usr/bin/env bash
# Catppuccin Mocha — sketchybar uses 0xAARRGGBB.
export BAR=0xf01e1e2e     # base @ ~94% for the blur to show through
export BASE=0xff1e1e2e
export MANTLE=0xff181825
export CRUST=0xff11111b
export TEXT=0xffcdd6f4
export SUBTEXT0=0xffa6adc8
export SURFACE0=0xff313244
export SURFACE1=0xff45475a
export SURFACE2=0xff585b70
export BLUE=0xff89b4fa
export LAVENDER=0xffb4befe
export SAPPHIRE=0xff74c7ec
export TEAL=0xff94e2d5
export GREEN=0xffa6e3a1
export YELLOW=0xfff9e2af
export PEACH=0xfffab387
export MAROON=0xffeba0ac
export RED=0xfff38ba8
export MAUVE=0xffcba6f7
export TRANSPARENT=0x00000000

# Number of left islands to create — one per sketchybar display index. A bracket
# cannot span items pinned to different displays, so each display owns a separate
# item set (apple + workspace pills + app label) pinned via display=<sb>. Sourced
# by both sketchybarrc (item/bracket creation) and spaces.sh (the controller).
# Set to the most monitors you'll ever attach; items pinned to an absent display
# just don't draw, so over-provisioning is free.
export MAX_DISPLAYS=3

# Nerd Font glyphs (JetBrainsMono Nerd Font). Emitted as raw UTF-8 bytes via
# printf so they survive editing — literal PUA chars get stripped in transit.
# bash 3.2's printf supports \xHH (not \u), so use byte sequences.
export ICON_APPLE=$(printf '\xef\x85\xb9')      # nf-fa-apple      U+F179
export ICON_CLOCK=$(printf '\xef\x80\x97')      # nf-fa-clock_o    U+F017
export ICON_CPU=$(printf '\xef\x8b\x9b')        # nf-fa-microchip  U+F2DB
export ICON_MEM=$(printf '\xf3\xb0\x8d\x9b')     # nf-md-memory     U+F035B (fa-memory U+F538 absent from this font)
export ICON_WIFI=$(printf '\xef\x87\xab')       # nf-fa-wifi       U+F1EB
export ICON_BELL=$(printf '\xef\x83\xb3')       # nf-fa-bell       U+F0F3
export ICON_BELL_OFF=$(printf '\xef\x87\xb6')   # nf-fa-bell_slash U+F1F6
export ICON_BAT_FULL=$(printf '\xef\x89\x80')   # nf-fa-battery_4  U+F240
export ICON_BAT_3=$(printf '\xef\x89\x81')      # nf-fa-battery_3  U+F241
export ICON_BAT_HALF=$(printf '\xef\x89\x82')   # nf-fa-battery_2  U+F242
export ICON_BAT_1=$(printf '\xef\x89\x83')      # nf-fa-battery_1  U+F243
export ICON_BAT_EMPTY=$(printf '\xef\x89\x84')  # nf-fa-battery_0  U+F244
export ICON_CHARGE=$(printf '\xef\x83\xa7')     # nf-fa-bolt       U+F0E7
export ICON_KEYS=$(printf '\xef\x84\x9c')       # nf-fa-keyboard_o U+F11C

# Weather glyphs (nf-md-weather_*). Condition text from wttr.in is mapped to
# one of these in weather.sh; sunny has a night variant for after-dark hours.
export ICON_WEATHER_SUNNY=$(printf '\xf3\xb0\x96\x99')   # nf-md-weather_sunny         U+F0599
export ICON_WEATHER_NIGHT=$(printf '\xf3\xb0\x96\x94')   # nf-md-weather_night         U+F0594
export ICON_WEATHER_PARTLY=$(printf '\xf3\xb0\x96\x95')  # nf-md-weather_partly_cloudy U+F0595
export ICON_WEATHER_CLOUDY=$(printf '\xf3\xb0\x96\x90')  # nf-md-weather_cloudy        U+F0590
export ICON_WEATHER_RAIN=$(printf '\xf3\xb0\x96\x97')    # nf-md-weather_rainy         U+F0597
export ICON_WEATHER_POUR=$(printf '\xf3\xb0\x96\x96')    # nf-md-weather_pouring       U+F0596
export ICON_WEATHER_SNOW=$(printf '\xf3\xb0\x96\x98')    # nf-md-weather_snowy         U+F0598
export ICON_WEATHER_FOG=$(printf '\xf3\xb0\x96\x91')     # nf-md-weather_fog           U+F0591
export ICON_WEATHER_STORM=$(printf '\xf3\xb0\x96\x93')   # nf-md-weather_lightning     U+F0593

# Per-workspace app glyphs (assigned workspaces show these instead of a number;
# other occupied workspaces show a dot).
export WS_ICON_1=$(printf '\xef\x89\xa9')          # firefox   (browser / Zen)
export WS_ICON_2=$(printf '\xef\x83\xa0')          # envelope  (mail)
export WS_ICON_3=$(printf '\xef\x84\xa0')          # terminal
export WS_ICON_4=$(printf '\xf3\xb0\xbb\xbf')      # kanban    (Linear)
export WS_ICON_7=$(printf '\xef\x86\x98')          # slack
export WS_DOT=$(printf '\xef\x84\x91')             # filled circle (other occupied)
