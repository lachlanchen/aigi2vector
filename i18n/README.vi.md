[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![Workflow](https://img.shields.io/badge/Workflow-CLI%20%2B%20Scripts-7F3CD9.svg)](#-table-of-contents)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Chuyển đổi hình ảnh raster tạo bởi AI thành SVG vector sạch, phù hợp để vẽ bằng plotter.

Kho này cung cấp một CLI Python phát hiện biên hoặc hình dạng nhị phân trong ảnh rồi ghi ra các đường path SVG. Nó được thiết kế cho mục đích vector hóa theo phong cách minh họa, thân thiện với máy plotter hơn là truy vết theo kiểu ảnh thật.

## 🧰 At a Glance (Quick Matrix)

| Khu vực | Vị trí | Mục đích |
|---|---|---|
| Chuyển đổi lõi | [`aigi2vector.py`](aigi2vector.py) | Chuyển ảnh raster/ảnh trích xuất từ PPTX sang SVG |
| Công cụ PPTX tùy chọn | `scripts/` | Trích xuất và render tài sản slide |
| Tự động hóa mở rộng | `AutoAppDev/` | Ngăn xếp tự động hóa bên ngoài, tùy chọn |

---

## 📚 Table of Contents

- [At a Glance (Quick Matrix)](#-at-a-glance-quick-matrix)
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

| Trường hợp dùng | Điểm vào | Kết quả |
|---|---|---|
| Chuyển một ảnh sang SVG | `python aigi2vector.py input.png output.svg` | `output.svg` |
| Tinh chỉnh chi tiết đầu ra | Tham số CLI trong [`Usage`](#-usage) (`--mode`, `--canny`, `--epsilon`, v.v.) | Đường viền sạch hơn hoặc dày hơn |
| Xử lý tài nguyên PPTX | Bộ hỗ trợ `scripts/` + môi trường conda tùy chọn | Ảnh đã trích xuất + file PNG slide đã render |

## 🎯 At a Glance

| Lớp | Mô tả | Vị trí |
|---|---|---|
| CLI lõi | Chuyển ảnh raster thành đường SVG chỉ bằng một lệnh | [`aigi2vector.py`](aigi2vector.py) |
| Công cụ PPTX | Trích xuất nội dung slide và render trang để vector hóa tiếp theo | `scripts/` |
| Tự động hóa tùy chọn | Luồng làm việc lớn hơn cho trích xuất, tái cấu trúc có hỗ trợ AI | `AutoAppDev/`, `scripts/` |

## ✨ Overview

`aigi2vector` gồm:

- Một CLI raster-to-SVG lõi: [`aigi2vector.py`](aigi2vector.py)
- Công cụ PPTX tùy chọn để trích xuất hình ảnh nhúng và render slide sang PNG
- Các script luồng công việc bổ sung trong `scripts/` cho trích xuất layout, cắt ảnh và pipeline hỗ trợ AI
- Một submodule `AutoAppDev/` (công cụ bên ngoài; không cần cho CLI chính)

| Mục | Chi tiết |
|---|---|
| Mục đích chính | Chuyển ảnh raster thành đầu ra đường path SVG |
| Chế độ chính | CLI Python một tệp |
| Phụ thuộc lõi | `opencv-python`, `numpy` |
| Workflow tùy chọn | Trích xuất/render PPTX, pipeline script AI-assited |

## 🚀 Features

- Chuyển ảnh raster sang path SVG qua hai chế độ:
  - `edges`: phát hiện biên dựa trên Canny
  - `binary`: trích xuất hình dạng theo ngưỡng
- Điều khiển tiền xử lý:
  - Làm mờ Gaussian (`--blur`)
  - Đảo ngược tùy chọn (`--invert`)
- Rút gọn đường theo xấp xỉ Douglas-Peucker (`--epsilon`)
- Đầu ra SVG giữ kích thước pixel đầu vào nhờ `width`, `height` và `viewBox`
- Tiện ích hình ảnh PPTX:
  - Trích xuất ảnh nhúng theo slide
  - Render trang slide thành `page1.png`, `page2.png`, ...

## 🗂️ Project Structure

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (optional for core CLI)
├── i18n/                            # Thư mục dịch (hiện tại scaffold/empty)
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
- Phụ thuộc từ [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Optional PPTX Helpers

- Đối với `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- Đối với `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` hoặc `libreoffice` trong `PATH`)
  - `PyMuPDF` (`fitz`)
- Thiết lập bổ sung tùy chọn:
  - Conda (cho `scripts/setup_conda_env.sh`)

### Optional Advanced Pipelines

Một số script trong `scripts/` phụ thuộc vào công cụ/dịch vụ bên ngoài (ví dụ `codex` CLI và GRS AI API). Các phần này không bắt buộc và không cần thiết để chạy `aigi2vector.py`.

## 🛠️ Installation

### Quick Start (luồng chuẩn hiện tại)

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

| Tùy chọn | Mặc định | Mô tả |
|---|---|---|
| `--mode edges|binary` | `edges` | Chế độ vector hóa |
| `--canny LOW HIGH` | `100 200` | Ngưỡng thấp/cao cho chế độ edges |
| `--threshold N` | `128` | Ngưỡng nhị phân dùng trong `binary` |
| `--invert` | off | Đảo trắng đen trước khi dò contour |
| `--blur K` | `3` | Kích thước kernel Gaussian (số nguyên lẻ) |
| `--epsilon E` | `1.5` | Đơn giản hóa đường cong; lớn hơn = ít điểm hơn |

### How Modes Work

- Chế độ `edges` chạy phát hiện biên Canny và truy vết các contour bên ngoài.
- Chế độ `binary` ngưỡng hóa ảnh xám rồi truy vết contour bên ngoài của mask kết quả.

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
  - Giá trị thấp giữ nhiều chi tiết/nhiễu hơn.
  - Giá trị cao cho ra đường viền sạch hơn nhưng có thể thưa hơn.
- `--threshold` (binary mode):
  - Ngưỡng thấp giữ thêm vùng sáng thành tiền cảnh.
  - Ngưỡng cao giữ chủ yếu vùng tối/độ tương phản cao.
- `--blur`:
  - Tự động chuẩn hóa thành kernel lẻ dương phía trong.
  - Giá trị lớn hơn làm mượt nhiễu trước khi dò contour.
- `--epsilon`:
  - Giá trị lớn rút gọn path mạnh hơn (ít điểm hơn).
  - Giá trị nhỏ giữ lại chi tiết hình dạng tốt hơn.

### Environment variables (advanced scripts)

- `GRSAI` là biến bắt buộc cho các script trích xuất GRS AI (ví dụ `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Lưu ý giả định: các script nâng cao phụ thuộc môi trường và tài liệu hiện tại chỉ ghi một phần; các lệnh dưới đây giữ đúng hành vi repository nhưng chưa đảm bảo khả năng dùng trên mọi máy.

## 🧪 Examples

### Raster to SVG

Edges (phù hợp cho line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes (phù hợp cho logo / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

Nếu bạn cần trích xuất ảnh nhúng từ một file `.pptx` (ví dụ một hoặc hai ảnh mỗi slide), dùng:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Thêm `--dedupe` để bỏ qua ảnh trùng lặp giữa các slide. Thêm `--png` để lưu file dưới dạng `p{slide}image{index}.png`.

### Render slides to images

Để render mỗi slide thành `page1.png`, `page2.png`, ... bạn cần cài LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Hoặc dùng renderer Python (cũng dùng LibreOffice rồi chuyển PDF sang PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optional advanced workflows (scripts)

Các script này có sẵn trong repo và có thể dùng cho pipelines tách/rà soát lớn hơn:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Quan trọng: một số script hiện có chứa đường dẫn tuyệt đối theo máy và phụ thuộc dịch vụ bên ngoài; hãy điều chỉnh trước khi dùng trong môi trường production.

## 🛠️ Development Notes

- Cách triển khai chính là một CLI Python một tệp: [`aigi2vector.py`](aigi2vector.py)
- Giữ tên hàm/biến dạng `snake_case`, hằng số dạng `UPPER_SNAKE_CASE`
- Ưu tiên hàm nhỏ, dễ test hơn các khối khổng lồ
- Hiện chưa có bộ test chính thức
- `AIGI/` bị bỏ qua trong git và dùng cho asset cục bộ

## 🛟 Troubleshooting

- `FileNotFoundError` với ảnh đầu vào/PPTX:
  - Kiểm tra đường dẫn đầu vào có đúng và có thể đọc.
- `Could not read image`:
  - Kiểm tra định dạng tệp được OpenCV hỗ trợ và file không bị hỏng.
- SVG đầu ra trống hoặc kém:
  - Thử `--mode binary` với `--threshold` đã tinh chỉnh.
  - Điều chỉnh ngưỡng `--canny` ở chế độ `edges`.
  - Giảm `--epsilon` để giữ nhiều điểm contour hơn.
  - Bắt đầu từ ảnh nguồn có độ tương phản cao.
- `LibreOffice (soffice) not found in PATH`:
  - Cài LibreOffice và đảm bảo `soffice` hoặc `libreoffice` có trong `PATH` shell.
- Thiếu gói Python cho luồng script:
  - Cài đủ dependency cho luồng script đó (`python-pptx`, `Pillow`, `PyMuPDF`, v.v.).
- Script GRS AI lỗi xác thực:
  - Xuất khóa của bạn, ví dụ: `export GRSAI=...`.

## 🗺️ Roadmap

Các hướng cải tiến tiềm năng:

- Thêm test tự động trong `tests/` với ảnh mẫu xác định
- Công bố dependency nhóm thống nhất cho các workflow script
- Tăng tính di động của các pipeline shell nâng cao (loại bỏ đường dẫn tuyệt đối hard-code)
- Thêm ví dụ input/output tham chiếu dưới assets mẫu versioned
- Bổ sung và duy trì các README dịch trong `i18n/`

## 🤝 Contributing

Đóng góp luôn được hoan nghênh.

Quy trình gợi ý:

1. Fork hoặc tạo nhánh từ mainline hiện tại.
2. Giữ thay đổi tập trung và dùng commit message ngắn, dạng mệnh lệnh.
3. Chạy các lệnh liên quan tới phần bạn thay đổi (đường dẫn CLI/script) và xác nhận đầu ra.
4. Cập nhật phần ghi chú sử dụng trong README khi hành vi thay đổi.

Nếu bạn thêm test, đặt vào `tests/` và đặt tên `test_*.py`.

## 📝 Notes

- SVG đầu ra dùng kích thước pixel đầu vào. Scale trong phần mềm vector nếu cần.
- Để có kết quả tốt nhất, nên bắt đầu từ ảnh có độ tương phản cao.

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
