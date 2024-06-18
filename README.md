# Subdomain-Symphony
 A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques.

## Installation Steps

Follow these steps to set up the project:

1. Clone the repository:
    ```sh
    git clone https://github.com/j4xx3n/Subdomain-Symphony.git
    ```

2. Navigate to the project directory:
    ```sh
    cd Subdomain-Symphony
    ```

3. Make the shell scripts executable:
    ```sh
    chmod u+x *.sh
    ```

4. Run the installer script:
    ```sh
    ./kali-installer.sh
    ```


echo
echo -e "${RED}Subdomain Symphony${NC}"
echo -e "${BLUE}A script to orchestrate subdomain discovery using passive, active, and fuzzing techniques.${NC}"
echo -e "${RED}By${NC}"
echo
echo -e "${BLUE}Usage:${NC}"
echo " ./SubdomainSymphony.sh -d <domain> [-p] [-a] [-c]"
echo
echo -e "${BLUE}Options:${NC}"
echo " -d Specify the target domain"
echo " -p Enable passive scanning"
echo " -a Enable active scanning"
echo " -c Clean subdomain list"
echo " -h Show this help message and exit"
echo
echo -e "${BLUE}Example:${NC}"
echo " ./SubdomainSymphony.sh -d example.com -p -a -c"
