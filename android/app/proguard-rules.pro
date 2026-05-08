# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep all annotations
-keepattributes *Annotation*

# Google Play Core (fixes R8 missing class errors)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }