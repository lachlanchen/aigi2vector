[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

將 AI 生成的點陣圖轉換為乾淨、可繪圖機使用的向量 SVG。

本儲存庫提供一個 Python CLI，可偵測影像中的邊緣或二值化形狀，並將其寫入 SVG 路徑。它設計重點在於風格化、繪圖機友善的向量化，而非高寫真追蹤。

## 🎯 總覽一覽

| 層級 | 說明 | 位置 |
|---|---|---|
| 核心 CLI | 透過單一指令將點陣圖轉為 SVG 路徑 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 輔助腳本 | 擷取投影片內容並渲染頁面，供後續向量化使用 | `scripts/` |
| 選用自動化 | 更大規模的 AI 協助萃取與組合流程 | `AutoAppDev/`, `scripts/` |

## ✨ 概覽

`aigi2vector` 包含：

- 核心的點陣圖轉 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可選的 PPTX 輔助腳本，用於擷取嵌入影像並將投影片渲染為 PNG
- `scripts/` 下的其他流程腳本，用於版面擷取、裁切與 AI 協助流程
- 一個 `AutoAppDev/` 子模組（外部工具，主 CLI 不必須）

| 項目 | 詳細 |
|---|---|
| 核心目的 | 將點陣圖轉為 SVG 路徑輸出 |
| 主要模式 | 單檔 Python CLI |
| 核心相依套件 | `opencv-python`, `numpy` |
| 可選工作流程 | PPTX 萃取/渲染、AI 輔助腳本流程 |

## 🚀 特性

- 使用兩種模式將點陣圖轉為 SVG 路徑：
  - `edges`：基於 Canny 的邊緣偵測
  - `binary`：二值化形狀萃取
- 預處理控制：
  - 高斯模糊（`--blur`）
  - 可選反轉（`--invert`）
- 使用 Douglas-Peucker 近似法簡化路徑（`--epsilon`）
- SVG 輸出會透過 `width`、`height` 與 `viewBox` 保留輸入像素尺寸
- PPTX 圖片工具：
  - 按投影片擷取內嵌影像
  - 將投影片頁面渲染為 `page1.png`、`page2.png`、...

## 🗂️ 專案結構

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git 子模組（核心 CLI 可選）
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

## 📦 前置需求

### 核心 CLI

- Python 3
- `pip`
- 來自 [`requirements.txt`](requirements.txt) 的套件：
  - `opencv-python`
  - `numpy`

### 選用 PPTX 輔助

- 針對 `scripts/extract_pptx_images.py`：
  - `python-pptx`
  - `Pillow`
- 針對 `scripts/render_pptx_slides.py`：
  - LibreOffice（`PATH` 內可找到 `soffice` 或 `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 選用輔助環境：
  - Conda（用於 `scripts/setup_conda_env.sh`）

### 選用進階流程

`scripts/` 下的部分腳本依賴外部工具/服務（例如 `codex` CLI 與 GRS AI API）。這些是可選項，執行 `aigi2vector.py` 不需要安裝它們。

## 🛠️ 安裝

### 快速開始（既有標準流程）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX 工具的選用 Conda 設定

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ 用法

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI 選項

| 選項 | 預設值 | 說明 |
|---|---|---|
| `--mode edges|binary` | `edges` | 向量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高門檻 |
| `--threshold N` | `128` | `binary` 模式使用的二值門檻 |
| `--invert` | off | 在輪廓偵測前反轉黑白 |
| `--blur K` | `3` | 高斯模糊核心大小（奇數） |
| `--epsilon E` | `1.5` | 曲線簡化；值越大點數越少 |

### 運作方式

- `edges` 模式會執行 Canny 邊緣偵測，並追蹤外部輪廓。
- `binary` 模式會將灰階像素做門檻化，並追蹤結果遮罩的外部輪廓。

## ⚙️ 設定

### 主要 CLI 參數微調

- `--canny LOW HIGH`：
  - 較低值可保留更多細節/雜訊。
  - 較高值會產生較乾淨但可能較稀疏的輪廓。
- `--threshold`（`binary` 模式）：
  - 較低門檻保留更多亮區作為前景。
  - 較高門檻主要保留暗區與高對比區域。
- `--blur`：
  - 會在內部自動正規化為正奇數核心。
  - 較大數值可在輪廓偵測前平滑雜訊。
- `--epsilon`：
  - 較大值會更積極簡化路徑（點數更少）。
  - 較小值可保留更多形狀細節。

### 環境變數（進階腳本）

- `GRSAI` 由 GRS AI 萃取腳本所需（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

假設說明：進階腳本高度依賴執行環境，且目前 README 基線部分內容仍未完整文件化；以下命令保留目前儲存庫行為，但不保證在所有機器上都能直接移植。

## 🧪 範例

### 點陣圖轉 SVG

邊緣模式（適合線條插圖）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

二值形狀（適合 logo / 平面插圖）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 影像擷取

如果你需要從 `.pptx` 抽取嵌入影像（例如每張投影片一到兩張），請使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

加上 `--dedupe` 可跳過跨投影片重複影像。加上 `--png` 可將檔案儲存為 `p{slide}image{index}.png`。

### 將投影片渲染成影像

若需將每張投影片渲染為 `page1.png`、`page2.png`，請先安裝 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（同樣依賴 LibreOffice，接著將 PDF 頁面轉為 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 選用進階工作流（腳本）

這些腳本存在於本庫，可用於較大型分解與重建流程：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

注意：其中部分腳本目前含有機器特定的絕對路徑與外部服務依賴；上線前請先依實際環境調整。

## 🧰 開發筆記

- 主要實作為單一 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 函式/變數命名請使用 `snake_case`，常數使用 `UPPER_SNAKE_CASE`
- 優先採用小型可測試函式，避免單體式大區塊實作
- 目前尚未提供正式測試框架
- `AIGI/` 被 git 忽略，作為本機資源使用

## 🛟 疑難排解

- `FileNotFoundError`（找不到輸入影像/PPTX）：
  - 確認輸入路徑是否正確且可讀取。
- `Could not read image`：
  - 確認檔案格式為 OpenCV 支援，且未損毀。
- SVG 輸出為空或品質不佳：
  - 嘗試在 `--mode binary` 下調整 `--threshold`。
  - 調整 `edges` 模式的 `--canny` 門檻。
  - 降低 `--epsilon` 以保留更多輪廓點。
  - 從較高對比的來源影像開始。
- `LibreOffice (soffice) not found in PATH`：
  - 安裝 LibreOffice，並確保 shell 中可找出 `soffice` 或 `libreoffice`。
- 腳本流程缺少 Python 套件：
  - 安裝該腳本路徑需要的套件（如 `python-pptx`、`Pillow`、`PyMuPDF`）。
- GRS AI 腳本因身分驗證失敗：
  - 匯出你的金鑰，例如：`export GRSAI=...`。

## 🗺️ 發展藍圖

未來可考慮的改進：

- 在 `tests/` 下新增自動化測試與可重現的小型範例影像
- 提供腳本流程統一的可選相依性群組
- 提升進階 shell 流程可攜性（移除硬編碼絕對路徑）
- 在版本化範例資產下新增參考輸入/輸出
- 持續充實 `i18n/` 的維護版 README

## 🤝 貢獻

歡迎貢獻。

建議流程：

1. 從目前主分支 fork 或建立分支。
2. 讓修改集中，並使用簡短、命令式的 commit 訊息。
3. 依你變動的 CLI/腳本路徑執行對應命令並驗證輸出。
4. 行為有變更時更新 README 使用說明。

如果你新增測試，請放到 `tests/` 並使用 `test_*.py` 命名。

## 📝 備註

- 輸出的 SVG 保持輸入像素尺寸；如有需要可在向量編輯器中縮放。
- 為達最佳結果，建議使用高對比度影像作為輸入。

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
