source mtui.sh
source 'config/colors.sh'

request() {
    curl --silent --output /dev/null "https://www.google.com"
}

sleep 3 & loader --text 'Downloading data' --color $BLACK --text-after '✅ Done' --color-after $GREEN
total=100

init_progress_bar $total --color $GREEN --width 80

for ((i = 0; i < total; i++)); do
    sleep 0.01 && advance_progress_bar
done