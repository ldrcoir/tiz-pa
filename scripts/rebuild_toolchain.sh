#!/bin/bash
# بازسازی کامل زنجیره ساخت بوقی پس از ریست کانتینر
# Godot 4.7.2 + قالب‌های اکسپورت + Android SDK (build-tools r34) + keystore + تنظیمات
set -uo pipefail
ROOT=/home/z/my-project
TOOLS=$ROOT/tools
SDK=/home/z/android-sdk
GODOT="https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip"
TPL="https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
BT="https://dl.google.com/android/repository/build-tools_r34-linux.zip"
PT="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
mkdir -p $TOOLS/dl $SDK ~/.android

C="curl -sL --retry 4 --retry-delay 2 -C -"

echo "== 1) godot binary =="
if [ ! -x $TOOLS/Godot_v4.7.2-stable_linux.x86_64 ]; then
  $C -o $TOOLS/dl/godot.zip "$GODOT" && (cd $TOOLS && unzip -o -q dl/godot.zip && rm -f dl/godot.zip)
fi
$TOOLS/Godot_v4.7.2-stable_linux.x86_64 --version | head -1

echo "== 2) export templates =="
TPLDIR=~/.local/share/godot/export_templates
if [ ! -f $TPLDIR/4.7.2.stable/templates_version.txt ] && [ ! -f $TPLDIR/4.7.2.stable/android_debug.apk ]; then
  $C -o $TOOLS/dl/tpl.tpz "$TPL" && mkdir -p $TPLDIR && (cd $TPLDIR && unzip -o -q $TOOLS/dl/tpl.tpz && rm -f $TOOLS/dl/tpl.tpz)
fi
ls $TPLDIR/4.7.2.stable/ 2>/dev/null | grep -E "android|version" | head -5

echo "== 3) android sdk =="
if [ ! -x $SDK/build-tools/34.0.0/aapt2 ]; then
  $C -o $TOOLS/dl/bt.zip "$BT" && (cd $SDK && unzip -o -q $TOOLS/dl/bt.zip)
  # پوشهٔ استخراج‌شده ممکن است android-14 نام داشته باشد
  for d in $SDK/android-* $SDK/build-tools/*/; do
    if [ -x "$d/aapt2" ] && [ "$(basename $d)" != "34.0.0" ]; then
      mkdir -p $SDK/build-tools/34.0.0 && cp -a $d/* $SDK/build-tools/34.0.0/ && rm -rf $d
    fi
  done
  rm -f $TOOLS/dl/bt.zip
fi
if [ ! -x $SDK/platform-tools/adb ]; then
  $C -o $TOOLS/dl/pt.zip "$PT" && (cd $SDK && unzip -o -q $TOOLS/dl/pt.zip && rm -f $TOOLS/dl/pt.zip)
fi
ls $SDK/build-tools/34.0.0/ 2>/dev/null | grep -E "aapt2|apksigner|zipalign" | head -3

echo "== 4) debug keystore =="
if [ ! -f ~/.android/debug.keystore ]; then
  keytool -genkeypair -v -keystore ~/.android/debug.keystore -storepass android \
    -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US" 2>&1 | tail -1
fi

echo "== 5) editor settings =="
mkdir -p ~/.config/godot
cat > ~/.config/godot/editor_settings-4.tres << 'EOF'
config_version=5

[export]

android/android_sdk_path="/home/z/android-sdk"
android/debug_keystore="/home/z/.android/debug.keystore"
android/debug_keystore_pass="android"
android/debug_keystore_user="androiddebugkey"
android/java_sdk_path="/usr/lib/jvm/java-21-openjdk-amd64"
EOF
echo "editor settings written"

echo "== DONE =="
