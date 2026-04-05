#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

if [[ $INPUT =~ ^[0-9]+$ ]]
then
  DATA=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE e.atomic_number=$INPUT")
else
  DATA=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE e.symbol='$INPUT' OR e.name='$INPUT'")
fi

if [[ -z $DATA ]]
then
  echo "I could not find that element in the database."
else
  echo $DATA | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done
fi