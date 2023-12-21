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

# TODO: determine the difference between iA Writer word count on Windows and macOS.
# The above correlates to macOS (most of the time?), and missed 10 words on on today's base word count
# after adding questions.txt.