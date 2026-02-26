package com.gymblog.powercoach_studio

import android.app.Application

/**
 * Prefer IPv4 so the emulator can reach Sentry ingest and Supabase
 * (avoids SocketTimeoutException when the device tries IPv6 first).
 */
class PowerCoachStudioApplication : Application() {

    override fun onCreate() {
        System.setProperty("java.net.preferIPv4Stack", "true")
        super.onCreate()
    }
}
