# https://flutter.io/android-release/#enabling-proguard
# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# https://developer.android.com/google/play/billing/billing_best_practices#obfuscate
-keep class com.android.vending.billing.**

#Amazon SDK rules
-dontwarn com.amazon.**
-keep class com.amazon.** {*;}
-keepattributes *Annotation*
#end amazon sdk rules

-dontwarn android.app.**
-dontwarn android.content.pm.**
-dontwarn me.dm7.barcodescanner.**
-dontoptimize

# https://foreachi.com/android/androidx-proguard/
-dontwarn com.google.android.material.**
-keep class com.google.android.material.** { *; }

-dontwarn androidx.**
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

-dontwarn android.support.v4.**
-keep class android.support.v4.** { *; }

-dontwarn android.support.v7.**
-keep class android.support.v7.** { *; }

-dontwarn
-dontnote

# 3P providers are optional
-dontwarn com.facebook.**
-dontwarn com.twitter.**
# Keep the class names used to check for availablility
-keepnames class com.facebook.login.LoginManager
-keepnames class com.twitter.sdk.android.core.identity.TwitterAuthClient

# Don't note a bunch of dynamically referenced classes
-dontnote com.google.**
-dontnote com.facebook.**
-dontnote com.twitter.**
-dontnote com.squareup.okhttp.**
-dontnote okhttp3.internal.**

# Recommended flags for Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*

# Retrofit config
-dontnote retrofit2.Platform
-dontwarn retrofit2.** # Also keeps Twitter at bay as long as they keep using Retrofit
-dontwarn okhttp3.**
-dontwarn okio.**
-keepattributes Exceptions

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.firestore.** { *; }
-dontwarn com.google.firebase.firestore.**
-dontnote io.flutter.plugins.**

# TODO remove https://github.com/google/gson/issues/1174
-dontwarn com.google.gson.Gson$6