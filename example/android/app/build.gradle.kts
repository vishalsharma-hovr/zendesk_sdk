import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadZendeskSecrets(repoRoot: File): Properties {
    val secrets = Properties()
    val secretsFile = repoRoot.resolve(".secrets/zendesk.env")
    if (!secretsFile.exists()) {
        return secrets
    }

    secretsFile.readLines().forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed.startsWith("#")) return@forEach
        val separatorIndex = trimmed.indexOf('=')
        if (separatorIndex > 0) {
            val key = trimmed.substring(0, separatorIndex).trim()
            val value = trimmed.substring(separatorIndex + 1).trim()
                .removeSurrounding("\"")
                .removeSurrounding("'")
            secrets.setProperty(key, value)
        }
    }

    return secrets
}

val repoRoot = rootProject.projectDir.parentFile.parentFile
val zendeskSecrets = loadZendeskSecrets(repoRoot)

android {
    namespace = "com.example.zendesk_sdk_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13846066 rc3"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.zendesk_sdk_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["ZENDESK_URL"] =
            zendeskSecrets.getProperty("ZENDESK_URL", "")
        manifestPlaceholders["ZENDESK_APP_ID"] =
            zendeskSecrets.getProperty("ZENDESK_APP_ID", "")
        manifestPlaceholders["ZENDESK_CLIENT_ID"] =
            zendeskSecrets.getProperty("ZENDESK_CLIENT_ID", "")
        manifestPlaceholders["ZENDESK_CHANNEL_ID"] =
            zendeskSecrets.getProperty("ZENDESK_CHANNEL_ID", "")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
