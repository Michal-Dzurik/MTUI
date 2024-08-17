#!/bin/sh

source 'config/colors.sh'

# Test is an equivalend for output that 
# laravel test give outputs
test(){    
    # TODO:Implement
    echo 'test'
}

# Basic loader animation
loader(){    
    hide_cursor

    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    local length=5

    text=$(parse_arg --text "$@")
    color=$(parse_arg --color "$@")
    textAfter=$(parse_arg --text-after "$@")
    colorAfter=$(parse_arg --color-after "$@")

    if [[ -n "$text" ]]; then 
        length=$((length + ${#text}))
    fi

    if [[ -n "$color" ]]; then 
        printf "$color"
    fi

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "[%c] " "$spinstr"
        if [[ -n "$text" ]]; then 
            printf $text
        fi
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        print '\b' $length

    done
    
    # Based on string length it prints empty spaces
    # so after the printing there are no ghosts
    printf "\r%*s\r" "$length" ""

    if [[ -n "$colorAfter" ]]; then 
        printf "$colorAfter"
    fi

    if [[ -n "$textAfter" ]]; then 
        printf "$textAfter\n"
    fi

    if [[ -n "$color" ]]; then 
        printf $RESET
    fi
    show_cursor
}

# Progress bar
progress(){    
    # TODO:Implement
    echo 'progress'
}

### USER INPUT VIEWS

# UI list of options and the 
# ability to select multiple
# choicees
option_select(){
    # TODO:Implement
    echo 'option_select'
}

# UI list of options and the 
# ability to select on choice
radio_select(){
    # TODO:Implement
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
    key="$1"
    shift

    while [[ $# -gt 0 ]]; do
        current_key="$1"
        if [[ "$current_key" == "$key" ]]; then
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
    for ((i=0; i < $2; i++)); do
        printf $1
    done
}