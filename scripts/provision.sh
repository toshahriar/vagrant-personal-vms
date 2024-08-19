#!/bin/bash

# Get the VM index from the argument
VM_INDEX=$1

# Function to log the received environment variables in a tabular format
log_vm_settings() {
  echo "-------------------------------------------------------------"
  echo "Provisioning VM${VM_INDEX} with the following settings:"
  echo "-------------------------------------------------------------"
  printf "%-25s : %s\n" "VM Index" "VM${VM_INDEX}"
  printf "%-25s : %s\n" "VM Prefix" "$VM_PREFIX"
  printf "%-25s : %s\n" "VM IP Address" "$VM_IP"
  printf "%-25s : %s\n" "VM Memory" "$VM_MEMORY"
  printf "%-25s : %s\n" "VM CPUs" "$VM_CPUS"
  printf "%-25s : %s\n" "VM Image" "$VM_IMAGE"
  printf "%-25s : %s\n" "VM Bridge Interface" "$VM_NETWORK_BRIDGE"
  printf "%-25s : %s\n" "VM Root Password" "$VM_ROOT_PASSWORD"
  printf "%-25s : %s\n" "VM SSH Port" "$VM_SSH_PORT"
  printf "%-25s : %s\n" "VM Package List" "$VM_PACKAGE_LIST"
  printf "%-25s : %s\n" "VM UFW Allowed Apps" "$VM_UFW_ALLOW_APPS"
  echo "-------------------------------------------------------------"
}

# Function to set default values for environment variables
set_defaults() {
  VM_ROOT_PASSWORD=${VM_ROOT_PASSWORD:-"p@ssword"}
  VM_ADDITIONAL_PACKAGES=${VM_ADDITIONAL_PACKAGES:-"vim git curl telnet nano"}
  VM_UFW_ALLOWED_APPS=${VM_UFW_ALLOWED_APPS:-"ssh http https"}
  VM_SSH_PORT=${VM_SSH_PORT:-22}
}

# Function to configure SSH settings
configure_ssh() {
  echo "root:${VM_ROOT_PASSWORD}" | sudo chpasswd

  # Update the SSH configuration file to use the custom port
  if ! sudo sed -i "s/^#Port 22/Port $VM_SSH_PORT/" /etc/ssh/sshd_config; then
    echo "Error: Failed to set SSH port in configuration."
    exit 1
  fi

  # Ensure SSH service is enabled and running
  sudo systemctl enable ssh
  sudo systemctl start ssh

  # Restart SSH service to apply changes
  sudo systemctl restart ssh
}

# Function to install additional packages
install_packages() {
  sudo apt-get update && sudo apt-get upgrade -y

  if [[ -n "$VM_PACKAGE_LIST" ]]; then
    if ! sudo apt-get install -y $VM_PACKAGE_LIST; then
      echo "Error: Failed to install one or more packages: $VM_PACKAGE_LIST"
      exit 1
    fi
  fi
}

# Function to configure UFW settings
configure_ufw() {
  # Install UFW (Uncomplicated Firewall) if not already installed
  sudo apt-get install -y ufw

  # Enable UFW
  sudo ufw enable

  # Allow specified applications through the firewall
  if [[ -n "$VM_UFW_ALLOW_APPS" ]]; then
    for app in $VM_UFW_ALLOW_APPS; do
      sudo ufw allow $app
    done
  fi

  # Allow the SSH port in UFW if not the default 22
  if [[ "$VM_SSH_PORT" != "22" ]]; then
    sudo ufw allow "$VM_SSH_PORT"
    sudo ufw deny 22
  else
    # Allow default SSH port 22 if no custom port is set
    sudo ufw allow 22
  fi

  # Reload UFW to apply the rules
  sudo ufw reload

  # Verify UFW and SSH status
  sudo ufw status
  sudo systemctl status ssh
}

# Function to generate SSH keys and display the key information
setup_ssh_keys() {
  # Generate an SSH key pair in the default directory for the current user (no passphrase)
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/${VM_NAME}_id_rsa"

  # Display the public key
  echo "Your SSH public key for ${VM_NAME} is:"
  cat "$HOME/.ssh/${VM_NAME}_id_rsa.pub"

  # Save the public key to the authorized_keys for the root user
  sudo mkdir -p /root/.ssh
  sudo cp "$HOME/.ssh/${VM_NAME}_id_rsa.pub" /root/.ssh/authorized_keys

  # Set the proper permissions
  sudo chmod 700 /root/.ssh
  sudo chmod 600 /root/.ssh/authorized_keys
  sudo chown root:root /root/.ssh
  sudo chown root:root /root/.ssh/authorized_keys

  # Disable password authentication to enhance security
  sudo sed -i 's/^[#]*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

  # Update the SSH port in the configuration file
  sudo sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

  # Restart the SSH service to apply the changes
  sudo systemctl restart ssh

  # Display the private key location
  echo "Your SSH private key for ${VM_NAME} is saved at: $HOME/.ssh/${VM_NAME}_id_rsa"
}

# Function to generate a VM-specific name
generate_vm_name() {
  VM_PREFIX=$(echo "$VM_PREFIX" | sed -E 's/[-[:space:]]+/_/g' | tr '[:upper:]' '[:lower:]')
  VM_NAME="${VM_PREFIX}_${VM_INDEX}"
}

# Main provisioning logic
main() {
  # Set default values if not provided
  set_defaults

  # Generate the VM name
  generate_vm_name

  # Log the VM settings
  log_vm_settings

  # Install packages
  install_packages

  # Configure SSH
  configure_ssh

  # Configure UFW
  configure_ufw

  # Set up SSH keys
  setup_ssh_keys
}

# Run the main function
main
