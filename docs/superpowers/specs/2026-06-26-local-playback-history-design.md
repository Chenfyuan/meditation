# Local Playback History and Sleep Timer Design

## Context

The app now has real audio playback through `PlayerProvider`, shared expanded and mini-player state, and audio URLs flowing through mock and remote content repositories. The next product step is to turn playback into a user-visible practice loop: users can fall asleep with a timer, completed sessions are remembered locally, and the profile page reflects real listening activity.

This version is local-first. It does not add authenticated users, write APIs, or backend statistic mutation. The implementation should preserve the existing repository/provider architecture and leave a clean path for future backend sync.

## Goals

- Add a sleep timer to the player with `off`, `15`, `30`, `45`, and `60` minute options.
- Stop playback automatically when the active sleep timer expires.
- Record local playback history for completed or meaningfully listened sessions.
- Derive local profile statistics from recorded history and merge them with existing repository-provided baseline stats.
- Keep playback usable in normal audio mode and fallback timer mode.
- Keep the implementation testable without requiring real audio playback or a running backend.

## Non-Goals

- User accounts, login, or cross-device sync.
- Backend write endpoints for history or statistics.
- A full playback queue or playlist system.
- Replacing the current mock and remote content repository contract.
- Redesigning the profile page layout beyond adding real local data.

## Recommended Approach

Use a small local practice domain:

- `PracticeSessionRecord` model stores a single finished playback session.
- `PracticeHistoryRepository` abstracts reading and writing records.
- `SharedPreferencesPracticeHistoryRepository` persists records as JSON in `shared_preferences`.
- `PracticeStats` or a helper on the repository summarizes local records into totals and weekly data.
- `PlayerProvider` owns sleep timer state and emits one local history record when a session qualifies.
- `ProfileProvider` loads repository baseline stats, then overlays local stats.

This keeps the current provider structure familiar while separating local persistence from UI widgets.

## Data Model

`PracticeSessionRecord` should contain:

- `id`: stable local ID, generated from timestamp plus a short suffix.
- `title`: content title shown to the user.
- `subtitle`: instructor, category, or content type.
- `durationSeconds`: planned content duration.
- `listenedSeconds`: actual listened duration when the record was written.
- `completedAt`: local timestamp in ISO 8601 format.
- `completionReason`: one of `finished`, `threshold`, or `sleepTimer`.
- `source`: one of `meditation`, `sleepStory`, `soundscape`, or `unknown`.

The repository should keep the most recent 20 records for display-ready history and use all retained records for local summary.

## Completion Rules

A session is recorded once, and only once, when any of these conditions becomes true:

- The audio player reaches its completed state.
- The user listened to at least 80 percent of the planned or loaded duration.
- A sleep timer expires while a session is active.

Manual close/reset should not record a session unless the 80 percent threshold has already been reached. This avoids inflating stats from quick accidental starts while still crediting meaningful practice.

## Sleep Timer Behavior

The player exposes timer options:

- `off`
- `15 minutes`
- `30 minutes`
- `45 minutes`
- `60 minutes`

Selecting a timer starts or replaces the current countdown. The countdown is tied to wall-clock time, not playback position, so it still expires if audio buffers briefly. When the timer expires, the player should stop audio, record the session with `sleepTimer`, clear the active session, and notify listeners.

The player UI should show a compact timer control near the current status badge. The mini-player should show the remaining timer when one is active.

## Profile Statistics

The profile page continues to use `ProfileProvider` as its only state source. `ProfileProvider` should:

- load baseline `UserStats` from `ContentRepository`,
- load local practice records from `PracticeHistoryRepository`,
- derive local totals,
- expose merged `UserStats`.

Merged stats:

- `totalMinutes`: baseline minutes plus summed local listened minutes.
- `totalSessions`: baseline sessions plus completed local records.
- `weeklyCompleted`: baseline weekly completed plus local records completed during the current week.
- `weeklyMinutes`: element-wise addition of baseline and local week minutes.
- `streakDays`: max of baseline streak and local derived streak.

This lets mock or remote stats remain useful while making new listening activity visible immediately.

## Provider Wiring

`main.dart` should provide one `PracticeHistoryRepository` instance above `PlayerProvider` and `ProfileProvider`.

`PlayerProvider` should receive the history repository through its constructor. It should call the repository only through a narrow private method such as `_recordCurrentSession`, so playback logic and persistence stay loosely coupled.

`ProfileProvider` should receive both `ContentRepository` and `PracticeHistoryRepository`. It should expose a `refreshLocalStats()` method or reload when notified by the player. If direct provider coupling is needed, use a lightweight callback from `PlayerProvider` after recording completion rather than making profile UI depend on player internals.

## UI Changes

Player screen:

- Add a compact timer selector with the five timer choices.
- Show remaining timer text when active.
- Keep play/pause, progress, and fallback messages as they are.

Mini-player:

- Continue showing title and progress.
- If a sleep timer is active, show remaining timer text in the detail line.

Profile screen:

- Keep the current layout.
- Use merged stats so existing cards update after completed sessions.
- Optionally add a small "recent practice" section later; it is not required for this slice.

## Error Handling

- If local history read fails, fall back to repository baseline stats and expose no blocking page error.
- If a record write fails, keep playback stable and log the failure with `debugPrint`.
- If persisted JSON contains invalid entries, skip invalid entries rather than failing the whole profile page.

## Testing

Add focused unit tests for:

- `PracticeSessionRecord` JSON round-trip.
- Local stats aggregation: total minutes, total sessions, weekly minutes, weekly completed, and streak.
- Completion rule: no record for short manual reset, record after 80 percent, record on natural completion, record on sleep timer expiry.
- Existing widget smoke test remains green.

Validation commands:

```bash
flutter analyze
flutter test
```

Backend tests do not need to change for this local-first slice.

## Rollout Notes

This feature should work with mock and remote content because it depends on the playback metadata already passed into `PlayerProvider`. Later backend sync can reuse `PracticeSessionRecord` as the client-side DTO and add a remote repository implementation behind the same local history abstraction.

## Self-Review

- No placeholder requirements remain.
- The scope is limited to local timer, history, and profile statistics.
- Backend writes, account sync, queue behavior, and recent-history UI are explicitly out of scope.
- Completion rules are deterministic and testable.
- The design preserves the existing `Screen -> Provider -> Repository` direction.
