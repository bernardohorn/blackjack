plugins {
    id("com.android.application")
    // Carrega o Flutter depois do suporte ao Android.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.clube21.clube_21"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Identificador do aplicativo no Android.
        applicationId = "br.com.clube21.clube_21"
        // Usa as versões de Android compatíveis com este Flutter.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // A versão do aplicativo vem de pubspec.yaml.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Assinatura de desenvolvimento; troque por uma própria antes de publicar em loja.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
