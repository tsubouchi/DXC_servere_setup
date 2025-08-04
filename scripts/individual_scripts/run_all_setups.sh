#!/bin/bash

# Run all individual setup scripts
# This will create setup files for all users

echo "Running setup for all users..."
echo ""

for script in setup_800000*.sh; do
    if [ -f "$script" ]; then
        echo "Running $script..."
        ./"$script"
        echo ""
        echo "-----------------------------------"
        echo ""
    fi
done

echo "All setups completed!"
echo "Each user's files are in their respective workspaces_setup_* directories"
