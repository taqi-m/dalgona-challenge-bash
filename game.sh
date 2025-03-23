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
                cat elder_wand.txt
                ;;
            "Stone")
                cat resurrection_stone.txt
                ;;
            "Cloak")
                cat invisibility_cloak.txt
                ;;
        esac
    fi
}

# Function to validate user input (checks if input is one of the valid shapes)
validate_input() 
{
    local input=$1
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
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Append data to the file in a structured format
    echo "$timestamp|$player_score|$computer_score|$attempts|$difficulty|$theme" >> "$RECORDS_FILE"
    echo "Record saved successfully!"
}

# Function to load and display all records
load_records() {
    if [[ ! -f "$RECORDS_FILE" ]]; then
        echo "No records found!"
        return
    fi

    # Print table header
    echo -e "Date & Time\t\tPlayer Score\tComputer Score\tAttempts\tDifficulty\tTheme"
    echo "-------------------------------------------------------------------------------------"

    # Read and format each record
    while IFS='|' read -r timestamp player_score computer_score attempts difficulty theme; do
        echo -e "$timestamp\t$player_score\t\t$computer_score\t\t$attempts\t$difficulty\t$theme"
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
                sleep 1
                return
                ;;
            2)
                TIME_LIMIT=$MEDIUM_TIME
                DIFFICULTY="Medium"
                echo "Difficulty set to Medium!"
                sleep 1
                return
                ;;
            3)
                TIME_LIMIT=$HARD_TIME
                DIFFICULTY="Hard"
                echo "Difficulty set to Hard!"
                sleep 1
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
                sleep 1
                return
                ;;
            2)
                THEME="Harry Potter"
                shapes=("${HALLOWS_SHAPES[@]}")
                echo "Theme set to Harry Potter!"
                sleep 1
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
    echo "5) Exit Game"
    
    while true; do
        read -p "Enter your choice (1-5): " menu_choice
        case $menu_choice in
            1)
                return 0  # Start the game
                ;;
            2)
                select_difficulty
                display_main_menu
                ;;
            3)
                select_theme
                display_main_menu
                ;;
            4)
                clear
                load_records
                echo -e "\nPress Enter to return to the main menu..."
                read
                display_main_menu
                ;;
            5)
                echo "Thanks for playing!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 5."
                ;;
        esac
    done
}

# Main function to run the game
play_game() {
    player_score=0
    computer_score=0
    attempts=3

    while true; do
        clear
        if [[ "$THEME" == "Squid Game" ]]; then
            echo -e "Presenting Squid Game inspired"
        else
            echo -e "Presenting Harry Potter inspired"
        fi
        
        figlet -f digital "Shape Challenge!"
        echo "Theme: $THEME | Difficulty: $DIFFICULTY - You have $TIME_LIMIT seconds to respond"
        echo "You have $attempts attempts left to guess the shape."
        echo "Available shapes: ${shapes[*]}"

        # Select a random shape
        random_index=$((RANDOM % ${#shapes[@]}))
        random_shape=${shapes[$random_index]}

        # Display the selected shape
        echo "Here is your challenge shape:"
        display_shape "$random_shape" "$THEME"

        # Prompt user for input with appropriate time limit
        while true; do
            echo -e "You have $TIME_LIMIT seconds to guess..."
            read -t $TIME_LIMIT -p "Guess the shape: " user_guess
            echo
            if [[ -z $user_guess ]]; then
                echo "Time's up! You didn't make a guess in time. Player eliminated!"
                break
            elif validate_input "$user_guess"; then
                break  # Input is valid, exit the loop
            else
                echo "Invalid shape! Please enter one of: ${shapes[*]}"
                # Reset timer for another attempt
                read -t $TIME_LIMIT -p "Guess the shape: " user_guess
                if [[ -z $user_guess ]]; then
                    echo "Time's up! You didn't make a guess in time."
                    break
                elif validate_input "$user_guess"; then
                    break
                else 
                    echo "Invalid shape again! Player eliminated!"
                    break
                fi
            fi
        done

        # Check user's answer
    if [[ -z $user_guess ]]; then
        echo "You didn't make a valid guess in time."
        ((attempts--))
        
        if [[ $attempts -gt 0 ]]; then
            echo "You have $attempts attempts remaining."
            echo "Let's try again with a new shape."
            continue  # Skip to next iteration to get a new shape
        fi
    elif [[ ${user_guess,,} == ${random_shape,,} ]]; then
        echo "Correct! You identified the shape."
        ((player_score=player_score+1))
        
        # Computer's turn only happens after correct user guess
        echo -e "\nComputer's turn to guess..."
        sleep 1  # Simulate computer thinking
        comp_guess=${shapes[$((RANDOM % ${#shapes[@]}))]}
        echo "Computer guessed: $comp_guess"
        if [[ $comp_guess == $random_shape ]]; then
            echo "Computer guessed correctly!"
            ((computer_score=computer_score+1))
        else
            echo "Computer guessed wrong!"
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
    
    # Remove the separate computer's turn section since it's now handled above
    # Check if player is out of attempts
    if [[ $attempts -le 0 ]]; then
        echo "Game over! Final Scores - Player|Computer: $player_score | $computer_score"
        save_record $player_score $computer_score $attempts "$DIFFICULTY" "$THEME"
        echo -e "\nPress Enter to continue..."
        read
        break
    fi
        
        # save_record $player_score $computer_score $attempts "$DIFFICULTY" "$THEME"
        
        # Replay option
        while true; do
            read -p "Do you want to play again? (y/n): " choice
            if [[ ${choice^} == "Y" || ${choice^} == "N" ]]; then
                break
            else
                echo "Invalid input. Please enter 'y' or 'n'."
            fi
        done

        if [[ ${choice^} != "Y" ]]; then
            echo "Thanks for playing! Final Scores - Player|Computer: $player_score | $computer_score"
            echo "Returning to main menu..."
        	save_record $player_score $computer_score $attempts "$DIFFICULTY" "$THEME"
            sleep 2
            return
        fi
        attempts=3  # Reset attempts for new game
    done
}

# Main program loop
while true; do
    display_main_menu
    play_game
done
