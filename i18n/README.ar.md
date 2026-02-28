[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

حوّل الصور النقطية المُنشأة بالذكاء الاصطناعي إلى ملفات SVG متجهية نظيفة ومناسبة للرسم.

يوفّر هذا المستودع أداة سطر أوامر بلغة Python تكتشف الحواف أو الأشكال الثنائية داخل الصورة ثم تكتبها كمسارات SVG. صُمِّمت الأداة لسيناريوهات التحويل إلى متجهات بأسلوب مبسّط ومناسب لأجهزة الرسم (plotter)، وليس للتتبّع الفوتوغرافي الواقعي.

## ✨ نظرة عامة

يتضمن `aigi2vector` ما يلي:

- أداة CLI أساسية للتحويل من raster إلى SVG: [`aigi2vector.py`](../aigi2vector.py)
- أدوات PPTX اختيارية لاستخراج الصور المضمّنة وتحويل الشرائح إلى PNG
- سكربتات سير عمل إضافية تحت `scripts/` لاستخراج التخطيط والقصّ وخطوط الأنابيب المدعومة بالذكاء الاصطناعي
- وحدة فرعية `AutoAppDev/` (أدوات خارجية؛ غير مطلوبة لتشغيل الـ CLI الأساسي)

| العنصر | التفاصيل |
|---|---|
| الهدف الأساسي | تحويل الصور النقطية إلى مخرجات SVG مبنية على المسارات |
| النمط الأساسي | أداة Python أحادية الملف عبر سطر الأوامر |
| الاعتماديات الأساسية | `opencv-python`, `numpy` |
| مسارات عمل اختيارية | استخراج/عرض PPTX، وخطوط أنابيب سكربتات بمساعدة الذكاء الاصطناعي |

## 🚀 الميزات

- تحويل الصور النقطية إلى مسارات SVG عبر نمطين:
  - `edges`: كشف الحواف المعتمد على Canny
  - `binary`: استخراج الأشكال بعد تطبيق threshold
- عناصر تحكم في المعالجة المسبقة:
  - Gaussian blur (`--blur`)
  - عكس اختياري (`--invert`)
- تبسيط المسارات باستخدام تقريب Douglas-Peucker (`--epsilon`)
- مخرجات SVG تحافظ على أبعاد بكسلات الإدخال عبر `width` و`height` و`viewBox`
- أدوات صور PPTX:
  - استخراج الصور المضمّنة حسب الشريحة
  - تصدير صفحات الشرائح إلى `page1.png`, `page2.png`, ...

## 🗂️ هيكل المشروع

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

## 📦 المتطلبات المسبقة

### Core CLI

- Python 3
- `pip`
- الاعتماديات من [`requirements.txt`](../requirements.txt):
  - `opencv-python`
  - `numpy`

### أدوات PPTX الاختيارية

- بالنسبة إلى `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- بالنسبة إلى `scripts/render_pptx_slides.py`:
  - LibreOffice (وجود `soffice` أو `libreoffice` ضمن `PATH`)
  - `PyMuPDF` (`fitz`)
- إعداد مساعد اختياري:
  - Conda (من أجل `scripts/setup_conda_env.sh`)

### خطوط أنابيب متقدمة اختيارية

تعتمد عدة سكربتات داخل `scripts/` على أدوات/خدمات خارجية (مثل `codex` CLI وواجهات GRS AI). هذه اختيارية وليست مطلوبة لتشغيل `aigi2vector.py`.

## 🛠️ التثبيت

### Quick Start (existing canonical flow)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### إعداد Conda اختياري لأدوات PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ الاستخدام

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### خيارات CLI

| الخيار | الافتراضي | الوصف |
|---|---|---|
| `--mode edges|binary` | `edges` | نمط التحويل إلى متجهات |
| `--canny LOW HIGH` | `100 200` | حدّا Canny المنخفض/العالي في نمط الحواف |
| `--threshold N` | `128` | قيمة العتبة الثنائية المستخدمة في نمط `binary` |
| `--invert` | off | عكس الأسود/الأبيض قبل كشف الـ contour |
| `--blur K` | `3` | حجم نواة Gaussian blur (عدد فردي) |
| `--epsilon E` | `1.5` | تبسيط المنحنى؛ قيمة أكبر = نقاط أقل |

### آلية عمل الأنماط

- نمط `edges` يشغّل كشف حواف Canny ثم يتتبع الـ external contours.
- نمط `binary` يطبّق threshold على الصورة الرمادية ثم يتتبع الـ external contours للقناع الناتج.

## ⚙️ الإعداد

### ضبط معاملات CLI الأساسية

- `--canny LOW HIGH`:
  - القيم الأقل تلتقط تفاصيل/ضجيجًا أكثر.
  - القيم الأعلى تنتج contours أنظف لكن قد تكون أقل كثافة.
- `--threshold` (نمط binary):
  - العتبة الأقل تُبقي مناطق فاتحة أكثر كمقدمة (foreground).
  - العتبة الأعلى تُبقي غالبًا المناطق الداكنة/عالية التباين.
- `--blur`:
  - يُطبَّع تلقائيًا داخليًا إلى نواة موجبة وفردية.
  - القيم الأكبر تُنعّم الضجيج قبل كشف الـ contour.
- `--epsilon`:
  - القيم الأكبر تبسّط المسارات بشكل أكثر شدة (نقاط أقل).
  - القيم الأصغر تحافظ على تفاصيل الشكل.

### متغيرات البيئة (للسكربتات المتقدمة)

- المتغير `GRSAI` مطلوب لسكربتات استخراج GRS AI (مثل `extract_part_grsai.py` و`extract_elements_grsai_pipeline.py` و`extract_elements_from_prompt_json.py`).

ملاحظة افتراضية: السكربتات المتقدمة مرتبطة بالبيئة ومُوثّقة جزئيًا فقط في خط الأساس الحالي لـ README؛ الأوامر أدناه تحافظ على سلوك مطابق للمستودع دون ضمان قابلية النقل على جميع الأجهزة.

## 🧪 أمثلة

### تحويل Raster إلى SVG

حواف (مناسب للرسوم الخطية):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

أشكال ثنائية (مناسب للشعارات/الرسوم المسطحة):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### استخراج صور PPTX

إذا احتجت إلى استخراج الصور المضمّنة من ملف `.pptx` (مثل صورة أو صورتين لكل شريحة)، استخدم:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

أضف `--dedupe` لتجاوز الصور المكررة بين الشرائح. وأضف `--png` لحفظ الملفات بصيغة `p{slide}image{index}.png`.

### تحويل الشرائح إلى صور

لتحويل كل شريحة إلى `page1.png`, `page2.png`, ... تحتاج إلى تثبيت LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

أو استخدم العارض المكتوب بـ Python (يستخدم LibreOffice أيضًا، ثم يحوّل صفحات PDF إلى PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### مسارات عمل متقدمة اختيارية (scripts)

هذه السكربتات موجودة داخل المستودع ويمكن استخدامها لخطوط أنابيب أكبر للتفكيك/إعادة البناء:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

مهم: بعض هذه السكربتات يحتوي حاليًا على مسارات مطلقة خاصة بأجهزة معينة واعتماديات على خدمات خارجية؛ عدّلها قبل الاستخدام الإنتاجي.

## 🧰 ملاحظات التطوير

- التنفيذ الأساسي عبارة عن CLI أحادي الملف في Python: [`aigi2vector.py`](../aigi2vector.py)
- استخدم `snake_case` لأسماء الدوال والمتغيرات، و`UPPER_SNAKE_CASE` للثوابت
- فضّل الدوال الصغيرة القابلة للاختبار بدل الكتل الضخمة
- لا توجد حاليًا حزمة اختبارات رسمية
- المجلد `AIGI/` متجاهَل في git ومخصص للأصول المحلية

## 🛟 استكشاف الأخطاء وإصلاحها

- خطأ `FileNotFoundError` لملف صورة/PPTX:
  - تحقق من صحة مسار الإدخال وإمكانية قراءته.
- خطأ `Could not read image`:
  - تأكد أن الصيغة مدعومة من OpenCV وأن الملف غير تالف.
- مخرجات SVG فارغة أو ضعيفة:
  - جرّب `--mode binary` مع ضبط `--threshold`.
  - عدّل حدود `--canny` في نمط `edges`.
  - قلّل `--epsilon` للحفاظ على نقاط contour أكثر.
  - ابدأ من صورة مصدر أعلى تباينًا.
- `LibreOffice (soffice) not found in PATH`:
  - ثبّت LibreOffice وتأكد أن `soffice` أو `libreoffice` متاح في الصدفة.
- حزم Python مفقودة لمسارات سكربتات معينة:
  - ثبّت الاعتماديات المطلوبة لذلك المسار (`python-pptx`, `Pillow`, `PyMuPDF`, إلخ).
- فشل سكربتات GRS AI بسبب أخطاء مصادقة:
  - صدّر المفتاح مثلًا: `export GRSAI=...`.

## 🗺️ خارطة الطريق

تحسينات محتملة لاحقًا:

- إضافة اختبارات آلية تحت `tests/` باستخدام صور عينات حتمية
- نشر مجموعات اعتماديات اختيارية موحّدة لمسارات السكربتات
- تحسين قابلية نقل خطوط أنابيب shell المتقدمة (إزالة المسارات المطلقة المضمّنة)
- إضافة أمثلة مرجعية للمدخلات/المخرجات تحت أصول عينات مُدارة بالإصدارات
- تعبئة `i18n/` بنسخ README مترجمة ومُصانة

## 🤝 المساهمة

المساهمات مرحّب بها.

العملية المقترحة:

1. اعمل fork أو فرعًا من الخط الرئيسي الحالي.
2. اجعل التعديلات مركّزة واستخدم رسائل commit قصيرة بصيغة الأمر.
3. شغّل الأوامر ذات الصلة التي غيّرتها (مسار CLI/السكربت) وتحقق من المخرجات.
4. حدّث ملاحظات الاستخدام في README عند تغيّر السلوك.

إذا أضفت اختبارات، ضعها تحت `tests/` واسمِ الملفات بصيغة `test_*.py`.

## 📝 ملاحظات

- ملف SVG الناتج يستخدم أبعاد البكسل لملف الإدخال. غيّر المقياس في محرر المتجهات إذا لزم.
- للحصول على أفضل نتائج، ابدأ بصورة عالية التباين.

## License

MIT
