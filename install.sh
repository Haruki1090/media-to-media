#!/bin/bash

# Media-to-Media インストールスクリプト

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# プロジェクトディレクトリ取得
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$PROJECT_DIR/bin"

echo -e "${PURPLE}🚀 Media-to-Media インストーラー${NC}\n"

# 依存関係チェック関数
check_dependency() {
    local cmd=$1
    local package=$2
    local install_cmd=$3
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✅ $cmd が見つかりました${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $cmd が見つかりません${NC}"
        echo -e "${BLUE}   インストールコマンド: $install_cmd${NC}"
        return 1
    fi
}

# 依存関係チェック
echo -e "${CYAN}🔍 依存関係をチェックしています...${NC}\n"

missing_deps=0

# ffmpeg チェック
if ! check_dependency "ffmpeg" "ffmpeg" "brew install ffmpeg"; then
    ((missing_deps++))
fi

# poppler チェック
if ! check_dependency "pdftoppm" "poppler-utils" "brew install poppler"; then
    ((missing_deps++))
fi

echo

if [[ $missing_deps -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  依存関係が不足しています。上記のコマンドでインストールしてください。${NC}"
    echo -e "${BLUE}続行しますか？ (y/N): ${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}インストールを中止しました${NC}"
        exit 1
    fi
fi

# シェル設定ファイル検出
SHELL_CONFIG=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo -e "${YELLOW}⚠️  シェルを自動検出できませんでした${NC}"
    echo -e "${BLUE}使用しているシェル設定ファイルのパスを入力してください:${NC}"
    read -r SHELL_CONFIG
fi

echo -e "${CYAN}📝 設定ファイル: $SHELL_CONFIG${NC}"

# PATH設定の追加
PATH_EXPORT="export PATH=\"$BIN_DIR:\$PATH\""

# 既存の設定をチェック
if grep -q "$BIN_DIR" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}✅ PATH設定は既に存在しています${NC}"
else
    echo -e "${BLUE}🔧 PATH設定を追加しています...${NC}"
    
    # バックアップ作成
    if [[ -f "$SHELL_CONFIG" ]]; then
        cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}   バックアップを作成しました: $SHELL_CONFIG.backup.$(date +%Y%m%d_%H%M%S)${NC}"
    fi
    
    # PATH設定追加
    echo "" >> "$SHELL_CONFIG"
    echo "# Media-to-Media Tools" >> "$SHELL_CONFIG"
    echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
    
    echo -e "${GREEN}✅ PATH設定を追加しました${NC}"
fi

# 利用可能なコマンド一覧表示
echo -e "\n${PURPLE}🎉 インストール完了！${NC}\n"
echo -e "${CYAN}利用可能なコマンド:${NC}"
echo -e "${WHITE}  音声変換:${NC}"
echo -e "    mp4tomp3    - MP4 → MP3 (192kbps)"
echo -e "    mp4tomp3hq  - MP4 → MP3 (320kbps 高音質)"
echo -e "    mp4towav    - MP4 → WAV (無圧縮)"
echo -e "    mp4toaac    - MP4 → AAC (256kbps)"
echo
echo -e "${WHITE}  画像変換:${NC}"
echo -e "    pdftopng    - PDF → PNG (150dpi)"
echo -e "    pdftopnghq  - PDF → PNG (300dpi 高品質)"
echo -e "    pdftojpg    - PDF → JPG (150dpi)"
echo -e "    pdftojpghq  - PDF → JPG (300dpi 高品質)"
echo
echo -e "${YELLOW}📋 使用方法: ${NC}"
echo -e "  各コマンドに ${CYAN}-h${NC} または ${CYAN}--help${NC} オプションをつけて詳細を確認できます"
echo -e "  例: ${CYAN}mp4tomp3 --help${NC}"
echo
echo -e "${GREEN}🔄 新しいターミナルセッションを開始するか、以下のコマンドを実行してください:${NC}"
echo -e "${CYAN}source $SHELL_CONFIG${NC}" 