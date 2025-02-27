#!/bin/bash

# Exit on the first command that returns a nonzero code
set -e

if ! which gcluster > /dev/null; then
    echo "Couldn't find gcluster. Installing from the source..."

    cd /opt
    sudo curl -o ./cluster-toolkit.zip -L "https://github.com/GoogleCloudPlatform/cluster-toolkit/archive/refs/tags/v1.46.1.zip"
    unzip cluster-toolkit.zip
    cd cluster-toolkit-1.46.1
    echo "Compiling gcluster..."

    make

    cd ..
    rm -rf cluster-toolkit.zip

    export PATH=$PATH:/opt/cluster-toolkit-1.46.1

    echo "Add the following to your shell configuration file, i.e., .bash_profile, .profile, .bashrc, etc."
    echo "\n"
    echo -e "\e[1;32mexport PATH=$PATH:/opt/cluster-toolkit-1.46.1\e[0m"
    echo "\n"
    echo "gcluster installed successfully."
else
    echo "gcluster is already installed. You are all set!"
fi
