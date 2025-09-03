#!/bin/bash
set -e

APP_NAME="EyeCare"
SCHEME="EyeCare"                    
CONFIGURATION="Release"              # Debug / Release
SDK="macosx"

PROJECT_PATH="./EyeCare.xcodeproj"   
BUILD_DIR="./build"

SRC_APP="$BUILD_DIR/$CONFIGURATION/$APP_NAME.app"
DST_DIR="$BUILD_DIR/$CONFIGURATION"
DMG_PATH="$DST_DIR/$APP_NAME.dmg"

echo "编译 $APP_NAME..."
xcodebuild -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk "$SDK" \
  BUILD_DIR="$BUILD_DIR" \
  clean build

mkdir -p "$DST_DIR"

TMP_DIR=$(mktemp -d)
cp -R "$SRC_APP" "$TMP_DIR/"

echo "移除 quarantine 属性..."
xattr -dr com.apple.quarantine "$TMP_DIR/$APP_NAME.app"

# === 打包 DMG ===
echo "生成 DMG..."
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$TMP_DIR/$APP_NAME.app" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$TMP_DIR"

echo "完成！DMG 文件生成在：$DMG_PATH"

