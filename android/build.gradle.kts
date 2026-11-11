import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    // Makes KotlinCompile / JvmTarget available so plugin subprojects can be aligned to 17.
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Flutter plugins (e.g. geolocator_android, permission_handler_android) still
// declare Java 8. Force 17 so javac stops warning that source/target 8 is obsolete.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            try {
                val compileOptions = ext.javaClass.getMethod("getCompileOptions").invoke(ext)
                compileOptions.javaClass
                    .getMethod("setSourceCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass
                    .getMethod("setTargetCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (_: ReflectiveOperationException) {
                // Non-Android subprojects can be ignored.
            }
        }

        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
            // Plugins still call deprecated Android APIs (e.g. Bundle.get). Those
            // emit mandatory javac Notes that -Xlint/-nowarn cannot silence.
            options.compilerArgs.add("-XDsuppressNotes")
        }

        tasks.withType<KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(JvmTarget.JVM_17)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
