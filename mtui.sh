#!/bin/sh
source 'config/colors.sh'
source 'config/constants.sh'
source 'config/helpers.sh'

#custom imports
source 'custom/colors.sh'

mtui_config(){
    if [[ $# -gt 0 ]]; then  
        ACCENT_COLOR=$(_json_get $1 "accent-color")
        ACCENT_BACKGROUND_COLOR=$(_json_get $1 "accent-background-color")
        PADDING_HORIZONTAL=$(_json_get $1 "padding-horizontal")
        PADDING_VERTICAL=$(_json_get $1 "padding-vertical")
    fi
}

# Basic loader animation
loader(){    
    _hide_cursor

    local _pid=$!
    local _delay=0.1
    local _spinstr='|/-\'

    local _text="Loading..."
    local _color="${ACCENT_COLOR:-}"
    local _text_success="✅ SUCCESS"
    local _text_fail="❌ FAIL"
    local _color_success="$GREEN"
    local _color_fail="$RED"
    local _padding_vertical="${PADDING_VERTICAL:-}"
    local _padding_horizontal="${PADDING_HORIZONTAL:-}"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color | -c)
                _color="$2"
                shift 2
                ;;
            --text-success | -ts)
                _text_success="$2"
                shift 2
                ;;
            --text-fail | -tf)
                _text_success="$2"
                shift 2
                ;;
            --color-success | -cs)
                _color_success="$2"
                shift 2
                ;;
            --color-fail | -cf)
                _color_fail="$2"
                shift 2
                ;;
            --padding-vertical | -pv)
                _padding_vertical="$2"
                shift 2
                ;;
            --padding-horizontal | -pv)
                _padding_horizontal="$2"
                shift 2
                ;;
            *)
                _text="$1"
                shift
                ;;
        esac
    done


    # Cycle runs until the previous process is finished

    local _temp=${_spinstr#?}

    # Building the ouptput
    _apply_padding $_padding_vertical $_padding_horizontal

    printf "$_color[" 
    _cursor_save
    printf "%c" "$_spinstr"
    printf "] $_text"

    _apply_padding $_padding_vertical $_padding_horizontal

    _spinstr=$_temp${_spinstr%"$_temp"}
    sleep $_delay


    while [ "$(ps a | awk '{print $1}' | grep $_pid)" ]; do
        _cursor_restore
        
        local _temp=${_spinstr#?}

        printf "%c" "$_spinstr"


        _spinstr=$_temp${_spinstr%"$_temp"}
        sleep $_delay
        
    done
    
    wait $_pid
    _exit_status=$?

    # Based on string length it prints empty spaces
    # so after the printing there are no ghosts
    _clear_line
    _cursor_up

    _apply_padding $_padding_vertical $_padding_horizontal

    if [[ $_exit_status -eq 0 ]]; then 
        # process success
        printf "$_color_success$_text_success\n"
    else
        # process failed
        printf "$_color_fail$_text_fail\n"
    fi

    _apply_padding $_padding_vertical $_padding_horizontal
    
    printf "$RESET \r"
    _show_cursor
}

# Progress bar
init_progress_bar() {
    local _width=""
    local _color=""
    local _padding_vertical="${PADDING_VERTICAL:-}"
    local _padding_horizontal="${PADDING_HORIZONTAL:-}"

    PROGRESS_BAR_TOTAL=$1

    while [[ $# -gt 0 ]]; do
        case $1 in
            --width | -w)
                _width="$2"
                shift 2
                ;;
            --color | -c)
                _color="$2"
                shift 2
                ;;
            --padding-vertical | -pv)
                _padding_vertical="$2"
                shift 2
                ;;
            --padding-horizontal | -pv)
                _padding_horizontal="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    _hide_cursor

    PROGRESS_BAR_PROGRESS=0
    PROGRESS_BAR_PADDING_VERTICAL=$_padding_vertical
    PROGRESS_BAR_PADDING_HORIZONTAL=$_padding_horizontal

    if [[ -n $_width ]]; then
        PROGRESS_BAR_WIDTH=$_width
    else 
        PROGRESS_BAR_WIDTH=50
    fi

    if [[ -n $_color ]]; then
        PROGRESS_BAR_COLOR=$_color
    else 
        PROGRESS_BAR_COLOR=$WHITE
    fi

    local _percent=0
    local _remaining=$PROGRESS_BAR_WIDTH

    # Building the output
    _apply_padding $PROGRESS_BAR_PADDING_VERTICAL $PROGRESS_BAR_PADDING_HORIZONTAL

    _cursor_save
    printf "$PROGRESS_BAR_COLOR["
    _print "-" $_remaining
    printf "] %d%%" "$_percent"
    _apply_padding $PROGRESS_BAR_PADDING_VERTICAL $PROGRESS_BAR_PADDING_HORIZONTAL
    printf "\n"

    # Cleanup
    printf $RESET

}

advance_progress_bar(){

    PROGRESS_BAR_PROGRESS=$((PROGRESS_BAR_PROGRESS + 1))

    local _percent=$((PROGRESS_BAR_PROGRESS * 100 / PROGRESS_BAR_TOTAL))
    local _completed=$((_percent * PROGRESS_BAR_WIDTH / 100))
    local _remaining=$((PROGRESS_BAR_WIDTH - _completed))

    # Building the output

    _cursor_restore
    printf "$PROGRESS_BAR_COLOR["

    _print "#" $_completed
    _print "-" $_remaining
    printf "] %d%%" "$_percent"


    # Cleanup
    printf $RESET
    if (( $_percent >= 100 )); then
        _apply_padding $PROGRESS_BAR_PADDING_VERTICAL $PROGRESS_BAR_PADDING_HORIZONTAL
        printf "\n"
        _show_cursor
        return
    fi
}

### USER INPUT VIEWS

option_select() {
    _hide_cursor

    local _highlight_color="${ACCENT_COLOR:-}"
    local _color="$BLACK"
    _padding_vertical="${PADDING_VERTICAL:-}"
    _padding_horizontal="${PADDING_HORIZONTAL:-}"
    local -a _options=()
    declare -a _selected=()
    local _cursor=0
    local _first_print=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color | -c)
                _color="$2"
                shift 2
                ;;
            --highlight-color | -hc)
                _highlight_color="$2"
                shift 2
                ;;
            --padding-vertical | -pv)
                _padding_vertical="$2"
                shift 2
                ;;
            --padding-horizontal | -pv)
                _padding_horizontal="$2"
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
        _print_menu $_first_print _option_output_print
        _first_print=1

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

    local _highlight_color="${ACCENT_COLOR:-}"
    local _color="$BLACK"
    _padding_vertical="${PADDING_VERTICAL:-}"
    _padding_horizontal="${PADDING_HORIZONTAL:-}"
    local -a _options=()
    SELECTED=-1
    local _cursor=0
    local _first_print=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --color | -c)
                _color="$2"
                shift 2
                ;;
            --highlight-color | -hc)
                _highlight_color="$2"
                shift 2
                ;;
            --padding-vertical | -pv)
                _padding_vertical="$2"
                shift 2
                ;;
            --padding-horizontal | -pv)
                _padding_horizontal="$2"
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
        _print_menu $_first_print _radio_output_print
        _first_print=1

        local _key=$(_get_char)

        if [[ $_key == "" ]]; then  # Space key for selection
            SELECTED=$_cursor
            _print_menu $_first_print _radio_output_print

            echo "\n"
            _cursor_up
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
}



label(){
    local _background_color="${ACCENT_BACKGROUND_COLOR:-}"
    local _padding_horizontal=3

    while [[ $# -gt 0 ]]; do
        case $1 in
            --background-color | -bc)
                _background_color="$2"
                shift 2
                ;;
            --margin-horizontal | -mh)
                _padding_horizontal=$2
                shift 2
                ;;
            *)
                _text=$1
                shift
                ;;
        esac
    done

    # Building output
    printf "$_background_color"
    _print " " $(( ${#_text} + ($_padding_horizontal * 2) ))
    printf "$RESET\n"
    printf "$_background_color"
    _print " " $_padding_horizontal
    printf "$_text"
    _print " " $_padding_horizontal
    printf "$RESET\n"
    printf "$_background_color"
    _print " " $(( ${#_text} + ($_padding_horizontal * 2) ))
    printf "$RESET\n"
} 