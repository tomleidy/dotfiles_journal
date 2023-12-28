#!/bin/bash
source ~/.dot/helper/which_os
source ~/.dot/helper/get_wordcount.sh

# Get today's date components
get_title_today() {
    local year=$(date +%Y)
    local month=$(date +%B)
    local day=$(date +%d)
    local weekday=$(date +%A)

    # Remove leading zero from the day if present
    local day=$(echo $day | sed 's/^0*//')
    # Determine the ordinal suffix
    case $day in
        1 | 21 | 31) ordinal="st" ;;
        2 | 22)      ordinal="nd" ;;
        3 | 23)      ordinal="rd" ;;
        *)           ordinal="th" ;;
    esac
    echo "${year}$(date +%m)$(date +%d) ${weekday} the ${day}${ordinal} of ${month}"
}

get_filename_8_weeks_ago() {
    if [ "$OS" = "macOS" ]; then
        local year=$(date -v-8w +%Y)
        local month=$(date -v-8w +%B)
        local day=$(date -v-8w +%d)
        local weekday=$(date -v-8w +%A)
        local day=$(echo $day | sed 's/^0*//')
        case $day in
            1 | 21 | 31) local ordinal="st" ;;
            2 | 22)      local ordinal="nd" ;;
            3 | 23)      local ordinal="rd" ;;
            *)           local ordinal="th" ;;
        esac
        echo "${year}$(date -v-8w +%m)$(date -v-8w +%d) ${weekday} the ${day}${ordinal} of ${month}.txt"
    fi
    # TODO: Windows for 8 weeks ago? date -d '8 weeks ago' +...
}

fix_questions_txt() {
    # Add spaces to lines expecting answers on the same line. VS Code will remove them.
    unspaced_endings=$(grep "$questions_file" -e ":$" | wc -l | tr -d '[:blank:]')
    if [ "$unspaced_endings" -gt 0 ]; then
        temp_file="${questions_file}.tmp"
        sed -e 's/\([:]\)$/\1 /' "$questions_file" > "$temp_file"
        mv "$temp_file" "$questions_file"
    fi
}

update_goal_wordcount() {
    # pass in either MORNINGWORDCOUNT or EVENINGWORDCOUNT, replace it in today's entry with goal word count
    replace_string="$1"

    if [ ! -z "$replace_string" ]; then
        replacement_count=$(grep "$morning_page_file" -e "$replace_string" | wc -l)
        if [ "$replacement_count" -gt 0 ]; then
            current_wordcount=$(get_approximate_ia_writer_wordcount_from_file "$morning_page_file")
            new_wordcount=$((current_wordcount + 750))
            echo "Replacing \"$replace_string\" with \"$new_wordcount\""
            temp_file="${morning_page_file}.tmp"
            sed -e "s/${replace_string}/${new_wordcount}/" "$morning_page_file" > "$temp_file"
            mv -f "$temp_file" "$morning_page_file"
        fi
    fi
}

create_morningpages() {
    # Create today's entry if it doesn't exist
    morning_page_file="${JOURNAL_DIR}/${filename}"
    questions_file="${JOURNAL_DIR}/questions.txt"
    fix_questions_txt
    if [ ! -e "$morning_page_file" ]; then
        echo "Preparing $morning_page_file"
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
        # Open morning pages from 8 weeks ago if they exist
        local review_filename="$(get_filename_8_weeks_ago)"
        review_pathname="${JOURNAL_DIR}/${review_filename}"


    else
        if [ "$(date +%H)" -ge 18 ]; then
            update_goal_wordcount EVENINGWORDCOUNT
        fi
    fi
}


# Construct the filename
title="$(get_title_today)"
filename="${title}.txt"

cur_os=$(which_os)
if [ "$cur_os" = "macOS" ]; then
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
    create_morningpages
    open -a "iA Writer" "$morning_page_file"
    if [ -e "$review_pathname" ]; then
        less "$review_pathname"
    fi
elif [ "$cur_os" = "Windows" ]; then
    JOURNAL_DIR=~/iCloudDrive/27N4MQEA55~pro~writer/Morning\ Pages
    create_morningpages
    '/c/Program Files/iA Writer/iAWriter.exe' "$morning_page_file" &
fi
