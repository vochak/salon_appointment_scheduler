#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read LINE; do
    # Extract service ID and name
    SERVICE_ID=$(echo $LINE | cut -d '|' -f 1 | xargs)
    NAME=$(echo $LINE | cut -d '|' -f 2 | xargs)
    
    # Skip empty lines
    if [[ -n $SERVICE_ID ]]; then
      echo "$SERVICE_ID) $NAME"
    fi
  done

  read SERVICE_ID_SELECTED
  AVAILABLE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [[ -z $AVAILABLE ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$(echo $AVAILABLE | xargs)
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    NUMBER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    
    if [[ -z $NUMBER ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else
      CUSTOMER_NAME=$(echo $NUMBER | xargs)
    fi
    
    echo -e "\nWhat time would you like your appointment?"
    read SERVICE_TIME
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
