# Media-to-Media 🎵📄

**効率的なメディアファイル変換ツール集 v1.1.0**

MP4動画ファイルから音声への変換、PDFファイルから画像への変換、動画からの静止画抽出など、様々なメディア変換を簡単に行えるコマンドラインツールです。

## 特徴 ✨

- 🎵 **音声変換**: MP4 → MP3/AAC/WAV
- 📄 **画像変換**: PDF → PNG/JPG  
- 🎬 **静止画抽出**: 動画 → 静止画（複数形式対応）
- 🚀 **高速処理**: 並列処理によるバッチ変換
- 📊 **進捗表示**: アニメーション付きプログレスバー
- 🎨 **美しいUI**: カラフルで見やすい出力
- ⚙️ **設定管理**: カスタマイズ可能な設定ファイル
- 📝 **ログ機能**: 変換履歴の自動記録
- 🔔 **通知機能**: macOS/Linux デスクトップ通知
- ⚡ **依存関係チェック**: 自動で必要なツールを確認

## インストール 🔧

### 1. リポジトリのクローン
```bash
git clone <repository-url>
cd media-to-media
```

### 2. 自動インストール
```bash
./install.sh
```

インストールスクリプトが以下を実行します：
- 依存関係のチェック（ffmpeg, poppler）
- PATHの設定
- シェル設定ファイルの更新
- 設定ファイルの作成
- 実行権限の設定

### 3. インストールオプション
```bash
./install.sh --help          # ヘルプ表示
./install.sh --check-only    # 依存関係チェックのみ
./install.sh --force         # 強制インストール
./install.sh --uninstall     # アンインストール
```

## 依存関係 📦

### macOS
```bash
brew install ffmpeg poppler bc
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ffmpeg poppler-utils bc libnotify-bin
```

## 利用可能なコマンド 🛠️

### 音声変換コマンド

| コマンド | 説明 | デフォルト品質 | 新機能 |
|----------|------|---------------|--------|
| `mp4tomp3` | MP4 → MP3 | 192kbps | 並列処理、設定管理 |
| `mp4tomp3hq` | MP4 → MP3 | 320kbps | 高音質変換 |
| `mp4towav` | MP4 → WAV | 無圧縮 | ロスレス変換 |
| `mp4toaac` | MP4 → AAC | 256kbps | 高効率エンコーディング |

### 画像変換コマンド

| コマンド | 説明 | デフォルト品質 | 新機能 |
|----------|------|---------------|--------|
| `pdftopng` | PDF → PNG | 150dpi | 複数ページ対応 |
| `pdftopnghq` | PDF → PNG | 300dpi | 高解像度変換 |
| `pdftojpg` | PDF → JPG | 150dpi | 圧縮率調整 |
| `pdftojpghq` | PDF → JPG | 300dpi | 高品質変換 |

### 新機能コマンド

| コマンド | 説明 | 主な機能 |
|----------|------|----------|
| `media-batch` | バッチ処理ツール | 一括変換、再帰処理、フィルタリング |
| `video-extract` | 動画静止画抽出 | サムネイル、キーフレーム、間隔抽出 |
| `media-config` | 設定管理ツール | 設定変更、統計表示、ログ管理 |

## 使用方法 📖

### 基本的な変換

```bash
# 単一ファイルを変換
mp4tomp3 video.mp4

# 複数ファイルを一括変換
mp4tomp3 video1.mp4 video2.mp4 video3.mp4

# ワイルドカードを使用
mp4tomp3 *.mp4

# 高品質で変換
mp4tomp3 -q 320k video.mp4

# 並列処理数を指定
mp4tomp3 -j 8 *.mp4
```

### バッチ処理

```bash
# ディレクトリ内の全MP4をMP3に変換
media-batch mp3 ~/Videos ~/Music

# 再帰的にサブディレクトリも処理
media-batch -r png ~/Documents ~/Images

# 8並列で高音質変換
media-batch -j 8 -q 320k mp3hq ~/Downloads

# 実際の変換前に確認（Dry run）
media-batch --dry-run auto ~/Media

# 日付別に整理して出力
media-batch --organize mp3 ~/Videos ~/Music
```

### 動画から静止画抽出

```bash
# 10秒間隔で抽出
video-extract video.mp4

# サムネイル抽出（開始・中間・終了）
video-extract --thumbnail *.mp4

# 特定の時間で抽出
video-extract -t 00:01:30 video.mp4

# 指定枚数で抽出
video-extract -n 10 video.mp4

# キーフレームのみ抽出
video-extract --keyframes video.mp4

# PNG形式で高解像度出力
video-extract -f png -s 1920x1080 video.mp4
```

### 設定管理

```bash
# 現在の設定を表示
media-config show

# 設定値を変更
media-config set PARALLEL_JOBS 8
media-config set MP3_QUALITY 320k
media-config set ENABLE_NOTIFICATIONS false

# 変換統計を表示
media-config stats

# ログを表示
media-config logs

# システムテスト
media-config test

# 設定をリセット
media-config reset
```

## 設定ファイル ⚙️

設定ファイル場所: `~/.media-to-media/config.conf`

### 主な設定項目

```bash
# 並列処理数（自動検出されますが手動で変更可能）
PARALLEL_JOBS=4

# 通知機能
ENABLE_NOTIFICATIONS=true

# ログ機能
ENABLE_LOGGING=true

# 音質設定
MP3_QUALITY=192k
AAC_QUALITY=256k

# 画像品質設定
PNG_DPI=150
JPG_DPI=150
JPG_QUALITY=90

# 変換後の元ファイル削除
DELETE_ORIGINAL=false
```

## 実行例 🎯

### MP3変換（新機能）
```bash
$ mp4tomp3 -q 320k -j 4 sample.mp4
🎵 MP4→MP3変換を開始します
ファイル数: 1 | 並列処理: 4 | 音質: 320k

📁 ファイル 1/1: sample.mp4
   入力サイズ: 45MB
   音質: 320k
   出力先: sample.mp3
   ✅ 完了 (8s) - 出力: 12MB
   🔍 検証: OK

🎉 変換処理が完了しました！
成功: 1 | 失敗: 0 | 総処理時間: 8s
```

### バッチ処理
```bash
$ media-batch -r mp3 ~/Videos ~/Music
🚀 Media-to-Media バッチ処理を開始します
変換タイプ: mp3 | 入力: /Users/user/Videos
出力: /Users/user/Music
並列処理: 4 | 再帰: true

📁 処理対象ファイル: 15個
🚀 並列処理で変換を実行します...

🎉 バッチ処理が完了しました！
成功: 14 | 失敗: 1 | 総処理時間: 2m 15s
```

## プロジェクト構造 📁

```
media-to-media/
├── bin/                    # 実行可能なコマンド
│   ├── mp4tomp3           # MP4→MP3変換（並列処理対応）
│   ├── mp4tomp3hq         # MP4→MP3高音質変換
│   ├── mp4towav           # MP4→WAV変換
│   ├── mp4toaac           # MP4→AAC変換
│   ├── pdftopng           # PDF→PNG変換
│   ├── pdftopnghq         # PDF→PNG高品質変換
│   ├── pdftojpg           # PDF→JPG変換
│   ├── pdftojpghq         # PDF→JPG高品質変換
│   ├── media-batch        # バッチ処理ツール
│   ├── video-extract      # 動画静止画抽出ツール
│   └── media-config       # 設定管理ツール
├── lib/
│   └── common.sh          # 共通ライブラリ（大幅拡張）
├── install.sh             # インストールスクリプト（v1.1.0）
└── README.md              # このファイル
```

## 新機能詳細 🆕

### 並列処理
- CPUコア数に応じた自動調整
- 手動での並列数指定可能
- 最大8並列まで対応

### ログ機能
- 全変換履歴の自動記録
- ログローテーション機能
- エラー追跡とデバッグ情報

### 通知機能
- macOS: ネイティブ通知
- Linux: libnotify対応
- 変換完了時の自動通知

### ファイル検証
- 変換前のファイル妥当性チェック
- 変換後の出力検証
- 破損ファイルの検出

### 設定管理
- ユーザー設定のカスタマイズ
- 品質プリセットの管理
- 統計情報の表示

## 高度な使用例 🚀

### 条件付きバッチ処理
```bash
# 特定のパターンにマッチするファイルのみ処理
media-batch -f ".*_HD.*" mp3hq ~/Videos

# 既存ファイルをスキップして処理
media-batch --skip-existing png ~/Documents

# 日付別に整理して出力
media-batch --organize jpg ~/PDFs ~/Images
```

### カスタム品質設定
```bash
# 設定ファイルで品質を変更
media-config set MP3_QUALITY 256k
media-config set PNG_DPI 300

# 一時的に品質を指定
mp4tomp3 -q 128k low_quality.mp4
video-extract -q 600 -f png high_res.mp4
```

### 自動化スクリプト例
```bash
#!/bin/bash
# 毎日のメディア処理を自動化

# 新しい動画ファイルをMP3に変換
media-batch --skip-existing mp3 ~/Downloads ~/Music

# PDFドキュメントを画像に変換
media-batch --organize png ~/Documents ~/Images

# 統計を確認
media-config stats

# ログをクリーンアップ
media-config cleanup
```

## トラブルシューティング 🚨

### コマンドが見つからない場合
```bash
# PATHの確認
echo $PATH

# 手動でPATHを設定
source ~/.zshrc  # または ~/.bashrc

# インストール状況の確認
media-config test
```

### 依存関係エラー
```bash
# 依存関係の再チェック
./install.sh --check-only

# 手動インストール（macOS）
brew install ffmpeg poppler bc

# 手動インストール（Ubuntu）
sudo apt install ffmpeg poppler-utils bc libnotify-bin
```

### 設定ファイルの問題
```bash
# 設定ファイルの場所確認
media-config show

# 設定をデフォルトにリセット
media-config reset

# ログファイルの確認
media-config logs
```

### パフォーマンスの最適化
```bash
# 並列処理数の調整
media-config set PARALLEL_JOBS 8

# ログを無効化（高速化）
media-config set ENABLE_LOGGING false

# 通知を無効化
media-config set ENABLE_NOTIFICATIONS false
```

## アップデート 🔄

```bash
# 最新版の確認
media-config update

# 手動アップデート
git pull origin main
./install.sh --force
```

## アンインストール 🗑️

```bash
# 完全アンインストール
./install.sh --uninstall
```

## 開発 🔧

### 新しいコマンドの追加

1. `bin/` ディレクトリに新しいスクリプトファイルを作成
2. 共通ライブラリを読み込み: `source "$SCRIPT_DIR/../lib/common.sh"`
3. 実行可能にする: `chmod +x bin/new-command`
4. `install.sh` の `setup_permissions()` に追加

### 共通関数の拡張

`lib/common.sh` に新しいユーティリティ関数を追加できます：
- ログ機能の拡張
- 新しいファイル形式のサポート
- 通知機能の改善
- 設定項目の追加

## ライセンス 📄

このプロジェクトはMITライセンスの下で公開されています。

## 貢献 🤝

プルリクエストや機能要求を歓迎します！

### 貢献ガイドライン
1. 新機能は適切なテストとドキュメントを含める
2. 既存のコードスタイルに従う  
3. ログ機能と設定管理を活用する
4. エラーハンドリングを適切に実装する

---

## 📞 Contact & Info

<div align="center">

### 🧑‍💻 Created by **Haruki Inoue**

[![Version](https://img.shields.io/badge/Version-1.1.0-blue.svg?style=for-the-badge)](https://github.com/Haruki1090/media-to-media)
[![Last Updated](https://img.shields.io/badge/Last%20Updated-2025--07--02-green.svg?style=for-the-badge)](https://github.com/Haruki1090/media-to-media)

### 🌟 **新機能** 
`並列処理` • `設定管理` • `ログ機能` • `通知機能` • `バッチ処理` • `静止画抽出`

### 🔗 **Connect with me**

[![X](https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/Haruki_dev)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/haruki1090/)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Haruki1090)

### ⭐ **If you found this tool helpful, please consider giving it a star!**

[![GitHub stars](https://img.shields.io/github/stars/Haruki1090/media-to-media?style=social)](https://github.com/Haruki1090/media-to-media/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Haruki1090/media-to-media?style=social)](https://github.com/Haruki1090/media-to-media/network)

</div>

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/Haruki1090">Haruki Inoue</a></sub>
</div>