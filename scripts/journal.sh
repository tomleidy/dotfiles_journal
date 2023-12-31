#!/bin/bash

which_os() {
    local OS=$(uname -s)
    case "$OS" in
        CYGWIN*|MINGW*|MSYS*)
            echo "Windows"
            ;;
        Darwin)
            echo "macOS"
            ;;
        Linux)
            echo "Linux"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

get_approximate_ia_writer_wordcount_from_file() {
    local non_word_strip1=$(sed -e 's/[_:\>\<\/]/ /g' \
                                -e 's/[A-Za-z]\/[A-Za-z]/ /g' \
                                -e 's/[&—-]//g' \
                                -e 's/\([0-9]\)\’\([[:alpha:]]\)/\1 \2/g' \
                                -e 's/ […\?]/…/g' \
                                -e 's/\([[:alnum:]]\)\.\([[:alnum:]]\)/\1 \2/g' "$1")
    local wordcount=$(echo $non_word_strip1 | wc -w | tr -d '[:blank:]')
    echo $wordcount
}


EVENING_HOUR_STARTS=18

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

open_8_weeks_ago_less() {
    # Open morning pages from 8 weeks ago if they exist
    local review_filename="$(get_filename_8_weeks_ago)"
    review_pathname="${JOURNAL_DIR}/${review_filename}"
    if [ -e "$review_pathname" ]; then
        less "$review_pathname"
    fi
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

add_questions_to_morningpages() {
    if [ -e "$questions_file" ]; then
        echo >> "$morning_page_file"
        echo >> "$morning_page_file"
        cat "$questions_file" >> "$morning_page_file"
    fi
}
add_date_and_title_to_morningpages() {
    echo "Preparing $morning_page_file"
    echo $title >> "$morning_page_file"
    echo "#MorningPages" >> "$morning_page_file"
    echo >> "$morning_page_file"
}
create_morningpages() {
    if [ ! -e "$morning_page_file" ]; then
        add_date_and_title_to_morningpages
        add_questions_to_morningpages
        update_goal_wordcount MORNINGWORDCOUNT
    fi
    if [ -e "$morning_page_file" ] && [ "$(date +%H)" -ge 18 ]; then
        update_goal_wordcount EVENINGWORDCOUNT
    fi
    sleep 1
}

set_today_file_and_path() {
    # TODO: reduce the number of variables we need to set external to this function
    title="$(get_title_today)"
    filename="${title}.txt"
    morning_page_file="${JOURNAL_DIR}/${filename}"
    questions_file="${JOURNAL_DIR}/questions.txt"
}

open_ia_writer_mac() {
    open -a "iA Writer" "$morning_page_file"
}
open_ia_writer_win() {
    '/c/Program Files/iA Writer/iAWriter.exe' "$morning_page_file" &
}

OS=$(which_os)
if [ "$OS" = "macOS" ]; then
    # TODO: find better place for JOURNAL_DIR determination?
    JOURNAL_DIR=~/Library/Mobile\ Documents/27N4MQEA55~pro~writer/Documents/Morning\ Pages
    set_today_file_and_path
    fix_questions_txt
    create_morningpages
    open_ia_writer_mac
    open_8_weeks_ago_less

elif [ "$OS" = "Windows" ]; then
    JOURNAL_DIR=~/iCloudDrive/27N4MQEA55~pro~writer/Morning\ Pages
    create_morningpages
    open_ia_writer_win
fi
