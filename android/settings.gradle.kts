pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    // kotlin-android plugin'i geri eklendi (built-in Kotlin yerine klasik yol) —
    // AGP 9 + newDsl=false + builtInKotlin=false ile resmi olarak desteklenen kombinasyon.
    id("org.jetbrains.kotlin.android") version "2.3.0" apply false
}

include(":app")
