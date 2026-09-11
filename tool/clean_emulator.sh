#!/usr/bin/env bash
#
# clean_emulator.sh — stop the Pixel_9 emulator and wipe its internal storage.
#
# Use this when the emulator reports "not enough space" / internal storage full.
# It stops the emulator (if running), deletes its writable data overlays and
# fast-boot snapshot, then exits. Start the emulator again from IntelliJ.
#
# Usage: tool/clean_emulator.sh

set -euo pipefail

AVD="Pixel_9"
AVD_DIR="$HOME/.android/avd/${AVD}.avd"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
ADB="$SDK/platform-tools/adb"

if [ ! -x "$ADB" ]; then
  echo "error: adb not found at $ADB (set ANDROID_HOME/ANDROID_SDK_ROOT)" >&2
  exit 1
fi

if [ ! -d "$AVD_DIR" ]; then
  echo "error: AVD directory not found: $AVD_DIR" >&2
  exit 1
fi

# --- 1. Stop the Pixel_9 emulator if it is running -------------------------
echo "Looking for a running '$AVD' emulator..."
for serial in $("$ADB" devices | awk '/^emulator-/{print $1}'); do
  name="$("$ADB" -s "$serial" emu avd name 2>/dev/null | head -n1 | tr -d '\r')"
  if [ "$name" = "$AVD" ]; then
    echo "Stopping $AVD ($serial)..."
    "$ADB" -s "$serial" emu kill >/dev/null 2>&1 || true
    for _ in $(seq 1 30); do
      if ! "$ADB" -s "$serial" get-state >/dev/null 2>&1; then
        break
      fi
      sleep 1
    done
  fi
done

# --- 2. Wipe the writable overlays and fast-boot snapshot -------------------
targets=(
  "$AVD_DIR/userdata-qemu.img"
  "$AVD_DIR/userdata-qemu.img.qcow2"
  "$AVD_DIR/cache.img.qcow2"
  "$AVD_DIR/encryptionkey.img.qcow2"
  "$AVD_DIR/snapshots/default_boot"
)

removed=0
for target in "${targets[@]}"; do
  if [ -e "$target" ]; then
    echo "Removing $target"
    rm -rf -- "$target"
    removed=$((removed + 1))
  fi
done

if [ "$removed" -eq 0 ]; then
  echo "Nothing to remove — '$AVD' storage already looks clean."
else
  echo "Removed $removed item(s)."
fi

echo
echo "Done. '$AVD' internal storage has been reset."
echo "Start the emulator again from IntelliJ, then verify with:"
echo "  \"$ADB\" shell df -h /data"
