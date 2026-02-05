#!/bin/bash

DEVICE_NAME=${1:-"battery_BAT0"}    # Default: battery_BAT0
CRON_EXP="${2:-"* * * * *"}"        # Default: every minute

# Check dependencies
missing=()
dependencies=("sqlite3" "upower" "curl" "grep" "awk" "crontab")
for cmd in "${dependencies[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done

if [ ${#missing[@]} -ne 0 ]; then
    echo "Error: The following dependencies are missing: ${missing[*]}"
    exit 1
fi

# Check if device exist (exact match on the last path component; non-noisy)
if ! upower -e | awk -F'/' '{print $NF}' | grep -Fx "$DEVICE_NAME" >/dev/null 2>&1; then
    echo "Error: Device '$DEVICE_NAME' not found."
    exit 1
fi

SCRIPT_NAME="uwatthour"
INSTALL_DIR="$HOME/.local/bin"
DB_DIR="$HOME/.local/share/uwatthour"

mkdir -p "$DB_DIR"
mkdir -p "$INSTALL_DIR"

if [ -f "$INSTALL_DIR/uwatthour" ]; then
    echo "Skipping install; uwatthour already installed at '$INSTALL_DIR/uwatthour'."
else
    echo "Installing..."
    curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/uwatthour.sh -o "$INSTALL_DIR/uwatthour" || {
        echo "Error: Failed to download uwatthour script."
        exit 1
    }

    chmod +x "$INSTALL_DIR/uwatthour" || {
        echo "Error: Failed to mark uwatthour as executable."
        exit 1
    }
fi

# Run check
if ! "$INSTALL_DIR/uwatthour" "$DEVICE_NAME"; then
    echo "Error: Unable to run uwatthour." >&2
    exit 1
fi

# Create cronjob
CRON_TAG="# uwatthour:$DEVICE_NAME"
CRON_CMD="$INSTALL_DIR/uwatthour $DEVICE_NAME"
(crontab -l 2>/dev/null | grep -vF "$CRON_TAG"; echo "$CRON_EXP $CRON_CMD $CRON_TAG") | crontab -

echo "Cronjob created for '$DEVICE_NAME'."
