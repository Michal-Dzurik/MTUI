source mtui.sh

request() {
    curl "https://www.google.com"
}

tput civis
request & loader
tput cnorm