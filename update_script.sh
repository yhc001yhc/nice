#!/bin/bash

# Path to 3000.txt and 1.sh files
ADDRESS_FILE="/var/www/html/3000.txt"
SCRIPT_FILE="/var/www/html/1.sh"

# Get the first address from 3000.txt
NEW_ADDRESS=$(head -n 1 "$ADDRESS_FILE")

# Check if address is retrieved successfully
if [ -z "$NEW_ADDRESS" ]; then
    echo "Failed to retrieve new address!"
    exit 1
fi

# Update WITHDRAW_ADDRESS in 1.sh script
sed -i "s/WITHDRAW_ADDRESS=\".*\"/WITHDRAW_ADDRESS=\"$NEW_ADDRESS\"/" "$SCRIPT_FILE"

# Move used address to the end of 3000.txt file
tail -n +2 "$ADDRESS_FILE" > "$ADDRESS_FILE.tmp"
echo "$NEW_ADDRESS" >> "$ADDRESS_FILE.tmp"
mv "$ADDRESS_FILE.tmp" "$ADDRESS_FILE"

echo "Address updated successfully!"
