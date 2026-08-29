-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.** { *; }

-keepclasseswithmembernames class * {
    native <methods>;
}
-dontwarn com.sun.jna.**

-keep class com.kopri.translator.** { *; }

-keep class androidx.** { *; }
-dontwarn androidx.**

-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.mlkit.** { *; }

-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
-dontwarn com.google.mlkit.**
-dontwarn com.google.auto.value.**
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.common.annotation.**
-dontwarn com.google.mlkit.common.annotation.**

-keep class com.csdcorp.speech_to_text.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class es.antoniobermudez.home_widget.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }

-dontwarn com.csdcorp.speech_to_text.**
-dontwarn com.tundralabs.fluttertts.**
-dontwarn com.baseflow.permissionhandler.**
-dontwarn es.antoniobermudez.home_widget.**
-dontwarn dev.fluttercommunity.plus.**

-keep class androidx.camera.** { *; }

-keepnames class * implements android.os.Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keep class * extends android.app.Activity
-keep class * extends android.app.Application
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.content.ContentProvider
-keep class * extends android.appwidget.AppWidgetProvider

-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class com.google.gson.** { *; }

-keepattributes *Annotation*, SourceFile, LineNumberTable, Signature, InnerClasses, EnclosingMethod
-renamesourcefileattribute SourceFile