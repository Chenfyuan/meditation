# 静 — 冥想应用

一个温暖治愈的跨平台冥想应用，使用 Flutter 构建。柔和的暖陶色系、优雅的衬线排版与大量留白，陪伴你度过平静的每一刻。

## 功能

- **首页** — 个性化问候、每日推荐冥想、继续聆听、主题探索
- **探索** — 搜索与筛选冥想课程列表
- **呼吸练习** — 4·7·8 呼吸法引导动画，实时计时与轮次追踪
- **冥想播放器** — 沉浸式暗色播放界面，动态脉动光球动画
- **睡眠** — 睡眠故事、环境音景（雨声/海浪/篝火/白噪）
- **个人进度** — 连续天数、总时长、本周统计图表、成就徽章

## 技术栈

- **Flutter** — 跨平台（iOS / Android / Web / Desktop）
- **Provider** — 状态管理
- **Noto Serif SC** — 本地打包衬线字体

## 开始使用

```bash
# 安装依赖
flutter pub get

# 运行（连接设备或模拟器）
flutter run

# 构建 Web 版本
flutter build web

# 构建 Android APK
flutter build apk
```

## 项目结构

```
lib/
├── main.dart              # 入口
├── app.dart               # 导航壳与页面切换
├── theme/
│   ├── app_colors.dart    # 设计色彩常量
│   ├── app_fonts.dart     # 字体工具类
│   └── app_theme.dart     # ThemeData 配置
├── models/                # 数据模型
├── providers/             # 状态管理 (Navigation / Player / Breathing)
├── screens/               # 6 个核心页面
└── widgets/               # 复用组件 (呼吸圆圈、播放光球、周报图表等)
```

## 设计色板

| 色彩 | 色值 | 用途 |
|------|------|------|
| 暖铜 | `#B8865F` | 主色调 |
| 奶油 | `#EFE8DE` | 背景 |
| 深棕 | `#3A3127` | 文字/深色 |
| 鼠尾草 | `#94A07A` | 辅助绿 |
| 玫瑰陶 | `#D8AA98` | 辅助粉 |

## 环境要求

- Flutter SDK >= 3.10
- Dart >= 3.10
