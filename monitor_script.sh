#!/bin/bash

# Path to 1.sh file
SCRIPT_FILE="/var/www/html/1.sh"

# Monitor for changes in the directory containing 1.sh
inotifywait -e close_write "$SCRIPT_FILE" | 
    while read -r directory events filename; do
        # Once 1.sh is closed for writing (download complete), execute update script
        /bin/bash /path/to/update_script.sh
    done
