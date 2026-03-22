#!/usr/bin/env bash
set -euo pipefail

NSC=app/src/main/res/xml/network_security_config.xml
mkdir -p "$(dirname "$NSC")"

cat > "$NSC" << 'XMLEOF'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">max.rethinkdns.com</domain>
        <domain includeSubdomains="true">rdns.deno.dev</domain>
        <domain includeSubdomains="true">sky.rethinkdns.com</domain>
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
XMLEOF

MANIFEST=app/src/main/AndroidManifest.xml
if [ -f "$MANIFEST" ] && ! grep -q "networkSecurityConfig" "$MANIFEST"; then
  sed -i 's/<application/<application android:networkSecurityConfig="@xml\/network_security_config"/' "$MANIFEST"
  echo "NSC linked in AndroidManifest.xml"
fi

echo "Network security hardened"
