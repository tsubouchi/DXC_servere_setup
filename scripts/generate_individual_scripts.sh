#!/bin/bash

# Generate individual setup scripts for each WorkSpaces user
# This script creates personalized setup scripts for each user

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Create scripts directory
mkdir -p individual_scripts

# Common variables
REGISTRATION_CODE="wsnrt+KEQA4Y"
INITIAL_PASSWORD="98765@dxj"

# Function to create individual user script
create_user_script() {
    local username=$1
    local last_name=$2
    local first_name=$3
    local full_name_en=$4
    local script_file="individual_scripts/setup_${username}.sh"
    
    cat > "$script_file" << 'EOF'
#!/bin/bash

# Amazon WorkSpaces Setup Script for Individual User
# Auto-generated setup script - DO NOT EDIT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# User Information
EOF
    
    cat >> "$script_file" << EOF
USERNAME="${username}"
LAST_NAME="${last_name}"
FIRST_NAME="${first_name}"
FULL_NAME_EN="${full_name_en}"
FULL_NAME_JP="${last_name} ${first_name}"
REGISTRATION_CODE="${REGISTRATION_CODE}"
INITIAL_PASSWORD="${INITIAL_PASSWORD}"
EOF
    
    cat >> "$script_file" << 'EOF'

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Amazon WorkSpaces セットアップツール${NC}"
    echo -e "${BLUE}  ユーザー: ${FULL_NAME_JP} (${FULL_NAME_EN})${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "前提条件を確認しています..."
    
    # Check if running on supported OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_info "macOSが検出されました"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_info "Linuxが検出されました"
    else
        print_warning "未検証のOSです。問題が発生する可能性があります。"
    fi
    
    # Check for optional tools
    if command -v qrencode >/dev/null 2>&1; then
        print_info "qrencodeが利用可能です - QRコードを生成します"
        QRENCODE_AVAILABLE=true
    else
        print_warning "qrencodeがインストールされていません - QRコード生成をスキップします"
        QRENCODE_AVAILABLE=false
    fi
}

# Function to generate MFA secret
generate_mfa_secret() {
    if command -v openssl >/dev/null 2>&1; then
        MFA_SECRET=$(openssl rand -base64 20 | tr -d "=+/" | cut -c1-32 | tr '[:lower:]' '[:upper:]')
    else
        # Fallback to using /dev/urandom
        MFA_SECRET=$(LC_ALL=C tr -dc 'A-Z2-7' < /dev/urandom | head -c32)
    fi
    
    # Generate QR URL
    ISSUER="DXJ-SV-0327"
    MFA_QR_URL="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=otpauth://totp/${USERNAME}@${ISSUER}?secret=${MFA_SECRET}&issuer=${ISSUER}"
}

# Function to create setup files
create_setup_files() {
    print_info "セットアップファイルを作成しています..."
    
    # Create user directory
    USER_DIR="workspaces_setup_${USERNAME}"
    mkdir -p "$USER_DIR"
    
    # Create .env.local file
    cat > "$USER_DIR/.env.local" << ENV_EOF
# Amazon WorkSpaces Configuration
WORKSPACES_REGISTRATION_CODE=${REGISTRATION_CODE}

# User Credentials
WORKSPACES_USERNAME=${USERNAME}
WORKSPACES_INITIAL_PASSWORD=${INITIAL_PASSWORD}

# User Info
USER_LAST_NAME="${LAST_NAME}"
USER_FIRST_NAME="${FIRST_NAME}"
USER_FULL_NAME_EN="${FULL_NAME_EN}"
USER_FULL_NAME_JP="${FULL_NAME_JP}"

# MFA Configuration
MFA_SECRET_KEY=${MFA_SECRET}
MFA_QR_URL=${MFA_QR_URL}

# Generated on: $(date '+%Y-%m-%d %H:%M:%S')
ENV_EOF
    
    print_info ".env.localファイルを作成しました"
    
    # Create README file
    cat > "$USER_DIR/README.md" << README_EOF
# Amazon WorkSpaces セットアップ情報

## ユーザー情報
- **氏名**: ${FULL_NAME_JP} (${FULL_NAME_EN})
- **ユーザー名**: ${USERNAME}
- **登録コード**: ${REGISTRATION_CODE}
- **初期パスワード**: ${INITIAL_PASSWORD}

## セットアップ手順

### 1. WorkSpacesクライアントのインストール
1. Amazon WorkSpacesクライアントをダウンロード
   - Windows: https://clients.amazonworkspaces.com/
   - Mac: App Storeから「Amazon WorkSpaces」を検索
2. インストールを完了

### 2. 初回ログイン
1. WorkSpacesクライアントを起動
2. 登録コード「${REGISTRATION_CODE}」を入力
3. ユーザー名「${USERNAME}」を入力
4. パスワード「${INITIAL_PASSWORD}」を入力
5. MFA認証コード（6桁）を入力

### 3. MFA（多要素認証）の設定
1. スマートフォンに認証アプリをインストール
   - Google Authenticator（推奨）
   - Microsoft Authenticator
2. 以下のいずれかの方法で設定：
   - QRコード: mfa_qr.png をスキャン
   - 手動入力: 
     - アカウント名: ${USERNAME}
     - キー: ${MFA_SECRET}
     - 発行者: DXJ-SV-0327

### 4. 初回ログイン後の設定
1. **パスワード変更**（必須）
   - Ctrl + Alt + Insert を押下
   - 「パスワードの変更」をクリック
   - 新しいパスワードを設定

2. **Outlookの設定**
   - プロファイル名: ${USERNAME}

3. **OneDriveの設定**
   - 「今すぐ同期」をクリック

## セキュリティ注意事項
- この情報は機密情報です。安全に保管してください
- MFAシークレットキーは他人と共有しないでください
- 初回ログイン後は必ずパスワードを変更してください

生成日時: $(date '+%Y-%m-%d %H:%M:%S')
README_EOF
    
    print_info "READMEファイルを作成しました"
    
    # Generate QR code if possible
    if [ "$QRENCODE_AVAILABLE" = true ]; then
        qrencode -o "$USER_DIR/mfa_qr.png" "$MFA_QR_URL"
        print_info "MFA QRコードを生成しました: mfa_qr.png"
    fi
    
    # Create MFA info text file
    cat > "$USER_DIR/mfa_info.txt" << MFA_EOF
Amazon WorkSpaces MFA情報
========================

ユーザー名: ${USERNAME}
氏名: ${FULL_NAME_JP} (${FULL_NAME_EN})

MFAシークレットキー: ${MFA_SECRET}

QRコードURL:
${MFA_QR_URL}

設定方法:
1. 認証アプリ（Google Authenticator等）を開く
2. 「+」または「アカウントを追加」をタップ
3. 「手動で入力」を選択
4. アカウント名: ${USERNAME}
5. キー: ${MFA_SECRET}
6. 時間ベース: はい

生成日時: $(date '+%Y-%m-%d %H:%M:%S')
MFA_EOF
    
    print_info "MFA情報ファイルを作成しました"
}

# Function to display summary
display_summary() {
    echo ""
    echo -e "${GREEN}========== セットアップ完了 ==========${NC}"
    echo ""
    echo "作成されたファイル:"
    echo "  - ${USER_DIR}/.env.local (環境変数)"
    echo "  - ${USER_DIR}/README.md (セットアップ手順)"
    echo "  - ${USER_DIR}/mfa_info.txt (MFA情報)"
    if [ "$QRENCODE_AVAILABLE" = true ]; then
        echo "  - ${USER_DIR}/mfa_qr.png (QRコード)"
    fi
    echo ""
    echo -e "${YELLOW}重要な情報:${NC}"
    echo "  ユーザー名: ${USERNAME}"
    echo "  初期パスワード: ${INITIAL_PASSWORD}"
    echo "  MFAシークレット: ${MFA_SECRET}"
    echo ""
    echo -e "${RED}注意: これらの情報は機密情報です。安全に管理してください。${NC}"
    echo ""
}

# Main execution
main() {
    print_header
    
    # Check prerequisites
    check_prerequisites
    
    # Generate MFA secret
    print_info "MFA情報を生成しています..."
    generate_mfa_secret
    print_info "MFAシークレットキーを生成しました"
    
    # Create setup files
    create_setup_files
    
    # Display summary
    display_summary
    
    print_info "セットアップが完了しました！"
    print_info "生成されたファイルは '${USER_DIR}' ディレクトリに保存されています。"
}

# Run main function
main
EOF
    
    chmod +x "$script_file"
    print_info "Created script for ${username}: ${full_name_en} (${last_name} ${first_name})"
}

# Main execution
print_info "Generating individual setup scripts..."

# Create scripts for each user
create_user_script "8000000043" "児玉" "直樹" "Kodama Naoki"
create_user_script "8000000044" "安東" "竜平" "Ando Ryuhei"
create_user_script "8000000045" "岸田" "崇史" "Kishida Takashi"
create_user_script "8000000046" "常重" "友佑" "Tsuneshige Yusuke"
create_user_script "8000000047" "池田" "昌樹" "Ikeda Masaki"
create_user_script "8000000048" "坪内" "弘毅" "Tsubochi Koki"
create_user_script "8000000049" "楠田" "佳世" "Kusuda Kayo"
create_user_script "8000000050" "石田" "彰吾" "Ishida Shogo"

# Create master script to run all individual scripts
cat > "individual_scripts/run_all_setups.sh" << 'EOF'
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
EOF

chmod +x "individual_scripts/run_all_setups.sh"

# Create distribution script
cat > "individual_scripts/distribute_files.sh" << 'EOF'
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
EOF

chmod +x "individual_scripts/distribute_files.sh"

print_info "Individual setup scripts created in 'individual_scripts' directory"
print_info ""
print_info "Available scripts:"
print_info "  - setup_8000000XX.sh : Individual user setup scripts"
print_info "  - run_all_setups.sh  : Run all setups at once"
print_info "  - distribute_files.sh : Package files for distribution"
print_info ""
print_info "To set up a specific user:"
print_info "  cd individual_scripts"
print_info "  ./setup_8000000XX.sh"
print_info ""
print_info "To set up all users:"
print_info "  cd individual_scripts"
print_info "  ./run_all_setups.sh"