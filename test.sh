source mtui.sh

mtui_config "config.json"

request() {
    curl --silent --output /dev/null "https://www.google.com"
}

sleep 2 & loader 'Downloading data'
total=100
#init_progress_bar $total --width 80 

#for ((i = 0; i < total; i++)); do
#    sleep 0.04 && advance_progress_bar
#done

options=("Option 1" "Option 2" "Option 3" "Option 4")

#option_select --color $BLACK --highlight-color $GREEN "${options[@]}"


#echo Your choices:

#for i in ${SELECTED[@]}; do
    #echo "${options[$i]}"
#done

#radio_select --color $BLACK "${options[@]}"

#echo "${options[$SELECTED]}"

_cursor_restore

echo "\n"
label "Done" --background-color $BACKGROUND_GREEN --margin-horizontal 3
echo "\n"
