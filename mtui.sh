#!/bin/sh

source 'config/colors.sh'

# Basic loader animation
loader(){    
    hide_cursor

    local _pid=$!
    local _delay=0.1
    local _spinstr='|/-\'
    local _length=5

    local _text=$(parse_arg --text "$@")
    local _color=$(parse_arg --color "$@")
    local _textAfter=$(parse_arg --text-after "$@")
    local _colorAfter=$(parse_arg --color-after "$@")

    if [[ -n "$_text" ]]; then 
        _length=$((_length + ${#_text}))
    fi

    if [[ -n "$_color" ]]; then 
        printf "$_color"
    fi

    while [ "$(ps a | awk '{print $1}' | grep $_pid)" ]; do
        local _temp=${_spinstr#?}
        printf "[%c] " "$_spinstr"
        if [[ -n "$_text" ]]; then 
            printf $_text
        fi
        _spinstr=$_temp${_spinstr%"$_temp"}
        sleep $_delay
        print '\b' $_length
    done
    
    # Based on string length it prints empty spaces
    # so after the printing there are no ghosts
    printf "\r%*s\r" "$_length" ""

    if [[ -n "$_colorAfter" ]]; then 
        printf "$_colorAfter"
    fi

    if [[ -n "$_textAfter" ]]; then 
        printf "$_textAfter\n"
    fi

    if [[ -n "$_color" ]]; then 
        printf $RESET
    fi
    show_cursor
}

# Progress bar
init_progress_bar() {
    _width=$(parse_arg --width "$@")
    _color=$(parse_arg --color "$@")

    export PROGRESS_BAR_PROGRESS=0
    export PROGRESS_BAR_TOTAL=$1

    if [[ -n $_width ]]; then
        export PROGRESS_BAR_WIDTH=$_width
    else 
        export PROGRESS_BAR_WIDTH=50
    fi

    if [[ -n $_color ]]; then
        export PROGRESS_BAR_COLOR=$_color
    else 
        export PROGRESS_BAR_WIDTH=$WHITE
    fi
}

advance_progress_bar(){
    hide_cursor

    export PROGRESS_BAR_PROGRESS=$((PROGRESS_BAR_PROGRESS + 1))

    local _length=$((7 + PROGRESS_BAR_WIDTH))

    local _percent=$((PROGRESS_BAR_PROGRESS * 100 / PROGRESS_BAR_TOTAL))
    if (( $_percent >= 100 )); then
        printf "\r%*s\r" "$_length" ""
        show_cursor
        return
    fi

    local _completed=$((_percent * PROGRESS_BAR_WIDTH / 100))
    local _remaining=$((PROGRESS_BAR_WIDTH - _completed))
    printf "$PROGRESS_BAR_COLOR["
    for ((_completedCounter = 0; _completedCounter < _completed; _completedCounter++)); do
        printf "#"
    done
    for ((_remainingCounter = 0; _remainingCounter < _remaining; _remainingCounter++)); do
        printf "-"
    done
    printf "] %d%%" "$_percent"

    # Cleanup
    print '\b' $_length

    printf $RESET
    show_cursor
}

### USER INPUT VIEWS

# UI list of options and the 
# ability to select multiple
# choices
option_select(){
    # TODO: Implement
    echo 'option_select'
}

# UI list of options and the 
# ability to select one choice
radio_select(){
    # TODO: Implement
    echo 'radio_select'
}

### HELPER FUNCTIONS
# CURSOR

hide_cursor() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        tput civis
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo -e "\e[?25l"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

show_cursor() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        tput cnorm
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo -e "\e[?25h"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Parser

parse_arg() {
    _key="$1"
    shift

    while [[ $# -gt 0 ]]; do
        _current_key="$1"
        if [[ "$_current_key" == "$_key" ]]; then
            shift
            if [[ $# -gt 0 ]]; then
                echo "$1"
            else
                echo ""  # No value available
            fi
            return 0
        fi
        shift
    done

    echo ""  # Key not found
    return 1
}

# Print
# Usage => print 'a' 10
# The usage will print character a 10 times 
print(){
    for ((_printCounter=0; _printCounter < $2; _printCounter++)); do
        printf $1
    done
}
