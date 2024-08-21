source mtui.sh
source 'config/colors.sh'

request() {
    curl --silent --output /dev/null "https://www.google.com"
}

#sleep 2 & loader 'Downloading data' --color $BLACK --text-after "Failed" --color-after $BOLD_RED
total=100

init_progress_bar $total --color $CYAN --width 80 --hide

#for ((i = 0; i < total; i++)); do
#    sleep 0.04 && advance_progress_bar
#done

options=("Option 1" "Option 2" "Option 3" "Option 4")

#option_select --color $BLACK --highlight-color $RED "${options[@]}"


#echo Your choices:

#for i in ${SELECTED[@]}; do
    #echo "${options[$i]}"
#done

#radio_select --color $BLACK --highlight-color $RED "${options[@]}"

#echo "${options[$SELECTED]}"

echo "\n"
label "Expecto patronum!" --color "\033[48;2;255;215;0m" --margin-horizontal 3
echo "\n"