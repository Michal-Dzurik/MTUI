
# MTUI Documentation

**MTUI** is a Terminal User Interface (TUI) framework designed to enhance your bash scripts with user-friendly command-line interfaces. It provides utility functions such as loaders, progress bars, option selectors, and radio selectors, making your scripts more interactive and visually appealing.

### Prerequisites

MTUI relies on a separate `config/colors.sh` file that defines color constants for customization. Ensure you create this file with your desired color codes to customize the appearance of the UI components.

## Features

### 1. Loader

The `loader` function displays a loading animation while a process runs in the background. This is useful for indicating that your script is working on something that might take time.

**Usage:**

```bash
your_process & loader \
  --text "Loading..."       # Text to display during loading
  --color "$BLACK"          # Color for the loading text
  --text-after "Done!"      # Text to display after the process completes
  --color-after "$GREEN"    # Color for the completion text
```

**Example:**

```bash
sleep 5 & loader \
  --text "Processing..." \
  --color "$YELLOW" \
  --text-after "Completed!" \
  --color-after "$GREEN"
```

### 2. Progress Bar

The `progress_bar` function visually represents the progress of a task. It is useful for loops or processes where you can determine the progress percentage.

**Initialization:**

```bash
totalComputations=100

init_progress_bar $totalComputations \ 
  --color $GREEN         # Color of the progress bar
  --width 80             # Width of the progress bar (default is 50)
```

**Advancing the Progress Bar:**

```bash
for ((i = 0; i < totalComputations; i++)); do
    your_computation && advance_progress_bar
done
```

**Example:**

```bash
tasks=50
init_progress_bar $tasks --color $BLUE --width 60

for ((i = 0; i < tasks; i++)); do
    sleep 0.1  # Simulate work
    advance_progress_bar
done
```

### 3. Option Selector

The `option_select` function allows users to select multiple options from a list. This is useful when you need to gather multiple pieces of input from a user in a single interaction.

**Usage:**

```bash
options=("Option 1" "Option 2" "Option 3" "Option 4")

option_select \
    --color $BLACK          # Text color for options
    --highlight-color $WHITE # Highlight color for the selected option
    "${options[@]}"         # Array of options
```

**Retrieving Selections:**

```bash
for i in ${SELECTED[@]}; do
    echo "You selected: ${options[$i]}"
done
```

**Example:**

```bash
options=("Apple" "Banana" "Cherry" "Date")

option_select --color $CYAN --highlight-color $YELLOW "${options[@]}"

for i in ${SELECTED[@]}; do
    echo "Selected: ${options[$i]}"
done
```

### 4. Radio Selector

The `radio_select` function allows users to select a single option from a list. This is ideal for scenarios where you need a singular choice, like picking a configuration option.

**Usage:**

```bash
options=("Option 1" "Option 2" "Option 3" "Option 4")

radio_select \
    --color $BLACK           # Text color for options
    --highlight-color $WHITE # Highlight color for the selected option
    "${options[@]}"          # Array of options
```

**Retrieving the Selection:**

```bash
echo "You selected: ${options[$SELECTED]}"
```

**Example:**

```bash
choices=("Red" "Green" "Blue" "Yellow")

radio_select --color $MAGENTA --highlight-color $WHITE "${choices[@]}"

echo "You selected: ${choices[$SELECTED]}"
```

---

**Note:** Remember to source the `config/colors.sh` file in your script to use color constants. This allows for consistent styling across all components.

### 5. Label

The `label` function allows you to print text in form of label with margins for text inside. Function doesn't return any value.

**Usage:**

```bash

label \ 
    "Expecto patronum!"               # Label conten
    --color $BACKGROUND_COLOR_GREEN   # Background color of label
    --margin-horizontal 5             # Margin from each side
```

---
## How to mix your own color?
- You can set the color by modifying these templates as a RGB colors

1. `\033[38;2;R;G;Bm` sets the text color.

2. `\033[48;2;R;G;Bm` sets the background color.