#!/bin/bash

# === 色設定 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# === ユーティリティ関数 ===
# ファイルサイズを取得
get_file_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$1" 2>/dev/null || echo "0"
    else
        stat -c%s "$1" 2>/dev/null || echo "0"
    fi
}

# ファイルサイズを人間が読みやすい形式に変換
format_size() {
    local size=$1
    if (( size < 1024 )); then
        echo "${size}B"
    elif (( size < 1048576 )); then
        echo "$(( size / 1024 ))KB"
    elif (( size < 1073741824 )); then
        echo "$(( size / 1048576 ))MB"
    else
        echo "$(( size / 1073741824 ))GB"
    fi
}

# プログレスバー表示
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${CYAN}進捗: [${NC}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '·'
    printf "${CYAN}] ${WHITE}%d%%${NC} (${current}/${total})" $percent
}

# 処理時間計算
format_duration() {
    local duration=$1
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    if (( hours > 0 )); then
        printf "%dh %dm %ds" $hours $minutes $seconds
    elif (( minutes > 0 )); then
        printf "%dm %ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

# 依存関係チェック
check_dependency() {
    local cmd=$1
    local package=$2
    
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}❌ エラー: $cmd が見つかりません${NC}"
        echo -e "${YELLOW}   インストールが必要です: $package${NC}"
        return 1
    fi
    return 0
}

# ファイル拡張子チェック
check_file_extension() {
    local file=$1
    local expected_ext=$2
    
    if [[ "$file" != *.$expected_ext ]]; then
        echo -e "${RED}⚠️  スキップ: ${file} (${expected_ext^^}ファイルではありません)${NC}"
        return 1
    fi
    return 0
} 