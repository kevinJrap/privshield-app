package com.privshield.watchdog

import android.content.Context
import androidx.work.*
import java.util.concurrent.TimeUnit

object PrivShieldWatchdog {
    private const val TAG = "privshield_watchdog"

    fun schedule(ctx: Context) {
        val req = PeriodicWorkRequestBuilder<VpnHealthWorker>(15, TimeUnit.MINUTES)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                WorkRequest.MIN_BACKOFF_MILLIS,
                TimeUnit.MILLISECONDS
            )
            .addTag(TAG)
            .build()
        WorkManager.getInstance(ctx)
            .enqueueUniquePeriodicWork(TAG, ExistingPeriodicWorkPolicy.KEEP, req)
    }

    fun cancel(ctx: Context) =
        WorkManager.getInstance(ctx).cancelAllWorkByTag(TAG)
}

class VpnHealthWorker(
    ctx: Context,
    params: WorkerParameters
) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        return try {
            if (!VpnServiceChecker.isAlive(applicationContext)) {
                VpnServiceChecker.restart(applicationContext)
                kotlinx.coroutines.delay(3_000)
                if (VpnServiceChecker.isAlive(applicationContext))
                    Result.success()
                else
                    Result.retry()
            } else {
                Result.success()
            }
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
