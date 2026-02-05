#!/bin/bash

VERSION="0.1.0"
case "${1:-}" in
  --version)
    echo "uwatthour $VERSION"
    exit 0
    ;;
esac

DEVICE_NAME=${1:-"battery_BAT0"}    # Default: battery_BAT0

# Create data dir, if not exist
DB_DIR="$HOME/.local/share/uwatthour"
mkdir -p "$DB_DIR"

# Create sqlite3 table
DB_NAME=uwatthour.sqlite
DB_PATH="$DB_DIR/$DB_NAME"
sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT (datetime('now','localtime')),
    device_name TEXT,
    energy_wh REAL,
    energy_full_wh REAL,
    energy_full_design_wh REAL
);"

# Extract data
DEVICE_PATH="/org/freedesktop/UPower/devices/$DEVICE_NAME"
RAW=$(upower -i "$DEVICE_PATH")
ENERGY=$(echo "$RAW" | awk '$1=="energy:" {print $2; exit}')
FULL=$(echo "$RAW" | awk '$1=="energy-full:" {print $2; exit}')
DESIGN=$(echo "$RAW" | awk '$1=="energy-full-design:" {print $2; exit}')

# Only insert if have data
if [ -n "$DEVICE_NAME" ] && [ -n "$ENERGY" ] && [ -n "$FULL" ] && [ -n "$DESIGN" ]; then
    DEVICE_NAME_SQL=${DEVICE_NAME//\'/\'\'} # Escape single quotes, if any
    sqlite3 "$DB_PATH" "INSERT INTO log (device_name, energy_wh, energy_full_wh, energy_full_design_wh)
    VALUES ('$DEVICE_NAME_SQL', $ENERGY, $FULL, $DESIGN);"
else
    echo "Error: Device $DEVICE_NAME has no energy data."
fi
