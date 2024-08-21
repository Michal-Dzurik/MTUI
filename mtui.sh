#!/bin/sh
source 'config/colors.sh'
source 'config/constants.sh'
source 'config/helpers.sh'

# Basic loader animation
loader(){    
    _hide_cursor
    _cursor_save

    local _pid=$!
    local _delay=0.1
    local _spinstr='|/-\'

    local _text=""
    local _color=""
    local _textAfter=""
    local _colorAfter=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color)
                _color="$2"
                shift 2
                ;;
            --color-after)
                _colorAfter="$2"
                shift 2
                ;;
            --text-after)
                _textAfter="$2"
                shift 2
                ;;
            *)
                _text="$1"
                shift
                ;;
        esac
    done

    # Cycle runs until the previous process is finished
    while [ "$(ps a | awk '{print $1}' | grep $_pid)" ]; do
        local _temp=${_spinstr#?}

        # Building the ouptput
        printf "$_color[%c] $_text" "$_spinstr"

        _spinstr=$_temp${_spinstr%"$_temp"}
        sleep $_delay
        _cursor_restore
    done
    
    # Based on string length it prints empty spaces
    # so after the printing there are no ghosts
    _cursor_restore
    _clear_line

    if [[ -n "$_textAfter" ]]; then 
        printf "$_colorAfter$_textAfter\n"
    fi

    printf $RESET
    _show_cursor
}

# Progress bar
init_progress_bar() {
    _width=""
    _color=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --width)
                _width="$2"
                shift 2
                ;;
            --color)
                _color="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    PROGRESS_BAR_PROGRESS=0
    PROGRESS_BAR_TOTAL=$1

    if [[ -n $_width ]]; then
        PROGRESS_BAR_WIDTH=$_width
    else 
        PROGRESS_BAR_WIDTH=50
    fi

    if [[ -n $_color ]]; then
        PROGRESS_BAR_COLOR=$_color
    else 
        PROGRESS_BAR_WIDTH=$WHITE
    fi
}

advance_progress_bar(){
    _cursor_save
    _hide_cursor

    PROGRESS_BAR_PROGRESS=$((PROGRESS_BAR_PROGRESS + 1))

    local _percent=$((PROGRESS_BAR_PROGRESS * 100 / PROGRESS_BAR_TOTAL))
    local _completed=$((_percent * PROGRESS_BAR_WIDTH / 100))
    local _remaining=$((PROGRESS_BAR_WIDTH - _completed))

    # Building the output
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

option_select() {
    _hide_cursor
    _cursor_save

    local _highlightColor=""
    local _color=""
    local -a _options=()
    declare -a _selected=()
    local _cursor=0
    local firstPrint=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color)
                _color="$2"
                shift 2
                ;;
            --highlight-color)
                _highlightColor="$2"
                shift 2
                ;;
            *)
                _options+=("$1")
                shift
                ;;
        esac
    done

    while true; do
        # Here the second parameter is callback for accepting our choices
        _print_menu $firstPrint _option_output_print
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
                read -rsn2 _key 
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

radio_select(){
    _hide_cursor
    _cursor_save

    local _highlightColor=""
    local _coolor=""
    local -a _options=()
    SELECTED=-1
    local _cursor=0
    local firstPrint=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color)
                _color="$2"
                shift 2
                ;;
            --highlight-color)
                _highlightColor="$2"
                shift 2
                ;;
            *)
                _options+=("$1")
                shift
                ;;
        esac
    done

    while true; do
        # Here the second parameter is callback for accepting our choice
        _print_menu $firstPrint _radio_output_print
        firstPrint=1

        local _key=$(_get_char)

        if [[ $_key == "" ]]; then  # Space key for selection
            SELECTED=$_cursor
            _print_menu $firstPrint _radio_output_print

            echo "\n"
            _show_cursor

            return
        fi

        case $_key in
            $'\x1b')  # Arrow key handling
                read -rsn2 _key 
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



label(){
    _color=""
    _marginHorizontal=3

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color)
                _color="$2"
                shift 2
                ;;
            --margin-horizontal)
                _marginHorizontal=$2
                shift 2
                ;;
            *)
                _text=$1
                shift
                ;;
        esac
    done

    # Building output
    printf "$_color"
    _print " " $(( ${#_text} + ($_marginHorizontal * 2) ))
    printf "$RESET\n"
    printf "$_color"
    _print " " $_marginHorizontal
    printf "$_text"
    _print " " $_marginHorizontal
    printf "$RESET\n"
    printf "$_color"
    _print " " $(( ${#_text} + ($_marginHorizontal * 2) ))
    printf "$RESET\n"
} 