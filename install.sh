#!usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SOURCE_DIR="$(CD "$dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_DIR="/opt/lirc-collector"
COMMAND_PATH="/usr/local/bin/lirc"

if (( EUID != 0)); then
	echo "Error: installation requires root privileges." >&2
	echo "Run: sudo bash install.sh" >&2
	exit 1
fi

required_paths=(
	"$SOURCE_DIR/main.sh"
	"$SOURCE_DIR/config"
	"$SOURCE_DIR/modules"
	"$SOURCE_DIR/utils"
)

for required_path in "${required_paths[@]}"; do 
	if [[ ! -e "$required_path" ]]; then
		echo "Error: required path is missing: $required_path" >$2
		exit 1
	fi
done

echo "Installing LIRC..."

install -d -o root -g root -m 755 "$INSTALL_DIR"

cp -R -- \
	"$SOURCE_DIR/main.sh" \
	"$SOURCE_DIR/config" \
	"$SOURCE_DIR/modules" \
	"$SOURCE_DIR/utils" \
	"$INSTALL_DIR/"

chown -R root:root "$INSTALL_DIR"

find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
find "$INSTALL_DIR" -type f -exec chmod 644 {} \;

chmod 755 "$INSTALL_DIR/main.sh"
chmod 755 "$INSTALL_DIR/modules/"*.sh
chmod 755 "$INSTALL_DIR/utils/"*.sh


##################### commmand launcher ##########################################

cat >"$COMMAND_PATH" <<'LIRC_COMMAND'
#!/usr/bin/env bash

readonly LIRC_MAIN="/opt/lirc-collector/main.sh"

if [[ ! -x "$LIRC_MAIN" ]]; then
	echo "Error: LIRC installation is incomplete." >&2
	echo "Missing executabel: $LIRC_MAIN" >&2
	exit 1
fi

exec "$LIRC_MAIN" "$@"
LIRC_COMMAND

chown root:root "$COMMAND_PATH"
chmod 755 "$COMMAND_PATH"

echo 
echo "LIRC isntalled successfully."
echo "Command: $COMMAND_PATH"
echo 
echo "start the application with:"
echo " lirc"
