#!/bin/bash

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

# macOS
if [ "$(which_os)" = "macOS" ]; then
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
    path_and_file="${JOURNAL_DIR}/${filename}"
    if [ ! -e "$path_and_file" ]; then
        echo $title >> "$path_and_file"
        echo "#MorningPages" >> "$path_and_file"
        if [ -e "$questions" ]; then
            questions="${JOURNAL_DIR}/questions.txt"
            word_count1=$(wc -w < "$path_and_file")
            word_count2=$(wc -w < "$questions")
            total_word_count=$((word_count1 + word_count2 + 753))
            echo "Goal WC:$total_word_count" >> "$path_and_file"
            echo >> "$path_and_file"
            cat "$questions" >> "$path_and_file"
        fi
    fi
    open -a "iA Writer" "$path_and_file"
fi