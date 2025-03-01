plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.elint.ultra_level"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.elint.ultra_level"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("/Users/chandrakumar/Desktop/outside/test_ultra_level_pro/ultra_level_pro/my-release-key.keystore")  // Ensure the path is correct
            storePassword = "apple1996"
            keyAlias = "my-key-alias"
            keyPassword = "apple1996"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs["release"]  // Linking to the signing config
            isMinifyEnabled = false  // Set to true if you want to use ProGuard or R8 minification
            isShrinkResources = false  // Enables resource shrinking
        }
    }
}

flutter {
    source = "../.."  // Adjust this if needed based on your Flutter project structure
}
