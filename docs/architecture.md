# LongiSync architecture

The repository originally contained a SwiftUI starter. It remains unchanged. The Flutter app lives at the repository root; use `ios/Runner.xcworkspace`, not `Longisync.xcodeproj`, for Flutter builds.

- `lib/main.dart`: bootstrap and Riverpod scope.
- `lib/app`: app, GoRouter navigation, light/dark design tokens.
- `lib/core/api`: centralized environment configuration, Dio transport, safe errors.
- `lib/core/auth`: secure access/refresh token storage interface.
- `lib/core/widgets`: adaptive navigation and reusable feature states.
- `lib/features/<feature>`: screens, models, data repositories, and providers as each feature is implemented. Avoid empty speculative implementation classes.

UI consumes providers; repositories own data access. Demo data and live data must stay visibly distinct. Never silently replace live health records with demo records after an API failure. No passwords, tokens, medical data, or genetic data may be logged.

## Configuration

`APP_ENV`: development (default), staging, production.
`API_BASE_URL`: http://localhost:8000 by default. Android Emulator uses http://10.0.2.2:8000. Staging/production require an explicit HTTPS URL.
`USE_MOCKS`: true by default. The backend contract is provisional; server integration requires matching payloads, token expiry/refresh policy, and backend tests before release.

Refresh-token storage is prepared; automatic refresh is deliberately deferred until the backend defines rotation/revocation behavior. Authenticated 401 responses must invalidate the session. No HTTP payload logging interceptor is installed.

## Later phases

Profile, event/sub-event paginated timestamped readings, therapies, environment, genetics metadata, reports, AI backend integration, and wearable adapters remain separate features. HealthKit, Health Connect, Bluetooth, location, and notification permissions are requested only when their future feature is explicitly enabled. No device API or AI provider key belongs in UI code. Genetic data must not imply diagnosis or disease prediction.

## Phase 1

Created iOS/Android runners, feature-first foundation, Riverpod scope, GoRouter five-tab shell with iPad navigation rail, themes, API configuration, Dio authorization handling, secure token interface, and navigation/configuration tests.

Required dependencies: flutter_riverpod, go_router, dio, flutter_secure_storage, fl_chart, intl. Exact versions are locked in pubspec.lock. Models currently use plain Dart; code generation is unnecessary at this stage.

## Phase 2

Implemented splash/session restoration, onboarding, validated login/signup/reset forms, safe failure messages, sign out, and route protection. `AuthRepository` separates a clearly labeled demo implementation from a provisional FastAPI JSON adapter. Demo signup deliberately opens Alex's sample account; it does not register a real user, save submitted personal information, or send an email. Only a demo session marker is retained in secure storage. A real API adapter expects `access_token`, optional `refresh_token`, and `user: {id, full_name, email}` from login/register. Confirm this schema with the backend before live use. A network failure during restoration shows Retry; it does not silently create a demo session.

## Phase 3 / first implementation scope

Implemented dashboard and health overview with ten metrics, seven days of mock measurements, timestamp-aware day/week/month/year selection, metric detail sheets, loading/error/empty states, and responsive light/dark layouts. Chart percent changes compare the prior sample day without clinical interpretation. Step goals and summary copy are illustrative. No invented longevity score is presented. The mock series has daily samples, so Day shows a single observation and longer periods show only available records.

Added a `HealthDataSource` contract for future permission-scoped adapters. Profile currently shows identity, appearance, logout, and links to future modules; comprehensive medical/body/goals editing is deferred to Phase 4. Timeline, reports, therapies, environment, genetics, AI, and devices are explicitly labeled placeholders. No real wearable or AI integration is active. Live health integration is deferred and presents a clear unavailable state with `USE_MOCKS=false`.

Authentication tests cover demo login, validation, navigation, logout; responsive tests cover restored sessions at 320×568, 393×852, and 1024×768 in light/dark mode. Data tests verify timestamps, IDs, user scope, and calendar filtering. API configuration tests enforce HTTPS outside development.

Secure storage uses the 10.x release line (locked to 10.3.1) for compatibility with Flutter 3.38.4 and Android compile SDK 36. Android SDK settings retain the Flutter defaults. No iOS permission or entitlement prompts are added at startup.
