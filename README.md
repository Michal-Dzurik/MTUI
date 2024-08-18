# Documentation 

MTIU is a Terminal User Interface framework for bash scripts. 

**This is a basic shell script providing utility functions to enhance command-line interfaces (CLIs) in your projects.**

## Loader

This script relies on a separate `config/colors.sh` file that defines color constants for customization. You'll need to create this file with your desired color codes.

Here's how to show `Loader`:

```bash
your_process & loader \
  --text "Loading..."      # Text to display
  --color "$BLACK"         # Color for the text
  --text-after "Done!"     # Text to display after completion
  --color-after "$GREEN"   # Color for the completion text
```

  ## Progress bar

This script relies on a separate `config/colors.sh` file that defines color constants for customization. You'll need to create this file with your desired color codes.

Here's how to show `Progress bar`:

```bash
totalComputations=100

init_progress_bar $totalComputations \ 
  --color $GREEN           # Color for the text
  --width 80               # Width in letters (default 50)

for ((i = 0; i < totalComputations; i++)); do
    your_computation && advance_progress_bar
done
       
```