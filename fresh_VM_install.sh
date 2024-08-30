#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Prompt for the hostname
read -p "Enter the new hostname: " new_hostname

# Validate hostname (example validation, customize as needed)
if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Invalid hostname. Hostname can only contain letters, numbers, hyphens, and underscores."
  exit 1
fi

# Update /etc/hostname with the new hostname
echo "$new_hostname" > /etc/hostname

# Update /etc/hosts to reflect the new hostname
sed -i "s/^\(127\.0\.1\.1\s*\).*/\1$new_hostname/" /etc/hosts

# Apply the new hostname immediately
hostnamectl set-hostname "$new_hostname"

# Prompt for the username
read -p "Enter the username to add: " username

# Prompt for the password (no echo) and verify it
while true; do
  read -sp "Enter the password for $username: " password1
  echo
  read -sp "Confirm the password for $username: " password2
  echo

  if [ "$password1" == "$password2" ]; then
    break
  else
    echo "Passwords do not match. Please try again."
  fi
done

# Add the user
useradd -m $username

# Set the user's password
echo "$username:$password1" | chpasswd

# Add the user to the sudo group
usermod -aG sudo $username

# Confirm user was added and updated
if [ $? -eq 0 ]; then
    echo "User $username added and added to sudo group successfully!"
else
    echo "Failed to add user $username or add to sudo group."
fi

# Check if entry already exists in sudoers, to avoid duplicate entries
if ! grep -q "%sudo ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
  echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "Passwordless sudo has been configured for all sudo group users."
else
  echo "Passwordless sudo is already configured for sudo group users."
fi

# Update package list and upgrade installed packages
echo "Updating package list..."
apt update -y

echo "Upgrading installed packages..."
apt upgrade -y

# Perform distribution upgrade
echo "Performing distribution upgrade..."
apt dist-upgrade -y

# Install the required packages
echo "Installing curl, wget, git..."
apt install -y curl wget git qemu-guest-agent

# Start qemu-guest-agent
echo "Starting qemu-guest-agent..."
systemctl start qemu-guest-agent.service

# Get Webmin
echo "Getting Webmin..."
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh && sh setup-repos.sh

# Install Webmin
echo "Installing Webmin..."
apt-get install webmin -y

# Clean up
echo "Cleaning up..."
rm -f setup-repos.sh
echo "Cleanup done."

echo "All tasks completed successfully."
