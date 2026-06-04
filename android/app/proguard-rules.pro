# ===== Flutter / Dart =====
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# ===== Google Mobile Ads (AdMob) =====
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ===== Google Play Billing (in_app_purchase) =====
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.api.** { *; }
-dontwarn com.android.billingclient.**

# ===== Play Core (deferred components / split install) =====
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ===== 일반 보안/안정성 규칙 =====
# 직렬화 클래스 보호
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 네이티브 메서드 보호
-keepclasseswithmembernames class * {
    native <methods>;
}

# 디버그 로그 제거 (릴리스 빌드에서 정보 노출 방지)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# 어노테이션/시그니처 유지
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
