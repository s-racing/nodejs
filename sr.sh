#!/bin/bash
 
echo "--------------------------------"
echo "    Deployment Script Start     "
echo "--------------------------------"
 
# Function to prompt for user input and read the response
prompt_for_input() {
    read -p "$1: " input
    echo "${input}"
}
 
# Function to confirm user's choice
confirm_choice() {
    while true; do
        read -p "$1 (yes/no): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}
 
 
 
# Default base folder
default_base_folder="/var/www"
 
# Prompt for Git username and PAT once
git_user=$(prompt_for_input "Enter your Git username")
pat=$(prompt_for_input "Enter your Personal Access Token (PAT)")
 
 
# Main deployment loop
while true; do
 
# Prompt user for base folder with default option
base_folder=$(prompt_for_input "Enter the path of the base folder (default: $default_base_folder)")
 
if [[ -z "$base_folder" ]]; then
    base_folder=$default_base_folder
fi
 
if ! confirm_choice "You have chosen the base folder as '$base_folder'. Do you want to proceed?"; then
    echo "Script aborted by user."
    exit 1
fi
 
# Prompt for Git username and PAT
#git_user=$(prompt_for_input "Enter your Git username")
#pat=$(prompt_for_input "Enter your Personal Access Token (PAT)")
 
# Check if the Git username and PAT are valid
#if ! git ls-remote --exit-code "https://$git_user:$pat@github.com" &> /dev/null; then
#    echo "Git username or PAT is invalid."
#    echo "Script aborted."
#    exit 1
#fi
 
# Application type options
app_options=("backend" "frontend" "fullstack")
 
echo "Select the type of application:"
for i in "${!app_options[@]}"; do
    echo "$((i + 1)). ${app_options[i]}"
done
 
# Prompt for user's choice and validate it
app_choice=""
while [[ -z "$app_choice" ]]; do
    read -p "Enter your choice (1-${#app_options[@]}): " choice
    if [[ $choice -ge 1 && $choice -le ${#app_options[@]} ]]; then
        app_choice="${app_options[choice - 1]}"
    else
        echo "Invalid choice, please try again."
    fi
done
 
echo "Selected option: $app_choice"
 
# Deployment type options
deployment_options=("Development" "Staging" "Production")
 
echo "Select the type of deployment:"
for i in "${!deployment_options[@]}"; do
    echo "$((i + 1)). ${deployment_options[i]}"
done
 
# Prompt for user's choice and validate it
deployment_choice=""
while [[ -z "$deployment_choice" ]]; do
    read -p "Enter your choice (1-${#deployment_options[@]}): " choice
    if [[ $choice -ge 1 && $choice -le ${#deployment_options[@]} ]]; then
        deployment_choice="${deployment_options[choice - 1]}"
    else
        echo "Invalid choice, please try again."
    fi
done
 
echo "Selected option: $deployment_choice"
 
# Prompt for the name of the folder to create
user_folder=$(prompt_for_input "Enter the name of the folder to create inside $base_folder/$app_choice/$deployment_choice")
 
# Construct the final folder path
final_folder="$base_folder/$app_choice/$deployment_choice/$user_folder"
 
echo "Creating folder at path: $final_folder"
 
# Confirm the final folder path
if ! confirm_choice "Final deployment directory will be '$final_folder'. Do you want to proceed?"; then
    echo "Script aborted by user."
    exit 1
fi
 
# Create the directory structure
mkdir -p "$final_folder" || { echo "Failed to create directory: $final_folder"; exit 1; }
 
# Navigate into the directory
cd "$final_folder" || { echo "Failed to navigate to directory: $final_folder"; exit 1; }
 
# Prompt for the repository name
repo_name=$(prompt_for_input "Enter the GitHub repository name (e.g., username/repo)")
 
# Construct the repository URL
repo_url="https://$git_user:$pat@github.com/evervent/$repo_name.git"
echo "Generated repository URL: $repo_url"
 
# Check if the repository exists
if ! git ls-remote --exit-code "$repo_url" &> /dev/null; then
    echo "Repository does not exist or user credentials are incorrect."
    echo "Reverting to the original state."
    rm -rf "$final_folder"
    echo "Script aborted."
    exit 1
fi
 
# Initialize Git and set remote repository URL
git init
git remote add origin "$repo_url"
 
# Pull the code from the remote repository
git pull origin "$deployment_choice" || { echo "Git pull failed"; exit 1; }
 
echo "--------------------------------"
echo "Deployment to $final_folder completed successfully."
echo "--------------------------------"
 
# Ask if user wants to start another deployment
    read -p "Would you like to start another deployment? (yes/no): " continue_choice
    case $continue_choice in
        [Yy]* ) continue;;
        [Nn]* ) echo "Exiting deployment script."; break;;
        * ) echo "Please answer yes or no."; break;;
    esac
 
done
 
echo "Script completed."

 
