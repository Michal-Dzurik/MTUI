# Documentation 

MTIU is a Terminal User Interface framework for bash scripts. 

**This is a basic shell script providing utility functions to enhance command-line interfaces (CLIs) in your projects.**

## Loader

This script relies on a separate `config/colors.sh` file that defines color constants for customization. You'll need to create this file with your desired color codes.

Here's how to use the `loader` function:

```bash
your_process & loader \
  --text "Loading..."  # Text to display
  --color "$BLACK"     # Color for the text
  --text-after "Done!" # Text to display after completion
  --color-after "$GREEN"  # Color for the completion text