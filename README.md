# README for User Management Automation Script

## Introduction

This Bash script automates the process of creating new system users based on information provided in a file. The script is designed to simplify user management tasks by reading a file containing user details and automatically creating users with specified groups and random passwords.

## Script Location and Permissions

Ensure that the script, `user_management.sh`, is located in a directory accessible by the system administrator. Before running the script, make sure it has execute permissions by executing the following command:

```bash
chmod +x user_management.sh
```

## Functionality

The script takes a single argument, which is the path to a file containing user information. The file should adhere to the following format:

```
username;group1;group2;...;groupN
```

Where:
- `username`: The name of the user to be created.
- `group1;group2;...;groupN`: A semicolon-separated list of groups the user should belong to.

The script performs the following actions for each user entry in the provided file:

1. Checks for Existing User: It verifies if the user already exists on the system.
2. Generates Random Password: If the user doesn’t exist, the script generates a random password using `openssl`.
3. Logs User and Password:
   - The script logs the username and a message indicating a new user was created to the log file (`/var/log/user_management.log`).
   - The username and randomly generated password are securely stored (hashed with SHA-512) in a separate file (`/var/secure/user_passwords.txt`).
4. Creates User: It uses `sudo useradd` to create the new user with the following options:
   - `-m`: Creates a home directory for the user.
   - `-G $groups`: Assigns the user to the specified groups.
   - `-p $(echo $(generate_password) | mkpasswd -s SHA-512)`: Sets the password securely using a piped command with `mkpasswd`.

## Script Breakdown

### Log Files and Permissions:
- The script defines paths to log and password files (`LOG_FILE` and `PASSWORD_FILE`).
- It checks if these files exist and creates them if necessary using `touch`.

### `log_action` Function:
- This function takes a message as input and logs it with a timestamp to the log file using `tee -a`.

### Argument Check:
- The script verifies if exactly one argument (the file path) is provided. If not, it displays an usage message and exits.

### Processing User File:
- The script reads the user information file line by line using a `while` loop.
- The field separator is set to `;` (semicolon) using `IFS`.
- Inside the loop:
  - It checks if the user already exists using `id "$username" &>/dev/null`.
  - If the user exists, a message is logged and the script continues to the next line.
  - The `generate_password` function creates a random password.
  - The username and password are securely stored in the password file.
  - The script creates the user with `sudo useradd` using the generated password and group information.

## Notes

- This script requires root privileges to create users.
- The script stores passwords in a file. Make sure this file has proper permissions to restrict access. Consider additional security measures for password storage.
- You can adjust the password length in the `generate_password` function.

## Usage

To use the script, run it with the path to the user information file as an argument:

```bash
sudo ./user_management.sh /path/to/user_info_file
```

## Disclaimer

This task is an HNG internship devops task. Ensure to test the script in a controlled environment before using it in a production setting. Modify the script as needed to fit your specific requirements and security policies.
