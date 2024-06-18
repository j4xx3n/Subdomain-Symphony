#!/bin/bash

# Subdomain Symphony
# A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques.

# ANSI color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display help message
show_help() {
  echo "Subdomain Symphony"
  echo "A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques."
  echo
  echo "Usage:"
  echo "  ./SubdomainSymphony.sh -d <domain> [-a] [-f]"
  echo
  echo "Options:"
  echo "  -d    Specify the target domain"
  echo "  -a    Enable active scanning with amass"
  echo "  -f    Enable fuzzing for subdomains with ffuf"
  echo "  -h    Show this help message and exit"
  echo
  echo "Example:"
  echo "  ./SubdomainSymphony.sh -d example.com -a -f"
}

# Create variable for target domain, active and fuzz options
domain=""
active=false
fuzz=false

# Parse command-line options
while getopts ":d:afh" opt; do
  case ${opt} in
    d )
      domain="$OPTARG"
      ;;
    a )
      active=true
      ;;
    f )
      fuzz=true
      ;;
    h )
      show_help
      exit 0
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      show_help
      exit 1
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      show_help
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check if domain is provided
if [ -z "$domain" ]; then
  echo "Error: Domain is required."
  show_help
  exit 1
fi

# Scan with all passive tools and add to file
passiveScan() {
  # Run sublist3r and add to a file.
  sublist3r -d "$domain" -o bigDomain &&

  # Run subfinder and add to a file.
  subfinder -d "$domain" | tee -a bigDomain &&

  # Get subdoamins form crt.sh
  echo "
            _         _     
   ___ _ __| |_   ___| |__  
  / __| '__| __| / __| '_ \ 
 | (__| |  | |_ _\__ \ | | |
  \___|_|   \__(_)___/_| |_|

  "
  echo -e "${RED}Checking crt.sh${NC}"
  echo
  curl -s "https://crt.sh/?q=$domain&output=json" | jq -r '.[].common_name' | sed 's/*.//g' | sort -u | grep $domain | tee -a bigDomain &&

  # Wait for all processes to finish
  wait
}


# Scan with all active tools and add to file
activeScan() {
  # Run amass and add to a file.
  amass enum -d "$domain" | tee -a bigDomain
}


# Fuzz with ffuf and add to file
fuzzScan() {
  # Fuzz for subdomains with ffuf
  ffuf -w subdomains-top1million-5000.txt -u https://FUZZ.$domain -o fuzz
}

# Function to clean and combine results
clean() {
  cat bigDomain >> subdomains
  [ -f fuzz ] && cat fuzz >> subdomains
  sort -u subdomains -o subdomains
  cat subdomains | httpx | tee subdomains
}


# Main function to call other functions
main() {
  passiveScan

  if [ "$active" = true ]; then
    activeScan
  fi

  if [ "$fuzz" = true ]; then
    fuzzScan
  fi

  #clean
}

main
