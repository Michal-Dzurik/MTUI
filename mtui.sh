#!/bin/sh

source 'config/colors.sh'
source 'config/constants.sh'

# Basic loader animation
loader(){    
    _hide_cursor
    _cursor_save

    local _pid=$!
    local _delay=0.1
    local _spinstr='|/-\'

    local _text=$(_parse_arg --text "$@")
    local _color=$(_parse_arg --color "$@")
    local _textAfter=$(_parse_arg --text-after "$@")
    local _colorAfter=$(_parse_arg --color-after "$@")


    while [ "$(ps a | awk '{print $1}' | grep $_pid)" ]; do
        if [[ -n "$_color" ]]; then 
            printf "$_color"
        fi

        local _temp=${_spinstr#?}
        printf "[%c] " "$_spinstr"
        if [[ -n "$_text" ]]; then 
            printf $_text
        fi
        _spinstr=$_temp${_spinstr%"$_temp"}
        sleep $_delay
        _cursor_restore
    done
    
    # Based on string length it prints empty spaces
    # so after the printing there are no ghosts
    _cursor_restore
    _clear_line

    if [[ -n "$_colorAfter" ]]; then 
        printf "$_colorAfter"
    fi

    if [[ -n "$_textAfter" ]]; then 
        printf "$_textAfter\n"
    fi

    if [[ -n "$_color" ]]; then 
        printf $RESET
    fi
    _show_cursor
}

# Progress bar
init_progress_bar() {
    _width=$(_parse_arg --width "$@")
    _color=$(_parse_arg --color "$@")

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
    _cursor_save
    _hide_cursor

    export PROGRESS_BAR_PROGRESS=$((PROGRESS_BAR_PROGRESS + 1))


    local _percent=$((PROGRESS_BAR_PROGRESS * 100 / PROGRESS_BAR_TOTAL))

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
    _cursor_restore

    printf $RESET

    if (( $_percent >= 100 )); then
        printf "\n"
        _show_cursor
    fi
}

### USER INPUT VIEWS

# UI list of options and the 
# ability to select multiple
# choices
option_select() {
    _hide_cursor
    _cursor_save

    local _highligthColor=""
    local _coolor=""
    local -a _options=()
    local -a _selected=()
    local _cursor=0
    local firstPrint=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            "--color")
                _color="$2"
                shift 2
                ;;
            "--highlight-color")
                _highligthColor="$2"
                shift 2
                ;;
            *)
                _options+=("$1")
                shift
                ;;
        esac
    done


    # Function to print the options and highlight the selected one
    _print_menu() {
        if [ "$1" = "1"  ]; then
            _cursor_restore
        fi
        for _i in "${!_options[@]}"; do
            printf $_color
            if [[ $_i -ne 0 ]]; then
                printf "\n"
            fi
            if [[ " ${_selected[*]} " == *" ${_i} "* ]]; then
                printf "[x]"    
            else 
                printf "[ ]"  
            fi
            
            if [[ $_i == $_cursor ]]; then
                printf "${_highligthColor}"
            fi

   
            printf " ${_options[_i]}"
            printf $RESET
        done
    }

    while true; do
        _print_menu $firstPrint
        firstPrint=1

        local _key=$(_get_char)

        if [[ $_key == "\s" ]]; then  # Space key for selection
            if [[ " ${_selected[*]} " == *" ${_cursor} "* ]]; then
                _selected=("${_selected[@]/$_cursor}")
            else
                _selected+=("$_cursor")
            fi 
        elif [[ $_key == "" ]]; then  # Enter key to finalize selection
            break
        fi

        case $_key in
            $'\x1b')  # Arrow key handling
                read -s -n 2 _key 
                case $_key in
                    "[A")  # Up arrow
                        ((_cursor--))
                        if [ $_cursor -lt 0 ]; then
                            _cursor=$((${#_options[@]} - 1))
                        fi
                        ;;
                    "[B")  # Down arrow
                        ((_cursor++))
                        if [ $_cursor -ge ${#_options[@]} ]; then
                            _cursor=0
                        fi
                        ;;
                esac
                ;;
        esac
    done
    _show_cursor
    SELECTED="${_selected[@]}"
    printf "\n"
}

# UI list of options and the 
# ability to select one choice
radio_select(){
    _hide_cursor
    _cursor_save

    local _highligthColor=""
    local _coolor=""
    local -a _options=()
    SELECTED=-1
    local _cursor=0
    local firstPrint=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            "--color")
                _color="$2"
                shift 2
                ;;
            "--highlight-color")
                _highligthColor="$2"
                shift 2
                ;;
            *)
                _options+=("$1")
                shift
                ;;
        esac
    done


    # Function to print the options and highlight the selected one
    _print_menu() {
        if [ "$1" = "1"  ]; then
            _cursor_restore
        fi
        for _i in "${!_options[@]}"; do
            printf $_color
            if [[ $_i -ne 0 ]]; then
                printf "\n"
            fi
            if [[ $SELECTED -gt -1 && " $SELECTED " == *" ${_i} "* ]]; then
                printf "[x]"    
            else 
                printf "[ ]"  
            fi
            
            if [[ $_i == $_cursor ]]; then
                printf "${_highligthColor}"
            fi

   
            printf " ${_options[_i]}"
            printf $RESET
        done
    }

    while true; do
        _print_menu $firstPrint
        firstPrint=1

        local _key=$(_get_char)

        if [[ $_key == "\s" || $_key == "" ]]; then  # Space key for selection
            SELECTED=$_cursor
            _print_menu $firstPrint
            echo "\n"
            _show_cursor
            return
        fi

        case $_key in
            $'\x1b')  # Arrow key handling
                read -s -n 2 _key 
                case $_key in
                    "[A")  # Up arrow
                        ((_cursor--))
                        if [ $_cursor -lt 0 ]; then
                            _cursor=$((${#_options[@]} - 1))
                        fi
                        ;;
                    "[B")  # Down arrow
                        ((_cursor++))
                        if [ $_cursor -ge ${#_options[@]} ]; then
                            _cursor=0
                        fi
                        ;;
                esac
                ;;
        esac
    done
    _show_cursor
    
    printf "\n"
}

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
        printf "%s" $_char
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