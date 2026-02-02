#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  echo "Welcome to My Salon, how can I help you?"

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU
  else
    CUSTOMER_MENU
  fi
}

CUSTOMER_MENU() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  fi

  APPOINTMENT_MENU
}

APPOINTMENT_MENU() {
  echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU