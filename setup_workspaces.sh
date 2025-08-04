#!/bin/bash

# Amazon WorkSpaces Setup Script
# This script helps automate the setup process for WorkSpaces users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to setup individual user
setup_user() {
    local username=$1
    local fullname=$2
    local secret_key=$3
    local qr_url=$4
    
    print_info "Setting up user: $username ($fullname)"
    
    # Create user-specific directory
    mkdir -p "users/$username"
    
    # Create user-specific .env file
    cat > "users/$username/.env.local" << EOF
# Amazon WorkSpaces Configuration
WORKSPACES_REGISTRATION_CODE=wsnrt+KEQA4Y

# User Credentials
WORKSPACES_USERNAME=$username
WORKSPACES_INITIAL_PASSWORD=98765@dxj

# MFA Configuration
MFA_SECRET_KEY=$secret_key
MFA_QR_URL=$qr_url

# User Info
USER_FULLNAME="$fullname"
EOF
    
    # Generate QR code if qrencode is installed
    if command_exists qrencode; then
        qrencode -o "users/$username/mfa_qr.png" "$qr_url"
        print_info "QR code saved to users/$username/mfa_qr.png"
    fi
    
    # Create user-specific README
    cat > "users/$username/README.md" << EOF
# WorkSpaces Setup for $fullname

## Your Login Information
- **Username**: $username
- **Initial Password**: 98765@dxj
- **Registration Code**: wsnrt+KEQA4Y

## MFA Setup
1. Install Google Authenticator or Microsoft Authenticator on your phone
2. Scan the QR code in mfa_qr.png or use the secret key below
3. **Secret Key**: $secret_key

## Important Notes
- Change your password immediately after first login
- Keep your MFA secret key secure
- Do not share this information with anyone
EOF
    
    print_info "Setup completed for $username"
}

# Function to generate MFA secret and QR URL
generate_mfa_info() {
    local username=$1
    local issuer="DXJ-SV-0327"
    
    # Generate random secret key (32 characters, base32)
    if command_exists openssl; then
        secret=$(openssl rand -base64 20 | tr -d "=+/" | cut -c1-32 | tr '[:lower:]' '[:upper:]')
    else
        # Fallback to using /dev/urandom
        secret=$(LC_ALL=C tr -dc 'A-Z2-7' < /dev/urandom | head -c32)
    fi
    
    # Create QR URL
    qr_url="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=otpauth://totp/${username}@${issuer}?secret=${secret}&issuer=${issuer}"
    
    echo "$secret|$qr_url"
}

# Main script
main() {
    print_info "Amazon WorkSpaces Setup Script"
    print_info "=============================="
    
    # Check for required tools
    if ! command_exists openssl && ! [ -e /dev/urandom ]; then
        print_error "Neither openssl nor /dev/urandom available. Cannot generate secure keys."
        exit 1
    fi
    
    # Create base directories
    mkdir -p users
    mkdir -p logs
    
    # User data (you can modify this list or read from a CSV file)
    declare -A users=(
        ["8000000043"]="Kodama Naoki|児玉 直樹"
        ["8000000044"]="Ando Ryuhei|安東 竜平"
        ["8000000045"]="Kishida Takashi|岸田 崇史"
        ["8000000046"]="Tsuneshige Yusuke|常重 友佑"
        ["8000000047"]="Ikeda Masaki|池田 昌樹"
        ["8000000048"]="Tsubochi Koki|坪内 弘毅"
        ["8000000049"]="Kusuda Kayo|楠田 佳世"
        ["8000000050"]="Ishida Shogo|石田 彰吾"
    )
    
    # Process command line arguments
    case "$1" in
        "all")
            print_info "Setting up all users..."
            for username in "${!users[@]}"; do
                IFS='|' read -r fullname_en fullname_jp <<< "${users[$username]}"
                mfa_info=$(generate_mfa_info "$username")
                IFS='|' read -r secret qr_url <<< "$mfa_info"
                setup_user "$username" "$fullname_en ($fullname_jp)" "$secret" "$qr_url"
            done
            ;;
        "single")
            if [ -z "$2" ]; then
                print_error "Please specify a username"
                echo "Usage: $0 single <username>"
                exit 1
            fi
            username=$2
            if [ -z "${users[$username]}" ]; then
                print_error "User $username not found"
                exit 1
            fi
            IFS='|' read -r fullname_en fullname_jp <<< "${users[$username]}"
            
            # Check if we have existing MFA info
            if [ -n "$3" ] && [ -n "$4" ]; then
                # Use provided MFA info
                setup_user "$username" "$fullname_en ($fullname_jp)" "$3" "$4"
            else
                # Generate new MFA info
                mfa_info=$(generate_mfa_info "$username")
                IFS='|' read -r secret qr_url <<< "$mfa_info"
                setup_user "$username" "$fullname_en ($fullname_jp)" "$secret" "$qr_url"
            fi
            ;;
        "list")
            print_info "Available users:"
            for username in "${!users[@]}"; do
                IFS='|' read -r fullname_en fullname_jp <<< "${users[$username]}"
                echo "  $username: $fullname_en ($fullname_jp)"
            done | sort
            ;;
        *)
            echo "Usage: $0 {all|single <username> [secret] [qr_url]|list}"
            echo ""
            echo "Commands:"
            echo "  all    - Setup all users with generated MFA keys"
            echo "  single - Setup a single user"
            echo "  list   - List all available users"
            echo ""
            echo "Examples:"
            echo "  $0 all"
            echo "  $0 single 8000000048"
            echo "  $0 single 8000000048 'SECRET_KEY' 'QR_URL'"
            exit 1
            ;;
    esac
    
    print_info "Setup completed successfully!"
    
    # Create summary report
    if [ "$1" = "all" ]; then
        cat > "setup_summary.txt" << EOF
Amazon WorkSpaces Setup Summary
Generated on: $(date)

All user directories have been created in the 'users' folder.
Each user directory contains:
- .env.local: Environment variables for the user
- README.md: User-specific instructions
- mfa_qr.png: QR code for MFA setup (if qrencode is installed)

IMPORTANT: Distribute these directories securely to each user.
EOF
        print_info "Summary report saved to setup_summary.txt"
    fi
}

# Run main function
main "$@"