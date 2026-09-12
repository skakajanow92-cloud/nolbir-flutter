import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // "kotlin-android" kaldırıldı — AGP 9'un built-in Kotlin desteği
    // Kotlin dosyalarını otomatik derliyor, ayrı eklentiye gerek yok.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties dosyasını oku (bu dosya CI'da workflow tarafından otomatik
// oluşturulur, senin bilgisayarında elle test etmek istersen android/key.properties
// olarak kendin oluşturabilirsin — repoya asla commit etme).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.nolbir"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // "kotlinOptions { jvmTarget = ... }" bloğu kaldırıldı — bu, ayrı
    // Kotlin eklentisinin (org.jetbrains.kotlin.android) DSL'iydi. AGP 9'un
    // built-in Kotlin desteği, hedef JVM sürümünü yukarıdaki
    // compileOptions'tan otomatik alıyor. Kotlin derleme ayarlarını
    // özelleştirmen gerekirse yeni sözdizimi farklıdır (bkz. AGP 9 release notes).

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nolbir"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
