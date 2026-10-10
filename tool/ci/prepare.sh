#!/usr/bin/env bash
# Scaffolding android/ + windows/ sengaja tidak di-commit (mengandung binary
# gradle-wrapper.jar dan .ico hasil generate). File dibuat di sini, lalu
# overlay kita timpa di atasnya.
set -euo pipefail

flutter create . \
  --platforms=android,windows \
  --project-name rebana_injector \
  --org com.rebana \
  --no-pub

cp tool/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml

kt=android/app/src/main/kotlin/com/rebana/rebana_injector/MainActivity.kt
mkdir -p "$(dirname "$kt")"
cp tool/android/MainActivity.kt "$kt"

# Template bawaan tidak dipakai, test kita sendiri yang jalan.
rm -f test/widget_test.dart