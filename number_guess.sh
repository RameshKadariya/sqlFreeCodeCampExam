#!/bin/bash
# commit version 2 - game logic update
# update 3 - username logic
# feat: input validation added
# fix: improve best game tracking logic

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if user exists in database
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user - insert into database
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Existing user - extract their stats
  USER_ID=$(echo $USER_INFO | cut -d'|' -f1)
  GAMES_PLAYED=$(echo $USER_INFO | cut -d'|' -f2)
  BEST_GAME=$(echo $USER_INFO | cut -d'|' -f3)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start guessing
echo "Guess the secret number between 1 and 1000:"
NUM_GUESSES=0

while true; do
  read GUESS

  # Validate it's an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUM_GUESSES=$((NUM_GUESSES + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    # Correct!
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update stats in database
    PREV_GAMES=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
    PREV_BEST=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
    NEW_GAMES=$((PREV_GAMES + 1))

    if [[ $PREV_BEST -eq 0 || $NUM_GUESSES -lt $PREV_BEST ]]; then
      NEW_BEST=$NUM_GUESSES
    else
      NEW_BEST=$PREV_BEST
    fi

    $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$NEW_BEST WHERE user_id=$USER_ID" > /dev/null
    break
  fi
done