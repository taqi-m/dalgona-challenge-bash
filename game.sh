#!/bin/bash

# array to store all available shapes
shapes=("Circle" "Triangle" "Star" "Umbrella" "Hallows")
# file to store records
RECORDS_FILE="records.txt"

# Function to display selected shape
display_shape() 
{
    case $1 in
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
        "Hallows")
            cat hallows.txt
            ;;
    esac
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
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Append data to the file in a structured format
    echo "$timestamp|$player_score|$computer_score|$attempts" >> "$RECORDS_FILE"
    echo "Record saved successfully!"
}

# Function to load and display all records
load_records() {
    if [[ ! -f "$RECORDS_FILE" ]]; then
        echo "No records found!"
        return
    fi

    # Print table header
    echo -e "Date & Time\t\tPlayer Score\tComputer Score\tAttempts"
    echo "------------------------------------------------------------"

    # Read and format each record
    while IFS='|' read -r timestamp player_score computer_score attempts; do
        echo -e "$timestamp\t$player_score\t\t$computer_score\t\t$attempts"
    done < "$RECORDS_FILE"
}

# Main game loop
player_score=0
computer_score=0
attempts=3

while true; do
    echo -e "Presenting Squid game inspired"
    figlet -f digital "Dalgona Challenge!"
    echo "You have $attempts attempts to guess the shape."

    # Select a random shape
    random_index=$((RANDOM % 5))
    random_shape=${shapes[$random_index]}

    # Display the selected shape
    echo "Here is your challenge shape:"
    display_shape "$random_shape"

    # Prompt user for input
    while true; do
        read -t 5 -p "Guess the shape: " user_guess
        echo
        if [[ -z $user_guess ]]; then
            echo "You didn't make a guess. Player eliminated!"
            break
        elif validate_input "$user_guess"; then
            break  # Input is valid, exit the loop
        else
            echo "Invalid shape! Please enter one of: ${shapes[*]}"
        fi
    done

    # Check user's answer
    if [[ -z $user_guess ]]; then
        echo "You didn't make a guess."
    elif [[ ${user_guess,,} == ${random_shape,,} ]]; then
        echo "Correct! You identified the shape."
        ((player_score=player_score+1))
    else
        echo "Wrong guess! The correct answer was: $random_shape"
        ((attempts--))
    fi

    # Computer's turn to guess
    if [[ $attempts -gt 0 ]]; then
        echo -e "\nComputer's turn to guess..."
        sleep 1  # Simulate computer thinking
        comp_guess=${shapes[$((RANDOM % 5))]}
        echo "Computer guessed: $comp_guess"
        if [[ $comp_guess == $random_shape ]]; then
            echo "Computer guessed correctly!"
            ((computer_score=computer_score+1))
        else
            echo "Computer guessed wrong!"
        fi
    fi

    # Check if player is out of attempts
    if [[ $attempts -le 0 ]]; then
        echo "Game over! Final Scores - Player|Computer: $player_score | $computer_score"
        break
    fi
    
    save_record $player_score $computer_score $attempts
    
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
        load_records
        break
    fi
    attempts=3  # Reset attempts for new game
	
	
done
