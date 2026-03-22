#!/usr/bin/env bash
set -euo pipefail

echo "Removing Firebase from Gradle files..."

for f in build.gradle build.gradle.kts; do
  [ -f "$f" ] || continue
  sed -i '/com\.google\.gms:google-services/d' "$f"
  sed -i '/com\.google\.firebase/d' "$f"
done

for f in app/build.gradle app/build.gradle.kts; do
  [ -f "$f" ] || continue
  sed -i '/apply plugin.*google-services/d' "$f"
  sed -i '/com\.google\.firebase/d' "$f"
  sed -i '/firebase-crashlytics/d' "$f"
  sed -i '/firebase-analytics/d' "$f"
  sed -i '/firebase-perf/d' "$f"
  sed -i '/gms\.play-services/d' "$f"
done

echo "Removing Firebase from source files..."
find app/src -name "*.kt" -o -name "*.java" 2>/dev/null | while read -r f; do
  sed -i '/import com\.google\.firebase/d' "$f"
  sed -i '/FirebaseCrashlytics/d' "$f"
  sed -i '/Firebase\.initialize/d' "$f"
  sed -i '/FirebaseAnalytics/d' "$f"
  sed -i '/FirebasePerformance/d' "$f"
done || true

echo "Firebase removed successfully"
