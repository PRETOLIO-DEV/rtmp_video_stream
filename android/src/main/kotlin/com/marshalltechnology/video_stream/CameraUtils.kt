package com.marshalltechnology.video_stream


import android.app.Activity
import android.content.Context
import android.graphics.ImageFormat
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.hardware.camera2.params.StreamConfigurationMap
import android.media.CamcorderProfile
import android.os.Build
import android.util.Log
import android.util.Size
import androidx.annotation.RequiresApi
import com.marshalltechnology.video_stream.Camera.ResolutionPreset
import java.util.*


/** Provides various utilities for camera.  */
object CameraUtils {
    val profileArray = arrayOf(
        CamcorderProfile.QUALITY_HIGH,
        CamcorderProfile.QUALITY_2160P,
        CamcorderProfile.QUALITY_1080P,
        CamcorderProfile.QUALITY_720P,
        CamcorderProfile.QUALITY_480P,
        CamcorderProfile.QUALITY_QVGA,
        CamcorderProfile.QUALITY_LOW
    )
    val qualityStartLookupProfileMap = mapOf(
        ResolutionPreset.max to 0,
        ResolutionPreset.ultraHigh to 1,
        ResolutionPreset.veryHigh to 2,
        ResolutionPreset.high to 3,
        ResolutionPreset.medium to 4,
        ResolutionPreset.low to 5
    )
    val rtmpSupportedRes = setOf(
//        "1920x1080",
//        "1280x720",
//        "854x480",
        "640x360",
        "426x240"
    )

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun computeBestPreviewSize(cameraName: String, presetArg: ResolutionPreset): Size {
        var preset = presetArg
        if (preset.ordinal > ResolutionPreset.high.ordinal) {
            preset = ResolutionPreset.high
        }
        val profile = getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset)
        return Size(profile.videoFrameWidth, profile.videoFrameHeight)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun computeBestCaptureSize(streamConfigurationMap: StreamConfigurationMap): Size {
        // For still image captures, we use the largest available size.
        return Collections.max(
                Arrays.asList(*streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
                CompareSizesByArea())
    }

    @Throws(CameraAccessException::class)
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun getAvailableCameras(activity: Activity): List<Map<String, Any>> {
        val cameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraNames = cameraManager.cameraIdList
        val cameras: MutableList<Map<String, Any>> = ArrayList()
        for (cameraName in cameraNames) {
            val details = HashMap<String, Any>()
            val characteristics = cameraManager.getCameraCharacteristics(cameraName)
            details["name"] = cameraName
            val sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION)
            details["sensorOrientation"] = sensorOrientation!!
            val lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING)
            when (lensFacing) {
                CameraMetadata.LENS_FACING_FRONT -> details["lensFacing"] = "front"
                CameraMetadata.LENS_FACING_BACK -> details["lensFacing"] = "back"
                CameraMetadata.LENS_FACING_EXTERNAL -> details["lensFacing"] = "external"
            }
            cameras.add(details)
        }
        return cameras
    }

    fun getBestAvailableCamcorderProfileForResolutionPreset2(
        context: Context, cameraName: String, preset: ResolutionPreset?): CamcorderProfile {
        val cameraId = cameraName.toInt()

        val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val characteristics = cameraManager.getCameraCharacteristics(cameraName)
        val map = characteristics[CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP]!!
        val supportedSet = mutableSetOf<String>()

//        for (size in map.getOutputSizes(ImageFormat.JPEG)) {
        for (size in map.getOutputSizes(SurfaceTexture::class.java)) {
            supportedSet.add(size.toString())
        }

        Log.d("CameraUtils", "Supported set of modes for SurfaceTexture: $supportedSet")
        val startIndex = qualityStartLookupProfileMap[preset]
        var fallbackProfile: CamcorderProfile? = null

        if (startIndex == null)
            throw IllegalArgumentException("No capture session available for current capture session.")

        for (i in startIndex until profileArray.size) {
            if (CamcorderProfile.hasProfile(cameraId, profileArray[i])) {
                val profile = CamcorderProfile.get(cameraId, profileArray[i])
                val profileKey = "${profile.videoFrameWidth}x${profile.videoFrameHeight}"
                var error: String? = null

                if (supportedSet.contains(profileKey)) {
                    if (fallbackProfile == null)
                        fallbackProfile = profile

                    if (rtmpSupportedRes.contains(profileKey)) {
                        Log.d("CameraUtils", "Profile: $profileKey passed")
                        return profile
                    } else
                        error = "unsupported by RTMP"
                } else
                    error = "unsupported by JPEG format"

                if (error != null)
                    Log.d("CameraUtils", "Trying profile: $profileKey failed ($error)")
            }
        }

        if (fallbackProfile != null)
            return fallbackProfile

        return getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset)
    }

    fun getBestAvailableCamcorderProfileForResolutionPreset(
            cameraName: String, preset: ResolutionPreset?): CamcorderProfile {
        val cameraId = cameraName.toInt()
        return when (preset) {
            ResolutionPreset.max -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_HIGH)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_HIGH)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.ultraHigh -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_2160P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_2160P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.veryHigh -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_1080P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_1080P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.high -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_720P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_720P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.medium -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_480P)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_480P)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            ResolutionPreset.low -> {
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_QVGA)) {
                    return CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_QVGA)
                }
                if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                    CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
                } else {
                    throw IllegalArgumentException(
                            "No capture session available for current capture session.")
                }
            }
            else -> if (CamcorderProfile.hasProfile(cameraId, CamcorderProfile.QUALITY_LOW)) {
                CamcorderProfile.get(cameraId, CamcorderProfile.QUALITY_LOW)
            } else {
                throw IllegalArgumentException(
                        "No capture session available for current capture session.")
            }
        }
    }

    private class CompareSizesByArea : Comparator<Size> {
        override fun compare(lhs: Size, rhs: Size): Int {
            // We cast here to ensure the multiplications won't overflow.
            return java.lang.Long.signum(
                    lhs.width.toLong() * lhs.height - rhs.width.toLong() * rhs.height)
        }
    }
}