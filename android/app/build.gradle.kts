plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val uploadKeystoreFile = rootProject.file("upload-keystore.jks")
val hasUploadKeystore = keystorePropertiesFile.exists() && uploadKeystoreFile.exists()
if (hasUploadKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.golfimprove.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.golfimprove.app"
        // google_mlkit_pose_detection needs a modern Android API level
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKeystore) {
            create("upload") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = uploadKeystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        // Sign debug with upload keystore so SHA-1 matches Firebase
        // (6D:E3:C2:C9...) and Google Sign-In works (fixes ApiException: 10).
        getByName("debug") {
            if (hasUploadKeystore) {
                signingConfig = signingConfigs.getByName("upload")
            }
        }
        getByName("release") {
            if (hasUploadKeystore) {
                signingConfig = signingConfigs.getByName("upload")
            }
        }
    }
}

flutter {
    source = "../.."
}
