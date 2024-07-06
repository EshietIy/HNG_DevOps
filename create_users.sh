#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Clear previous log and password files
> $LOG_FILE
> $PASSWORD_FILE

# Function to generate a random password
	generate_password() {
	length=16  # Adjust password length as desired
	openssl rand -base64 $((length / 3)) | tr -dc 'A-Za-z0-9!@#$%^&*' | fold -w $length | head -n 1
    }
    

# Function to create user and groups
create_user() {
  IFS=';' read -r username groups <<< "$1"
  username=$(echo "$username" | xargs) # Remove whitespace
  groups=$(echo "$groups" | xargs) # Remove whitespace
  
  if id "$username" &>/dev/null; then
    echo "User $username already exists. Adding to groups..." | tee -a $LOG_FILE
  else
    useradd -m -s /bin/bash "$username" | tee -a $LOG_FILE
    echo "Created user $username" | tee -a $LOG_FILE
    password=$(generate_password)
    echo "$username:$password" | chpasswd
    echo "$username,$password" >> $PASSWORD_FILE
  fi

  # Ensure that user's personal group exists
  if ! getent group "$username" &>/dev/null; then
    groupadd "$username" | tee -a $LOG_FILE
  fi

  usermod -aG "$username" "$username" | tee -a $LOG_FILE

  # Add user to specified groups
  IFS=',' read -ra group_list <<< "$groups"
  for group in "${group_list[@]}"; do
    if ! getent group "$group" &>/dev/null; then
      groupadd "$group" | tee -a $LOG_FILE
      echo "Created group $group" | tee -a $LOG_FILE
    fi
    usermod -aG "$group" "$username" | tee -a $LOG_FILE
  done
}

# Read input file and create users and groups
while IFS= read -r line; do
  create_user "$line"
done < "$1"

# Set permissions for password file
chmod 600 $PASSWORD_FILE
chown root:root $PASSWORD_FILE