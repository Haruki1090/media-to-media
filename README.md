# Media-to-Media 🎵📄

**効率的なメディアファイル変換ツール集**

MP4動画ファイルから音声への変換、PDFファイルから画像への変換を簡単に行えるコマンドラインツールです。

## 特徴 ✨

- 🎵 **音声変換**: MP4 → MP3/AAC/WAV
- 📄 **画像変換**: PDF → PNG/JPG
- 🚀 **高速処理**: バッチ処理対応
- 📊 **進捗表示**: リアルタイムプログレスバー
- 🎨 **美しいUI**: カラフルで見やすい出力
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

### 3. 手動でPATHを設定する場合
```bash
# ~/.zshrc または ~/.bashrc に追加
export PATH="/path/to/media-to-media/bin:$PATH"
```

## 依存関係 📦

### macOS
```bash
brew install ffmpeg poppler
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ffmpeg poppler-utils
```

## 利用可能なコマンド 🛠️

### 音声変換コマンド

| コマンド | 説明 | 品質 |
|----------|------|------|
| `mp4tomp3` | MP4 → MP3 | 192kbps |
| `mp4tomp3hq` | MP4 → MP3 | 320kbps（高音質） |
| `mp4towav` | MP4 → WAV | 無圧縮 |
| `mp4toaac` | MP4 → AAC | 256kbps |

### 画像変換コマンド

| コマンド | 説明 | 品質 |
|----------|------|------|
| `pdftopng` | PDF → PNG | 150dpi |
| `pdftopnghq` | PDF → PNG | 300dpi（高品質） |
| `pdftojpg` | PDF → JPG | 150dpi |
| `pdftojpghq` | PDF → JPG | 300dpi（高品質） |

## 使用方法 📖

### 基本的な使い方

```bash
# 単一ファイルを変換
mp4tomp3 video.mp4

# 複数ファイルを一括変換
mp4tomp3 video1.mp4 video2.mp4 video3.mp4

# ワイルドカードを使用
mp4tomp3 *.mp4

# PDFを画像に変換
pdftopng document.pdf
```

### ヘルプの表示

```bash
# 各コマンドのヘルプを表示
mp4tomp3 --help
pdftopng -h
```

### 実行例

```bash
# MP3に変換（標準品質）
$ mp4tomp3 sample.mp4
🎵 MP4→MP3変換を開始します (1ファイル)

📁 ファイル 1/1: sample.mp4
   入力サイズ: 45MB
   出力先: sample.mp3
   ✅ 完了 (12s) - 出力: 8MB
進捗: [██████████████████████████████████████████████████] 100% (1/1)

🎉 すべての変換が完了しました！
総処理時間: 12s
```

## プロジェクト構造 📁

```
media-to-media/
├── bin/                    # 実行可能なコマンド
│   ├── mp4tomp3           # MP4→MP3変換
│   ├── mp4tomp3hq         # MP4→MP3高音質変換
│   ├── mp4towav           # MP4→WAV変換
│   ├── mp4toaac           # MP4→AAC変換
│   ├── pdftopng           # PDF→PNG変換
│   ├── pdftopnghq         # PDF→PNG高品質変換
│   ├── pdftojpg           # PDF→JPG変換
│   └── pdftojpghq         # PDF→JPG高品質変換
├── lib/
│   └── common.sh          # 共通ユーティリティ関数
├── install.sh             # インストールスクリプト
└── README.md              # このファイル
```

## 開発 🔧

### 新しいコマンドの追加

1. `bin/` ディレクトリに新しいスクリプトファイルを作成
2. 共通ライブラリを読み込み: `source "$SCRIPT_DIR/../lib/common.sh"`
3. 実行可能にする: `chmod +x bin/new-command`

### 共通関数の追加

`lib/common.sh` に新しいユーティリティ関数を追加できます。

## トラブルシューティング 🚨

### コマンドが見つからない場合

```bash
# PATHが正しく設定されているか確認
echo $PATH

# 手動でPATHを設定
source ~/.zshrc  # または ~/.bashrc
```

### 依存関係エラー

```bash
# ffmpegのインストール確認
ffmpeg -version

# popplerのインストール確認
pdftoppm -h
```

### 権限エラー

```bash
# スクリプトファイルを実行可能にする
chmod +x bin/*
```

## ライセンス 📄

このプロジェクトはMITライセンスの下で公開されています。

## 貢献 🤝

プルリクエストや機能要求を歓迎します！

---

**作成者**: あなたの名前  
**バージョン**: 1.0.0  
**最終更新**: $(date +%Y-%m-%d) # media-to-media
