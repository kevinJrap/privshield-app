package com.privshield.vpn

import android.net.VpnService

object PrivShieldVpnBuilder {

    // RFC 5737 documentation range — never routes anywhere
    // Prevents getaddrinfo DNS leak during tunnel reconfiguration
    // Android OS bug, unpatched as of March 2026 (confirmed Mullvad 2024)
    private const val BOGUS_DNS_V4 = "192.0.2.1"
    private const val BOGUS_DNS_V6 = "2001:db8::1"

    private val LAN_RANGES = listOf(
        Pair("10.0.0.0", 8),
        Pair("172.16.0.0", 12),
        Pair("192.168.0.0", 16),
        Pair("169.254.0.0", 16),
        Pair("fc00::", 7)
    )

    fun VpnService.Builder.applyPrivShieldDefaults(
        allowLan: Boolean = true,
        blockingState: Boolean = false
    ): VpnService.Builder {

        if (blockingState) {
            addDnsServer(BOGUS_DNS_V4)
            addDnsServer(BOGUS_DNS_V6)
            addRoute("0.0.0.0", 0)
            addRoute("::", 0)
            return this
        }

        if (allowLan) {
            LAN_RANGES.forEach { (ip, prefix) ->
                try {
                    excludeRoute(java.net.InetAddress.getByName(ip), prefix)
                } catch (e: Exception) { }
            }
        }

        setMetered(false)
        setBlocking(true)
        return this
    }
}
