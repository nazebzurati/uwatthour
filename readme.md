# uwatthour

A cronjob extracting energy (Wh) from upower dbus into sqlite for further analysis.

If you encounter any issues, please report them promptly [here](https://github.com/nazebzurati/uwatthour/issues). Additionally, feel free to request any necessary features [here](https://github.com/nazebzurati/uwatthour/issues).

## Install

```sh
# get upower devices
upower -e | awk -F'/' '{print $NF}'

# get battery upower device
upower -e | awk -F'/' '/_BAT/ {print $NF}'

# run cron for default device 'battery_BAT0' and log for every minute
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash

# run cron for device 'battery_BAT1' and log for every minute
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash -s -- battery_BAT1

# run cron for device 'battery_BAT2' and log for every 5 minutes
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash -s -- battery_BAT2 "*/5 * * * *"
```

The log will be saved in `~/.local/share/uwatthour/uwatthour.sqlite`. You can view using `sqlite3 ~/.local/share/uwatthour/uwatthour.sqlite "SELECT * FROM log ORDER BY timestamp DESC LIMIT 100;"` or use a sqlite viewer (e.g. [sqlitebrowser](https://sqlitebrowser.org/dl/)).

> [!IMPORTANT]  
>  If you reinstall or switch operating systems, back up your SQLite database and restore it to the same path (`~/.local/share/uwatthour/uwatthour.sqlite`) on the new system to continue logging into the existing history.

## Uninstall

```sh
# Check existing cronjobs
crontab -l | grep -n 'uwatthour' || echo "No uwatthour cronjobs found"

# Remove all
crontab -l 2>/dev/null | grep -vE '# uwatthour:' | crontab -

# Remove specific device (e.g. battery_BAT0)
crontab -l 2>/dev/null | grep -vF "# uwatthour:battery_BAT0" | crontab -

# Uninstall
rm -f ~/.local/bin/uwatthour    # delete script
rm -rf ~/.local/share/uwatthour # delete history including uwatthour.sqlite
```
