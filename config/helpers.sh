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
 
# Parser for arguments with no array in it
#
# @param $1 array
# @return mixed 
_parse_arg() {
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