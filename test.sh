source mtui.sh
source 'config/colors.sh'

request() {
    curl --silent --output /dev/null "https://www.google.com"
}

sleep 3 & loader --text 'Downloading data' --color $BLACK --text-after '✅ Done' --color-after $GREEN