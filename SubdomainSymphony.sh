#!/bin/bash

# Subdomain Symphony
# A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques.

# ANSI color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display help message
showHelp() {
  echo "Subdomain Symphony"
  echo "A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques."
  echo
  echo "Usage:"
  echo "  ./SubdomainSymphony.sh -d <domain> [-a] [-f] [-c] -o ~/example/"
  echo
  echo "Options:"
  echo "  -d    Specify the target domain"
  echo "  -a    Enable active scanning with amass"
  echo "  -f    Enable fuzzing for subdomains with ffuf"
  echo "  -c    Clean subdomain list with sort and httpx"
  echo "  -o    Output file"
  echo "  -h    Show this help message and exit"
  echo
  echo "Example:"
  echo "  ./SubdomainSymphony.sh -d example.com -a -f -c -o ~/example"
}

# Create variable for target domain, active and fuzz options
domain=""
passive=false
active=false
clean=false
output=""

# Parse command-line options
while getopts ":d:pacoh" opt; do
  case ${opt} in
    d )
      domain="$OPTARG"
      ;;
    p )
      passive=true
      ;;
    a )
      active=true
      ;;
    c )
      clean=true
      ;;
    o )
      output="$OPTARG"
      ;;
    h )
      showHelp
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
  showHelp
  exit 1
fi

# Scan with all passive tools and add to file
passiveScan() {
  # Run subfinder and add to a file.
  subfinder -d "$domain" | tee -a "$output"subdomains &&

  assetfinder -subs-only $domain | tee -a "$output"subdomains &&

  # Run sublist3r and add to a file.
  sublist3r -d "$domain" -o "$output"subdomains &&

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
  curl -s "https://crt.sh/?q=$domain&output=json" | jq -r '.[].common_name' | sed 's/*.//g' | sort -u | grep $domain | tee -a "$output"subdomains &&

  # Wait for all processes to finish
  wait
}


# Scan with all active tools and add to file
activeScan() {
  # Run amass and add to a file.
  amass enum -d cat.com | cut -d ' ' -f1  | sort -u | tee -a $output/subdomains

  # Fuzz for subdomains with ffuf
  ffuf -w subdomains-top1million-5000.txt -u https://FUZZ.$domain -o $output/fuzz
}



# Function to clean and combine results
cleanList() {
  sort -u subdomains -o subdomains
  cat subdomains | httpx-toolkit | tee $output/subdomains
}


# Main function to call other functions
main() {
  passiveScan

  if [ "$passive" = true ]; then
    passiveScan
  fi

  if [ "$active" = true ]; then
    activeScan
  fi

  if [ "$clean" = true ]; then
    cleanList
  fi
}

main
