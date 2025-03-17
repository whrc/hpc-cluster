#!/bin/sh
echo "Hello, world!" > /home/startup_script.txt
apt-get install tree -y

echo "=== Installing Python 3.11.3 and dependencies ==="

# Update package lists
apt update -y
echo "STEP COMPLETE: Package lists updated"

# Configure apt to not prompt for confirmations
export DEBIAN_FRONTEND=noninteractive
echo "STEP COMPLETE: Set DEBIAN_FRONTEND to noninteractive"

# Install necessary build tools and libraries
echo "=== Installing system dependencies ==="
apt install -y software-properties-common build-essential wget curl
echo "STEP COMPLETE: Installed system dependencies (build tools and libraries)"

# Add deadsnakes PPA without confirmation
echo "=== Adding deadsnakes PPA ==="
add-apt-repository -y ppa:deadsnakes/ppa
echo "STEP COMPLETE: Added deadsnakes PPA repository"
apt update -y
echo "STEP COMPLETE: Updated package lists after adding PPA"

# Install Python 3.11.3
echo "=== Installing Python 3.11.3 ==="
apt install -y python3.11 python3.11-dev python3.11-distutils python3.11-venv
echo "STEP COMPLETE: Installed Python 3.11 and related packages"

# Install pip for Python 3.11
echo "=== Installing pip for Python 3.11 ==="
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
echo "STEP COMPLETE: Downloaded get-pip.py"
python3.11 get-pip.py
echo "STEP COMPLETE: Installed pip for Python 3.11"
rm get-pip.py
echo "STEP COMPLETE: Removed get-pip.py file"

# Install dependencies for geospatial and scientific packages
echo "=== Installing system dependencies for geospatial and scientific packages ==="
DEBIAN_FRONTEND=noninteractive apt install -y libhdf5-dev netcdf-bin libnetcdf-dev
echo "STEP COMPLETE: Installed geospatial and scientific system dependencies"

# Create and set permissions for /data folder
echo "=== Creating /data folder with read/write permissions for all users ==="
mkdir -p /data
echo "STEP COMPLETE: Created /data directory"
chmod 1777 /data
echo "STEP COMPLETE: Set sticky bit permissions (1777) on /data directory"

# Create a virtual environment
echo "=== Creating Python virtual environment ==="
python3.11 -m venv /data/venv
echo "STEP COMPLETE: Created Python virtual environment at /data/venv"

# Install Python packages in the virtual environment
echo "=== Installing Python packages in virtual environment ==="
source /data/venv/bin/activate
echo "STEP COMPLETE: Activated virtual environment"
pip install --upgrade pip
echo "STEP COMPLETE: Upgraded pip in virtual environment"

chmod 1777 -R /data/venv
