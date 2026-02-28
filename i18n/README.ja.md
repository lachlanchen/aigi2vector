[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

AI 生成のラスター画像を、クリーンなベクターパス SVG に変換します。

このリポジトリは、画像内のエッジまたは二値形状を検出して SVG パスとして書き出す Python CLI を提供します。フォトリアリスティックなトレースではなく、スタイライズされたプロッター向けベクター化を想定しています。

## 🎯 概要

| レイヤー | 説明 | 場所 |
|---|---|---|
| コア CLI | 1 回のコマンドでラスター画像を SVG パスに変換 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX ヘルパー | スライド内容の抽出とレンダリングを行い、下流のベクター化に備える | `scripts/` |
| 任意の自動化 | AI 支援の抽出・合成などより大きな処理フロー | `AutoAppDev/`, `scripts/` |

## ✨ 概要

`aigi2vector` には以下が含まれます。

- コアのラスター→SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- 埋め込み画像を抽出し、スライドを PNG でレンダリングする任意 PPTX ヘルパー
- レイアウト抽出、切り抜き、AI 支援パイプライン用の追加ワークフロースクリプト（`scripts/` 配下）
- `AutoAppDev/` サブモジュール（外部ツール。メイン CLI には不要）

| 項目 | 詳細 |
|---|---|
| コア目的 | ラスター画像を SVG パスとして出力 |
| 主な実行形態 | 単一ファイルの Python CLI |
| コア依存関係 | `opencv-python`, `numpy` |
| 任意ワークフロー | PPTX 抽出/レンダリング、AI 支援スクリプトパイプライン |

## 🚀 特徴

- ラスター画像を SVG パスへ変換する 2 つのモードを提供します。
  - `edges`: Canny ベースのエッジ検出
  - `binary`: 閾値処理による形状抽出
- 前処理コントロール:
  - ガウシアンぼかし (`--blur`)
  - 反転の有無 (`--invert`)
- Douglas-Peucker 近似 (`--epsilon`) によるパス簡略化
- `width`、`height`、`viewBox` を使って入力ピクセル寸法を保持した SVG を出力
- PPTX 画像ユーティリティ:
  - スライドごとに埋め込み画像を抽出
  - `page1.png`, `page2.png`, ... のようにスライドページをレンダリング

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

### 任意の PPTX ヘルパー

- `scripts/extract_pptx_images.py` 用:
  - `python-pptx`
  - `Pillow`
- `scripts/render_pptx_slides.py` 用:
  - LibreOffice（`PATH` 上の `soffice` か `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 任意のヘルパー設定:
  - Conda（`scripts/setup_conda_env.sh` 用）

### 任意の高度なパイプライン

`scripts/` 配下のいくつかのスクリプトは外部ツール/サービス（例: `codex` CLI や GRS AI API）に依存します。これは任意で、`aigi2vector.py` の実行には不要です。

## 🛠️ インストール

### クイックスタート（既存の標準フロー）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX ユーティリティ向け任意 Conda セットアップ

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
| `--canny LOW HIGH` | `100 200` | `edges` モードの low/high しきい値 |
| `--threshold N` | `128` | `binary` モードで使う二値化しきい値 |
| `--invert` | off | 輪郭検出前に白黒を反転 |
| `--blur K` | `3` | ガウシアンぼかしのカーネルサイズ（奇数） |
| `--epsilon E` | `1.5` | 曲線の簡略化。大きいほど点数が少なくなります |

### モードの仕組み

- `edges` モードは Canny エッジ検出を実行し、外側の輪郭をトレースします。
- `binary` モードはグレースケール画像を二値化し、結果マスクの外側輪郭をトレースします。

## ⚙️ 設定

### メイン CLI パラメータの調整

- `--canny LOW HIGH`:
  - 値を下げると細部（とノイズ）を多く拾います。
  - 値を上げると輪郭がクリーンになりますが、場合によっては疎になります。
- `--threshold`（binary モード）:
  - 低いしきい値では明るい領域も前景として残りやすくなります。
  - 高いしきい値では暗部や高コントラスト領域が主に残ります。
- `--blur`:
  - 内部で正の奇数カーネルに自動正規化されます。
  - 大きい値は輪郭検出前のノイズをより滑らかにします。
- `--epsilon`:
  - 大きい値ほどパスをより強く簡略化し、点数が少なくなります。
  - 小さい値ほど形状の細部が維持されます。

### 環境変数（高度なスクリプト）

- `GRSAI` は GRS AI 抽出スクリプトで必要です（例: `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`）。

前提: 高度なスクリプトは環境依存で、現行 README には一部未整備の部分があります。以下のコマンドはリポジトリ上での実際の挙動を保ちますが、すべての環境での移植性は保証しません。

## 🧪 使用例

### ラスター画像から SVG へ

エッジモード（線画に向く）:

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

二値モード（ロゴ／フラットアートに向く）:

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 画像抽出

`.pptx` から埋め込み画像（例: スライドごとに 1〜2 枚）を抽出したい場合:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

`--dedupe` を付けるとスライド間の重複画像を除外できます。`--png` を付けると `p{slide}image{index}.png` として保存されます。

### スライドを画像としてレンダリング

各スライドを `page1.png`、`page2.png` ... にレンダリングするには、LibreOffice（`soffice`）が必要です:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

または Python レンダラーを使います（LibreOffice を利用して PDF を PNG に変換します）:

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 任意の高度なワークフロー（scripts）

これらのスクリプトはリポジトリ内にあり、より大規模な分解／再構成パイプラインで利用できます。

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要: これらの一部のスクリプトは、現在の環境依存の絶対パスや外部サービス依存を含みます。運用前に必ず調整してください。

## 🧰 開発ノート

- メイン実装は単一ファイルの Python CLI です: [`aigi2vector.py`](aigi2vector.py)
- 関数名・変数名は `snake_case`、定数は `UPPER_SNAKE_CASE` を維持します。
- 大きな一体型コードより、テストしやすい小さな関数を優先します。
- 公式なテストスイートは現時点では未整備です。
- `AIGI/` は git 無視対象で、ローカル資産の保管先です。

## 🛟 トラブルシューティング

- 入力画像 / PPTX で `FileNotFoundError` が出る:
  - 入力パスが正しく、読み取り可能であることを確認してください。
- `Could not read image`:
  - OpenCV が対応する形式かつ破損していないファイルか確認してください。
- SVG の出力が空、または品質が悪い:
  - `--mode binary` を使い `--threshold` を調整してください。
  - `edges` モードで `--canny` のしきい値を調整してください。
  - `--epsilon` を下げると輪郭点がより多く保持されます。
  - まず高コントラストの元画像から開始してください。
- `LibreOffice (soffice) not found in PATH`:
  - LibreOffice をインストールし、`soffice` または `libreoffice` がシェル PATH で見つかるようにしてください。
- スクリプト実行フローで Python パッケージが不足:
  - 対象スクリプトの依存をインストールしてください（`python-pptx`、`Pillow`、`PyMuPDF` など）。
- GRS AI スクリプトが認証エラーで失敗:
  - 例: `export GRSAI=...` のようにキーをエクスポートしてください。

## 🗺️ ロードマップ

今後の改善候補:

- `tests/` を追加して決定的なサンプル画像で自動テストを実施
- スクリプトワークフロー向けに依存関係グループを統一公開
- 高度なシェルパイプラインの移植性改善（ハードコードの絶対パス削減）
- 参照となる入出力例をバージョン管理されたサンプル資産として追加
- `i18n/` を保守運用される翻訳 README で充実

## 🤝 Contributing

コントリビューションは歓迎します。

推奨される手順:

1. 現在のメインラインからフォークまたはブランチを作成します。
2. 変更は目的を絞り、短く命令形のコミットメッセージを使います。
3. 変更した CLI/スクリプト系コマンドを実行し、出力を確認します。
4. 挙動が変わった場合は README の使用メモを更新します。

テストを追加する場合は、`tests/` 配下に配置し、ファイル名は `test_*.py` とします。

## 📝 Notes

- 出力 SVG は入力画像のピクセル寸法を使います。必要に応じてベクター編集ソフト側でスケーリングしてください。
- 最良の結果を得るには、まずコントラストの高い画像を使ってください。

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
