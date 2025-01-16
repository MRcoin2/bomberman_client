#!/bin/bash

SVG_DIR="svgs/"
PNG_DIR="pngs/"

mkdir -p "$PNG_DIR"

for svg_file in "$SVG_DIR"/*.svg; do
  base_name=$(basename "$svg_file" .svg)
  inkscape "$svg_file" --export-type=png --export-filename="$PNG_DIR/$base_name.png" --export-width=128 --export-height=128
done

echo "Conversion completed!"
