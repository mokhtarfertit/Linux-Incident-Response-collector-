# LIRC — Linux Incident Response Collector

```text
 __       __   _______       _____
|  |     |  | |   _   \     /     |
|  |     |  | |  |_)  |    |  ,---'
|  |     |  | |      /     |  |
|  `----.|  | |  |\  \--.  |  `----.
|_______||__| | _| `.___|    \_____|

       LINUX INCIDENT RESPONSE COLLECTOR
```

LIRC is a modular Bash tool for collecting live-response evidence from a Linux system after a suspected security incident. It can run every enabled collector or let the operator choose individual collectors from an interactive terminal menu.

> [!IMPORTANT]
> LIRC performs live-system triage. It is not a replacement for forensic disk imaging, memory acquisition, evidence hashing, or a documented chain-of-custody process. Test it before using it during a real incident.

## Features

- Collect all enabled modules or select specific modules.
- Enable and disable collectors through one configuration file.
- Store standard output and standard error separately for every module.
- Create UTC timestamped incident directories with random suffixes.
- Protect report directories with root ownership and mode `0700`.
- Launch from any directory with the global `lirc` command.
- Request root privileges automatically through `sudo`.
- Use `netstat` as a fallback when `ss` is unavailable.

## Evidence collectors

| Collector | Evidence | Sources |
|---|---|---|
| System information | Host, kernel, OS, time, uptime, CPU, memory and disks | `hostname`, `uname`, `/etc/os-release`, `hostnamectl`, `lscpu`, `free`, `lsblk` |
| Running processes | IDs, owners, start time, state, resource use and arguments | `ps -eo` |
| Logged-in users | Current sessions and recent login records | `who -a`, `last` |
| Network connections | Interfaces, IPv4/IPv6 routes and active sockets | `ip`, `ss` or `netstat` |
| Listening ports | Listening TCP/UDP sockets and process details | `ss` or `netstat` |
| Scheduled jobs | Current user's crontab | `crontab -l` |
| Command history | Bash, Zsh and shell history found through users' home directories | `/etc/passwd`, history files |
| Modified files | Recently modified regular files in validated paths | `find` |
| System logs | Journal, authentication, system and kernel logs | `journalctl`, traditional files, `dmesg` |

The system-log collector is still under active development on the `dev` branch and requires further testing.

## Requirements

- Linux and Bash
- Root privileges through `sudo`
- Git for cloning
- Standard Linux utilities required by enabled collectors

For broad coverage, the system should provide:

```text
ps who last find ip ss crontab hostname uname date uptime
lscpu free lsblk journalctl tail dmesg
```

`netstat` is an optional fallback for `ss`.

## Installation

Clone the current development branch:

```bash
git clone --branch dev \
    https://github.com/mokhtarfertit/Linux-Incident-Response-collector-.git

cd Linux-Incident-Response-collector-
```

Validate and install:

```bash
bash -n install.sh
bash -n bin/lirc
sudo bash install.sh
```

The installer creates:

| Location | Purpose |
|---|---|
| `/opt/lirc-collector/` | Application, configuration, modules and helpers |
| `/usr/local/bin/lirc` | Global launcher |
| `/var/lib/lirc-collector/reports/` | Root-only evidence reports |

Verify the installation:

```bash
command -v lirc
ls -l /usr/local/bin/lirc
sudo ls -ld /var/lib/lirc-collector/reports
```

`command -v lirc` should print `/usr/local/bin/lirc`.

## Usage

Start the application from any directory:

```bash
lirc
```

The launcher requests root privileges and starts `/opt/lirc-collector/main.sh`. Normally, type `lirc`, not `sudo lirc`.

The menu provides:

```text
1. Collect all enabled evidence
2. Select specific evidence modules
3. Exit
```

For option 2, enter module numbers separated by spaces, for example:

```text
1 3 5 9
```

A module disabled in the configuration cannot be selected.

## Reports

Reports are stored in:

```text
/var/lib/lirc-collector/reports/
```

Each run creates a directory similar to:

```text
incident_2026-08-15_14-30-00Z_A1b2C3/
```

Every collector produces an evidence file and an error file:

```text
system_info.txt
system_info.stderr.txt
```

- `*.txt` contains the report header and evidence.
- `*.stderr.txt` contains warnings and errors and may be empty.

Inspect reports with:

```bash
sudo ls -la /var/lib/lirc-collector/reports
sudo find /var/lib/lirc-collector/reports -maxdepth 2 -type f -print
```

Reports contain sensitive data. Do not use `chmod 777` on evidence directories.

## Configuration

Edit the installed configuration:

```bash
sudo nano /opt/lirc-collector/config/config.collector.conf
bash -n /opt/lirc-collector/config/config.collector.conf
```

### Limits and paths

| Option | Default | Purpose |
|---|---:|---|
| `MODIFIED_DAYS` | `7` | Previous days searched for modified files; valid range 1–365 |
| `MAX_LOGIN_RECORDS` | `50` | Maximum records requested from `last` |
| `SCAN_PATH` | `/etc /home /tmp /var/tmp` | Directories searched for modified files |
| `EXCLUDED_PATHS` | system pseudo-filesystems and mounts | Planned exclusions; not applied by the current collector |
| `LOG_DAYS` | `7` | Previous days requested from journal sources |
| `MAX_LOG_LINES` | `20000` | Maximum lines read from each log source |

`SCAN_PATH` is a Bash array:

```bash
SCAN_PATH=(
    "/etc"
    "/home"
    "/tmp"
    "/var/tmp"
)
```

### Module switches

Only `true` and `false` are valid:

```bash
COLLECT_SYSTEM_INFO=true
COLLECT_PROCESSES=true
COLLECT_USERS=true
COLLECT_NETWORK_CONNECTIONS=true
COLLECT_LISTENING_PORTS=true
COLLECT_SCHEDULED_JOBS=true
COLLECT_COMMAND_HISTORY=true
COLLECT_MODIFIED_FILES=true
COLLECT_SYSTEM_LOGS=true
```

For example:

```bash
COLLECT_USERS=false
```

### Reserved options

These options exist but are not fully implemented in the current execution flow:

```bash
INCLUDE_COMMAND_ERRORS=true
CREATE_SUMMARY_REPORT=true
COMPRESS_REPORT=false
```

Do not depend on them until their implementations are completed and tested.

## Project structure

```text
Linux-Incident-Response-collector-/
├── bin/
│   └── lirc
├── config/
│   └── config.collector.conf
├── doc/
├── modules/
│   ├── command_history.sh
│   ├── listening_ports.sh
│   ├── modified_files.sh
│   ├── network_connections.sh
│   ├── processes.sh
│   ├── scheduled_jobs.sh
│   ├── system_info.sh
│   ├── system_logs.sh
│   └── user.sh
├── utils/
│   └── helpers.sh
├── install.sh
├── main.sh
└── README.md
```

- `main.sh` loads configuration/modules, validates startup, shows the menu and runs collectors.
- `utils/helpers.sh` provides shared validation, logging, module metadata and execution helpers.
- `modules/*.sh` contains the evidence collectors.
- `config/config.collector.conf` contains limits, paths and module switches.
- `bin/lirc` starts the installed main script with root privileges.
- `install.sh` installs the command, application and protected report directory.

## Troubleshooting

### `lirc: command not found`

```bash
ls -l /usr/local/bin/lirc
command -v lirc
hash -r
```

Re-run `sudo bash install.sh` if the launcher is absent.

### `sudo: lirc: command not found`

Some `sudo` configurations exclude `/usr/local/bin` from `secure_path`. Run:

```bash
lirc
```

The launcher invokes `sudo` internally. For diagnosis:

```bash
sudo /usr/local/bin/lirc
```

### Report directory permission error

```bash
sudo ls -ld /var/lib/lirc-collector/reports
sudo install -d -o root -g root -m 700 \
    /var/lib/lirc-collector/reports
```

### Collector command unavailable

```bash
command -v COMMAND_NAME
echo "$PATH"
```

Install the relevant package or disable that module.

### Locate incidents

```bash
sudo find /var/lib/lirc-collector /opt/lirc-collector \
    -type d -name 'incident_*' 2>/dev/null
```

## Development checks

```bash
bash -n main.sh
bash -n install.sh
bash -n bin/lirc

for file in modules/*.sh utils/*.sh; do
    bash -n "$file" || exit 1
done
```

When ShellCheck is installed:

```bash
shellcheck main.sh install.sh bin/lirc modules/*.sh utils/*.sh
```

Do not commit editor swap files such as `.swp`, `.swo`, or `.swn`.

## Current development status

Before the `dev` branch is release-ready, it still needs:

- Correction and full testing of the system-log collector.
- Implementation or removal of reserved configuration options.
- Application of `EXCLUDED_PATHS` in the modified-files collector.
- Summary generation, archive creation and integrity hashes.
- Automated tests and continuous integration.
- A documented release version and license.

## Security and privacy

Reports may contain usernames, processes, command histories, network endpoints, scheduled commands, paths and authentication records. Keep reports encrypted during storage and transfer, restrict access, and collect only from systems you are authorized to investigate.

## Contributing

Work from the `dev` branch, keep each collector focused on one evidence category, preserve errors on standard error, and run syntax checks before opening a pull request.

Repository: <https://github.com/mokhtarfertit/Linux-Incident-Response-collector->
