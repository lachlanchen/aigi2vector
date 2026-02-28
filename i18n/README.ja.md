[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI生成のラスタ画像を、クリーンなプロッタ向けベクターSVGに変換します。

このリポジトリは、画像内のエッジまたは2値形状を検出し、SVGパスとして書き出すPython CLIを提供します。写真的なトレースではなく、プロッター向けのスタイル化されたベクトル化に特化しています。

## 🧰 At a Glance (Quick Matrix)

| 領域 | 場所 | 用途 |
|---|---|---|
| コア変換 | [`aigi2vector.py`](aigi2vector.py) | ラスター/PPTX抽出画像をSVGに変換 |
| PPTX補助機能（任意） | `scripts/` | スライド資産の抽出とレンダリング |
| 拡張自動化 | `AutoAppDev/` | 外部自動化スタック（任意） |

---

## 📚 Table of Contents

- [At a Glance](#-at-a-glance-quick-map)
- [Overview](#-overview)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Visual Workflow](#-visual-workflow)
- [Configuration](#-configuration)
- [Examples](#-examples)
- [Development Notes](#-development-notes)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [Notes](#-notes)
- [Support](#️-support)
- [License](#license)

## 🧭 At a Glance (Quick Map)

| 利用シーン | エントリーポイント | 出力 |
|---|---|---|
| 1枚の画像をSVGに変換 | `python aigi2vector.py input.png output.svg` | `output.svg` |
| 出力の詳細を調整 | [`Usage`](#-usage) のCLIフラグ（`--mode`, `--canny`, `--epsilon` など） | よりクリーンまたは密度の高い輪郭 |
| PPTX資産を処理 | `scripts/` のヘルパー + 任意のconda環境 | 抽出画像 + レンダリング済みスライドPNG |

## 🎯 At a Glance

| 層 | 説明 | 場所 |
|---|---|---|
| コアCLI | 1コマンドでラスター画像をSVGパスへ変換 | [`aigi2vector.py`](aigi2vector.py) |
| PPTXヘルパー | スライド内容を取得し、後段のベクトル化向けにページをレンダリング | `scripts/` |
| 任意の自動化 | より大きなAI支援の抽出・再構成ワークフロー | `AutoAppDev/`, `scripts/` |

## ✨ Overview

`aigi2vector`には次が含まれます:

- コアのラスター→SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- 画像を埋め込みから抽出し、スライドをPNGへレンダリングする任意のPPTXヘルパー
- レイアウト抽出、トリミング、AI支援パイプライン向けの追加ワークフロー用スクリプト `scripts/`
- `AutoAppDev/` サブモジュール（外部ツール。メインCLI実行には不要）

| 項目 | 詳細 |
|---|---|
| 主目的 | ラスター画像をSVGパスとして出力 |
| 主モード | 単一ファイルのPython CLI |
| コア依存 | `opencv-python`, `numpy` |
| 任意のワークフロー | PPTX抽出/レンダリング、AI支援スクリプトパイプライン |

## 🚀 Features

- ラスター画像を2つのモードでSVGパスに変換します。
  - `edges`: Cannyベースのエッジ検出
  - `binary`: 閾値付き形状抽出
- 前処理の制御:
  - ガウシアンブラー (`--blur`)
  - 反転の指定 (`--invert`, 任意)
- Douglas-Peucker近似（`--epsilon`）によるパス簡略化
- `width`、`height`、`viewBox` により入力ピクセルサイズを保持したSVG出力
- PPTX画像ユーティリティ:
  - スライドごとの埋め込み画像抽出
  - `page1.png`、`page2.png` ... へのレンダリング

## 🗂️ Project Structure

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

## 📦 Prerequisites

### Core CLI

- Python 3
- `pip`
- [`requirements.txt`](requirements.txt) の依存:
  - `opencv-python`
  - `numpy`

### Optional PPTX Helpers

- `scripts/extract_pptx_images.py` 向け:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py` 向け:
  - LibreOffice（`PATH` にある `soffice` または `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 任意のヘルパー構成:
  - Conda（`scripts/setup_conda_env.sh` 向け）

### Optional Advanced Pipelines

`scripts/` 配下の一部スクリプトは外部ツール/サービス（例: `codex` CLI や GRS AI API）に依存します。これらは任意であり、`aigi2vector.py` の実行には必要ありません。

## 🛠️ Installation

### Quick Start (existing canonical flow)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Optional Conda setup for PPTX utilities

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Usage

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI Options

| Option | デフォルト | 説明 |
|---|---|---|
| `--mode edges|binary` | `edges` | ベクトル化モード |
| `--canny LOW HIGH` | `100 200` | edgesモードの低/高閾値 |
| `--threshold N` | `128` | `binary` モードで使用する2値化閾値 |
| `--invert` | off | 輪郭検出前に黒/白を反転 |
| `--blur K` | `3` | ガウシアンブラーのカーネルサイズ（奇数の整数） |
| `--epsilon E` | `1.5` | 曲線簡略化。値が大きいほど点数が減少 |

### How Modes Work

- `edges` モード: Cannyエッジ検出を実行し、外側の輪郭をトレースします。
- `binary` モード: グレースケール画像を閾値化し、その結果マスクの外側輪郭をトレースします。

## 🔧 Visual Workflow

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/` (optional)
   |
   v
Raster tracing + contour simplification
   |
   v
SVG output
```

## ⚙️ Configuration

### Main CLI parameter tuning

- `--canny LOW HIGH`:
  - 小さい値はより多くの詳細/ノイズを取り込みます。
  - 大きい値は輪郭をよりクリーンにしますが、疎な結果になりやすいです。
- `--threshold`（`binary` モード）:
  - 低い閾値は明るい領域をより多く前景として保持します。
  - 高い閾値は主に暗い領域／高コントラスト領域のみを保持します。
- `--blur`:
  - 内部で正規化され、正の奇数カーネルに調整されます。
  - 大きい値は輪郭検出前のノイズを滑らかにします。
- `--epsilon`:
  - 大きい値はパスをより積極的に簡略化し、点数を減らします。
  - 小さい値は形状ディテールを保ちます。

### Environment variables (advanced scripts)

- `GRSAI` は GRS AI抽出スクリプト（例: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`）で必要になります。

Assumption note: advanced scripts are environment-specific and partially undocumented in the current README baseline; commands below keep repository-accurate behavior without guaranteeing portability across all machines.

## 🧪 Examples

### Raster to SVG

Edges（線画向け）:

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes（ロゴやフラットアート向け）:

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

`.pptx` から埋め込み画像を抽出したい場合（例: スライドあたり1〜2枚）:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

`--dedupe` を付けるとスライド間の重複画像をスキップできます。`--png` を付けると `p{slide}image{index}.png` として保存されます。

### Render slides to images

各スライドを `page1.png`、`page2.png` ... としてレンダリングするには、LibreOffice（`soffice`）をインストールしておく必要があります:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

あるいは Python レンダラを使って（LibreOfficeを使用し、PDFページをPNGに変換）:

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optional advanced workflows (scripts)

これらのスクリプトはリポジトリ内にあり、大規模な分割・再構成パイプラインで使うことができます:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要: これらの一部は現在、マシン固有の絶対パスや外部サービス依存を含みます。実運用で使う前に環境に合わせて調整してください。

## 🧰 Development Notes

- 主実装は単一ファイルのPython CLIです: [`aigi2vector.py`](aigi2vector.py)
- 関数/変数名は `snake_case`、定数は `UPPER_SNAKE_CASE` を推奨
- モノリシックな実装より、テストしやすい小さな関数を優先
- 現時点では正式なテストスイートは存在しません
- `AIGI/` はGitに含まれず、ローカルアセット用です

## 🛟 Troubleshooting

- 入力画像/PPTXの `FileNotFoundError`:
  - 入力パスが正しく、読み取り可能か確認してください。
- `Could not read image`:
  - ファイル形式がOpenCVでサポートされているか、破損していないか確認してください。
- SVG出力が空、または品質が低い場合:
  - `--mode binary` と `--threshold` を調整して試してください。
  - `edges` モードで `--canny` の閾値を調整してください。
  - `--epsilon` を下げると輪郭点をより多く保持できます。
  - コントラストの高い元画像から試すと効果的です。
- `LibreOffice (soffice) not found in PATH`:
  - LibreOfficeをインストールし、`soffice` または `libreoffice` がシェルの `PATH` で参照できることを確認してください。
- スクリプト実行フローでPythonパッケージが不足している場合:
  - 該当フローで必要な依存をインストールしてください（`python-pptx`、`Pillow`、`PyMuPDF` など）。
- GRS AI スクリプトで認証エラーが発生する場合:
  - キーをエクスポートしてください（例: `export GRSAI=...`）。

## 🗺️ Roadmap

今後の改善候補:

- `tests/` 配下に決定的なサンプル画像を用いた自動テストを追加
- 任意ワークフロー向けの統一された依存関係グループを公開
- 高度なシェルパイプラインの可搬性を改善（ハードコードされた絶対パスを削減）
- 参照用の入出力サンプルをバージョン管理された資産で追加
- 維持される翻訳READMEを `i18n/` に追加

## 🤝 Contributing

コントリビュートは歓迎します。

推奨手順:

1. 現在のmainlineからforkまたはbranchを作成します。
2. 変更は焦点を絞り、短い命令形のコミットメッセージを使います。
3. 変更したCLI/スクリプト経路に対して関連コマンドを実行し、結果を確認します。
4. 挙動変更時はREADMEの利用セクションを更新します。

テストを追加する場合は、`tests/` 配下に `test_*.py` という名前で配置してください。

## 📝 Notes

- 出力SVGは入力画像のピクセル寸法を使用します。必要に応じてベクターエディターでスケーリングしてください。
- 最適な結果を得るには、高コントラスト画像から開始してください。

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
