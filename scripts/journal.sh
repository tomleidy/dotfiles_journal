#!/bin/bash
source ~/.dot/functions

# Get today's date components
year=$(date +%Y)
month=$(date +%B)
day=$(date +%d)
weekday=$(date +%A)

# Remove leading zero from the day if present
day=$(echo $day | sed 's/^0*//')

# Determine the ordinal suffix
case $day in
    1 | 21 | 31) ordinal="st" ;;
    2 | 22)      ordinal="nd" ;;
    3 | 23)      ordinal="rd" ;;
    *)           ordinal="th" ;;
esac

# Construct the filename
title="${year}$(date +%m)$(date +%d) ${weekday} the ${day}${ordinal} of ${month}"
filename=${title}.txt

cur_os=$(which_os)
# macOS
if [ "$cur_os" = "macOS" ]; then
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
    editor_command='open -a "iA Writer"'
elif [ "$cur_os" = "Windows" ]; then
    JOURNAL_DIR=~/iCloudDrive/27N4MQEA55~pro~writer/Morning\ Pages
    editor_command='/c/Program Files/iA Writer/iAWriter.exe'
fi
path_and_file="${JOURNAL_DIR}/${filename}"
questions="${JOURNAL_DIR}/questions.txt"

# create file
if [ ! -e "$path_and_file" ]; then
    echo $title >> "$path_and_file"
    echo "#MorningPages" >> "$path_and_file"
    echo >> "$path_and_file"

    # add questions if they exist
    if [ -e "$questions" ]; then
        echo "$questions"
        word_count1=$(wc -w < "$path_and_file")
        word_count2=$(cat "$questions" | sed s/^-// | wc -w)
        total_word_count=$((word_count1 + word_count2 + 753))
        echo >> "$path_and_file"
        echo >> "$path_and_file"
        echo "Goal WC: $total_word_count" >> "$path_and_file"
        cat "$questions" >> "$path_and_file"
        sleep 1
    fi
fi
echo "$path_and_file"

if [ "$cur_os" = "macOS" ]; then
    open -a "iA Writer" "$path_and_file"
elif [ "$cur_os" = "Windows" ]; then
    '/c/Program Files/iA Writer/iAWriter.exe' "$path_and_file" &
fi