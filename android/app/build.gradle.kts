import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, read from the untracked `android/key.properties`.
//
// The file is absent in a fresh clone and in CI jobs that are not building a
// release, and that is a supported state: the release build type falls back to
// debug signing below so those builds still succeed.  Because that fallback is
// silent, CI verifies the signing certificate of the artifact it publishes
// rather than trusting the build to have picked the right key.
val releaseKeyProperties: Properties? =
    rootProject.file("key.properties").takeIf { it.exists() }?.let { file ->
        Properties().apply { file.inputStream().use { load(it) } }
    }

android {
    namespace = "dev.wisnij.unitary"
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
        applicationId = "dev.wisnij.unitary"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        releaseKeyProperties?.let { props ->
            create("release") {
                val missing = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
                    .filter { props.getProperty(it).isNullOrBlank() }
                require(missing.isEmpty()) {
                    "android/key.properties is present but missing: ${missing.joinToString(", ")}"
                }

                // A relative storeFile resolves against android/app; keystores are
                // expected to live outside the repository, so use an absolute path.
                storeFile = file(props.getProperty("storeFile"))
                storePassword = props.getProperty("storePassword")
                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeyProperties != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
