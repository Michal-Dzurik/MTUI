###--------HELPER FUNCTIONS--------###

# Hides the cursor depending on OS
#
# @return void 
_hide_cursor() {
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

# Shows the cursor depending on OS
#
# @return void 
_show_cursor() {
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


# Print n times
#
# @param $1 char
# @param $2 int
# @return char 
_print(){
    local _char=$1
    local _count=$2
    for ((_printCounter=0; _printCounter < _count; _printCounter++)); do
        printf "$_char"
    done
}

# Get's a character and convert it into the
# form we need
#
# @return char
_get_char(){
    # Disable terminal echo and buffering
    stty -echo -icanon time 0 min 1

    # Read a single character
    _char=$(dd bs=1 count=1 2>/dev/null)

    # Restore terminal settings
    stty echo icanon

    # Converting to the correct form
    if [[ $_char == " " ]]; then
        echo "\s"
    else 
        echo $_char
    fi
}


_clear_line(){
    printf $CURSOR_CLEAR_LINE
}

_cursor_save(){
    printf $CURSOR_SAVE_POSITION
}

_cursor_restore(){
    printf $CURSOR_RESTORE_POSITION
}

# Printing 

# Callback for radio output
_radio_output_print(){
    if [[ $SELECTED -gt -1 && " $SELECTED " == *" ${_i} "* ]]; then
        printf "[x]"    
    else 
        printf "[ ]"  
    fi
}

# Callback for option output
_option_output_print(){
    if [[ " ${_selected[*]} " == *" ${_i} "* ]]; then
        printf "[x]"    
    else 
        printf "[ ]"  
    fi
}

# Prints out menu of options
#
# @param $1 firstIteratedOutput
# @param $2 callback for dispalying mark or endidng the cycle
_print_menu() {
    local _callback=$2
    if [ "$1" = "1"  ]; then
        _cursor_restore
    fi
    for _i in "${!_options[@]}"; do
        [[ $_i -ne 0 ]] && printf "\n"
        printf $_color

        $_callback
        
        if [[ $_i -eq $_cursor ]]; then
            printf "${_highlightColor}"
        fi


        printf " ${_options[_i]}"
        printf $RESET
    done
}