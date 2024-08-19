require 'logger'

# Initialize a logger to capture error messages and log them to the console.
logger = Logger.new(STDOUT)
logger.level = Logger::ERROR

# Function to load environment variables from a .env file.
def load_env(file, logger)
  unless File.exist?(file)
    logger.error("Environment file '#{file}' not found. Exiting process.")
    exit(1)
  end

  # Read each line from the .env file
  File.readlines(file).each do |line|
    # Skip empty lines and comments (lines that start with '#')
    next if line.strip.empty? || line.start_with?('#')

    # Split the line at the first '=' character to separate the key and value
    key, value = line.split('=', 2).map(&:strip)

    # Set the environment variable
    ENV[key] = value
  end
end

# Load environment variables from the .env file
load_env('.env', logger)

# Get the VM count from the environment variable. Default to 2 if not set or if set to a non-positive value.
vm_count = ENV["VM_COUNT"].to_i > 0 ? ENV["VM_COUNT"].to_i : 2

# Get the VM prefix from the environment variable. Default to 'VM' if not set.
vm_prefix = ENV["VM_PREFIX"] || "VM"

# Configure Vagrant for the specified number of VMs.
Vagrant.configure("2") do |config|
  # Loop through the number of VMs to be created
  (1..vm_count).each do |i|
    # Set the Vagrant box image for each VM. Default to 'ubuntu/jammy64' if not specified in the environment variable.
    config.vm.box = ENV["VM#{i}_IMAGE"] || "ubuntu/jammy64"

    # Define each VM with a unique name based on the VM prefix and the loop index
    config.vm.define "#{vm_prefix}#{i}" do |vm_config|
      # Set the hostname of the VM
      vm_config.vm.hostname = "#{vm_prefix}#{i}"

      # Assign VM configurations from environment variables or use defaults
      ip_address = ENV["VM#{i}_IP"] || "192.168.0.13#{i-1}"
      memory = ENV["VM#{i}_MEMORY"] || "2048"
      cpus = ENV["VM#{i}_CPUS"] || "2"
      network_bridge = ENV["VM#{i}_NETWORK_BRIDGE"] || "wlp1s0"

      # Configure the VM's public network with the specified IP address and bridge interface
      vm_config.vm.network "public_network", ip: ip_address, bridge: network_bridge

      # Forward the VM's SSH port to a unique port on the host machine to avoid conflicts
      vm_config.vm.network "forwarded_port", guest: 22, host: 2200 + i

      # Configure the VirtualBox provider with memory, CPU, and name settings for the VM
      vm_config.vm.provider "virtualbox" do |vb|
        vb.memory = memory
        vb.cpus = cpus
        vb.name = "#{vm_prefix}-#{i}"  # Set the VirtualBox machine name
      end

      # Pass VM-specific environment variables to the provision script
      vm_config.vm.provision "shell" do |shell|
        shell.path = "scripts/provision.sh"
        shell.args = [i]
        shell.env = {
          "VM_PREFIX" => vm_prefix,
          "VM_IP" => ip_address,
          "VM_MEMORY" => memory,
          "VM_CPUS" => cpus,
          "VM_IMAGE" => ENV["VM#{i}_IMAGE"],
          "VM_NETWORK_BRIDGE" => network_bridge,
          "VM_ROOT_PASSWORD" => ENV["VM#{i}_ROOT_PASSWORD"],
          "VM_SSH_PORT" => ENV["VM#{i}_SSH_PORT"],
          "VM_SSH_KEY_DIR" => ENV["VM#{i}_SSH_KEY_DIR"],
          "VM_PACKAGE_LIST" => ENV["VM#{i}_PACKAGE_LIST"],
          "VM_UFW_ALLOW_APPS" => ENV["VM#{i}_UFW_ALLOW_APPS"]
        }
      end

      # Provisioning step to sync public keys
      vm_config.vm.provision "shell", inline: <<-SHELL
        KEYS_DIR="/vagrant/.keys/#{vm_prefix}-#{i}"
        mkdir -p "$KEYS_DIR"
        cp /root/.ssh/*.pub "$KEYS_DIR/"
      SHELL
    end
  end
end
