# Linux-Incident-Response-collector-
Linux Incident Response Collector is a Bash-based defensive security tool designed to collect important system evidence after a suspected security incident.  The script gathers information that can help security analysts investigate suspicious activity, understand the current state of a Linux system, and identify possible indicators of compromise.

## REQUIREMENTS
bEFOTOR, ENSURE THAT THE SYSTEM HAS:

* a lINUX OPERATING SYSTEM
* bASH SHELL
* sTANDARD lINUX UTILITIES SUCH AS `PS`, `WHO`, `FIND`, `SS`, AND `SYSTEMCTL`
* gIT FOR CLONING THE REPOSITORY
* rOOT OR `SUDO` PERMISSIONS FOR COLLECTING COMPLETE SYSTEM EVIDENCE
sOME INFORMATION, SUCH AS PROCESS OWNERSHIP, OTHER USERS' COMMAND HISTORIES, SCHEDULED JOBS, AND NETWORK PROCESS DETAILS, MAY BE UNAVAILABLE WITHOUT ELEVATED PRIVILEGES.

## Project STRUCTURE 
    linux-incidenet-response-collector/
    |-- main.sh
    |-- config/
    |   |__ collector.conf
    |-- modules/
    |  |-- processes.sh
    |  |-- user.sh
    |  |-- network_connections.sh
    |  |-- listening_ports.sh
    |  |-- command_history.sh
    |  |-- system_info.sh
    |  |-- scheduled_jobs.sh
    |  |__  modifiied_files.sh
    | 
    |-- utils/
    |   |__ helpers.sh
    |
    |-- reports/
    |   |__ .gitkeep
    |
    |-- README.md
    |-- LICENSE
    |__ .gitignore

