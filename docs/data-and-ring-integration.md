# LongiSync 1.1 — data collection and ring integration

## Platform health sources

Apple Health and Android Health Connect are available from Settings & privacy → Health data consent & sources. LongiSync requests read access only after the user taps Connect, imports supported records from the previous 30 days, normalizes them into `HealthMeasurement`, preserves platform/device provenance, and deduplicates repeated imports. Users can sync again or revoke future access. Apple Health requires iOS 15 or later. Health Connect requires Android API 26 or later and availability on the device.

## Collection flow

Profile/goals and manual measurements → validated forms → user-scoped encrypted local document → Riverpod state → dashboard, chronological timeline, reports and local insights.

Mini Zone ring → Bluetooth discovery (flutter_blue_plus) → Bonlala Android SDK → method channel → live observations / separate historical reports → the same local data store.

Manual measurements carry UUID, user UUID, measurement type, value, unit, timestamp, source and optional device ID. Journal entries carry kind, UUID, timestamp, notes, structured fields and optional parent ID for sub-events. Entries are saved before the UI confirms success; writes are serialized so simultaneous ring and manual updates do not overwrite one another. Auth tokens use separate storage keys. No health record is uploaded by this implementation.

## Functional screens

- Home/Health: actual saved observations; manual entry and deletion; timestamp-spaced charts; day/week/month/year selection. Optional sample preview is separate and excluded from reports.
- Profile: editable name, DOB, gender, height, blood group, goals, conditions, allergies, surgeries, medications and family history; age/BMI derived when inputs exist.
- Timeline: lazy chronological list combining journal events/sub-events and manual/ring measurements.
- Nutrition: food/portion, calories, protein, carbs, fat, notes, date/time; add/edit/delete/history.
- Workouts: duration, sets, reps, load, distance; add/edit/delete/history.
- Water: individual drinks and daily totals; user-defined water goal.
- Plans/check-ins: user-authored schedules/targets, energy, mood, waist and body-fat records.
- Therapy, environment, genetics: structured editable personal records with history. Genetics contains report metadata, not diagnosis.
- Reports: daily/weekly/monthly/custom-date summaries from personal records; cumulative steps use the latest daily observation instead of summing snapshots.
- Insights: deterministic summaries of actual records, clearly labeled as locally calculated. No fictitious AI response.
- Settings: appearance, optional sample preview, collection explanation and explicit local-data deletion.

## Mini Zone / Immortiva reference

Reference inspected read-only: `/Users/mousamdebadatta/echoos/immortiva/lib/minizone/minizone_panel.dart` and its Android Kotlin bridge. The supplied `Bonlala_ble_v1.4.aar` and `NordicDfuLibrary.aar` are copied into `android/app/libs`. The Android method channel is `longisync/wearable_sdk`; no EchoOS branding or account logic is included.

Add Ring is a separate page. Scan asks only for the Bluetooth permissions needed by the Android version (location permission on Android 11 and earlier is required by BLE scanning, but no location is collected). Nearby device names/service advertisements are hints, not proof of compatibility. Connection requires user selection and successful data-channel setup. Ring context persists; reconnect/sync is explicit. Connections stop in the background and on logout. Forget removes the binding without factory-resetting the ring.

Live heart rate/steps are validated and persisted at most every 30 seconds with observation time and wearable provenance. Historical HR/steps/SpO2/stress/HRV data from structured SDK callbacks are retained as daily ring reports. The SDK arrays lack verified per-sample timestamps, so their chart axis is sample order; they are not turned into fabricated time-series observations. Daily reports are retained by requested date. Raw and structured records are not merged twice. Sleep stages, temperature units, historical sample cadence, and firmware OTA require verified vendor documentation; these are not guessed. iOS has no supplied vendor SDK and explains that Android ring sync is the currently available path.

The reused app bridge's raw logs were removed. The bundled SDK itself also emits logs; R8 is enabled for both debug and release builds with log-stripping rules. Its optional LitePal-based Application class is unused: LongiSync initializes the SDK manager directly through its Flutter activity. No vendor factory-reset or account-ID assignment is invoked.

Physical-ring pairing, callbacks and units still require testing with the user's exact ring. Emulator testing cannot validate Bluetooth hardware. Vendor SDK redistribution/production support should be confirmed before store distribution.

## FITTR and Mini Zone sources

The scope prioritizes the user's clarification about **how data is collected**, not a replica of another service's marketplace:

- [FITTR public app description](https://play.google.com/store/apps/details?id=com.squats.fittr): user goals, meals/macros, training, progress and wearable integrations.
- [Mini Zone supplied by user](https://play.google.com/store/apps/details?id=com.bonlala.minizone&hl=en_IN): ring health tracking, Bluetooth connection, device management.

These public descriptions do not expose FITTR's private backend. Paid coaching, social/community accounts, lab bookings, consultations, food catalog/barcodes, verified sleep-stage interpretation, cloud sync, PDF export, and backend AI remain separate integrations. No fake coaches, appointments, shared user posts, or diagnoses are presented.

## Storage limits

This release uses Flutter secure storage for a user-scoped JSON document. It is suitable for testing modest local datasets, not an indefinitely growing wearable archive. A transactional encrypted database and server synchronization contract are needed before sustained production collection. Data is local to the current account/session identifier; demo authentication still uses the existing sample account. Live authentication remains the pre-existing provisional FastAPI adapter.
