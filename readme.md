# uwatthour

A cronjob extracting energy (Wh) from upower dbus into sqlite for further analysis.

If you encounter any issues, please report them promptly [here](https://github.com/nazebzurati/uwatthour/issues). Additionally, feel free to request any necessary features [here](https://github.com/nazebzurati/uwatthour/issues).

## Install

```sh
# get upower devices
upower -e | awk -F'/' '{print $NF}'

# get battery upower device
upower -e | awk -F'/' '/_BAT/ {print $NF}'

# install run cron for default device 'battery_BAT0' and log for every minute
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash

# run cron for device 'battery_BAT1' and log for every minute
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash -s -- battery_BAT1

# run cron for device 'battery_BAT2' and log for every 5 minutes
curl -fsSL https://github.com/nazebzurati/uwatthour/releases/latest/download/install.sh | bash -s -- battery_BAT2 "*/5 * * * *"

# if installed, get version
uwatthour --version
```

## Uninstall

```sh
# Remove cronjob
crontab -l 2>/dev/null | grep -vE '# uwatthour:' | crontab -                # Remove all
crontab -l 2>/dev/null | grep -vF "# uwatthour:battery_BAT0" | crontab -    # Remove specific device (e.g. battery_BAT0)

# Uninstall
rm -f ~/.local/bin/uwatthour    # Delete script
rm -rf ~/.local/share/uwatthour # Delete history including uwatthour.sqlite
```

## Notes

The log will be saved in `~/.local/share/uwatthour/uwatthour.sqlite`.

If installed, you can insert data point manually into sqlite log by running the following command.
```sh
uwatthour [device] # e.g. uwatthour battery_BAT0
```

You can view log created by running the following sqlite3 command or use any sqlite viewer (e.g. [sqlitebrowser](https://sqlitebrowser.org/dl/)).
```sh
sqlite3 ~/.local/share/uwatthour/uwatthour.sqlite "SELECT * FROM log ORDER BY timestamp DESC LIMIT 100;"
```

You can check cronjob created by running the following command.
```sh
crontab -l | grep -n 'uwatthour' || echo "No uwatthour cronjobs found"
```

> [!IMPORTANT]  
>  If you reinstall or switch operating systems, back up your SQLite database and restore it to the same path (`~/.local/share/uwatthour/uwatthour.sqlite`) on the new system to continue logging into the existing history.
