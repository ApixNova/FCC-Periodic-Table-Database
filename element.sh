#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#parameter order : atomic num, symbol, name.
DISPLAY() {
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$1")
  MELTING_P=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$1")
  BOILING_P=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$1")
  TYPE=$($PSQL "SELECT type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$1")
  echo "The element with atomic number $1 is $3 ($2). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $3 has a melting point of $MELTING_P celsius and a boiling point of $BOILING_P celsius."
}


#if no argument
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  #if number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    #set variables
    if [[ ! -z $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1") ]]
    then
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")
      ATOMIC_NUM=$1
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
      DISPLAY $ATOMIC_NUM $SYMBOL $NAME
    fi
  #if not number
  else
  #if symbol
    if [[ ! -z $($PSQL "SELECT name FROM elements WHERE symbol='$1'") ]]
    then
      #set variables
      SYMBOL=$1
      ATOMIC_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")
      DISPLAY $ATOMIC_NUM $SYMBOL $NAME
      #else if name
    elif [[ ! -z $($PSQL "SELECT atomic_number FROM elements WHERE name='$1'") ]]
    then
      #set variables
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$1'")
      ATOMIC_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      NAME=$1
      DISPLAY $ATOMIC_NUM $SYMBOL $NAME
    else
      echo "I could not find that element in the database."
    fi
  fi
fi
