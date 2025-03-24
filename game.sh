#!/bin/bash

# File to store records
RECORDS_FILE="records.txt"

# Difficulty level time limits (in seconds)
EASY_TIME=10
MEDIUM_TIME=5
HARD_TIME=3

# Default settings
TIME_LIMIT=$MEDIUM_TIME
DIFFICULTY="Medium"
THEME="Squid Game"

# Paths to theme music
HARRY_POTTER_MUSIC="/home/toobanadeem/game/old/harry-potter-hedwigs-theme.mp3"
SQUID_GAME_MUSIC="/home/toobanadeem/game/old/SquidGameBgm.mp3"

# Theme-specific shape arrays
SQUID_SHAPES=("Circle" "Triangle" "Star" "Umbrella")
HALLOWS_SHAPES=("Wand" "Stone" "Cloak")

# Active shapes array (will be set based on selected theme)
shapes=("${SQUID_SHAPES[@]}")

# Function to display selected shape
display_shape() 
{
    local shape=$1
    local theme=$2
    
    if [[ "$theme" == "Squid Game" ]]; then
        case $shape in
            "Circle")
                cat circle.txt
                ;;
            "Triangle")
                cat triangle.txt
                ;;
            "Star")
                cat star.txt
                ;;
            "Umbrella")
                cat umbrella.txt
                ;;
        esac
    else  # Harry Potter theme
        case $shape in
            "Wand")
                cat wand.txt
                ;;
            "Stone")
                cat stone.txt
                ;;
            "Cloak")
                cat cloak.txt
                ;;
        esac
    fi
}

# Function to validate user input (checks if input is one of the valid shapes)
validate_input() 
{
    local input=$1
    # Check for exit command first
    if [[ ${input,,} == "exit" ]]; then
        return 2  # Special return code for exit
    fi
    
    for shape in "${shapes[@]}"; do
        if [[ ${input,,} == ${shape,,} ]]; then
            return 0  # Input is valid
        fi
    done
    return 1  # Input is invalid
}

# Function to save records
save_record() {
    local player_score="$1"
    local computer_score="$2"
    local attempts="$3"
    local difficulty="$4"
    local theme="$5"
    local timestamp=$(date +"%H:%M:%S %d-%m-%Y")

    # Append data to the file in a structured format
    echo "$timestamp|$player_score|$computer_score|$difficulty|$theme" >> "$RECORDS_FILE"
    echo "Record saved successfully!"
}

# Function to load and display all records
load_records() {
    if [[ ! -f "$RECORDS_FILE" ]]; then
        echo "No records found!"
        return
    fi

    # Print table header
    echo -e "\tTime\t\tPlayer\tComputer\tDifficulty\tTheme"
    echo "-------------------------------------------------------------------------------------"

    # Read and format each record
    while IFS='|' read -r timestamp player_score computer_score difficulty theme; do
        echo -e "$timestamp\t$player_score\t$computer_score\t\t$difficulty\t\t$theme"
    done < "$RECORDS_FILE"
}

# Function to display the difficulty submenu
select_difficulty() {
    clear
    echo -e "DIFFICULTY SETTINGS"
    echo -e "==================="
    echo "1) Easy   - $EASY_TIME seconds to guess"
    echo "2) Medium - $MEDIUM_TIME seconds to guess"
    echo "3) Hard   - $HARD_TIME seconds to guess"
    echo "4) Back to main menu"
    
    while true; do
        read -p "Enter your choice (1-4): " diff_choice
        case $diff_choice in
            1)
                TIME_LIMIT=$EASY_TIME
                DIFFICULTY="Easy"
                echo "Difficulty set to Easy!"
                return
                ;;
            2)
                TIME_LIMIT=$MEDIUM_TIME
                DIFFICULTY="Medium"
                echo "Difficulty set to Medium!"
                return
                ;;
            3)
                TIME_LIMIT=$HARD_TIME
                DIFFICULTY="Hard"
                echo "Difficulty set to Hard!"
                return
                ;;
            4)
                return
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 4."
                ;;
        esac
    done
}

# Function to start theme music
start_music() {
    pkill mpg123  > /dev/null 2>&1 # Stop any existing music and supress msgs
    
     # Reset volume to a neutral level before setting theme-specific volume
    pactl set-sink-volume @DEFAULT_SINK@ 50% 
    
    if [[ "$THEME" == "Harry Potter" ]]; then
        mpg123 --loop -1 "$HARRY_POTTER_MUSIC"> /dev/null 2>&1 &
        pactl set-sink-volume @DEFAULT_SINK@ 200%  # Increase system volume
        echo "Playing Harry Potter theme..."
        
    else
        mpg123 --loop -1 "$SQUID_GAME_MUSIC" > /dev/null 2>&1 &
        pactl set-sink-volume @DEFAULT_SINK@ 50%  # Reset system volume
        echo "Playing Squid Game theme..."
    fi
}

# Function to stop music and supress msgs
stop_music() {
    pkill mpg123 > /dev/null 2>&1
}

# Cleanup function to ensure music stops when the script exits
cleanup() {
    stop_music
}

# Set up trap to call cleanup function on script exit
trap cleanup EXIT

# Function to display the theme selection submenu
select_theme() {
    clear
    echo -e "THEME SETTINGS"
    echo -e "=============="
    echo "1) Squid Game - Classic Dalgona shapes"
    echo "2) Harry Potter - Deathly Hallows themed shapes"
    echo "3) Back to main menu"
    
    while true; do
        read -p "Enter your choice (1-3): " theme_choice
        case $theme_choice in
            1)
                THEME="Squid Game"
                shapes=("${SQUID_SHAPES[@]}")
                echo "Theme set to Squid Game!"
                start_music  # Start the corresponding music
                return
                ;;
            2)
                THEME="Harry Potter"
                shapes=("${HALLOWS_SHAPES[@]}")
                echo "Theme set to Harry Potter!"
                start_music  # Start the corresponding music
                return
                ;;
            3)
                return
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 3."
                ;;
        esac
    done
}

# Function to display main menu
display_main_menu() {
    
    while true; do
		clear
		echo -e "Welcome to the"
		figlet -f digital "Shape Challenge!"
		echo -e "\nCurrent Settings:"
		echo -e "Theme: $THEME | Difficulty: $DIFFICULTY (${TIME_LIMIT}s)"
		echo -e "\nMAIN MENU:"
		echo "1) Play Game"
		echo "2) Select Difficulty"
		echo "3) Select Theme"
		echo "4) View Records"
		echo "5) View Game Credits"
		echo "6) Exit Game"
        read -p "Enter your choice (1-6): " menu_choice
        case $menu_choice in
            1)
                return 1
                ;;
            2)
                select_difficulty
                echo -e "\nPress Enter to return to the main menu..."
                read
                ;;
            3)
                select_theme
                echo -e "\nPress Enter to return to the main menu..."
                read
                ;;
            4)
                clear
                load_records
                echo -e "\nPress Enter to return to the main menu..."
                read
                ;;
            5) 
               clear
               echo -e "Game credits:\n Tooba Nadeem  23L-2550\n Muhummad Taqi 23F-3026"
               echo -e "\tFrom: SE-4A"
               echo -e " Hope you like our game!"
               echo -e "\nPress Enter to return to the main menu..."
               read
               ;;
            6)
                echo "Thanks for playing!"
                # Stop music when the game ends
                stop_music
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 5."
                ;;
        esac
    done
}

# Function to handle game exit
exit_game() {
    local player_score=$1
    local computer_score=$2
    local attempts=$3
    
    echo "Game aborted! Final Scores - Player|Computer: $player_score | $computer_score"
    save_record $player_score $computer_score $attempts "$DIFFICULTY" "$THEME"
    echo -e "\nPress Enter to return to the main menu..."
    read
    return 1
}

# Main function to run the game
play_game() {
    player_score=0
    computer_score=0
    attempts=3
    
    # Start the default theme music (Squid Game)
    start_music

    while true; do
        clear
        if [[ "$THEME" == "Squid Game" ]]; then
            echo -e "Presenting Squid Game inspired"
        else
            echo -e "Presenting Harry Potter inspired"
        fi
        
        figlet -f digital "Shape Challenge!"
        echo "Theme: $THEME | Difficulty: $DIFFICULTY - You have $TIME_LIMIT seconds to respond"
        echo "You have $attempts attempt(s) left to guess the shape."
        echo "Available shapes: ${shapes[*]}"
        echo "Type 'exit' at any time to quit the game and return to the main menu."

        # Select a random shape
        random_index=$((RANDOM % ${#shapes[@]}))
        random_shape=${shapes[$random_index]}

        # Display the selected shape
        echo "Here is your challenge shape:"
        display_shape "$random_shape" "$THEME"

        # Prompt user for input with appropriate time limit
        exit_requested=false
        while true; do
            echo -e "You have $TIME_LIMIT seconds to guess..."
            read -t $TIME_LIMIT -p "Guess the shape: " user_guess
            echo
            
            if [[ -z $user_guess ]]; then
                echo "Time's up! You didn't make a guess in time. Player eliminated!"
                break
            fi
            
            validate_input "$user_guess"
            validation_result=$?
            
            if [[ $validation_result -eq 2 ]]; then
                # User wants to exit
                exit_requested=true
                break
            elif [[ $validation_result -eq 0 ]]; then
                # Valid shape input
                break
            else
                echo "Invalid shape! Please enter one of: ${shapes[*]} (or type 'exit' to quit)"
                # Reset timer for another attempt
                read -t $TIME_LIMIT -p "Guess the shape: " user_guess
                if [[ -z $user_guess ]]; then
                    echo "Time's up! You didn't make a guess in time."
                    break
                fi
                
                validate_input "$user_guess"
                validation_result=$?
                
                if [[ $validation_result -eq 2 ]]; then
                    # User wants to exit
                    exit_requested=true
                    break
                elif [[ $validation_result -eq 0 ]]; then
                    # Valid shape input
                    break
                else
                    echo "Invalid shape again! Player eliminated!"
                    break
                fi
            fi
        done
        
        # Handle exit request
        if [[ $exit_requested == true ]]; then
            exit_game $player_score $computer_score $attempts
            # Stop music when the game ends
            stop_music
            return
        fi

        # Check user's answer
        if [[ -z $user_guess ]]; then
            echo "You didn't make a valid guess in time."
            ((attempts--))
            
            if [[ $attempts -gt 0 ]]; then
                echo "You have $attempts attempt(s) remaining."
                echo "Let's try again with a new shape."
                continue 
            fi
        elif [[ ${user_guess,,} == ${random_shape,,} ]]; then
            echo "Correct! You identified the shape."
            ((player_score=player_score+1))
            
            # Computer's turn only happens after correct user guess
            echo -e "\nComputer's turn to guess..."
            # Simulate computer thinking
            sleep 1  
            comp_guess=${shapes[$((RANDOM % ${#shapes[@]}))]}
            echo "Computer guessed: $comp_guess"
            if [[ $comp_guess == $random_shape ]]; then
                echo "Computer guessed correctly!"
                ((computer_score=computer_score+1))
                # Select a new shape for next round
                sleep 1
                continue
            else
                echo "Computer guessed wrong!"
                # Select a new shape for next round
                sleep 1
                continue
            fi
        else
            echo "Wrong guess! The correct answer was: $random_shape"
            ((attempts--))
            
            if [[ $attempts -gt 0 ]]; then
                echo "You have $attempts attempts remaining."
                echo "Let's try again with a new shape."
                continue  # Skip to next iteration to get a new shape
            fi
        fi
        
        # Check if player is out of attempts
        if [[ $attempts -le 0 ]]; then
            echo "Game over! Final Scores - Player|Computer: $player_score | $computer_score"
            save_record $player_score $computer_score $attempts "$DIFFICULTY" "$THEME"
            echo -e "\nPress Enter to continue..."
            read
            break
        fi
    done
    
    # Stop music when the game ends
    stop_music
}

# Main program loop
while true; do
    display_main_menu
    ret_val=$?
    
    # Only play the game if return value is 1 (indicating option 1)
    if [[ $ret_val -eq 1 ]]; then
        play_game
    fi
done
