#!/bin/bash

# Let user choose a file from /etc
selected_file=$(yad --list --title="Select a file from /etc" \
    --width=600 --height=400 \
    --column="Files in /etc" \
    $(ls /etc) --separator="")

[[ -z "$selected_file" ]] && exit

filepath="/etc/$selected_file"

# If passwd is selected, parse and show as table
if [[ "$selected_file" == "passwd" ]]; then

    # Create an array to hold rows
    rows=()

    while IFS=':' read -r user pass uid gid desc home shell; do
        rows+=("$user" "$uid" "$gid" "$home" "$shell")
    done < "$filepath"

    yad --list --title="/etc/passwd Table View" \
        --width=900 --height=600 \
        --column="Username" \
        --column="UID" \
        --column="GID" \
        --column="Home Directory" \
        --column="Shell" \
        "${rows[@]}"

else
    # For other files, just show content
    yad --text-info --title="File Content: $selected_file" \
        --filename="$filepath" \
        --width=800 --height=600
fi