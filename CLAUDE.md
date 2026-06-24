# CLAUDE.md

## 项目概述

这是一个 Flutter 冥想应用「静」，基于 Claude Design 的设计稿实现。

## 构建与运行

```bash
flutter pub get
flutter run              # 默认设备
flutter run -d chrome    # Web
flutter build apk        # Android APK
flutter build web        # Web 产物在 build/web/
```

## 代码规范

- 状态管理使用 Provider + ChangeNotifier
- 颜色常量统一在 `lib/theme/app_colors.dart`
- 字体通过 `lib/theme/app_fonts.dart` 的 `AppFonts.serif()` / `AppFonts.sans()` 调用
- 衬线字体 (Noto Serif SC) 打包在 `assets/fonts/`，无网络依赖
- Sans 字体使用系统默认 sans-serif

## 关键架构决策

- 播放器作为全局覆盖层显示（当 `PlayerProvider.isPlaying` 或 `position > 0` 时）
- 底部导航使用 `IndexedStack` 保持各页面状态
- 呼吸动画使用 `AnimationController` + `TweenSequence`
- 睡眠页和播放页使用深色主题，通过各自的 Container 背景渐变实现

## 已知问题

- Flutter SDK 3.38.9 与 Gradle 8.14 的 `flutter-plugin-loader` 存在 repository 模式冲突，需修改 Flutter SDK 的 `packages/flutter_tools/gradle/settings.gradle.kts` 将 `FAIL_ON_PROJECT_REPOS` 改为 `PREFER_SETTINGS`
- Android 设备如无法访问 Google Fonts，已移除 google_fonts 依赖，改用本地打包字体
