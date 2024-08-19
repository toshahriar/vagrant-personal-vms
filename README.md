# Vagrant Personal VMs

## Overview

This project uses Vagrant to simplify the management of virtual machines. It provides a set of configuration files and provisioning scripts designed to automate the setup and customization of multiple VMs, streamlining the process of deploying and managing virtual environments. The included scripts handle various aspects of VM configuration, ensuring a consistent and efficient setup for development and testing purposes.

## File Structure

- `scripts/`: Directory containing provisioning scripts.
- `.env.example`: Example environment configuration file.
- `LICENSE`: License file for the project.
- `README.md`: This file.
- `Vagrantfile`: Configuration file for Vagrant to set up and manage VMs.

## Setup

1. **Clone the Repository:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Prepare Environment Configuration:**

   Copy `.env.example` to `.env` and update the values according to your setup:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` to configure VM settings such as IP addresses, memory, CPUs, etc.

3. **Install Vagrant and VirtualBox:**

   Ensure that you have Vagrant and VirtualBox installed on your system. You can download them from:

    - [Vagrant](https://www.vagrantup.com/)
    - [VirtualBox](https://www.virtualbox.org/)

4. **Initialize and Start VMs:**

   Run the following command to start and provision the VMs:

   ```bash
   vagrant up
   ```

5. **Provisioning:**

   The `scripts/provision.sh` script is used to set up the VMs as specified in the Vagrantfile. This script is executed during the provisioning phase.

## Files and Directories

- **`scripts/provision.sh`**: Provisioning script used for configuring the VMs. Modify this script if you need to customize the VM setup further.
- **`.env`**: Contains sensitive environment-specific configuration details. Ensure that this file is properly secured and not shared publicly.
- **`.env.example`**: Template for the `.env` file. Use this file to understand what variables need to be set in `.env`.

## Contributing

If you want to contribute to this project, please fork the repository and create a pull request with your changes. Make sure to follow the project's coding standards and guidelines.

## Contact

For any questions or support, please contact [shahriar.talk@gmail.com](mailto:shahriar.talk@gmail.com).

## License

This project is licensed under the following terms:

```
MIT License

Copyright (c) 2024 Shahriar Shabbir

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```