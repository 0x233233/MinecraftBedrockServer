#!/bin/bash
# To run the script use:
# curl https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/ChangeRepo.sh | bash
#
# GitHub Repository: https://github.com/0x233233/MinecraftBedrockServer

echo "Minecraft Bedrock Server change Repo from 'TheRemote' to '0x233233'"
echo "Latest version always at https://github.com/0x233233/MinecraftBedrockServer"

# You can override this for a custom installation directory but I only recommend it if you are using a separate drive for the server
# It is meant to point to the root folder that holds all servers
# For example if you had a separate drive mounted at /newdrive you would use DirName='/newdrive' for all servers
# The servers will be separated by their name/label into folders
DirName=$(readlink -e ~)
if [ -z "$DirName" ]; then
  DirName=~
fi

# Function to read input from user with a prompt
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name </dev/tty
    if [ ! -n "$(which xargs)" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}' | tr -cd '[a-zA-Z0-9]._-')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]]; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer </dev/tty
    if [[ "$answer" == "${answer#[Yy]}" ]]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

Update_Scripts() {
  # Remove existing scripts
  rm -f start.sh stop.sh restart.sh fixpermissions.sh revert.sh

  # Download start.sh from repository
  echo "Grabbing start.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o start.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/start.sh
  chmod +x start.sh
  sed -i "s:dirname:$DirName:g" start.sh
  sed -i "s:servername:$ServerName:g" start.sh
  sed -i "s:userxname:$UserName:g" start.sh
  sed -i "s<pathvariable<$PATH<g" start.sh

  # Download stop.sh from repository
  echo "Grabbing stop.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o stop.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/stop.sh
  chmod +x stop.sh
  sed -i "s:dirname:$DirName:g" stop.sh
  sed -i "s:servername:$ServerName:g" stop.sh
  sed -i "s:userxname:$UserName:g" stop.sh
  sed -i "s<pathvariable<$PATH<g" stop.sh

  # Download restart.sh from repository
  echo "Grabbing restart.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o restart.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/restart.sh
  chmod +x restart.sh
  sed -i "s:dirname:$DirName:g" restart.sh
  sed -i "s:servername:$ServerName:g" restart.sh
  sed -i "s:userxname:$UserName:g" restart.sh
  sed -i "s<pathvariable<$PATH<g" restart.sh

  # Download fixpermissions.sh from repository
  echo "Grabbing fixpermissions.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o fixpermissions.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/fixpermissions.sh
  chmod +x fixpermissions.sh
  sed -i "s:dirname:$DirName:g" fixpermissions.sh
  sed -i "s:servername:$ServerName:g" fixpermissions.sh
  sed -i "s:userxname:$UserName:g" fixpermissions.sh
  sed -i "s<pathvariable<$PATH<g" fixpermissions.sh

  # Download revert.sh from repository
  echo "Grabbing revert.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o revert.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/revert.sh
  chmod +x revert.sh
  sed -i "s:dirname:$DirName:g" revert.sh
  sed -i "s:servername:$ServerName:g" revert.sh
  sed -i "s:userxname:$UserName:g" revert.sh
  sed -i "s<pathvariable<$PATH<g" revert.sh

  # Download clean.sh from repository
  echo "Grabbing clean.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o clean.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/clean.sh
  chmod +x clean.sh
  sed -i "s:dirname:$DirName:g" clean.sh
  sed -i "s:servername:$ServerName:g" clean.sh
  sed -i "s:userxname:$UserName:g" clean.sh
  sed -i "s<pathvariable<$PATH<g" clean.sh

  # Download update.sh from repository
  echo "Grabbing update.sh from repository..."
  curl -H "Accept-Encoding: identity" -L -o update.sh https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/update.sh
  chmod +x update.sh
  sed -i "s<pathvariable<$PATH<g" update.sh
}

# Check to make sure we aren't running as root
if [[ $(id -u) = 0 ]]; then
  echo "This script is not meant to be run as root. Please run ./ChangeRepo.sh as a non-root user, without sudo; the script will call sudo when it is needed. Exiting..."
  exit 1
fi

if [ -e "ChangeRepo.sh" ]; then
  rm -f "ChangeRepo.sh"
  echo "Local copy of ChangeRepo.sh running.  Exiting and running online version..."
  curl https://raw.githubusercontent.com/0x233233/MinecraftBedrockServer/master/ChangeRepo.sh | bash
  exit 1
fi

# Check to see if Minecraft server main directory already exists
cd $DirName
if [ -d "minecraftbe" ]; then
  cd minecraftbe
else
  echo "Default directory 'minecraftbe' not exist. Are you logged in with the correct user?"
fi

# Server name configuration
echo "Enter the short one word label from your existing server (don't use minecraftbe)..."

read_with_prompt ServerName "Server Label"

# Remove non-alphanumeric characters from ServerName
ServerName=$(echo "$ServerName" | tr -cd '[a-zA-Z0-9]._-')

if [[ "$ServerName" == *"minecraftbe"* ]]; then
  echo "Server label of minecraftbe is not allowed.  Please choose a different server label!"
  exit 1
fi

if [ -d "$ServerName" ]; then
  echo "Directory minecraftbe/$ServerName exists!  Stopping server and updating scripts to new repository."

  # Stop Server
  sudo systemctl stop "$ServerName.service"

  # Get username
  UserName=$(whoami)
  cd $DirName
  cd minecraftbe
  cd $ServerName
  echo "Server directory is: $DirName/minecraftbe/$ServerName"

  # Update Minecraft server scripts
  Update_Scripts

  # Change completed
  echo "Change is complete.  Starting Minecraft $ServerName server.  To view the console use the command screen -r or check the logs folder if the server fails to start"
  sudo systemctl daemon-reload
  sudo systemctl start "$ServerName.service"

  exit 0
else
  echo "No Minecraft server exist with name: $ServerName"
fi