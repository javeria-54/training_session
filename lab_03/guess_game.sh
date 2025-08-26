#!/bin/bash

number=$(( ( RANDOM % 10 ) + 1 ))

echo "Guess a number between 1 and 10:"

while true
do
    read -p "Enter your guess: " guess

    if [ "$guess" -eq "$number" ]; then
        echo " Correct! The number was $number"
        break
    elif [ "$guess" -lt "$number" ]; then
        echo "Too Low!"
    else
        echo "Too high!"
    fi
done
