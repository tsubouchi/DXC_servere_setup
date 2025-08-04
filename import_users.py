#!/usr/bin/env python3

"""
Amazon WorkSpaces User Import Script
This script imports user data from Excel files and generates setup configurations
"""

import os
import sys
import json
import argparse
import pandas as pd
from pathlib import Path
from datetime import datetime

class WorkSpacesUserImporter:
    def __init__(self, workspaces_file, mfa_file):
        self.workspaces_file = workspaces_file
        self.mfa_file = mfa_file
        self.users = {}
        self.registration_code = None
        
    def load_workspaces_data(self):
        """Load WorkSpaces connection data from Excel file"""
        try:
            # Load login info sheet
            df_login = pd.read_excel(self.workspaces_file, sheet_name='ログイン情報')
            
            # Extract registration code
            for idx, row in df_login.iterrows():
                if pd.notna(row.get('Unnamed: 1')) and row['Unnamed: 1'] == '登録コード':
                    self.registration_code = str(row.get('Unnamed: 2', '')).strip()
                    break
            
            # Load user info sheet
            df_users = pd.read_excel(self.workspaces_file, sheet_name='サインイン情報')
            
            # Process user data
            for idx, row in df_users.iterrows():
                username = str(row.get('Unnamed: 1', '')).strip()
                if username and username.startswith('800000'):
                    self.users[username] = {
                        'username': username,
                        'last_name': str(row.get('Unnamed: 2', '')).strip(),
                        'first_name': str(row.get('Unnamed: 3', '')).strip(),
                        'full_name_en': str(row.get('Unnamed: 4', '')).strip(),
                        'initial_password': str(row.get('Unnamed: 5', '')).strip(),
                    }
            
            print(f"Loaded {len(self.users)} users from WorkSpaces file")
            print(f"Registration Code: {self.registration_code}")
            
        except Exception as e:
            print(f"Error loading WorkSpaces data: {e}")
            sys.exit(1)
    
    def load_mfa_data(self):
        """Load MFA data from Excel file"""
        try:
            # Load all sheets to find MFA data
            all_sheets = pd.read_excel(self.mfa_file, sheet_name=None)
            
            for sheet_name, df in all_sheets.items():
                # Look for MFA data in the sheet
                for col in df.columns:
                    # Find username in the data
                    username_found = None
                    secret_key = None
                    qr_url = None
                    
                    for idx, row in df.iterrows():
                        # Check if row contains username
                        if pd.notna(row.get('Unnamed: 1')):
                            if row['Unnamed: 1'] == 'ユーザー名' and pd.notna(row.get('Unnamed: 2')):
                                username_found = str(row['Unnamed: 2']).strip()
                            elif row['Unnamed: 1'] == 'シークレットコード' and pd.notna(row.get('Unnamed: 2')):
                                secret_key = str(row['Unnamed: 2']).strip()
                            elif row['Unnamed: 1'] == 'QRコードへのアクセスURL' and pd.notna(row.get('Unnamed: 2')):
                                qr_url = str(row['Unnamed: 2']).strip()
                    
                    # Update user data if found
                    if username_found and username_found in self.users:
                        if secret_key:
                            self.users[username_found]['mfa_secret'] = secret_key
                        if qr_url:
                            self.users[username_found]['mfa_qr_url'] = qr_url
                        print(f"Loaded MFA data for user: {username_found}")
                        
        except Exception as e:
            print(f"Error loading MFA data: {e}")
            # Continue without MFA data
    
    def generate_setup_files(self, output_dir='users'):
        """Generate setup files for all users"""
        # Create output directory
        Path(output_dir).mkdir(exist_ok=True)
        
        # Generate shell script for batch processing
        shell_script = f"""#!/bin/bash
# Auto-generated WorkSpaces setup script
# Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

# Registration code
REGISTRATION_CODE="{self.registration_code}"

# User data
declare -A users_data
"""
        
        for username, data in self.users.items():
            # Create user directory
            user_dir = Path(output_dir) / username
            user_dir.mkdir(exist_ok=True)
            
            # Create .env.local file
            env_content = f"""# Amazon WorkSpaces Configuration
WORKSPACES_REGISTRATION_CODE={self.registration_code}

# User Credentials
WORKSPACES_USERNAME={username}
WORKSPACES_INITIAL_PASSWORD={data.get('initial_password', '')}

# User Info
USER_LAST_NAME="{data.get('last_name', '')}"
USER_FIRST_NAME="{data.get('first_name', '')}"
USER_FULL_NAME_EN="{data.get('full_name_en', '')}"
"""
            
            # Add MFA data if available
            if 'mfa_secret' in data:
                env_content += f"""
# MFA Configuration
MFA_SECRET_KEY={data['mfa_secret']}
"""
            if 'mfa_qr_url' in data:
                env_content += f"""MFA_QR_URL={data['mfa_qr_url']}
"""
            
            # Write .env.local file
            with open(user_dir / '.env.local', 'w', encoding='utf-8') as f:
                f.write(env_content)
            
            # Add to shell script
            full_name = f"{data.get('full_name_en', '')} ({data.get('last_name', '')} {data.get('first_name', '')})"
            shell_script += f'users_data["{username}"]="{full_name}"\n'
        
        shell_script += """
# Function to display all users
list_users() {
    echo "Available users:"
    for username in "${!users_data[@]}"; do
        echo "  $username: ${users_data[$username]}"
    done | sort
}

# Main menu
case "$1" in
    "list")
        list_users
        ;;
    *)
        echo "Usage: $0 {list}"
        echo ""
        echo "Commands:"
        echo "  list - List all imported users"
        ;;
esac
"""
        
        # Write shell script
        with open(Path(output_dir) / 'manage_users.sh', 'w') as f:
            f.write(shell_script)
        
        # Make shell script executable
        os.chmod(Path(output_dir) / 'manage_users.sh', 0o755)
        
        # Generate summary report
        summary = f"""Amazon WorkSpaces User Import Summary
=====================================
Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Registration Code: {self.registration_code}

Users Imported: {len(self.users)}
--------------
"""
        for username, data in sorted(self.users.items()):
            summary += f"\n{username}: {data.get('full_name_en', '')} ({data.get('last_name', '')} {data.get('first_name', '')})"
            if 'mfa_secret' in data:
                summary += " [MFA Configured]"
        
        # Write summary
        with open(Path(output_dir) / 'import_summary.txt', 'w', encoding='utf-8') as f:
            f.write(summary)
        
        print(f"\nSetup files generated in '{output_dir}' directory")
        print(f"Total users processed: {len(self.users)}")

def main():
    parser = argparse.ArgumentParser(description='Import WorkSpaces users from Excel files')
    parser.add_argument('--workspaces', '-w', required=True, 
                        help='Path to WorkSpaces Excel file')
    parser.add_argument('--mfa', '-m', 
                        help='Path to MFA Excel file (optional)')
    parser.add_argument('--output', '-o', default='users',
                        help='Output directory (default: users)')
    
    args = parser.parse_args()
    
    # Check if files exist
    if not os.path.exists(args.workspaces):
        print(f"Error: WorkSpaces file not found: {args.workspaces}")
        sys.exit(1)
    
    # Create importer
    importer = WorkSpacesUserImporter(args.workspaces, args.mfa)
    
    # Load data
    print("Loading WorkSpaces data...")
    importer.load_workspaces_data()
    
    if args.mfa and os.path.exists(args.mfa):
        print("\nLoading MFA data...")
        importer.load_mfa_data()
    else:
        print("\nNo MFA file provided or file not found, skipping MFA data")
    
    # Generate setup files
    print("\nGenerating setup files...")
    importer.generate_setup_files(args.output)
    
    print("\nImport completed successfully!")

if __name__ == "__main__":
    main()