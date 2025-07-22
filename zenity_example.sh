#!/bin/bash

# Generate list of files in /etc (excluding directories)
files=()
while IFS= read -r -d $'\0' file; do
    files+=("$(basename "$file")")
done < <(find /etc -maxdepth 1 -type f -print0)

# Let user choose a file from /etc
selected_file=$(zenity --list \
    --title="Select a file from /etc" \
    --width=600 --height=400 \
    --column="Files in /etc" \
    "${files[@]}")

[[ -z "$selected_file" ]] && exit

filepath="/etc/$selected_file"

# If passwd is selected, parse and show as table
if [[ "$selected_file" == "passwd" ]]; then
    # Prepare temporary file for table data
    tmpfile=$(mktemp)
    
    # Parse passwd and format as table
    awk -F: '{print $1 "\n" $3 "\n" $4 "\n" $6 "\n" $7}' /etc/passwd > "$tmpfile"
    
    # Display in zenity list
    zenity --list \
        --title="/etc/passwd Table View" \
        --width=900 --height=600 \
        --column="Username" \
        --column="UID" \
        --column="GID" \
        --column="Home Directory" \
        --column="Shell" \
        $(<"$tmpfile")
    
    rm "$tmpfile"
else
    # For other files, show content
    zenity --text-info \
        --title="File Content: $selected_file" \
        --filename="$filepath" \
        --width=800 --height=600
fi