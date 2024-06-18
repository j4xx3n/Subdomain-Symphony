#!/bin/bash

# Update package list and install dependencies
sudo apt update
sudo apt install -y subfinder sublist3r jq amass ffuf curl httprobe httpx

# Ensure sublist3r is installed via pip3 (as it's often installed this way)
pip3 install sublist3r

# Clone sublist3r repository if sublist3r.py is not in the PATH
if ! command -v sublist3r &> /dev/null; then
  git clone https://github.com/aboul3la/Sublist3r.git
  cd Sublist3r
  sudo ln -s "$(pwd)/sublist3r.py" /usr/local/bin/sublist3r
  cd ..
fi
