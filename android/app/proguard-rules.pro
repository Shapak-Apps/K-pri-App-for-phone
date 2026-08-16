# ═══════════════════════════════════════════════════════════
# ── Flutter / Dart Engine ──
# ═══════════════════════════════════════════════════════════
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keepclassmembers class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# ── КРИТИЧНО: FFI (твой C++ splash_engine) ──
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class com.sun.jna.** { *; }
-keepclassmembers class * extends com.sun.jna.** { *; }

# ═══════════════════════════════════════════════════════════
# ── Google ML Kit (translation + language id) ──
# ═══════════════════════════════════════════════════════════
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.mlkit.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# ML Kit динамическая загрузка моделей
-keepclasseswithmembers class * {
    @com.google.android.gms.common.annotation.KeepForSdk *;
}
-keepclasseswithmembers class * {
    @com.google.mlkit.common.annotation.KeepForSdk *;
}

# AutoValue (ML Kit internal)
-keep class * extends com.google.auto.value.AutoValue { *; }
-keepclassmembers class * extends com.google.auto.value.AutoValue { *; }

# JNI для ML Kit (нативные библиотеки переводчика)
-keep class com.google.mlkit.nl.translate.** { *; }
-keep class com.google.mlkit.vision.common.internal.** { *; }
-keep class com.google.mlkit.common.internal.** { *; }
-keep class com.google.mlkit.nl.translate.internal.** { *; }
-keep class com.google.mlkit.nl.languageid.internal.** { *; }

# ═══════════════════════════════════════════════════════════
# ── Android System ──
# ═══════════════════════════════════════════════════════════
# Parcelable / Creator
-keepnames class * implements android.os.Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ═══════════════════════════════════════════════════════════
# ── CameraX ──
# ═══════════════════════════════════════════════════════════
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ═══════════════════════════════════════════════════════════
# ── Hive ──
# ═══════════════════════════════════════════════════════════
-keep class io.hive.** { *; }
-dontwarn io.hive.**

# ═══════════════════════════════════════════════════════════
# ── OkHttp / Gson (если используются в проекте) ──
# ═══════════════════════════════════════════════════════════
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class com.google.gson.** { *; }

# ═══════════════════════════════════════════════════════════
# ── Общие правила безопасности ──
# ═══════════════════════════════════════════════════════════
-keepattributes *Annotation*,SourceFile,LineNumberTable,Signature,InnerClasses,EnclosingMethod
-keep class * extends android.app.Activity
-keep class * extends android.app.Application
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.content.ContentProvider
-renamesourcefileattribute SourceFile
-dontwarn com.google.auto.value.**
-dontwarn com.google.android.gms.common.annotation.**
-dontwarn com.google.mlkit.common.annotation.**
-dontwarn com.google.android.play.core.**