# Silent Shield 图标资源

采用方案 A：所有尺寸统一使用盾牌与 S，不包含波纹。

`mark.json` 保存矢量路径与品牌颜色。SVG、PNG、ICO 和 Android 矢量资源由 `tool/generate_brand.cjs` 生成，不直接修改导出文件。

在仓库根目录执行：

```powershell
npm install --prefix design/brand
$env:NODE_PATH = (Resolve-Path design/brand/node_modules).Path
npm --prefix design/brand run generate
```

需要 Node.js 及 sharp 0.35.4。TV 横幅字体使用本机 sans-serif，跨操作系统的字形可能略有差异。

输出覆盖 Windows 应用与安装包 ICO、macOS AppIcon、Linux 打包 PNG、应用内品牌图、Android 各密度图标、自适应前景、主题单色图层、商店图及 TV 横幅。

Android 前景使用 108 单位画布，关键图形位于中央安全区域。启动资源使用 288 单位画布，蓝色圆形直径为 96；Flutter 以 288 逻辑像素显示同一透明画布。系统与 Flutter 加载页跟随系统亮暗模式，未增加等待时间。Flutter 背景常量位于 `lib/application.dart`，修改品牌背景颜色时同步更新。

Android 12+ 的启动主题放在 `values-v31` 和 `values-night-v31`。FlutterActivity 通过 Manifest 中的 NormalTheme 元数据切换主题，不依赖未调用的 AndroidX postSplashScreenTheme。

托盘图标与桌面图标由同一脚本生成。停止状态使用减号角标，系统代理状态使用无角标蓝色图标，TUN 状态使用绿色角标；ICO 包含系统缩放所需的独立小尺寸帧。

旧 `start.png`、`start_screen.png`、位图前景和未引用的 Flutter 启动图已从运行时资源中移除。

发布前检查 Windows 桌面及任务栏的 100%、125%、150% 缩放效果，Android 圆形与圆角蒙版、主题图标、亮暗冷启动，以及 macOS/Linux 的实际桌面效果。Windows 可能缓存旧快捷方式图标，应先确认安装的是新包。
