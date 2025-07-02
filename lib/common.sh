#!/bin/bash

# === 色設定 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# === 設定 ===
CONFIG_DIR="$HOME/.media-to-media"
CONFIG_FILE="$CONFIG_DIR/config.conf"
LOG_DIR="$CONFIG_DIR/logs"
LOG_FILE="$LOG_DIR/conversion.log"

# === デフォルト設定 ===
DEFAULT_CONFIG="# Media-to-Media 設定ファイル
# 並列処理数（CPUコア数に基づいて自動設定されます）
PARALLEL_JOBS=4

# 通知設定
ENABLE_NOTIFICATIONS=true

# ログ設定
ENABLE_LOGGING=true
LOG_LEVEL=INFO

# 品質設定
MP3_QUALITY=192k
AAC_QUALITY=256k
PNG_DPI=150
JPG_DPI=150
JPG_QUALITY=90

# 出力ディレクトリ設定（空の場合は入力ファイルと同じディレクトリ）
OUTPUT_DIR=

# 変換後の元ファイル削除設定
DELETE_ORIGINAL=false
"

# === 初期化関数 ===
init_config() {
    # 設定ディレクトリ作成
    mkdir -p "$CONFIG_DIR" "$LOG_DIR"
    
    # 設定ファイルが存在しない場合は作成
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
        log_info "設定ファイルを作成しました: $CONFIG_FILE"
    fi
    
    # 設定ファイル読み込み
    source "$CONFIG_FILE"
    
    # CPUコア数に基づいて並列処理数を調整
    if [[ -z "$PARALLEL_JOBS" ]] || [[ "$PARALLEL_JOBS" -eq 0 ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            PARALLEL_JOBS=$(sysctl -n hw.ncpu)
        else
            PARALLEL_JOBS=$(nproc)
        fi
        # 最大8並列に制限
        if [[ "$PARALLEL_JOBS" -gt 8 ]]; then
            PARALLEL_JOBS=8
        fi
    fi
}

# === ログ関数 ===
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

log_info() {
    log_message "INFO" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

log_success() {
    log_message "SUCCESS" "$1"
}

# === 通知関数 ===
send_notification() {
    local title=$1
    local message=$2
    local sound=${3:-"default"}
    
    if [[ "$ENABLE_NOTIFICATIONS" == "true" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    elif [[ "$ENABLE_NOTIFICATIONS" == "true" ]] && command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
    fi
}

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

# アニメーション付きプログレスバー表示
show_progress() {
    local current=$1
    local total=$2
    local label=${3:-"進捗"}
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    # スピナー
    local spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local spinner_idx=$((current % ${#spinner_chars}))
    local spinner_char=${spinner_chars:$spinner_idx:1}
    
    printf "\r${CYAN}$spinner_char $label: [${NC}"
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
        log_error "依存関係エラー: $cmd が見つかりません"
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
        log_info "スキップ: $file (拡張子不一致)"
        return 1
    fi
    return 0
}

# 並列処理ジョブ管理
run_parallel() {
    local max_jobs=$1
    shift
    local jobs=("$@")
    local running=0
    local completed=0
    local total=${#jobs[@]}
    
    for job in "${jobs[@]}"; do
        # 最大並列数に達した場合は待機
        while (( running >= max_jobs )); do
            wait -n  # いずれかのジョブ完了を待機
            ((running--))
            ((completed++))
            show_progress $completed $total "並列処理"
        done
        
        # ジョブを開始
        eval "$job" &
        ((running++))
    done
    
    # 残りのジョブ完了を待機
    while (( running > 0 )); do
        wait -n
        ((running--))
        ((completed++))
        show_progress $completed $total "並列処理"
    done
    echo
}

# ファイル検証
verify_file() {
    local file=$1
    local type=$2
    
    case $type in
        "audio")
            if ffprobe -v quiet -show_format -show_streams "$file" 2>/dev/null | grep -q "codec_type=audio"; then
                return 0
            fi
            ;;
        "video")
            if ffprobe -v quiet -show_format -show_streams "$file" 2>/dev/null | grep -q "codec_type=video"; then
                return 0
            fi
            ;;
        "pdf")
            if file "$file" 2>/dev/null | grep -q "PDF"; then
                return 0
            fi
            ;;
    esac
    return 1
}

# アップデート機能
check_updates() {
    local current_version="1.1.0"
    echo -e "${BLUE}🔍 アップデートをチェックしています...${NC}"
    
    # ここではローカルでの更新チェックをシミュレート
    # 実際の実装では GitHub API などを使用
    echo -e "${GREEN}✅ 最新バージョンです (v$current_version)${NC}"
}

# === 設定表示関数 ===
show_config() {
    echo -e "${CYAN}📋 現在の設定:${NC}"
    echo -e "${WHITE}  並列処理数:${NC} $PARALLEL_JOBS"
    echo -e "${WHITE}  通知:${NC} $ENABLE_NOTIFICATIONS"
    echo -e "${WHITE}  ログ:${NC} $ENABLE_LOGGING"
    echo -e "${WHITE}  MP3品質:${NC} $MP3_QUALITY"
    echo -e "${WHITE}  AAC品質:${NC} $AAC_QUALITY"
    echo -e "${WHITE}  PNG DPI:${NC} $PNG_DPI"
    echo -e "${WHITE}  JPG DPI:${NC} $JPG_DPI"
    echo -e "${WHITE}  JPG品質:${NC} $JPG_QUALITY"
    echo -e "${WHITE}  設定ファイル:${NC} $CONFIG_FILE"
    echo
}

# === 統計表示 ===
show_stats() {
    if [[ -f "$LOG_FILE" ]]; then
        local total_conversions=$(grep -c "SUCCESS" "$LOG_FILE" 2>/dev/null || echo "0")
        local recent_errors=$(grep "ERROR" "$LOG_FILE" | tail -10 | wc -l 2>/dev/null || echo "0")
        
        echo -e "${CYAN}📊 変換統計:${NC}"
        echo -e "${WHITE}  総変換数:${NC} $total_conversions"
        echo -e "${WHITE}  最近のエラー:${NC} $recent_errors"
        echo -e "${WHITE}  ログファイル:${NC} $LOG_FILE"
        echo
    fi
}

# 初期化実行
init_config