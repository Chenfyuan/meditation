# AGENTS.md

## 项目概述

这是一个 Flutter 冥想应用「静」，基于 Codex Design 的设计稿实现。

## 构建与运行

```bash
flutter pub get
flutter run              # 默认设备
flutter run -d chrome    # Web
flutter build apk        # Android APK
flutter build web        # Web 产物在 build/web/
```

### 真实后端

```bash
cd backend
cp .env.example .env     # Windows 可手动复制
npm install
npm run db:up
npm run prisma:migrate -- --name init
npm run prisma:seed
npm run start:dev
```

## 代码规范

- 状态管理使用 Provider + ChangeNotifier
- 颜色常量统一在 `lib/theme/app_colors.dart`
- 字体通过 `lib/theme/app_fonts.dart` 的 `AppFonts.serif()` / `AppFonts.sans()` 调用
- 衬线字体 (Noto Serif SC) 打包在 `assets/fonts/`，无网络依赖
- Sans 字体使用系统默认 sans-serif

## 数据架构

- 内容页数据已从“页面内静态常量”迁移为 `Repository + PageProvider` 架构
- 当前只读内容统一通过 `ContentRepository` 提供，包括：
  - 首页：`fetchHomeData()`
  - 探索页：`fetchMeditations()`
  - 睡眠页：`fetchSleepContent()`
  - 我的页：`fetchUserStats()`
- 默认注入的是 `MockContentRepository`
- 真实 REST 接口实现位于 `lib/repositories/remote_content_repository.dart`
- 切换 mock / remote 的入口在 `lib/main.dart`
- Flutter 通过 `--dart-define` 控制是否接真实后端：
  - `USE_REMOTE_CONTENT=true`
  - `CONTENT_API_BASE_URL=http://127.0.0.1:3000`
- 页面 provider 统一负责 `loading / error / data / retry`
- 当前新增的页面 provider：
  - `HomeProvider`
  - `ExploreProvider`
  - `SleepProvider`
  - `ProfileProvider`

## 目录职责

- `lib/models/`
  - 页面和内容模型，支持 `fromJson`
- `lib/services/`
  - 通用 API 能力，如 `ApiClient`、`ApiException`
- `lib/repositories/`
  - 内容数据来源抽象与实现
- `lib/providers/`
  - 页面级状态管理和加载流程
- `lib/widgets/`
  - 共享 UI 组件，包括页面状态反馈组件

## API 接入约定

- 预留的 REST 路径：
  - `GET /home`
  - `GET /meditations`
  - `GET /sleep`
  - `GET /user/stats`
- 仓库现在包含真实后端：`backend/`
  - 技术栈：`NestJS + PostgreSQL + Prisma`
  - 当前版本定位：内容优先、只读 REST API
  - 本地开发依赖 PostgreSQL seed 数据
- 探索页支持的 query 参数约定：
  - `category`
  - `q`
- 模型中的 `gradientColors` 不作为后端必传字段
- 颜色和渐变仍然属于前端展示层映射，统一在 `lib/theme/app_colors.dart` 维护

## 当前边界

- 播放器仍然是本地模拟：
  - `PlayerProvider` 只维护本地播放状态和计时器
  - 尚未接入真实音频 SDK 或后端播放地址
- 呼吸练习仍然是本地逻辑：
  - `BreathingProvider` 尚未接入远程数据
- 成就徽章目前仍是静态展示内容，不在本次只读 REST 接入范围内

## 后续智能体协作建议

- 如果要接真实后端，优先保持 `ContentRepository` 接口稳定
- 尽量不要让页面重新直接读取静态常量
- 新的只读页面数据优先走：
  - `Screen -> Provider -> Repository -> ApiClient`
- 如果继续扩展内容模型，优先补 `fromJson`，不要把后端字段和 Flutter `Color` 直接耦合
- 后端接口变更时，优先兼容现有 Flutter contract，不要随意改：
  - `GET /home`
  - `GET /meditations`
  - `GET /sleep`
  - `GET /user/stats`
- `backend/prisma/seed.ts` 不是 demo 假接口，而是本地开发必需的真实初始化数据入口
- 已确认的数据架构设计文档在：
  - `docs/superpowers/specs/2026-06-24-rest-data-architecture-design.md`
  - `docs/superpowers/specs/2026-06-24-nestjs-backend-design.md`

## 关键架构决策

- 播放器作为全局覆盖层显示，支持 `expanded` 全屏态和 `collapsed` 迷你条态
- 点击完整播放器左上角下箭头时应收起到迷你播放器，并返回原页面且继续播放
- `AppShell` 采用响应式壳层：
  - 手机：保留底部导航和窄屏内容宽度
  - 平板：放宽主内容宽度，仍使用底部导航
  - 桌面：切换为左侧导航面板 + 右侧主内容区
- 页面级响应式优先保持“手机结构不变，桌面再增强”：
  - `Home`：宽屏两栏，主题区支持更多列
  - `Explore`：宽屏改为内容卡片网格
  - `Sleep`：宽屏改为故事/音景/列表分栏
  - `Profile`：宽屏改为旅程卡与统计分栏
  - `Player`：宽屏改为双栏播放器
- 底部导航使用 `IndexedStack` 保持各页面状态
- 呼吸动画使用 `AnimationController` + `TweenSequence`
- 睡眠页和播放页使用深色主题，通过各自的 Container 背景渐变实现

## 已知问题

- Flutter SDK 3.38.9 与 Gradle 8.14 的 `flutter-plugin-loader` 存在 repository 模式冲突，需修改 Flutter SDK 的 `packages/flutter_tools/gradle/settings.gradle.kts` 将 `FAIL_ON_PROJECT_REPOS` 改为 `PREFER_SETTINGS`
- Android 设备如无法访问 Google Fonts，已移除 google_fonts 依赖，改用本地打包字体
