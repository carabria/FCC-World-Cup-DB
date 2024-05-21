#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
  
# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE=$($PSQL"TRUNCATE teams, games RESTART IDENTITY")
echo $TRUNCATE
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != winner ]]
    then
      #get team_id of winner
      WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      #if not found
      if [[ -z $WINNING_TEAM_ID ]]
      then
        #insert team
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        echo $INSERT_TEAM_RESULT
      fi
      #get new team_id
      WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      #team id of loser
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      if [[ -z $OPPONENT_TEAM_ID ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        echo $INSERT_TEAM_RESULT
      fi
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$WINNING_TEAM_ID' AND opponent_id='$OPPONENT_TEAM_ID'")
    #if not found
    if [[ -z $GAME_ID ]]
    #insert game
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNING_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      echo $INSERT_GAME_RESULT
    fi
    #get new game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$WINNING_TEAM_ID' AND opponent_id='$OPPONENT_TEAM_ID'")
  fi
done  