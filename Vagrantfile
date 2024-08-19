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
    # Assign VM configurations from environment variables or use defaults
    vm_ip_address = ENV["VM#{i}_IP"] || "192.168.0.13#{i-1}"
    vm_memory = ENV["VM#{i}_MEMORY"] || "2048"
    vm_cpus = ENV["VM#{i}_CPUS"] || "2"
    vm_image = ENV["VM#{i}_IMAGE"] || "ubuntu/jammy64"
    vm_network_bridge = ENV["VM#{i}_NETWORK_BRIDGE"] || "wlp1s0"
    vm_root_password = ENV["VM#{i}_ROOT_PASSWORD"] || "p@ssword"
    vm_ssh_port = ENV["VM#{i}_SSH_PORT"] || "22"
    vm_ssh_key_dir = ENV["VM#{i}_SSH_KEY_DIR"] || "/vagrant/.keys"
    vm_package_list = ENV["VM#{i}_PACKAGE_LIST"] || "vim git curl telnet nano"
    vm_ufw_allow_apps = ENV["VM#{i}_UFW_ALLOW_APPS"] || "ssh http https"

    # Set the Vagrant box image for each VM. Default to 'ubuntu/jammy64' if not specified in the environment variable.
    config.vm.box = vm_image

    # Define each VM with a unique name based on the VM prefix and the loop index
    config.vm.define "#{vm_prefix}-#{i}" do |vm_config|
      # Set the hostname of the VM
      vm_config.vm.hostname = "#{vm_prefix}-#{i}"

      # Configure the VM's public network with the specified IP address and bridge interface
      vm_config.vm.network "public_network", ip: vm_ip_address, bridge: vm_network_bridge

      # Forward the VM's SSH port to a unique port on the host machine to avoid conflicts
      vm_config.vm.network "forwarded_port", guest: 22, host: 2200 + i

      # Configure the VirtualBox provider with memory, CPU, and name settings for the VM
      vm_config.vm.provider "virtualbox" do |vb|
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.name = "#{vm_prefix}-#{i}"  # Set the VirtualBox machine name
      end

      # Pass VM-specific environment variables to the provision script
      vm_config.vm.provision "shell" do |shell|
        shell.path = "scripts/provision.sh"
        shell.args = [i]
        shell.env = {
          "VM_PREFIX" => vm_prefix,
          "VM_IP" => vm_ip_address,
          "VM_MEMORY" => vm_memory,
          "VM_CPUS" => vm_cpus,
          "VM_IMAGE" => vm_image,
          "VM_NETWORK_BRIDGE" => vm_network_bridge,
          "VM_ROOT_PASSWORD" => vm_root_password,
          "VM_SSH_PORT" => vm_ssh_port,
          "VM_SSH_KEY_DIR" => vm_ssh_key_dir,
          "VM_PACKAGE_LIST" => vm_package_list,
          "VM_UFW_ALLOW_APPS" => vm_ufw_allow_apps
        }
      end
    end
  end
end
