[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

将 AI 生成的栅格图像转换为清晰的可绘制 SVG 向量图。

本仓库提供一个 Python CLI，可检测图像中的边缘或二值形状并写出 SVG 路径。它面向的是风格化、适合绘图机的向量化，而不是写实级别的追踪。

<a id="at-a-glance-quick-matrix"></a>
## 🧰 概览（快速矩阵）

| 范围 | 位置 | 用途 |
|---|---|---|
| 核心转换 | [`aigi2vector.py`](aigi2vector.py) | 将栅格 / 从 PPTX 提取的图像转换为 SVG |
| 可选 PPTX 辅助 | `scripts/` | 提取并渲染幻灯片资源 |
| 扩展自动化 | `AutoAppDev/` | 可选的外部自动化工具栈 |

---

<a id="table-of-contents"></a>
## 📚 目录

- [概览（快速矩阵）](#at-a-glance-quick-matrix)
- [简介](#overview)
- [功能](#features)
- [项目结构](#project-structure)
- [先决条件](#prerequisites)
- [安装](#installation)
- [用法](#usage)
- [可视化工作流](#visual-workflow)
- [配置](#configuration)
- [示例](#examples)
- [开发说明](#development-notes)
- [故障排查](#troubleshooting)
- [路线图](#roadmap)
- [参与贡献](#contributing)
- [说明](#notes)
- [支持](#support)
- [许可证](#license)

<a id="at-a-glance-quick-map"></a>
## 🧭 一览（快速地图）

| 使用场景 | 入口 | 输出 |
|---|---|---|
| 转换单张图像为 SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| 调整输出细节 | CLI 参数（[`用法`](#usage) 中的 `--mode`、`--canny`、`--epsilon` 等） | 更清晰或更丰富的轮廓 |
| 处理 PPTX 资源 | `scripts/` 辅助脚本 + 可选 conda 环境 | 提取的图像与渲染后的 slide PNG |

<a id="at-a-glance"></a>
## 🎯 一览

| 层级 | 说明 | 位置 |
|---|---|---|
| 核心 CLI | 通过单条命令将栅格图像转换为 SVG 路径 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 辅助 | 提取幻灯片内容并渲染页面，供后续向量化使用 | `scripts/` |
| 可选自动化 | 更大规模的 AI 辅助提取与重构流程 | `AutoAppDev/`, `scripts/` |

<a id="overview"></a>
## ✨ 简介

`aigi2vector` 包含：

- 一个核心的栅格转 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可选的 PPTX 辅助脚本，用于提取嵌入图像并将幻灯片渲染为 PNG
- `scripts/` 下的其他工作流脚本，用于版面提取、裁剪和 AI 辅助流程
- 一个 `AutoAppDev/` 子模块（外部工具；主 CLI 不依赖）

| 项目 | 说明 |
|---|---|
| 核心目标 | 将栅格图像输出为 SVG 路径 |
| 主要模式 | 单文件 Python CLI |
| 核心依赖 | `opencv-python`, `numpy` |
| 可选流程 | PPTX 提取/渲染、AI 辅助脚本流水线 |

<a id="features"></a>
## 🚀 功能

- 使用两种模式将栅格图像转换为 SVG 路径：
  - `edges`：基于 Canny 的边缘检测
  - `binary`：阈值提取形状
- 预处理参数：
  - 高斯模糊（`--blur`）
  - 可选反相（`--invert`）
- 使用 Douglas-Peucker 近似（`--epsilon`）简化路径
- SVG 输出通过 `width`、`height` 和 `viewBox` 保留输入像素尺寸
- PPTX 图像工具：
  - 按幻灯片提取嵌入图像
  - 将幻灯片页面渲染为 `page1.png`、`page2.png`、... 

<a id="project-structure"></a>
## 🗂️ 项目结构

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git 子模块（核心 CLI 可选）
├── i18n/                            # 翻译目录（目前为空）
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

<a id="prerequisites"></a>
## 📦 先决条件

### 核心 CLI

- Python 3
- `pip`
- 来自 [`requirements.txt`](requirements.txt) 的依赖：
  - `opencv-python`
  - `numpy`

### 可选 PPTX 辅助工具

- 对于 `scripts/extract_pptx_images.py`：
  - `python-pptx`
  - `Pillow`
- 对于 `scripts/render_pptx_slides.py`：
  - LibreOffice（`PATH` 中的 `soffice` 或 `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 可选辅助环境：
  - Conda（用于 `scripts/setup_conda_env.sh`）

### 可选高级流程

`scripts/` 下多个脚本依赖外部工具/服务（例如 `codex` CLI 与 GRS AI API）。这些属于可选项，不是运行 `aigi2vector.py` 的必要条件。

<a id="installation"></a>
## 🛠️ 安装

### 快速开始（现有标准流程）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX 工具的可选 Conda 环境

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

<a id="usage"></a>
## ▶️ 用法

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI 参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `--mode edges|binary` | `edges` | 向量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高阈值 |
| `--threshold N` | `128` | `binary` 模式使用的二值阈值 |
| `--invert` | off | 在轮廓检测前反转黑白 |
| `--blur K` | `3` | 高斯模糊核大小（奇数整数） |
| `--epsilon E` | `1.5` | 曲线简化；值越大点越少 |

### 模式工作原理

- `edges` 模式运行 Canny 边缘检测并追踪外部轮廓。
- `binary` 模式对灰度像素进行阈值化，并追踪生成掩码的外部轮廓。

<a id="visual-workflow"></a>
## 🔧 可视化工作流

```text
Input image/PPTX slide assets
   |
   v
`aigi2vector.py` (CLI) ---> `scripts/`（可选）
   |
   v
栅格追踪 + 轮廓简化
   |
   v
SVG 输出
```

<a id="configuration"></a>
## ⚙️ 配置

### 主 CLI 参数调优

- `--canny LOW HIGH`：
  - 值更低可保留更多细节和噪点。
  - 值更高可生成更干净但可能更稀疏的轮廓。
- `--threshold`（binary 模式）：
  - 较低阈值保留更多高亮区域作为前景。
  - 较高阈值更偏向保留暗色和高对比区域。
- `--blur`：
  - 内部会自动归一化为正奇数核。
  - 更大的值可在轮廓检测前平滑噪声。
- `--epsilon`：
  - 值越大，路径简化越激进（点更少）。
  - 值越小，形状细节保留越完整。

### 环境变量（高级脚本）

- `GRSAI` 为 GRS AI 提取脚本所需的变量（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

注意：高级脚本具有环境依赖性，并且在当前 README 中未完全文档化；以下命令保持与仓库实际行为一致，但不保证在所有机器上可直接复用。

<a id="examples"></a>
## 🧪 示例

### 栅格转 SVG

边缘模式（适合线稿）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

二值形状（适合 logo / 平面插画）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### 提取 PPTX 图像

如果你需要从 `.pptx` 提取嵌入图像（例如每张幻灯片一到两张），请使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

添加 `--dedupe` 以跳过跨幻灯片重复图像。添加 `--png` 可将文件保存为 `p{slide}image{index}.png`。

### 将幻灯片渲染为图像

要将每张幻灯片渲染为 `page1.png`、`page2.png` 等，你需要已安装 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（同样先使用 LibreOffice，再将 PDF 页面转为 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 可选高级工作流（脚本）

以下脚本可用于更大规模的拆解/重构流水线：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

注意：其中一些脚本当前仍含有机器特定绝对路径和外部服务依赖，请在生产环境使用前先调整。

<a id="development-notes"></a>
## 🧰 开发说明

- 核心实现是单文件 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 保持函数和变量名使用 `snake_case`，常量使用 `UPPER_SNAKE_CASE`
- 优先采用小而可测试的函数，而不是大而难维护的单块实现
- 当前没有正式测试套件
- `AIGI/` 目录被 Git 忽略，供本地资产使用

<a id="troubleshooting"></a>
## 🛟 故障排查

- `FileNotFoundError`（输入图像/PPTX）：
  - 检查输入路径是否正确且可读。
- `Could not read image`：
  - 确认文件格式受 OpenCV 支持且未损坏。
- SVG 输出为空或效果差：
  - 尝试在 `edges` 模式调节 `--canny`。
  - 在 `binary` 模式调节 `--threshold`。
  - 减小 `--epsilon` 以保留更多轮廓点。
  - 从更高对比度的源图像开始。
- `LibreOffice (soffice) not found in PATH`：
  - 安装 LibreOffice，并确保 `soffice` 或 `libreoffice` 在 shell 中可访问。
- 脚本链路缺少 Python 依赖：
  - 为对应脚本路径安装所需依赖（如 `python-pptx`、`Pillow`、`PyMuPDF` 等）。
- GRS AI 脚本出现认证错误：
  - 导出你的密钥，例如：`export GRSAI=...`。

<a id="roadmap"></a>
## 🗺️ 路线图

潜在的下一步改进：

- 在 `tests/` 下添加带确定性样例图像的自动化测试
- 发布统一的可选依赖分组用于脚本流程
- 提升高级 shell 流水线的可移植性（移除硬编码绝对路径）
- 在版本化样本资源中补充参考输入/输出示例
- 完善 `i18n/` 下持续维护的翻译 README

<a id="contributing"></a>
## 🤝 参与贡献

欢迎投稿。

建议流程：

1. 从当前主线分支 `fork` 或建分支。
2. 保持改动聚焦，并使用简短、命令式提交信息。
3. 运行你修改过的相关命令（CLI/脚本路径）并验证输出。
4. 当行为变化时更新 README 使用说明。

如果你新增测试，请放在 `tests/` 下并命名为 `test_*.py`。

<a id="notes"></a>
## 📝 说明

- 输出 SVG 会保留输入图像的像素尺寸；如有需要可在矢量编辑器中缩放。
- 为获得更好效果，建议从高对比度图像开始。

<a id="support"></a>
## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
