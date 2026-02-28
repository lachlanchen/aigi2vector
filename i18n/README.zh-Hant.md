[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

將 AI 生成的點陣圖像轉換為乾淨、可繪圖機使用的向量 SVG 路徑。

此儲存庫提供一個 Python CLI，可在圖像中偵測邊緣或二值化形狀，並輸出為 SVG 路徑。它的設計目標是風格化、繪圖機友善的向量化，而非擬真照片追蹤。

## ✨ 概覽

`aigi2vector` 包含：

- 核心的點陣轉 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可選的 PPTX 輔助工具，用於擷取內嵌圖片與將投影片渲染成 PNG
- 位於 `scripts/` 下的額外工作流程腳本，用於版面擷取、裁切與 AI 輔助流程
- `AutoAppDev/` 子模組（外部工具；執行主 CLI 不需要）

| 項目 | 詳細說明 |
|---|---|
| 核心目的 | 將點陣圖像轉換為 SVG 路徑輸出 |
| 主要模式 | 單檔 Python CLI |
| 核心相依套件 | `opencv-python`, `numpy` |
| 可選工作流程 | PPTX 擷取/渲染、AI 輔助腳本流程 |

## 🚀 功能

- 使用兩種模式將點陣圖像轉成 SVG 路徑：
  - `edges`：基於 Canny 的邊緣偵測
  - `binary`：二值化形狀擷取
- 前處理控制：
  - 高斯模糊（`--blur`）
  - 可選反相（`--invert`）
- 使用 Douglas-Peucker 近似進行路徑簡化（`--epsilon`）
- SVG 輸出透過 `width`、`height` 與 `viewBox` 保留輸入像素尺寸
- PPTX 圖片工具：
  - 依投影片擷取內嵌圖片
  - 將投影片頁面渲染為 `page1.png`、`page2.png`、...

## 🗂️ 專案結構

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

## 📦 先決條件

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
  - LibreOffice（`PATH` 中需可找到 `soffice` 或 `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 可選輔助設定：
  - Conda（用於 `scripts/setup_conda_env.sh`）

### Optional Advanced Pipelines

`scripts/` 下有數個腳本依賴外部工具/服務（例如 `codex` CLI 與 GRS AI APIs）。這些皆為可選，執行 `aigi2vector.py` 不需要。

## 🛠️ 安裝

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

## ▶️ 使用方式

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI Options

| Option | Default | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | 向量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高門檻 |
| `--threshold N` | `128` | `binary` 模式使用的二值化門檻 |
| `--invert` | off | 輪廓偵測前反轉黑白 |
| `--blur K` | `3` | 高斯模糊核心大小（奇數） |
| `--epsilon E` | `1.5` | 曲線簡化；值越大點越少 |

### How Modes Work

- `edges` 模式會執行 Canny 邊緣偵測，並追蹤外部輪廓。
- `binary` 模式會先對灰階像素做閾值化，再追蹤遮罩的外部輪廓。

## ⚙️ 設定

### Main CLI parameter tuning

- `--canny LOW HIGH`：
  - 較低數值可保留更多細節/雜訊。
  - 較高數值可得到更乾淨但可能更稀疏的輪廓。
- `--threshold`（binary 模式）：
  - 較低門檻會保留更多亮區為前景。
  - 較高門檻會主要保留深色/高對比區域。
- `--blur`：
  - 內部會自動正規化為正奇數核心。
  - 較大數值可在輪廓偵測前平滑雜訊。
- `--epsilon`：
  - 較大數值會更積極簡化路徑（更少點）。
  - 較小數值會保留更多形狀細節。

### Environment variables (advanced scripts)

- GRS AI 擷取腳本需要設定 `GRSAI`（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

假設說明：進階腳本高度依賴執行環境，且目前 README 基線中仍有部分未完整文件化內容；以下命令保持與儲存庫現況一致，但不保證能在所有機器上直接可攜執行。

## 🧪 範例

### Raster to SVG

Edges（適合線稿）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes（適合 Logo / 平面圖形）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

若你需要從 `.pptx` 擷取內嵌圖片（例如每張投影片一到兩張圖），可使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

加上 `--dedupe` 可跳過跨投影片重複圖片。加上 `--png` 可將檔案儲存為 `p{slide}image{index}.png`。

### Render slides to images

若要將每張投影片渲染為 `page1.png`、`page2.png`、...，需先安裝 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（同樣依賴 LibreOffice，接著把 PDF 頁面轉為 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optional advanced workflows (scripts)

這些腳本已存在於儲存庫，可用於較大型的拆解/重建流程：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要：其中部分腳本目前包含機器專屬絕對路徑與外部服務相依性；正式使用前請先調整。

## 🧰 開發說明

- 主要實作為單檔 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 函式/變數命名維持 `snake_case`，常數使用 `UPPER_SNAKE_CASE`
- 優先採用小型、可測試函式，避免單體式區塊
- 目前尚無正式測試套件
- `AIGI/` 被 git 忽略，預期用於本地資產

## 🛟 疑難排解

- 輸入圖片/PPTX 出現 `FileNotFoundError`：
  - 確認輸入路徑正確且可讀。
- `Could not read image`：
  - 確認檔案格式受 OpenCV 支援且未損毀。
- SVG 輸出為空或品質不佳：
  - 試試 `--mode binary` 並調整 `--threshold`。
  - 在 `edges` 模式調整 `--canny` 門檻。
  - 降低 `--epsilon` 以保留更多輪廓點。
  - 盡量使用更高對比的來源圖片。
- `LibreOffice (soffice) not found in PATH`：
  - 安裝 LibreOffice，並確保 shell 可找到 `soffice` 或 `libreoffice`。
- 腳本流程缺少 Python 套件：
  - 安裝該腳本所需相依（`python-pptx`、`Pillow`、`PyMuPDF` 等）。
- GRS AI 腳本因驗證失敗：
  - 匯出你的金鑰，例如：`export GRSAI=...`。

## 🗺️ 路線圖

後續可考慮的改進：

- 在 `tests/` 下加入自動化測試與可重現的範例圖片
- 為腳本工作流程提供統一的可選相依套件分組
- 提升進階 shell 管線可攜性（移除硬編碼絕對路徑）
- 在版控的範例資產中加入參考輸入/輸出
- 持續完善 `i18n/` 多語 README 版本

## 🤝 貢獻

歡迎提交貢獻。

建議流程：

1. 從目前主線 fork 或建立分支。
2. 讓每次修改聚焦，並使用簡短祈使句 commit 訊息。
3. 執行你修改到的相關命令（CLI/腳本路徑）並驗證輸出。
4. 行為有變更時同步更新 README 使用說明。

若你新增測試，請放在 `tests/`，檔名為 `test_*.py`。

## 📝 備註

- 輸出 SVG 會使用輸入圖片的像素尺寸；若有需要可在向量編輯器中縮放。
- 為了最佳結果，請從高對比圖片開始。

## License

MIT
