[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

将 AI 生成的栅格图像转换为干净、适合绘图设备的矢量 SVG。

本仓库提供一个 Python CLI，可检测图像中的边缘或二值形状，并将其写为 SVG 路径。它面向风格化、绘图仪友好的矢量化场景，而非照片级临摹。

## ✨ 概览

`aigi2vector` 包含：

- 核心栅格转 SVG CLI：[`aigi2vector.py`](aigi2vector.py)
- 可选的 PPTX 辅助工具，用于提取嵌入图片并将幻灯片渲染为 PNG
- `scripts/` 下用于版面提取、裁剪和 AI 辅助流水线的附加脚本
- `AutoAppDev/` 子模块（外部工具；运行主 CLI 并非必需）

| 项目 | 说明 |
|---|---|
| 核心用途 | 将栅格图像转换为 SVG 路径输出 |
| 主要模式 | 单文件 Python CLI |
| 核心依赖 | `opencv-python`, `numpy` |
| 可选工作流 | PPTX 提取/渲染、AI 辅助脚本流水线 |

## 🚀 功能

- 使用两种模式将栅格图像转换为 SVG 路径：
  - `edges`：基于 Canny 的边缘检测
  - `binary`：基于阈值的形状提取
- 预处理控制：
  - 高斯模糊（`--blur`）
  - 可选反相（`--invert`）
- 使用 Douglas-Peucker 近似进行路径简化（`--epsilon`）
- SVG 输出通过 `width`、`height` 和 `viewBox` 保留输入像素尺寸
- PPTX 图片工具：
  - 按幻灯片提取嵌入图片
  - 将幻灯片页面渲染为 `page1.png`、`page2.png`、...

## 🗂️ 项目结构

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

## 📦 前置要求

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
  - LibreOffice（`PATH` 中可找到 `soffice` 或 `libreoffice`）
  - `PyMuPDF` (`fitz`)
- 可选辅助环境：
  - Conda（用于 `scripts/setup_conda_env.sh`）

### 可选高级流水线

`scripts/` 下的若干脚本依赖外部工具/服务（例如 `codex` CLI 和 GRS AI API）。这些都是可选项，运行 `aigi2vector.py` 并不需要它们。

## 🛠️ 安装

### 快速开始（当前规范流程）

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### 用于 PPTX 工具的可选 Conda 配置

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ 用法

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI 选项

| 选项 | 默认值 | 说明 |
|---|---|---|
| `--mode edges|binary` | `edges` | 矢量化模式 |
| `--canny LOW HIGH` | `100 200` | `edges` 模式的低/高阈值 |
| `--threshold N` | `128` | `binary` 模式中使用的二值阈值 |
| `--invert` | off | 轮廓检测前反转黑白 |
| `--blur K` | `3` | 高斯模糊核大小（奇数） |
| `--epsilon E` | `1.5` | 曲线简化；值越大点越少 |

### 模式工作原理

- `edges` 模式运行 Canny 边缘检测，并跟踪外轮廓。
- `binary` 模式先对灰度像素做阈值化，再跟踪结果掩码的外轮廓。

## ⚙️ 配置

### 主 CLI 参数调优

- `--canny LOW HIGH`：
  - 较低数值会捕获更多细节/噪声。
  - 较高数值会得到更干净但可能更稀疏的轮廓。
- `--threshold`（binary 模式）：
  - 较低阈值会保留更多亮区域作为前景。
  - 较高阈值会主要保留较暗/高对比区域。
- `--blur`：
  - 内部会自动归一化为正奇数核。
  - 数值更大可在轮廓检测前平滑噪声。
- `--epsilon`：
  - 数值更大时路径简化更激进（点更少）。
  - 数值更小时可保留更多形状细节。

### 环境变量（高级脚本）

- GRS AI 提取脚本需要 `GRSAI`（例如 `extract_part_grsai.py`、`extract_elements_grsai_pipeline.py`、`extract_elements_from_prompt_json.py`）。

假设说明：高级脚本依赖具体环境，且在当前 README 基线中部分文档不完整；以下命令保持与仓库实际行为一致，但不保证在所有机器上可直接移植运行。

## 🧪 示例

### 栅格转 SVG

Edges（适合线稿）：

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes（适合 logo / 扁平图形）：

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX 图片提取

如果你需要从 `.pptx` 中提取嵌入图片（例如每页一到两张图），可使用：

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

添加 `--dedupe` 可跳过跨幻灯片重复图片。添加 `--png` 可将文件保存为 `p{slide}image{index}.png`。

### 将幻灯片渲染为图片

要将每页幻灯片渲染为 `page1.png`、`page2.png`、...，需要先安装 LibreOffice（`soffice`）：

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

或使用 Python 渲染器（同样依赖 LibreOffice，然后将 PDF 页面转为 PNG）：

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### 可选高级工作流（脚本）

这些脚本位于仓库中，可用于更大规模的拆解/重建流水线：

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

重要：其中部分脚本目前包含机器相关的绝对路径以及外部服务依赖；投入生产前请先按你的环境进行适配。

## 🧰 开发说明

- 主要实现是单文件 Python CLI：[`aigi2vector.py`](aigi2vector.py)
- 函数/变量命名保持 `snake_case`，常量使用 `UPPER_SNAKE_CASE`
- 优先编写小而可测试的函数，而非大型单体代码块
- 当前尚无正式测试套件
- `AIGI/` 被 git 忽略，用于本地资源

## 🛟 故障排查

- 输入图片/PPTX 报 `FileNotFoundError`：
  - 检查输入路径是否正确且可读。
- 报 `Could not read image`：
  - 确认文件格式受 OpenCV 支持且未损坏。
- SVG 输出为空或效果不佳：
  - 尝试 `--mode binary` 并调优 `--threshold`。
  - 在 `edges` 模式下调整 `--canny` 阈值。
  - 降低 `--epsilon` 以保留更多轮廓点。
  - 使用更高对比度的源图像。
- `PATH` 中找不到 `LibreOffice (soffice)`：
  - 安装 LibreOffice，并确保 shell 能发现 `soffice` 或 `libreoffice`。
- 脚本工作流缺少 Python 包：
  - 安装该脚本路径所需依赖（`python-pptx`、`Pillow`、`PyMuPDF` 等）。
- GRS AI 脚本因鉴权报错：
  - 导出你的密钥，例如：`export GRSAI=...`。

## 🗺️ 路线图

下一步的潜在改进：

- 在 `tests/` 下加入自动化测试，并使用可复现的小样例图像
- 为脚本工作流发布统一的可选依赖分组
- 提升高级 shell 流水线的可移植性（移除硬编码绝对路径）
- 在版本化样例资源中添加参考输入/输出示例
- 补齐并维护 `i18n/` 下的多语言 README 版本

## 🤝 贡献

欢迎贡献。

建议流程：

1. 从当前主线 fork 或新建分支。
2. 保持改动聚焦，并使用简短的祈使句提交信息。
3. 运行你改动涉及的命令（CLI/脚本路径）并验证输出。
4. 当行为变化时，同步更新 README 用法说明。

如果你添加测试，请放在 `tests/` 下，并命名为 `test_*.py`。

## 📝 备注

- 输出 SVG 使用输入图像的像素尺寸。如有需要，请在矢量编辑器中缩放。
- 为获得最佳效果，请从高对比度图像开始。

## License

MIT
