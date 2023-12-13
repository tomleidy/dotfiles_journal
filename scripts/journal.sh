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


get_wordcount_from_file() {
    # replace characters with space
    local non_word_strip1=$(sed -e 's/[_:\>\<\/]/ /g' -e 's/[A-Za-z]\/[A-Za-z]/ /g' "$morning_page_file")

    # remove characters
    local non_word_strip2=$(echo $non_word_strip1 | sed -e 's/[&—-]//g' )
    # remove preceding spaces
    local non_word_strip3=$(echo $non_word_strip2 | sed -e 's/ […\?]/…/g')

    local non_word_strip5="$non_word_strip3"
    local wordcount=$(echo $non_word_strip5 | wc -w | tr -d '[:blank:]')

    echo $wordcount
}

update_goal_wordcount() {
    # pass either MORNINGWORDCOUNT or EVENINGWORDCOUNT
    replace_string="$1"

    if [ ! -z "$replace_string" ]; then
        replacement_count=$(grep "$morning_page_file" -e "$replace_string" | wc -l)
        if [ "$replacement_count" -gt 0 ]; then
            current_wordcount=$(get_wordcount_from_file)
            new_wordcount=$((current_wordcount + 750))
            echo "Replacing \"$replace_string\" with \"$new_wordcount\""
            sed -i $OS_ARGUMENT -e "s/${replace_string}/${new_wordcount}/" "$morning_page_file"
            temp_file="${morning_page_file}${OS_ARGUMENT}"
            if [ -e "$temp_file" ]; then
                # to deal with macOS sed / OS_ARGUMENT shenanigans
                rm "$temp_file"
            fi
        fi
    fi
}

create_morningpages() {
    # Create today's entry if it doesn't exist
    morning_page_file="${JOURNAL_DIR}/${filename}"
    questions_file="${JOURNAL_DIR}/questions.txt"
    if [ ! -e "$morning_page_file" ]; then
        echo "$morning_page_file"
        echo $title >> "$morning_page_file"
        echo "#MorningPages" >> "$morning_page_file"
        echo >> "$morning_page_file"
        # Add questions if they exist
        if [ -e "$questions_file" ]; then
            echo >> "$morning_page_file"
            echo >> "$morning_page_file"
            cat "$questions_file" >> "$morning_page_file"
            update_goal_wordcount MORNINGWORDCOUNT
            sleep 1
        fi
    else
        if [ "$(date +%H)" -ge 18 ]; then
            update_goal_wordcount EVENINGWORDCOUNT
        fi
    fi
}

title="${year}$(date +%m)$(date +%d) ${weekday} the ${day}${ordinal} of ${month}"
filename=${title}.txt
cur_os=$(which_os)
if [ "$cur_os" = "macOS" ]; then
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
    OS_ARGUMENT=".tmp"
    create_morningpages
    open -a "iA Writer" "$morning_page_file"
elif [ "$cur_os" = "Windows" ]; then
    JOURNAL_DIR=~/iCloudDrive/27N4MQEA55~pro~writer/Morning\ Pages
    create_morningpages
    '/c/Program Files/iA Writer/iAWriter.exe' "$morning_page_file" &
fi
