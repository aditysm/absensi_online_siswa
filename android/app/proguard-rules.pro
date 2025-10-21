# Keep Flutter framework
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep plugins
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Keep Play Core SplitCompat
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Application
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }

# Optional: Prevent warnings from okhttp / retrofit / gson
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn retrofit2.**
-dontwarn com.google.gson.**
