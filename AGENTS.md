# Repository Guidelines

## Project Structure & Module Organization

- `aigi2vector.py`: Main CLI entry point. Reads a raster image and outputs an SVG with vector paths.
- `requirements.txt`: Python dependencies (OpenCV and NumPy).
- `README.md`: Usage, options, and examples.
- `AutoAppDev/`: Git submodule (external tooling, not required to run the CLI).
- `AIGI/`: Local assets folder, ignored by git.

There are currently no tests or additional modules.

## Build, Test, and Development Commands

Set up a virtual environment and install deps:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Run the CLI:

```bash
python aigi2vector.py input.png output.svg
```

No build step is required; this is a single-file Python tool.

## Coding Style & Naming Conventions

- Language: Python 3.
- Indentation: 4 spaces.
- Naming: `snake_case` for functions and variables, `UPPER_SNAKE_CASE` for constants.
- Keep CLI arguments explicit and documented in `README.md`.
- Prefer small, testable functions over large monoliths.

## Testing Guidelines

There is no test framework or suite yet. If you add tests, place them under `tests/` and name files `test_*.py`. Keep inputs/fixtures small and use deterministic sample images.

## Commit & Pull Request Guidelines

- Commit style: short, imperative messages (e.g., `Add AutoAppDev submodule`, `Fix SVG output`).
- Each commit should be focused on a single logical change.
- Always commit and push after edits.
- PRs should include: a concise summary, steps to verify (commands run), and example input/output SVGs when behavior changes.

## Configuration & Security Notes

- Avoid committing large or sensitive images. Use small, anonymized samples.
- The `AIGI/` directory is ignored; keep local assets there if needed.
