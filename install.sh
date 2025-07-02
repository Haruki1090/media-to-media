#!/bin/bash

# Media-to-Media インストールスクリプト v1.1.0

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# プロジェクトディレクトリ取得
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$PROJECT_DIR/bin"
LIB_DIR="$PROJECT_DIR/lib"

# バージョン情報
VERSION="1.1.0"
RELEASE_DATE=$(date +%Y-%m-%d)

echo -e "${PURPLE}${BOLD}🚀 Media-to-Media インストーラー v${VERSION}${NC}\n"

# アンインストール機能
uninstall() {
    echo -e "${YELLOW}⚠️  Media-to-Mediaをアンインストールしますか？ (y/N): ${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🧹 アンインストール中...${NC}"
        
        # PATH設定の削除
        local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
        for config in "${shell_configs[@]}"; do
            if [[ -f "$config" ]] && grep -q "$BIN_DIR" "$config"; then
                echo -e "${BLUE}   PATH設定を削除: $config${NC}"
                # Media-to-Media関連の行を削除
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' '/# Media-to-Media Tools/d' "$config"
                    sed -i '' "\|$BIN_DIR|d" "$config"
                else
                    sed -i '/# Media-to-Media Tools/d' "$config"
                    sed -i "\|$BIN_DIR|d" "$config"
                fi
            fi
        done
        
        # 設定ディレクトリの削除
        if [[ -d "$HOME/.media-to-media" ]]; then
            echo -e "${BLUE}   設定ディレクトリを削除: $HOME/.media-to-media${NC}"
            rm -rf "$HOME/.media-to-media"
        fi
        
        echo -e "${GREEN}✅ アンインストール完了${NC}"
        echo -e "${YELLOW}シェルを再起動してください${NC}"
    else
        echo -e "${BLUE}キャンセルしました${NC}"
    fi
    exit 0
}

# ヘルプ表示
show_help() {
    echo -e "${CYAN}使用方法:${NC}"
    echo "  ./install.sh [オプション]"
    echo
    echo -e "${CYAN}オプション:${NC}"
    echo "  -h, --help       このヘルプを表示"
    echo "  -u, --uninstall  アンインストール"
    echo "  -f, --force      強制インストール"
    echo "  --check-only     依存関係チェックのみ"
    echo "  --no-config      設定ファイルを作成しない"
    echo
    exit 0
}

# オプション解析
FORCE_INSTALL=false
CHECK_ONLY=false
CREATE_CONFIG=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -u|--uninstall)
            uninstall
            ;;
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --no-config)
            CREATE_CONFIG=false
            shift
            ;;
        *)
            echo -e "${RED}❌ 不明なオプション: $1${NC}"
            show_help
            ;;
    esac
done

# 依存関係チェック関数
check_dependency() {
    local cmd=$1
    local package=$2
    local install_cmd=$3
    local required=${4:-true}
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd -version 2>&1 | head -1 || echo "不明")
        echo -e "${GREEN}✅ $cmd が見つかりました${NC}"
        echo -e "${BLUE}   バージョン: $version${NC}"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo -e "${RED}❌ $cmd が見つかりません${NC}"
        else
            echo -e "${YELLOW}⚠️  $cmd が見つかりません (オプション)${NC}"
        fi
        echo -e "${BLUE}   パッケージ: $package${NC}"
        echo -e "${BLUE}   インストール: $install_cmd${NC}"
        return 1
    fi
}

# システム情報表示
show_system_info() {
    echo -e "${CYAN}📋 システム情報:${NC}"
    echo -e "${WHITE}  OS: $(uname -s) $(uname -r)${NC}"
    echo -e "${WHITE}  アーキテクチャ: $(uname -m)${NC}"
    echo -e "${WHITE}  シェル: $SHELL${NC}"
    echo -e "${WHITE}  ユーザー: $USER${NC}"
    echo -e "${WHITE}  ホーム: $HOME${NC}"
    echo -e "${WHITE}  プロジェクト: $PROJECT_DIR${NC}"
    echo
}

# 依存関係チェック
check_dependencies() {
    echo -e "${CYAN}🔍 依存関係をチェックしています...${NC}\n"

    local missing_deps=0
    local optional_missing=0

    # 必須依存関係
    echo -e "${CYAN}📦 必須依存関係:${NC}"
    
    # ffmpeg チェック
    if ! check_dependency "ffmpeg" "ffmpeg" "brew install ffmpeg / sudo apt install ffmpeg"; then
        ((missing_deps++))
    fi

    # poppler チェック
    if ! check_dependency "pdftoppm" "poppler-utils" "brew install poppler / sudo apt install poppler-utils"; then
        ((missing_deps++))
    fi

    echo

    # オプション依存関係
    echo -e "${CYAN}📦 オプション依存関係:${NC}"
    
    # bc チェック（計算用）
    if ! check_dependency "bc" "bc" "brew install bc / sudo apt install bc" false; then
        ((optional_missing++))
    fi

    # notify-send チェック（Linux通知用）
    if [[ "$OSTYPE" != "darwin"* ]]; then
        if ! check_dependency "notify-send" "libnotify-bin" "sudo apt install libnotify-bin" false; then
            ((optional_missing++))
        fi
    fi

    echo

    # 結果表示
    if [[ $missing_deps -gt 0 ]]; then
        echo -e "${RED}❌ $missing_deps個の必須依存関係が不足しています${NC}"
        
        if [[ "$FORCE_INSTALL" != "true" ]]; then
            echo -e "${YELLOW}続行しますか？ (y/N): ${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                echo -e "${RED}インストールを中止しました${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}✅ すべての必須依存関係が揃っています${NC}"
    fi

    if [[ $optional_missing -gt 0 ]]; then
        echo -e "${YELLOW}ℹ️  $optional_missing個のオプション依存関係が不足していますが、基本機能は利用できます${NC}"
    fi

    echo
}

# シェル設定ファイル検出
detect_shell_config() {
    local shell_configs=()
    
    # 現在のシェルに基づいて設定ファイルを決定
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_configs+=("$HOME/.zshrc")
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_configs+=("$HOME/.bashrc" "$HOME/.bash_profile")
    elif [[ "$SHELL" == *"fish"* ]]; then
        shell_configs+=("$HOME/.config/fish/config.fish")
    fi
    
    # 一般的な設定ファイルも追加
    shell_configs+=("$HOME/.profile")
    
    # 存在するファイルのみ返す
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            echo "$config"
            return 0
        fi
    done
    
    # デフォルト
    echo "$HOME/.bashrc"
}

# PATH設定の追加
setup_path() {
    echo -e "${CYAN}🔧 PATH設定をセットアップしています...${NC}"
    
    local shell_config=$(detect_shell_config)
    echo -e "${BLUE}   設定ファイル: $shell_config${NC}"
    
    # PATH設定の内容
    local path_export="export PATH=\"$BIN_DIR:\$PATH\""
    
    # 既存の設定をチェック
    if [[ -f "$shell_config" ]] && grep -q "$BIN_DIR" "$shell_config" 2>/dev/null; then
        echo -e "${GREEN}✅ PATH設定は既に存在しています${NC}"
        return 0
    fi
    
    # バックアップ作成
    if [[ -f "$shell_config" ]]; then
        local backup_file="$shell_config.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$shell_config" "$backup_file"
        echo -e "${GREEN}   バックアップを作成: $(basename "$backup_file")${NC}"
    fi
    
    # PATH設定追加
    {
        echo ""
        echo "# Media-to-Media Tools (v$VERSION - $RELEASE_DATE)"
        echo "$path_export"
        echo ""
    } >> "$shell_config"
    
    echo -e "${GREEN}✅ PATH設定を追加しました${NC}"
}

# ファイル権限設定
setup_permissions() {
    echo -e "${CYAN}🔐 ファイル権限を設定しています...${NC}"
    
    # 実行可能ファイルに権限設定
    local commands=(
        "mp4tomp3" "mp4tomp3hq" "mp4towav" "mp4toaac"
        "pdftopng" "pdftopnghq" "pdftojpg" "pdftojpghq"
        "media-config" "media-batch" "video-extract"
    )
    
    for cmd in "${commands[@]}"; do
        if [[ -f "$BIN_DIR/$cmd" ]]; then
            chmod +x "$BIN_DIR/$cmd"
            echo -e "${GREEN}   ✅ $cmd${NC}"
        else
            echo -e "${YELLOW}   ⚠️  $cmd が見つかりません${NC}"
        fi
    done
    
    # ライブラリファイルの権限設定
    if [[ -f "$LIB_DIR/common.sh" ]]; then
        chmod +r "$LIB_DIR/common.sh"
        echo -e "${GREEN}   ✅ common.sh${NC}"
    fi
    
    echo -e "${GREEN}✅ 権限設定完了${NC}"
}

# 設定ファイル作成
setup_config() {
    if [[ "$CREATE_CONFIG" != "true" ]]; then
        return 0
    fi
    
    echo -e "${CYAN}⚙️  設定ファイルを作成しています...${NC}"
    
    # 共通ライブラリを読み込んで初期化
    if [[ -f "$LIB_DIR/common.sh" ]]; then
        source "$LIB_DIR/common.sh"
        echo -e "${GREEN}✅ 設定ディレクトリ: $CONFIG_DIR${NC}"
        echo -e "${GREEN}✅ 設定ファイル: $CONFIG_FILE${NC}"
        echo -e "${GREEN}✅ ログディレクトリ: $LOG_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️  共通ライブラリが見つかりません${NC}"
    fi
}

# テスト実行
run_tests() {
    echo -e "${CYAN}🧪 インストールテストを実行しています...${NC}"
    
    local test_passed=0
    local test_total=0
    
    # コマンド実行テスト
    local commands=("mp4tomp3" "media-config" "media-batch")
    
    for cmd in "${commands[@]}"; do
        ((test_total++))
        echo -e "${BLUE}   テスト: $cmd --help${NC}"
        
        if "$BIN_DIR/$cmd" --help >/dev/null 2>&1; then
            echo -e "${GREEN}   ✅ $cmd OK${NC}"
            ((test_passed++))
        else
            echo -e "${RED}   ❌ $cmd エラー${NC}"
        fi
    done
    
    # 設定テスト
    ((test_total++))
    echo -e "${BLUE}   テスト: 設定ファイル${NC}"
    if [[ -f "$HOME/.media-to-media/config.conf" ]]; then
        echo -e "${GREEN}   ✅ 設定ファイル OK${NC}"
        ((test_passed++))
    else
        echo -e "${RED}   ❌ 設定ファイル エラー${NC}"
    fi
    
    echo
    echo -e "${CYAN}📊 テスト結果: ${test_passed}/${test_total} 通過${NC}"
    
    if [[ $test_passed -eq $test_total ]]; then
        echo -e "${GREEN}🎉 すべてのテストに合格しました！${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  一部のテストが失敗しました${NC}"
        return 1
    fi
}

# 利用可能なコマンド一覧表示
show_commands() {
    echo -e "${PURPLE}🎉 インストール完了！${NC}\n"
    echo -e "${CYAN}📋 利用可能なコマンド:${NC}"
    
    echo -e "${WHITE}  🎵 音声変換:${NC}"
    echo -e "    ${CYAN}mp4tomp3${NC}    - MP4 → MP3 (192kbps)"
    echo -e "    ${CYAN}mp4tomp3hq${NC}  - MP4 → MP3 (320kbps 高音質)"
    echo -e "    ${CYAN}mp4towav${NC}    - MP4 → WAV (無圧縮)"
    echo -e "    ${CYAN}mp4toaac${NC}    - MP4 → AAC (256kbps)"
    echo
    
    echo -e "${WHITE}  📄 画像変換:${NC}"
    echo -e "    ${CYAN}pdftopng${NC}    - PDF → PNG (150dpi)"
    echo -e "    ${CYAN}pdftopnghq${NC}  - PDF → PNG (300dpi 高品質)"
    echo -e "    ${CYAN}pdftojpg${NC}    - PDF → JPG (150dpi)"
    echo -e "    ${CYAN}pdftojpghq${NC}  - PDF → JPG (300dpi 高品質)"
    echo
    
    echo -e "${WHITE}  🚀 新機能:${NC}"
    echo -e "    ${CYAN}media-batch${NC}  - バッチ処理（一括変換）"
    echo -e "    ${CYAN}video-extract${NC} - 動画から静止画抽出"
    echo -e "    ${CYAN}media-config${NC} - 設定管理・統計表示"
    echo
    
    echo -e "${YELLOW}📋 クイックスタート: ${NC}"
    echo -e "  基本的な変換: ${CYAN}mp4tomp3 video.mp4${NC}"
    echo -e "  設定確認: ${CYAN}media-config show${NC}"
    echo -e "  バッチ処理: ${CYAN}media-batch mp3 ~/Videos${NC}"
    echo -e "  ヘルプ表示: ${CYAN}<コマンド> --help${NC}"
    echo
    
    echo -e "${GREEN}🔄 シェルを再起動するか、以下のコマンドを実行してください:${NC}"
    echo -e "${CYAN}source $(detect_shell_config)${NC}"
    echo
    
    echo -e "${BLUE}📚 詳細情報: README.md をご覧ください${NC}"
}

# メイン処理
main() {
    # システム情報表示
    show_system_info
    
    # 依存関係チェック
    check_dependencies
    
    # チェックのみの場合は終了
    if [[ "$CHECK_ONLY" == "true" ]]; then
        echo -e "${BLUE}依存関係チェックのみを実行しました${NC}"
        exit 0
    fi
    
    # ファイル権限設定
    setup_permissions
    
    # PATH設定
    setup_path
    
    # 設定ファイル作成
    setup_config
    
    # テスト実行
    if run_tests; then
        # 成功時のメッセージ
        show_commands
        
        # 初回実行の推奨事項
        echo -e "${CYAN}💡 次のステップ:${NC}"
        echo -e "  1. シェルを再起動または source コマンド実行"
        echo -e "  2. ${CYAN}media-config test${NC} でシステムテスト実行"
        echo -e "  3. ${CYAN}mp4tomp3 --help${NC} でヘルプ確認"
        echo
        
    else
        echo -e "${YELLOW}⚠️  インストールは完了しましたが、一部の機能に問題がある可能性があります${NC}"
        echo -e "${BLUE}問題がある場合は、依存関係を確認してください${NC}"
    fi
}

# 実行
main 