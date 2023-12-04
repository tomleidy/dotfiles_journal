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


# Determine paths based on OS
if [ "$cur_os" = "macOS" ]; then
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
elif [ "$cur_os" = "Windows" ]; then
    JOURNAL_DIR=~/iCloudDrive/27N4MQEA55~pro~writer/Morning\ Pages
fi
morning_page_file="${JOURNAL_DIR}/${filename}"
questions_file="${JOURNAL_DIR}/questions.txt"

# Create today's entry if it doesn't exist
if [ ! -e "$morning_page_file" ]; then
    echo $title >> "$morning_page_file"
    echo "#MorningPages" >> "$morning_page_file"
    echo >> "$morning_page_file"

    # Add questions if they exist
    if [ -e "$questions_file" ]; then
        echo "$questions_file"
        word_count1=$(wc -w < "$morning_page_file")
        word_count2=$(cat "$questions_file" | sed s/^-// | wc -w)
        total_word_count=$((word_count1 + word_count2 + 753))
        echo >> "$morning_page_file"
        echo >> "$morning_page_file"
        echo "Goal WC: $total_word_count" >> "$morning_page_file"
        cat "$questions_file" >> "$morning_page_file"
        sleep 1
    fi
fi

# Execute iA Writer based on OS
if [ "$cur_os" = "macOS" ]; then
    open -a "iA Writer" "$morning_page_file"
elif [ "$cur_os" = "Windows" ]; then
    '/c/Program Files/iA Writer/iAWriter.exe' "$morning_page_file" &
fi