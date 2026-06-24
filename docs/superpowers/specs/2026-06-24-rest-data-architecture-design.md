# REST Data Architecture Design

## Background

The current Flutter app renders nearly all product content from static, in-code values:

- `ExploreScreen` reads `sampleMeditations` directly from `lib/models/meditation.dart`.
- `ProfileScreen` instantiates `const UserStats()` directly.
- `HomeScreen` hardcodes the date, greeting, recommendation card, continue-listening card, and topic summaries.
- `SleepScreen` hardcodes the featured story, ambient sounds, and sleep item list.
- `PlayerProvider` simulates playback state locally and is not connected to a real audio backend.

This makes the app good for visual prototyping, but not ready for real backend integration.

## Goal

Refactor the app from static page data to a REST-oriented, provider-driven architecture that:

- preserves the existing `Provider + ChangeNotifier` pattern,
- supports `loading / error / data / retry` states on content pages,
- allows the app to switch between mock data and real REST endpoints through dependency injection,
- keeps the current player simulation untouched for now,
- updates project documentation so other agents can continue the work safely.

## Non-Goals

This design intentionally does not include:

- login or authenticated user sessions,
- real audio playback SDK integration,
- offline cache or persistence,
- pagination,
- advanced search debounce,
- backend schema design beyond the client-facing contract described here.

## Recommended Approach

Use an incremental layered architecture:

`Screen -> PageProvider -> ContentRepository -> ApiClient -> REST API`

This is preferred over a single large provider because it keeps page responsibilities isolated, and preferred over a full clean-architecture split because the current project does not justify heavier ceremony.

## Architecture

### Services

Add a small network layer under `lib/services/`:

- `api_exception.dart`
  - Defines typed exceptions for request failure, invalid response, and unexpected errors.
- `api_client.dart`
  - Wraps HTTP GET calls.
  - Parses JSON responses.
  - Normalizes HTTP failures into `ApiException`.

`ApiClient` should remain generic and unaware of page-specific models.

### Repositories

Add `lib/repositories/content_repository.dart` as the shared contract for read-only content:

- `Future<HomeData> fetchHomeData()`
- `Future<List<Meditation>> fetchMeditations({String? category, String? query})`
- `Future<SleepContent> fetchSleepContent()`
- `Future<UserStats> fetchUserStats()`

Provide two implementations:

- `MockContentRepository`
  - Returns in-memory data shaped like real API results.
  - Used by default during local development.
- `RemoteContentRepository`
  - Uses `ApiClient` to call REST endpoints and map JSON into models.

This keeps page code unchanged when switching from mock data to a real backend.

### Providers

Add one provider per data-driven page:

- `HomeProvider`
- `ExploreProvider`
- `SleepProvider`
- `ProfileProvider`

Each provider should:

- own exactly one page's loading lifecycle,
- expose `isLoading`, `errorMessage`, and page data,
- implement `load()`,
- implement `retry()` as a thin alias to `load()`,
- call `notifyListeners()` on every state transition.

`ExploreProvider` also owns the selected filter and optional search query state so that the screen no longer filters a static list directly.

### Screens

Screens become renderers of provider state:

- if loading, show a page-level loading state,
- if failed, show an error block with a retry action,
- if successful, render the returned page data.

The screens should no longer read static content constants as their primary data source.

## Data Model Design

### Meditation

Extend the existing `Meditation` model with API-friendly structure:

- `id`
- `title`
- `subtitle`
- `instructor`
- `durationMinutes`
- `category`
- optional `themeKey`

Add:

- `factory Meditation.fromJson(Map<String, dynamic> json)`

Do not require backend-owned `Color` values. Visual gradients remain a presentation concern inside Flutter. The UI should map a category or theme key to local color pairs.

### UserStats

Keep the current fields:

- `streakDays`
- `totalMinutes`
- `totalSessions`
- `weeklyCompleted`
- `weeklyMinutes`

Add:

- `factory UserStats.fromJson(Map<String, dynamic> json)`

Remove direct reliance on default constructor values inside the screen.

### HomeData

Add `lib/models/home_data.dart` to represent homepage content:

- `dateText`
- `greetingName`
- `greetingLine`
- `featuredSession`
- `continueSession`
- `topicSummaries`

This lets homepage text and counts come from data rather than being assembled in the widget tree.

### SleepContent

Add `lib/models/sleep_content.dart` to group sleep-page content:

- `featuredStory`
- `ambientSounds`
- `sleepItems`

This replaces the current scattered static tuples with a stable page contract.

### Nested Helper Models

To keep page objects explicit and easy to test, introduce small nested model types where helpful, such as:

- `SessionSummary`
- `TopicSummary`
- `AmbientSound`
- `SleepItem`

These can live beside their owning page models if they are not reused elsewhere.

## REST Contract

The client should be built against these read-only endpoints:

- `GET /home`
  - returns `HomeData`
- `GET /meditations`
  - supports optional query params:
    - `category`
    - `q`
- `GET /sleep`
  - returns `SleepContent`
- `GET /user/stats`
  - returns `UserStats`

The frontend should not assume authentication for this first pass. If auth is added later, repository interfaces should remain stable.

## Dependency Injection

Update `main.dart` so that:

- a single `ContentRepository` instance is created near app startup,
- the repository is injected into page providers,
- the default local wiring uses `MockContentRepository`,
- switching to `RemoteContentRepository(baseUrl: ...)` is a one-place change.

This keeps the migration path simple for later backend integration.

## UI State Rules

Each data-driven page follows the same rules:

### Loading

- The first load shows a page-level loading indicator.
- The page should not pretend to have content before data exists.

### Error

- Show a short error message.
- Show a retry button.
- Do not silently fall back to static content when the provider is using a remote source.

### Success

- Render provider data only.
- Keep current visual styling as much as possible.

## File Plan

### New Files

- `lib/services/api_exception.dart`
- `lib/services/api_client.dart`
- `lib/repositories/content_repository.dart`
- `lib/repositories/mock_content_repository.dart`
- `lib/repositories/remote_content_repository.dart`
- `lib/providers/home_provider.dart`
- `lib/providers/explore_provider.dart`
- `lib/providers/sleep_provider.dart`
- `lib/providers/profile_provider.dart`
- `lib/models/home_data.dart`
- `lib/models/sleep_content.dart`

### Updated Files

- `pubspec.yaml`
  - add `http`
- `lib/main.dart`
  - register repository and page providers
- `lib/models/meditation.dart`
  - add JSON parsing and remove dependence on static sample list as the primary source
- `lib/models/user_stats.dart`
  - add JSON parsing
- `lib/screens/home_screen.dart`
  - render `HomeProvider`
- `lib/screens/explore_screen.dart`
  - render `ExploreProvider`
- `lib/screens/sleep_screen.dart`
  - render `SleepProvider`
- `lib/screens/profile_screen.dart`
  - render `ProfileProvider`
- `AGENTS.md`
  - document the new architecture and continuation rules for other agents

## Migration Strategy

### Phase 1

Introduce models, repository interfaces, mock repository, and page providers.

### Phase 2

Move the four content screens from static values to provider-driven rendering with loading and error states.

### Phase 3

Keep the app defaulting to `MockContentRepository` until a backend base URL and real endpoints are available.

### Phase 4

Later, switch dependency injection to `RemoteContentRepository` with minimal UI changes.

## Testing Strategy

Implementation should at least verify:

- providers transition correctly across loading, success, and error,
- screens render loading UI when data is pending,
- screens render retry UI on failure,
- mock repository data matches the fields expected by the widgets,
- filtering in `ExploreProvider` behaves correctly for category and query combinations.

If widget or provider tests are not added in the first implementation pass, that gap should be called out explicitly.

## Risks And Mitigations

### Risk: Presentation fields mixed with backend fields

Mitigation:

- keep colors and gradients in the client,
- let the backend return semantic fields such as `category` or `themeKey`.

### Risk: Provider duplication

Mitigation:

- duplicate only the small, intentional `loading / error / data / retry` shape,
- avoid introducing a generic abstraction unless duplication becomes painful.

### Risk: Partial migration leaves mixed data sources

Mitigation:

- convert each targeted screen fully to provider-driven data,
- do not leave primary page content split between provider state and old constants.

## AGENTS.md Update Requirements

The implementation must update `AGENTS.md` to reflect:

- the app now uses a repository-backed content architecture,
- `ContentRepository` is the read-only source of truth for home, explore, sleep, and profile data,
- `MockContentRepository` is the default local implementation,
- the switch point to real REST data lives in `main.dart`,
- page providers own `loading / error / data / retry`,
- UI gradients remain a frontend concern,
- `PlayerProvider` still simulates playback and is not yet backed by a real audio service.

## Success Criteria

This work is successful when:

- the four content pages no longer depend on hardcoded in-widget data as their primary source,
- the app runs with mock API-shaped data through repository injection,
- screens handle loading and error states consistently,
- switching to a real REST repository is localized and predictable,
- `AGENTS.md` clearly explains the new architecture for future contributors and agents.
