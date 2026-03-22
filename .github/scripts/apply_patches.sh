#!/usr/bin/env bash
set -euo pipefail

echo "Applying PrivShield patches..."

# India-optimised DNS: Fly.io Mumbai PoP first
DNS_FILE=$(find app/src -name "*.kt" | xargs grep -l "sky.rethinkdns.com" 2>/dev/null | head -1 || true)
if [ -n "$DNS_FILE" ]; then
  sed -i 's|sky\.rethinkdns\.com|max.rethinkdns.com|g' "$DNS_FILE"
  echo "Default DNS -> max.rethinkdns.com (Fly.io Mumbai PoP)"
fi

# Add ACRA crash reporter (replaces Firebase Crashlytics)
for f in app/build.gradle app/build.gradle.kts; do
  [ -f "$f" ] || continue
  if ! grep -q "acra" "$f"; then
    sed -i "/dependencies {/a\    implementation 'ch.acra:acra-notification:5.11.3'" "$f"
    echo "ACRA added to $f"
  fi
done

echo "All patches applied"
