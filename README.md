# dotfiles journal.sh
## Description:
This project is born of my journey with "The Artist's Way." After working through it years ago, I journal daily as part of maintaining Morning Pages. After years of consistent practice and manually typing the date (e.g. "20240126 Friday the 26th of January"), and copy/pasting in questions/prompts to consider, I decided to automate the process. I still feel delight whenever I type "journal" at the terminal and iA Writer loads a text file prepared exactly how I want it. What's not to love about a little hit of dopamine before journaling?

This is currently the most involved and frequently used script from my ~/.dotfiles/ directory (if you're curious about that? check out https://dotfiles.github.io/tutorials/ for inspiration).

## Key Features:
### Automated Date and Information Insertion: 
Before each journaling session, the script creates the file and automatically adds the current date and other predefined information (from "questions.txt" in the Morning Pages directory)
### Dynamic Goal Word Count:
The application calculates a target word count for each entry, determined by the length of the templated content.
### Word Count Accuracy:
Special attention has been paid to replicate word count accuracy aligns with my favorite text editor, iA Writer on macOS. It has been exactly accurate for some time now, but it's extremely likely I'll find a new exception now that I've said this in public.
### 8 Week Review:
Opens the entry from 8 weeks ago (if it exists) using 'less' at the terminal. For reviewing after writing today's entry. This is part of the Artist's Way process that I had been neglecting up until recently, and it's allowed me increased awareness over what's changing/changed in my life over the past couple months.
### "Evening Pages":
Insufficiently satisfied with journaling once per day, I added functionality for "Evening Pages," updating the word count yet again for getting things out of my mind at the end of the day. This has helped facilitate evening routines, next day planning, and the quality of my sleep, as I already got the thoughts out of my head.
