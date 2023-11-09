#!/bin/bash

# Check if the user is a superuser
if [ "$EUID" -ne 0 ]; then
    echo "Script require superuser privileges."
    exit 1
fi

# Check if Fail2Ban is installed
if ! dpkg -s fail2ban >/dev/null 2>&1; then
    echo "Installing Fail2Ban..."

    # Update package repositories
    if ! sudo apt update; then
        echo "Failed to update package repositories."
        exit 1
    fi

    # Install Fail2Ban
    if ! sudo apt install fail2ban -y; then
        echo "Failed to install Fail2Ban."
        exit 1
    fi

    echo "Fail2Ban installed successfully!"
else
    echo "Fail2Ban is already installed."
fi

# Check if the configuration file exists
if [ -f "/etc/fail2ban/jail.local" ]; then
    echo "Fail2Ban configuration file found."
else
        echo "Creating Fail2Ban configuration file..."

    # Create the jail.local file
    if ! sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local; then
        echo "Failed to create Fail2Ban configuration file."
        exit 1
    fi

    echo "Fail2Ban configuration file created successfully!"
fi

echo "Checking SSH jail configuration..."
config_file="/etc/fail2ban/jail.local"
ssh_jail_enabled=$(grep -Ec "^\[sshd\]$" "$config_file")
if [ "$ssh_jail_enabled" -eq 0 ]; then
    echo "The SSH jail section is not enabled in the configuration file. Enabling it now..."

    # Enable the SSH jail section
    if ! sed -i '/^\[sshd\]$/,/^\[/ s/^enabled = false/enabled = true/' "$config_file"; then
        echo "Failed to enable the SSH jail section."
        exit 1
    fi

    echo "The SSH jail section has been enabled."
else
    echo "The SSH jail section is already enabled in the configuration file."
fi

# Link
sudo ln -s /var/log/fail2ban.log $HOME/f2ban/fail2ban.log

# Add to executable script to bashrc.
echo "sh $HOME/f2ban/f2ban.sh" >> ~/.bashrc
