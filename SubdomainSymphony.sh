#!/bin/bash

# Subdomain Symphony
# A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques.


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

# Create variable for target domain, active and fuzz options
domain=""
active=false
fuzz=false

# Scan with all passive tools and add to file
passive() {
  # Run subfinder and add to a file.
  subfinder -d "$domain" | tee -a bigDomain &

  # Run sublist3r and add to a file.
  python sublist3r.py -d "$domain" | tee -a bigDomain & 

  # Get subdoamins form crt.sh
  curl -s "https://crt.sh/?q=$domain&output=json" | jq -r '.[].common_name' | sed 's/*.//g' | sort -u | grep $domain | tee -a bigDomain &

  # Wait for all processes to finish
  wait
}

# Scan with all active tools and add to file
active() {
  # Run amass and add to a file.
  amass enum -d "$domain" | tee -a bigDomain
}


# Fuzz with ffuf and add to file
fuzz() {
  # Fuzz for subdomains with ffuf
  ffuf -w fuzzLists/subdomains-top1million-5000.txt -u FUZZ.$domain | tee fuzz
}

# Function to clean and combine results
clean() {
  cat bigDomain >> subdomains
  [ -f fuzz ] && cat fuzz >> subdomains
  sort -u subdomains -o subdomains
  cat subdomains | httpx | httprobe | tee subdomains
}


# Main function to call other functions
main() {
  passive
  
  if [ "$active" = true ]; then
    active
  fi

  if [ "$fuzz" = true ]; then
    fuzz
  fi

  clean
}

main
