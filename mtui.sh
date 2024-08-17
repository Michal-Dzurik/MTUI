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
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
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

