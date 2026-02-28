[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

حوّل صور الـ AI النقطية إلى ملفات SVG متجهة نظيفة وجاهزة للرسم.

يوفر هذا المستودع واجهة سطر أوامر Python تكشف الحواف أو الأشكال الثنائية في الصورة وتكتبها كمسارات SVG. صُمِّم هذا المشروع ليكون مناسبًا لتقنية التتبع الأسلوبي (plotter-friendly) أكثر من تتبّع فوتورياليستي دقيق.

## 🎯 لمحة سريعة

| الطبقة | الوصف | الموقع |
|---|---|---|
| واجهة CLI الأساسية | تحويل الصور النقطية إلى مسارات SVG عبر أمر واحد | [`aigi2vector.py`](aigi2vector.py) |
| أدوات PPTX | استخراج محتوى الشرائح وتحويل الصفحات لمرسومات تالية لـ vectorization | `scripts/` |
| الأتمتة الاختيارية | سير عمل أكبر قائم على الذكاء الاصطناعي، الاستخراج والتجميع | `AutoAppDev/`, `scripts/` |

## ✨ نظرة عامة

`aigi2vector` يتضمن:

- واجهة CLI أساسية لتحويل raster إلى SVG: [`aigi2vector.py`](aigi2vector.py)
- أدوات PPTX اختيارية لاستخراج الصور المضمنة وعرض الشرائح إلى PNG
- سكربتات سير عمل إضافية داخل `scripts/` لاستخراج التنسيق، الاقتصاص، وسيرات عمل بمساعدة AI
- وحدة فرعية `AutoAppDev/` (أدوات خارجية؛ غير مطلوبة لواجهة CLI الأساسية)

| العنصر | التفاصيل |
|---|---|
| الهدف الأساسي | تحويل الصور النقطية إلى مخرجات مسارات SVG |
| الوضع الأساسي | واجهة CLI واحدة بملف Python واحد |
| الاعتماديات الأساسية | `opencv-python`, `numpy` |
| سيرات العمل الاختيارية | استخراج/عرض PPTX، سكربتات سير عمل بمساعدة AI |

## 🚀 الميزات

- تحويل الصور النقطية إلى مسارات SVG باستخدام وضعين:
  - `edges`: اكتشاف الحواف باستخدام Canny
  - `binary`: استخراج الأشكال بالعتبة
- إعدادات المعالجة المبدئية:
  - Gaussian blur (`--blur`)
  - عكس الألوان اختياري (`--invert`)
- تبسيط المسارات باستخدام تقريب Douglas-Peucker (`--epsilon`)
- مخرجات SVG تحفظ أبعاد البكسل الأصلية عبر `width` و`height` و`viewBox`
- أدوات صور PPTX:
  - استخراج الصور المضمنة حسب الشريحة
  - تحويل صفحات الشرائح إلى `page1.png`, `page2.png`, ...

## 🗂️ هيكل المشروع

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (اختياري لواجهة CLI الأساسية)
├── i18n/                            # مجلد الترجمة (قيد الإعداد/فارغ حاليا)
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

### CLI الأساسي

- Python 3
- `pip`
- الاعتماديات من [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### أدوات PPTX الاختيارية

- لـ `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- لـ `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` أو `libreoffice` في `PATH`)
  - `PyMuPDF` (`fitz`)
- إعداد المساعدات الاختيارية:
  - Conda (لـ `scripts/setup_conda_env.sh`)

### سيرات العمل المتقدمة الاختيارية

تعتمد عدة سكربتات ضمن `scripts/` على أدوات/خدمات خارجية (مثل `codex` CLI وواجهات GRS AI APIs). هذه اختيارات اختيارية وليست مطلوبة لتشغيل `aigi2vector.py`.

## 🛠️ التثبيت

### بداية سريعة (التدفق القانوني الحالي)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### إعداد Conda اختياري لمرافق PPTX

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ الاستخدام

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### خيارات CLI

| الخيار | القيمة الافتراضية | الوصف |
|---|---|---|
| `--mode edges|binary` | `edges` | وضع المتجهة |
| `--canny LOW HIGH` | `100 200` | عتبات منخفض/مرتفع لوضع `edges` |
| `--threshold N` | `128` | عتبة ثنائية في وضع `binary` |
| `--invert` | off | عكس الأبيض/الأسود قبل استخراج الكونتورات |
| `--blur K` | `3` | حجم نواة Gaussian (عدد فردي)
| `--epsilon E` | `1.5` | تبسيط المنحنيات؛ كلما زاد الرقم قلّ عدد النقاط |

### كيف تعمل الأوضاع

- وضع `edges` يشغّل كشف حواف Canny ويرسم الكونتورات الخارجية.
- وضع `binary` يعمل Threshold على صورة التدرج الرمادي ويرسم الكونتورات الخارجية للـ mask الناتج.

## ⚙️ الإعداد

### ضبط معلمات CLI الأساسية

- `--canny LOW HIGH`:
  - القيم الأقل تلتقط تفاصيل/ضوضاء أكثر.
  - القيم الأعلى تنتج كونتورات أنظف لكن ربما أقل كثافة.
- `--threshold` (وضع binary):
  - قيمة threshold أقل تُبقي المزيد من المناطق الفاتحة في المقدمة.
  - قيمة threshold أعلى تُبقي غالبًا المناطق الداكنة/عالية التباين.
- `--blur`:
  - يتم تطبيعها داخليًا تلقائيًا إلى نواة فردية موجبة.
  - القيم الأكبر تُنعم الضوضاء قبل استخراج الكونتورات.
- `--epsilon`:
  - القيم الأكبر تُبسّط المسارات بشكل أكثر (عدد نقاط أقل).
  - القيم الأصغر تحافظ على تفاصيل الشكل أكثر.

### متغيرات البيئة (السكربتات المتقدمة)

- `GRSAI` مطلوبة بواسطة سكربتات استخراج GRS AI (مثل `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

ملاحظة افتراض: سكربتات المتقدمة تعتمد على البيئة جزئيًا ومُوثقة جزئيًا فقط في نسخة الـ README الحالية؛ الأوامر أدناه تحافظ على سلوك مطابق للمستودع دون ضمان قابلية النقل التامة بين كل الأجهزة.

## 🧪 أمثلة

### من raster إلى SVG

الحدود (ممتازة لفن الخطوط):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

الأشكال الثنائية (ممتازة للشعارات / الرسوم المسطحة):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### استخراج صور PPTX

إذا احتجت لاستخراج الصور المضمنة من ملف `.pptx` (مثلاً صورة أو اثنتين لكل شريحة)، استخدم:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

أضف `--dedupe` لتخطي الصور المكررة بين الشرائح. أضف `--png` لحفظ الملفات بصيغة `p{slide}image{index}.png`.

### تحويل الشرائح إلى صور

لعرض كل شريحة إلى `page1.png`, `page2.png`, ... تحتاج إلى تثبيت LibreOffice (`soffice`):

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

أو استخدم المولد بلغة Python (ويستخدم أيضًا LibreOffice، ثم يحوّل صفحات PDF إلى PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### سيرات العمل المتقدمة الاختيارية (سكريبتات)

توجد هذه السكربتات داخل المستودع ويمكن استخدامها لسيرات عمل أكبر لاستخلاص/إعادة بناء:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

مهم: بعض هذه السكربتات تحتوي حاليًا على مسارات مطلقة خاصة بجهاز معين واعتماديات خدمات خارجية؛ عدّلها قبل الاستخدام في الإنتاج.

## 🧰 ملاحظات التطوير

- التنفيذ الأساسي هو واجهة CLI واحدة بملف Python: [`aigi2vector.py`](aigi2vector.py)
- حافظ على أسماء الدوال/المتغيرات بصيغة `snake_case`، واسماء الثوابت بصيغة `UPPER_SNAKE_CASE`
- فضل الدوال الصغيرة القابلة للاختبار على الكتل الضخمة
- لا توجد حالياً مجموعة اختبارات رسمية
- `AIGI/` متجاهلة بواسطة git ومخصصة للأصول المحلية

## 🛟 استكشاف الأخطاء

- `FileNotFoundError` للصورة/ملف PPTX المدخل:
  - تحقق من صحة مسار الإدخال وقابليته للقراءة.
- `Could not read image`:
  - تأكد من أن صيغة الملف مدعومة في OpenCV وأنه غير تالف.
- إخراج SVG فارغ أو ضعيف:
  - جرّب `--mode binary` مع تعديل `--threshold`.
  - عدّل عتبات `--canny` في وضع `edges`.
  - قلل `--epsilon` للحفاظ على عدد أكبر من نقاط الكونتور.
  - ابدأ بصورة مصدر عالية التباين.
- `LibreOffice (soffice) not found in PATH`:
  - ثبّت LibreOffice وتأكد من أن `soffice` أو `libreoffice` متاح في shell الخاص بك.
- حزم Python مفقودة لتدفقات السكربتات:
  - ثبّت الاعتماديات المطلوبة لمسار السكربت المعني (`python-pptx`, `Pillow`, `PyMuPDF`, وغيرها).
- فشل سكربتات GRS AI بأخطاء تحقق:
  - صدّر مفتاحك، مثلًا: `export GRSAI=...`.

## 🗺️ خارطة الطريق

تحسينات قادمة محتملة:

- إضافة اختبارات آلية داخل `tests/` باستخدام عينات صور محددة
- نشر مجموعات اعتماديات موحدة اختيارية لسيرات عمل السكربتات
- تحسين قابلية نقل pipelines shell المتقدمة (إزالة المسارات المطلقة الثابتة)
- إضافة أمثلة مدخل/مخرج مرجعية ضمن أصول عينات مُدارة بالإصدارات
- ملء `i18n/` بمتغيرات README مترجمة ومصانة

## 🤝 المساهمة

المساهمات مرحّبة.

المقترح:

1. اعمل fork أو إنشاء فرع من الخط الرئيسي الحالي.
2. اجعل التغييرات مركزة واستخدم رسائل commit قصيرة وصيغة أمر.
3. شغّل الأوامر ذات الصلة بالمسار الذي عدّلته (CLI/سلاسل السكربت) وتأكد من المخرجات.
4. حدّث ملاحظات الاستخدام في README عند أي تغيير في السلوك.

إذا أضفت اختبارات، ضعها داخل `tests/` وسمّ الملفات بصيغة `test_*.py`.

## 📝 ملاحظات

- SVG الناتج يستخدم أبعاد البكسل الأصلية للصورة المدخلة. عدّل المقياس في محرّر المتجهات إذا لزم.
- للحصول على أفضل نتائج، ابدأ بصورة ذات تباين عالي.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## الترخيص

MIT
