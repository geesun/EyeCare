#!/bin/bash

SRC="screenshots/icon.png"
DST="EyeCare/Assets.xcassets/AppIcon.appiconset"

SIZES=(16 32 64 128 256 512 1024)

mkdir -p "$DST"

for SIZE in "${SIZES[@]}"; do
    OUTFILE="${DST}/${SIZE}-mac.png"
    echo "生成 ${OUTFILE}"
    sips --resampleWidth "$SIZE" "$SRC" --out "$OUTFILE"
done
