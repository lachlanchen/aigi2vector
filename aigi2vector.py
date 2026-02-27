#!/usr/bin/env python3
"""Convert raster images to vector plot SVGs."""

import argparse
import os
from typing import List, Tuple

import cv2
import numpy as np


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert AI-generated images into SVG vector plots."
    )
    parser.add_argument("input_image", help="Path to input image")
    parser.add_argument("output_svg", help="Path to output SVG")
    parser.add_argument(
        "--mode",
        choices=["edges", "binary"],
        default="edges",
        help="Vectorization mode",
    )
    parser.add_argument(
        "--canny",
        nargs=2,
        type=int,
        metavar=("LOW", "HIGH"),
        default=[100, 200],
        help="Canny edge thresholds for edges mode",
    )
    parser.add_argument(
        "--threshold",
        type=int,
        default=128,
        help="Binary threshold for binary mode",
    )
    parser.add_argument(
        "--invert",
        action="store_true",
        help="Invert black/white before contour detection",
    )
    parser.add_argument(
        "--blur",
        type=int,
        default=3,
        help="Gaussian blur kernel size (odd integer)",
    )
    parser.add_argument(
        "--epsilon",
        type=float,
        default=1.5,
        help="Curve simplification; higher = fewer points",
    )
    return parser.parse_args()


def ensure_odd(value: int) -> int:
    if value <= 0:
        return 1
    return value if value % 2 == 1 else value + 1


def load_grayscale(path: str) -> np.ndarray:
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        raise ValueError(f"Could not read image: {path}")
    return img


def preprocess(img: np.ndarray, blur_k: int, invert: bool) -> np.ndarray:
    k = ensure_odd(blur_k)
    if k > 1:
        img = cv2.GaussianBlur(img, (k, k), 0)
    if invert:
        img = cv2.bitwise_not(img)
    return img


def detect_mask(img: np.ndarray, mode: str, canny: List[int], threshold: int) -> np.ndarray:
    if mode == "edges":
        edges = cv2.Canny(img, canny[0], canny[1])
        return edges
    _, mask = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)
    return mask


def contours_to_paths(
    contours: List[np.ndarray],
    epsilon: float,
) -> List[str]:
    paths: List[str] = []
    for cnt in contours:
        if len(cnt) < 2:
            continue
        approx = cv2.approxPolyDP(cnt, epsilon, closed=True)
        pts = approx.reshape(-1, 2)
        if len(pts) < 2:
            continue
        cmds = [f"M {pts[0][0]} {pts[0][1]}"]
        for x, y in pts[1:]:
            cmds.append(f"L {x} {y}")
        cmds.append("Z")
        paths.append(" ".join(cmds))
    return paths


def write_svg(
    svg_path: str,
    width: int,
    height: int,
    paths: List[str],
) -> None:
    header = (
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" "
        f"width=\"{width}\" height=\"{height}\" "
        f"viewBox=\"0 0 {width} {height}\">\n"
    )
    body = []
    for d in paths:
        body.append(f"  <path d=\"{d}\" fill=\"none\" stroke=\"black\" stroke-width=\"1\" />")
    footer = "</svg>\n"
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(header)
        f.write("\n".join(body))
        f.write("\n")
        f.write(footer)


def main() -> None:
    args = parse_args()
    img = load_grayscale(args.input_image)
    img = preprocess(img, args.blur, args.invert)
    mask = detect_mask(img, args.mode, args.canny, args.threshold)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    paths = contours_to_paths(contours, args.epsilon)

    height, width = img.shape[:2]
    write_svg(args.output_svg, width, height, paths)


if __name__ == "__main__":
    main()
