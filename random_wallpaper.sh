#!/bin/bash
wallpaper_dir="/home/luytbq/Downloads/wallpaper"

wallpaper_files=($wallpaper_dir/*)
wallpaper_count=${#wallpaper_files[@]}
random_index=$((RANDOM % wallpaper_count))
wallpaper=${wallpaper_files[$random_index]}
echo New wallpaper: $wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"

echo $DIR