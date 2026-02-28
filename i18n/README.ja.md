[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI 生成のラスター画像を、クリーンなベクターパス SVG に変換します。

このリポジトリは、画像内のエッジまたは二値形状を検出して SVG パスとして書き出す Python CLI を提供します。写実的なトレースではなく、スタイライズされたプロッターフレンドリーなベクター化を目的としています。

## ✨ 概要

`aigi2vector` には次が含まれます:

- ラスターから SVG へ変換するコア CLI: [`aigi2vector.py`](aigi2vector.py)
- 埋め込み画像の抽出やスライドの PNG レンダリングを行う任意の PPTX 補助ツール
- レイアウト抽出、クロップ、AI 支援パイプライン向けの追加ワークフロースクリプト（`scripts/` 配下）
- `AutoAppDev/` サブモジュール（外部ツール。メイン CLI の実行には不要）

| 項目 | 詳細 |
|---|---|
| コアの目的 | ラスター画像を SVG パス出力へ変換 |
| 主な実行形態 | 単一ファイルの Python CLI |
| コア依存関係 | `opencv-python`, `numpy` |
| 任意ワークフロー | PPTX 抽出/レンダリング、AI 支援スクリプトパイプライン |

## 🚀 機能

- 2 つのモードでラスター画像を SVG パスへ変換:
  - `edges`: Canny ベースのエッジ検出
  - `binary`: 閾値処理による形状抽出
- 前処理オプション:
  - ガウシアンブラー（`--blur`）
  - 任意の反転（`--invert`）
- Douglas-Peucker 近似によるパス簡略化（`--epsilon`）
- `width`、`height`、`viewBox` により入力ピクセル寸法を保持する SVG 出力
- PPTX 画像ユーティリティ:
  - スライド単位で埋め込み画像を抽出
  - スライドページを `page1.png`, `page2.png`, ... にレンダリング

## 🗂️ プロジェクト構成

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (optional for core CLI)
├── i18n/                            # Translation directory (currently scaffold/empty)
└── scripts/
    ├── extract_pptx_images.py
    ├── render_pptx_slides.py
    ├── render_pptx_slides.sh
    ├── setup_conda_env.sh
    ├── crop_elements_from_layout.py
    ├── crop_elements_from_layout_v2.py
    ├── extract_part_grsai.py
    ├── extract_elements_grsai_pipeline.py
    ├── extract_elements_from_prompt_json.py
    ├── run_grsai_three_step.sh
    ├── codex_describe_images_to_md.sh
    ├── codex_extract_layout_elements.sh
    ├── codex_extract_layout_elements_v2.sh
    ├── codex_generate_tikz_from_parts.sh
    ├── codex_compile_tikz_pdf.sh
    └── run_tikz_prompt_pipeline.sh
```

## 📦 前提条件

### コア CLI

- Python 3
- `pip`
- [`requirements.txt`](requirements.txt) の依存関係:
  - `opencv-python`
  - `numpy`

### 任意の PPTX 補助ツール

- `scripts/extract_pptx_images.py` の実行に必要:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py` の実行に必要:
  - LibreOffice（`soffice` または `libreoffice` が `PATH` 上にあること）
  - `PyMuPDF`（`fitz`）
- 任意の補助セットアップ:
  - Conda（`scripts/setup_conda_env.sh` 用）

### 任意の高度なパイプライン

`scripts/` 配下のいくつかのスクリプトは外部ツール/サービス（例: `codex` CLI や GRS AI API）に依存します。これらは任意であり、`aigi2vector.py` の実行には不要です。

## 🛠️ インストール

### クイックスタート（既存の標準フロー）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX ユーティリティ向け任意の Conda セットアップ

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ 使い方

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI オプション

| オプション | デフォルト | 説明 |
|---|---|---|
| `--mode edges|binary` | `edges` | ベクター化モード |
| `--canny LOW HIGH` | `100 200` | `edges` モード用の低/高しきい値 |
| `--threshold N` | `128` | `binary` モードで使う二値化しきい値 |
| `--invert` | off | 輪郭検出前に白黒を反転 |
| `--blur K` | `3` | ガウシアンブラーのカーネルサイズ（奇数） |
| `--epsilon E` | `1.5` | 曲線の簡略化。大きいほど点数が減る |

### モードの動作

- `edges` モードは Canny エッジ検出を実行し、外側輪郭をトレースします。
- `binary` モードはグレースケールを二値化し、得られたマスクの外側輪郭をトレースします。

## ⚙️ 設定

### メイン CLI パラメータの調整

- `--canny LOW HIGH`:
  - 値を下げると、より多くの細部/ノイズを拾います。
  - 値を上げると、輪郭はよりクリーンになりますが疎になる場合があります。
- `--threshold`（binary モード）:
  - 低いしきい値では、明るい領域も前景として残りやすくなります。
  - 高いしきい値では、暗部/高コントラスト領域が主に残ります。
- `--blur`:
  - 内部的に正の奇数カーネルへ自動正規化されます。
  - 大きい値ほど輪郭検出前にノイズを平滑化します。
- `--epsilon`:
  - 大きい値ほどパスを強く簡略化します（点が少ない）。
  - 小さい値ほど形状の細部を保持します。

### 環境変数（高度なスクリプト）

- `GRSAI` は GRS AI 抽出スクリプト（例: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`）で必要です。

注記: 高度なスクリプトは環境依存で、現行 README ベースラインでは一部未文書化です。以下のコマンドはリポジトリ上で正確な挙動を維持していますが、すべてのマシンでの移植性は保証しません。

## 🧪 例

### ラスターから SVG

Edges（線画向き）:

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes（ロゴ/フラットアート向き）:

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 画像抽出

`.pptx` から埋め込み画像（例: スライドごとに 1〜2 枚）を抽出する場合:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

スライド間の重複画像をスキップするには `--dedupe` を追加します。`--png` を追加すると `p{slide}image{index}.png` 形式で保存します。

### スライドを画像にレンダリング

各スライドを `page1.png`, `page2.png`, ... にレンダリングするには、LibreOffice（`soffice`）が必要です:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

または Python レンダラーを使用します（これも LibreOffice を使用し、その後 PDF ページを PNG に変換）:

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 任意の高度なワークフロー（scripts）

これらのスクリプトはリポジトリに存在し、より大きな分解/再構成パイプラインに利用できます:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要: これらのスクリプトの一部には、現在マシン依存の絶対パスや外部サービス依存が含まれます。本番利用前に調整してください。

## 🧰 開発メモ

- 主実装は単一ファイルの Python CLI: [`aigi2vector.py`](aigi2vector.py)
- 関数/変数名は `snake_case`、定数は `UPPER_SNAKE_CASE` を維持
- 巨大な一塊より、小さくテストしやすい関数を優先
- 現時点では正式なテストスイートは未整備
- `AIGI/` は git で無視され、ローカル資産向けです

## 🛟 トラブルシューティング

- 入力画像/PPTX で `FileNotFoundError`:
  - 入力パスが正しく、読み取り可能か確認してください。
- `Could not read image`:
  - OpenCV が対応する形式で、ファイルが破損していないか確認してください。
- SVG 出力が空、または品質が低い:
  - `--mode binary` を使い、`--threshold` を調整してください。
  - `edges` モードで `--canny` のしきい値を調整してください。
  - `--epsilon` を下げて輪郭点をより多く保持してください。
  - まず高コントラストな元画像を使ってください。
- `LibreOffice (soffice) not found in PATH`:
  - LibreOffice をインストールし、`soffice` または `libreoffice` がシェルから見つかるようにしてください。
- スクリプト実行フローで Python パッケージ不足:
  - そのスクリプト経路に必要な依存関係（`python-pptx`, `Pillow`, `PyMuPDF` など）をインストールしてください。
- GRS AI スクリプトが認証エラーで失敗:
  - 例: `export GRSAI=...` のようにキーをエクスポートしてください。

## 🗺️ ロードマップ

今後の改善候補:

- `tests/` 配下に決定論的なサンプル画像を使った自動テストを追加
- スクリプトワークフロー向けの任意依存関係グループを統一公開
- 高度なシェルパイプラインの移植性を改善（ハードコードされた絶対パスの削減）
- バージョン管理されたサンプル資産配下に入出力の参照例を追加
- `i18n/` に維持管理された翻訳 README バリアントを拡充

## 🤝 コントリビュート

コントリビューションを歓迎します。

推奨プロセス:

1. 現在のメインラインからフォークまたはブランチを作成します。
2. 変更は一つの目的に絞り、短い命令形コミットメッセージを使ってください。
3. 変更したコマンド（CLI/スクリプト経路）を実行し、出力を確認してください。
4. 挙動が変わる場合は README の使用方法メモを更新してください。

テストを追加する場合は、`tests/` 配下に配置し、ファイル名は `test_*.py` にしてください。

## 📝 注記

- 出力 SVG は入力ピクセル寸法を使用します。必要に応じてベクターエディタ側でスケールしてください。
- 最良の結果を得るには、高コントラストな画像から始めてください。

## License

MIT
