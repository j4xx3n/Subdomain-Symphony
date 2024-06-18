#!/bin/bash

# Subdomain Symphony
# A script to orchestrate subdomain discovery using passive and active techniques.


# ANSI color codes
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display help message
showHelp() {
  echo
  echo -e "${RED}Subdomain Symphony${NC}"
  echo -e "${BLUE} A script to orchestrate subdomain discovery using passive and active techniques.${NC}"
  echo -e "${RED}By: J4xx3n${NC}"
  echo
  echo -e "${BLUE}Usage:${NC}"
  echo "  ./SubdomainSymphony.sh -d <domain> [-p] [-a] [-c]"
  echo
  echo -e "${BLUE}Options:${NC}"
  echo "  -d    Specify the target domain"
  echo "  -p    Enable passive scanning"
  echo "  -a    Enable active scanning"
  echo "  -c    Clean subdomain list"
  echo "  -h    Show this help message and exit"
  echo
  echo -e "${BLUE}Example:${NC}"
  echo "  ./SubdomainSymphony.sh -d example.com -p -a -c"
}

# Create variable for target domain, active and fuzz options
domain=""
passive=false
active=false
clean=false

# Parse command-line options
while getopts ":d:pach" opt; do
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
  echo
  echo -e "${RED}Subdomain Symphony${NC}"
  echo -e "${BLUE}Starting passive scan...${NC}"

  # Run sublist3r and add to a file.
  sublist3r -d "$domain" -o subdomains &&

  # Run subfinder and add to a file.
  subfinder -d "$domain" | tee -a subdomains &&

  # Run assetfinder and add to a file.
  assetfinder -subs-only $domain | tee -a subdomains &&

  # Wait for all processes to finish
  wait
}


# Scan with all active tools and add to file
activeScan() {
  echo
  echo -e "${RED}Subdomain Symphony${NC}"
  echo -e "${BLUE}Starting active scan...${NC}"

  # Run amass and add to a file.
  #amass enum -d cat.com | tee amass

  # Fuzz for subdomains with ffuf and add json to file
  ffuf -w subdomains-top1million-5000.txt -u https://FUZZ.$domain -o fuzz.json
  jq -r '.results[].url' fuzz.json | tee subdomains  # Parse subdomains from ffuf json file
}


# Function to clean and combine results
cleanList() {
  sort -u subdomains -o subdomains
  cat subdomains | httpx-toolkit | tee subdomains
}


# Main function to call other functions
main() {
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
