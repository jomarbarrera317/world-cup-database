#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=()
game_values=()
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  team_values+=("('$winner')" "('$opponent')")
  game_values+=("($year, '$round', '$winner', '$opponent', $winner_goals, $opponent_goals)")
done < <(tail -n +2 games.csv)

team_sql="INSERT INTO teams(name) VALUES $(IFS=,; printf '%s' "${team_values[*]}") ON CONFLICT (name) DO NOTHING"
game_sql="INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT game.year, game.round, winner.team_id, opponent.team_id, game.winner_goals, game.opponent_goals FROM (VALUES $(IFS=,; printf '%s' "${game_values[*]}")) AS game(year, round, winner, opponent, winner_goals, opponent_goals) JOIN teams AS winner ON winner.name = game.winner JOIN teams AS opponent ON opponent.name = game.opponent"

$PSQL "$team_sql"
$PSQL "$game_sql"
