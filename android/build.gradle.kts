buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // AGP 9'un built-in Kotlin desteği varsayılan olarak 2.2.10 kullanıyor,
        // ama Flutter en az 2.2.20 istiyor. Bu satır o sürümü zorluyor.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin") {
            version { strictly("2.3.0") }
        }
    }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
