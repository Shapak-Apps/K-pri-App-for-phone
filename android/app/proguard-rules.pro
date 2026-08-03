# ── Flutter / Dart ──
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keepclassmembers class io.flutter.embedding.** { *; }

# ── Google ML Kit (translation + language id) ──
# Именно эти правила нужны, чтобы в release ML Kit мог скачивать модели
# через Google Play Services (иначе silent fail, оффлайн не работает).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.mlkit.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Keep ML Kit classes marked with @KeepForSdk (dynamic module loader)
-keepclasseswithmembers class * {
    @com.google.android.gms.common.annotation.KeepForSdk *;
}

# AutoValue (ML Kit internal)
-keep class * extends com.google.auto.value.AutoValue { *; }
-keepclassmembers class * extends com.google.auto.value.AutoValue { *; }

# Parcelable / Creator
-keepnames class * implements android.os.Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ── Камера (CameraX / camera) ──
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ── Hive (если используется) ──
-keep class io.hive.** { *; }
-dontwarn io.hive.**

# ── Google ML Kit Translate: внутренние классы динамической загрузки моделей ──
-keep class com.google.mlkit.nl.translate.** { *; }
-keep class com.google.mlkit.vision.common.internal.** { *; }
-keep class com.google.mlkit.common.internal.** { *; }