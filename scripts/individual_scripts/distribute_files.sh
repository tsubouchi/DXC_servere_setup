#!/bin/bash

# Script to package individual user files for distribution

echo "Packaging user files for distribution..."

# Create distribution directory
mkdir -p distribution

# Package each user's files
for dir in workspaces_setup_*; do
    if [ -d "$dir" ]; then
        username=$(echo "$dir" | sed 's/workspaces_setup_//')
        zip_file="distribution/${username}_workspaces_setup.zip"
        
        # Create encrypted zip file (requires password)
        zip -er "$zip_file" "$dir"
        
        echo "Created: $zip_file"
    fi
done

echo ""
echo "Distribution packages created in 'distribution' directory"
echo "Each zip file is password-protected for security"
