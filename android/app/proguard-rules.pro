
-keep class com.follow.clash.models.** { *; }

-keep class com.follow.clash.service.models.** { *; }

# FlutterEngine 以插件实现类作为唯一键。禁止 R8 合并不同的 FlutterPlugin 实现，
# 否则后注册的插件会被误判为重复插件并导致 MissingPluginException。
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
