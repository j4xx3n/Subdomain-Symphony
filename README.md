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

##Usage
  `./SubdomainSymphony.sh -d <domain> [-p] [-a] [-c]`

Options:
  -d    Specify the target domain
  -p    Enable passive scanning
  -a    Enable active scanning
  -c    Clean subdomain list
  -h    Show this help message and exit

Example:
  `./SubdomainSymphony.sh -d example.com -p -a -c`
