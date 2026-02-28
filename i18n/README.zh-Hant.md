[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

將 AI 生成的光柵影像轉換為乾淨的向量繪圖 SVG。

本專案提供一個 Python CLI，可偵測影像中的邊緣或二值形狀，並將其寫入 SVG 路徑。它偏向於產生可供繪圖機使用的風格化向量化，並非寫實追蹤。

## 🧰 At a Glance (Quick Matrix)

| 區域 | 位置 | 目的 |
|---|---|---|
| 核心轉換 | [`aigi2vector.py`](aigi2vector.py) | 將光柵或由 PPTX 提取影像轉為 SVG |
| 可選 PPTX 輔助 | `scripts/` | 擷取並轉換投影片資產 |
| 擴充自動化 | `AutoAppDev/` | 可選的外部自動化工具組 |

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

| 使用情境 | 進入點 | 輸出 |
|---|---|---|
| 將單張影像轉成 SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| 調整輸出精細度 | CLI 參數（[`Usage`](#-usage)）中的 `--mode`、`--canny`、`--epsilon` 等 | 更乾淨或更密集的輪廓 |
| 處理 PPTX 資產 | `scripts/` 輔助工具 + 選用 conda 環境 | 提取影像 + 轉出的投影片 PNG |

## 🎯 At a Glance

| 層級 | 說明 | 位置 |
|---|---|---|
| 核心 CLI | 以單一指令將光柵影像轉為 SVG 路徑 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 輔助 | 抽取投影片內容並渲染頁面，供後續向量化處理 | `scripts/` |
| 選用自動化 | 更大型的 AI 輔助提取與組合流程 | `AutoAppDev/`, `scripts/` |

## ✨ Overview

`aigi2vector` 包含：

- 核心光柵轉 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可選的 PPTX 輔助腳本，用於抽取內嵌影像並將投影片渲染為 PNG
- `scripts/` 下的其他工作流程腳本，包含版面擷取、裁切與 AI 輔助流程
- 一個 `AutoAppDev/` 子模組（外部工具；主 CLI 不需要）

| 項目 | 說明 |
|---|---|
| 核心用途 | 將光柵影像轉為 SVG 路徑輸出 |
| 主要模式 | 單檔 Python CLI |
| 核心相依套件 | `opencv-python`, `numpy` |
| 可選流程 | PPTX 提取/渲染、AI 輔助腳本流程 |

## 🚀 Features

- 透過兩種模式將光柵影像轉為 SVG 路徑：
  - `edges`: 基於 Canny 的邊緣偵測
  - `binary`: 閾值分割形狀提取
- 前處理控制：
  - 高斯模糊 (`--blur`)
  - 可選反轉 (`--invert`)
- 使用 Douglas-Peucker 近似法簡化路徑 (`--epsilon`)
- 輸出 SVG 時保留輸入影像的像素尺寸，透過 `width`、`height` 與 `viewBox`
- PPTX 影像工具：
  - 按投影片抽取內嵌影像
  - 將投影片頁面轉為 `page1.png`、`page2.png`、...

## 🗂️ Project Structure

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule（核心 CLI 可選）
├── i18n/                            # 翻譯目錄
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
- 來自 [`requirements.txt`](requirements.txt) 的相依套件：
  - `opencv-python`
  - `numpy`

### Optional PPTX Helpers

- 對於 `scripts/extract_pptx_images.py`：
  - `python-pptx`
  - `Pillow`
- 對於 `scripts/render_pptx_slides.py`：
  - LibreOffice（`PATH` 中的 `soffice` 或 `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 可選輔助設定：
  - Conda（用於 `scripts/setup_conda_env.sh`）

### Optional Advanced Pipelines

`scripts/` 下若干腳本會依賴外部工具或服務（例如 `codex` CLI 與 GRS AI API）。這些並非必要，且不需要才能執行 `aigi2vector.py`。

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

| Option | Default | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | 向量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高門檻值 |
| `--threshold N` | `128` | `binary` 模式使用的二值化門檻 |
| `--invert` | off | 在輪廓偵測前反轉黑白 |
| `--blur K` | `3` | 高斯模糊核心大小（奇數整數） |
| `--epsilon E` | `1.5` | 曲線簡化；值越高點越少 |

### How Modes Work

- `edges` 模式會執行 Canny 邊緣偵測並追蹤外部輪廓。
- `binary` 模式會先對灰階像素做閾值化，並追蹤結果遮罩的外部輪廓。

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

- `--canny LOW HIGH`：
  - 較低值會保留更多細節與雜訊。
  - 較高值則會得到更乾淨但可能更稀疏的輪廓。
- `--threshold`（binary 模式）：
  - 較低門檻值會保留更多亮區為前景。
  - 較高門檻值只保留較暗且高對比的區域。
- `--blur`：
  - 會在內部自動正規化為正奇數 kernel。
  - 較大的值可在輪廓偵測前平滑雜訊。
- `--epsilon`：
  - 值越大，路徑簡化越積極（點數更少）。
  - 值越小，形狀細節保留越完整。

### Environment variables (advanced scripts)

- `GRSAI` 為 GRS AI 擷取腳本所需（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

假設說明：進階腳本具備環境專屬特性，且目前在 README 主文中的文件資訊仍不完整；下列指令保持與本庫行為一致，但不保證在所有機器上都可直接移植。

## 🧪 Examples

### Raster to SVG

Edges（適合線稿）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes（適合商標 / 扁平插畫）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

若你需要從 `.pptx` 抽取內嵌影像（例如每張投影片一到兩張），請使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

加上 `--dedupe` 以略過跨投影片重複影像。加上 `--png` 可將檔案儲存為 `p{slide}image{index}.png`。

### Render slides to images

要將每張投影片輸出為 `page1.png`、`page2.png`、... 需要安裝 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（同樣先用 LibreOffice，接著將 PDF 頁面轉為 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optional advanced workflows (scripts)

這些腳本存在於本庫，可用於更大規模的拆解／重建流程：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要：這些腳本目前仍含有機台特定的絕對路徑與外部服務相依；請在正式環境使用前先做調整。

## 🛠️ Development Notes

- 主要實作是單檔 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 保持函式與變數命名使用 `snake_case`，常數使用 `UPPER_SNAKE_CASE`
- 優先採用小型、可測試的函式，避免過於龐大的單一區塊
- 目前尚未建立正式測試套件
- `AIGI/` 會被 Git 忽略，僅供本機素材使用

## 🛟 Troubleshooting

- `FileNotFoundError`（輸入影像/PPTX）：
  - 確認輸入路徑正確且可讀取。
- `Could not read image`：
  - 確認影像格式受 OpenCV 支援且未損毀。
- SVG 輸出為空或效果不佳：
  - 改用 `binary` 模式並調整 `--threshold`。
  - 調整 `edges` 模式的 `--canny` 閾值。
  - 降低 `--epsilon` 以保留更多輪廓點。
  - 從高對比度來源影像開始處理。
- `LibreOffice (soffice) not found in PATH`：
  - 安裝 LibreOffice 並確認 `soffice` 或 `libreoffice` 可被 shell 找到。
- 缺少腳本流程所需的 Python 套件：
  - 安裝該腳本路徑的相依套件（如 `python-pptx`、`Pillow`、`PyMuPDF`）。
- GRS AI 腳本回報授權錯誤：
  - 匯出你的金鑰，例如：`export GRSAI=...`。

## 🗺️ Roadmap

未來可能的改善方向：

- 在 `tests/` 加入使用可重現樣本影像的自動化測試
- 為腳本流程提供統一的可選相依性群組
- 提升進階 shell 流程的可攜性（移除硬編碼絕對路徑）
- 新增版本化樣本資產中的輸入／輸出參考
- 完善 `i18n/` 內持續維護的翻譯 README

## 🤝 Contributing

歡迎提交貢獻。

建議流程：

1. 從目前主線 fork 或建立分支。
2. 維持變更聚焦，並使用簡短、命令式的提交訊息。
3. 執行你修改過的相關指令（CLI/腳本路徑）並驗證輸出。
4. 當行為變更時，更新 README 使用說明。

若新增測試，請放在 `tests/` 並使用 `test_*.py` 命名。

## 📝 Notes

- 輸出的 SVG 會保留輸入影像的像素尺寸，必要時可在向量編輯器中縮放。
- 為了取得最佳結果，請使用高對比度影像作為起點。

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
