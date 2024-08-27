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

_cursor_up(){
    printf $CURSOR_UP
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
# @return void
_print_menu() {
    local _callback=$2
    
    if [ "$1" = "1"  ]; then
        _cursor_restore
    else 
        _cursor_save
    fi

    _apply_padding $_padding_vertical 0

    for _i in "${!_options[@]}"; do
        [[ $_i -ne 0 ]] && printf "\n"

        _apply_padding 0 $_padding_horizontal
        printf $_color

        $_callback
        
        if [[ $_i -eq $_cursor ]]; then
            printf "$_highlight_color"
        fi

        printf " ${_options[_i]}"
        printf $RESET
    done

    _apply_padding $_padding_vertical 0
}

# Gets a json property
#
# @param $1 filePath
# @param $2 variable name
# @return eighter a value if string or value of variable name that string represents
_json_get(){
    _value=$(grep -o "\"$2\": \".*\"" "$1" | sed "s/\"$2\": \"\(.*\)\"/\1/")
    _varValue="${!_value}"

    if [[ -n $_varValue ]]; then 
        _re='^[0-9]+$'
        if ! [[ $_value =~ $_re ]] ; then
            echo $_varValue
            return 
        fi
    fi
        
    echo $_value
}

# Applies paddings
#
# @param $1 verticalPadding
# @param $2 horizontalPadding
# @return void
_apply_padding(){
    if [[ -n $1 ]]; then
        _print "\n" $1 
    fi

    _clear_line

    if [[ -n $2 ]]; then
        printf '%*s' $2 ''   
    fi
}


_input_disable(){
    stty -echo -icanon time 0 min 0
}

_input_enable(){
    stty echo icanon
}