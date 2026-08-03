allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1) Runtime: единая версия concurrent-futures во всех модулях
subprojects {
    configurations.configureEach {
        resolutionStrategy {
            force("androidx.concurrent:concurrent-futures:1.2.0")
        }
    }
}

// 2) Compile: javac (JDK 25) при чтении аннотаций camera-core требует
//    класс androidx.concurrent.futures.CallbackToFutureAdapter на classpath.
//    compileOnly = только на время компиляции, в APK не попадает.
//    Это чинит :camera_android_camerax:compileReleaseJavaWithJavac.
subprojects {
    plugins.withId("com.android.library") {
        dependencies.add("compileOnly", "androidx.concurrent:concurrent-futures:1.2.0")
    }
    plugins.withId("com.android.application") {
        dependencies.add("compileOnly", "androidx.concurrent:concurrent-futures:1.2.0")
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