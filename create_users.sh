#!/bin/bash

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

#check if the file exist
[ -f LOG_FILE ] || touch LOG_FILE
[ -f PASSWORD_FILE ] || touch PASSWORD_FILE

# Log function
log_action() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}


# Check if the correct number of arguments was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 filename"
  exit 1
fi

# Read the file line by line
while IFS=';' read -r username groups;
do
# checking if user exist
if id "$username" &>/dev/null; then
        log_action "User $username already exists."
        continue
    fi
# Function to generate a random password
	generate_password() {
	length=16  # Adjust password length as desired
	openssl rand -base64 $((length / 3)) | tr -dc 'A-Za-z0-9!@#$%^&*' | fold -w $length | head -n 1
    }
    password=$(generate_password)
    #Log user password 
    echo "$username:$password" >> PASSWORD_FILE
	sudo useradd -m -G $groups -p $(echo $(generate_password) | mkpasswd -s SHA-512) $username
  
done < "$1"
