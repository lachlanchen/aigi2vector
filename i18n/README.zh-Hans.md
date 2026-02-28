[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

将 AI 生成的栅格图像转换为清晰、适合绘图设备的矢量 SVG。

本仓库提供一个 Python CLI，可检测图像中的边缘或二值形状，并将其写入 SVG 路径。它更偏向于风格化、适用于绘图仪的矢量化，而非照片级追踪。

## 🎯 概览

| 层级 | 描述 | 位置 |
|---|---|---|
| 核心 CLI | 一条命令将栅格图像转换为 SVG 路径 | [`aigi2vector.py`](aigi2vector.py) |
| PPTX 辅助脚本 | 提取幻灯片内容并将页面渲染以供后续矢量化 | `scripts/` |
| 可选自动化 | 更大规模的 AI 辅助提取与组合工作流 | `AutoAppDev/`, `scripts/` |

## ✨ 概览

`aigi2vector` 包含：

- 一个核心栅格转 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可选的 PPTX 辅助脚本，用于提取嵌入图片并将幻灯片渲染为 PNG
- 附加的 `scripts/` 工作流脚本，用于版面提取、裁剪与 AI 辅助流水线
- 一个 `AutoAppDev/` 子模块（外部工具，主 CLI 不依赖）

| 项目 | 说明 |
|---|---|
| 核心目的 | 将栅格图像转换为 SVG 路径输出 |
| 主要模式 | 单文件 Python CLI |
| 核心依赖 | `opencv-python`, `numpy` |
| 可选工作流 | PPTX 提取/渲染、AI 辅助脚本流水线 |

## 🚀 特性

- 使用两种模式将栅格图像转换为 SVG 路径：
  - `edges`：基于 Canny 的边缘检测
  - `binary`：基于阈值的形状提取
- 预处理控制：
  - 高斯模糊（`--blur`）
  - 可选反色（`--invert`）
- 使用 Douglas-Peucker 近似进行路径简化（`--epsilon`）
- SVG 输出通过 `width`、`height` 和 `viewBox` 保留输入像素尺寸
- PPTX 图片工具：
  - 按幻灯片提取嵌入图片
  - 将幻灯片页渲染为 `page1.png`、`page2.png` 等

## 🗂️ 项目结构

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git 子模块（核心 CLI 可选）
├── i18n/                            # 翻译目录（当前骨架/空）
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

## 📦 前置条件

### 核心 CLI

- Python 3
- `pip`
- 来自 [`requirements.txt`](requirements.txt) 的依赖：
  - `opencv-python`
  - `numpy`

### 可选 PPTX 辅助

- 对于 `scripts/extract_pptx_images.py`：
  - `python-pptx`
  - `Pillow`
- 对于 `scripts/render_pptx_slides.py`：
  - LibreOffice（`PATH` 中可用 `soffice` 或 `libreoffice`）
  - `PyMuPDF`（`fitz`）
- 可选辅助环境：
  - Conda（用于 `scripts/setup_conda_env.sh`）

### 可选高级流水线

`scripts/` 中的一些脚本依赖外部工具/服务（例如 `codex` CLI 与 GRS AI API）。这些为可选项，运行 `aigi2vector.py` 不要求使用它们。

## 🛠️ 安装

### 快速开始（当前规范流程）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### PPTX 工具的可选 Conda 配置

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ 用法

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI 参数

| 参数 | 默认值 | 说明 |
|---|---|---|
| `--mode edges|binary` | `edges` | 矢量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高阈值 |
| `--threshold N` | `128` | `binary` 模式使用的二值阈值 |
| `--invert` | off | 在轮廓检测前反转黑白 |
| `--blur K` | `3` | 高斯模糊核大小（奇数） |
| `--epsilon E` | `1.5` | 曲线简化；值越大点越少 |

### 模式说明

- `edges` 模式执行 Canny 边缘检测并追踪外轮廓。
- `binary` 模式将灰度像素阈值化，并追踪生成掩码的外轮廓。

## ⚙️ 配置

### 主 CLI 参数调优

- `--canny LOW HIGH`：
  - 较低值会保留更多细节/噪点。
  - 较高值会生成更干净但可能更稀疏的轮廓。
- `--threshold`（binary 模式）：
  - 较低阈值保留更多亮区作为前景。
  - 较高阈值主要保留较暗且高对比度的区域。
- `--blur`：
  - 内部会自动归一化为正奇数核。
  - 更大的值可在轮廓检测前平滑噪声。
- `--epsilon`：
  - 更大值会更激进地简化路径（点数更少）。
  - 更小值保留更多形状细节。

### 环境变量（高级脚本）

- `GRSAI` 是 GRS AI 提取脚本的必需参数（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

注意：高级脚本依赖于特定环境，而且当前 README 基线中部分内容未完整记录；下列命令保持与仓库现状一致，但不保证在所有机器上都具备可移植性。

## 🧪 示例

### 栅格转 SVG

Edges（适合线稿）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary 形状（适合 logo/平面插画）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 图片提取

如果你需要从 `.pptx` 提取嵌入图片（例如每页一到两张），可使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

添加 `--dedupe` 可跳过跨幻灯片重复图片。添加 `--png` 可将文件保存为 `p{slide}image{index}.png`。

### 将幻灯片渲染为图片

若需将每页幻灯片渲染为 `page1.png`、`page2.png`，你需要安装 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（也会用到 LibreOffice，随后将 PDF 页面转换为 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 可选高级工作流（脚本）

这些脚本在仓库内可用于更大规模的拆分/重建流水线：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要：其中部分脚本当前包含机器特定的绝对路径和外部服务依赖；上线前请根据你的环境进行适配。

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 🧰 开发说明

- 主要实现是单文件 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 保持函数/变量命名为 `snake_case`，常量使用 `UPPER_SNAKE_CASE`
- 优先采用小而可测试的函数，而非单体大块实现
- 当前尚无正式测试套件
- `AIGI/` 被 git 忽略，用作本地资源

## 🛟 故障排查

- 输入图片/PPTX 报 `FileNotFoundError`：
  - 检查输入路径是否正确且可读。
- 报 `Could not read image`：
  - 确认文件格式受 OpenCV 支持，且文件未损坏。
- SVG 输出为空或效果不佳：
  - 尝试在 `--mode binary` 下调整 `--threshold`。
  - 在 `edges` 模式下微调 `--canny` 阈值。
  - 降低 `--epsilon` 以保留更多轮廓点。
  - 从更高对比度的源图开始。
- 报 `LibreOffice (soffice) not found in PATH`：
  - 安装 LibreOffice，并确保 shell 能发现 `soffice` 或 `libreoffice`。
- 脚本流程缺少 Python 依赖：
  - 安装该脚本路径所需依赖（如 `python-pptx`、`Pillow`、`PyMuPDF`）。
- GRS AI 脚本鉴权失败：
  - 导出你的密钥，例如：`export GRSAI=...`。

## 🗺️ 路线图

可能的下一步改进：

- 在 `tests/` 下加入自动化测试，并使用可复现的小样本图像
- 为脚本工作流发布统一的可选依赖分组
- 提升高级 shell 流水线的可移植性（移除硬编码绝对路径）
- 添加版本化样例资源中的输入/输出参考示例
- 完善并维护 `i18n/` 下的多语言 README 版本

## 🤝 贡献

欢迎参与贡献。

建议流程：

1. 从当前主分支 fork 或新建分支。
2. 保持改动聚焦，并使用简短的祈使式提交信息。
