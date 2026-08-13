# Mobile Performance Audit Checklist

Use this checklist as a coverage requirement. Mark each item as pass, partial, fail, not verifiable, or not applicable. Require file, command, trace, benchmark, or production evidence for pass.

## 1. Architecture and ownership

- Mobile repository contains the web application and Capacitor Android project.
- Native capabilities are wrapped behind platform services rather than called from arbitrary UI components.
- Location, realtime, uploads, sync, and lifecycle each have a single responsible manager or clearly bounded feature service.
- Backend responsibilities are not duplicated in the mobile client.
- Observability infrastructure is separated from product endpoints and secrets.

## 2. Startup and readiness

- Production build is measured, not only development mode.
- Initial route and critical assets are intentionally selected.
- Noncritical routes and heavy libraries are lazy-loaded.
- App readiness is marked when the first useful screen is usable.
- Android `reportFullyDrawn` is integrated when full-display timing is required.
- Cold, warm, and resume journeys are distinguishable.
- Startup work avoids unnecessary network, map, camera, location, and database initialization.

## 3. Rendering and main thread

- Long JavaScript tasks are measured or observable.
- Expensive transformations do not run in render paths.
- Repeated renders and state fan-out are controlled.
- Scroll, input, and animation paths avoid synchronous heavy work.
- Large computations use chunking, workers, native code, or backend processing where appropriate.
- Animations use compositor-friendly properties where practical.

## 4. Lists, images, maps, and media

- Large lists use pagination or virtualization.
- List rows do not load full-resolution media.
- Images use file paths or blobs instead of persistent Base64 strings.
- Compression and thumbnail generation happen before upload when appropriate.
- Concurrent uploads and decodes are bounded.
- Maps mount only when needed and avoid complete marker or route reconstruction.
- Camera, audio, and media streams are released after use.

## 5. Network and API client

- Requests pass through a central API client.
- Duplicate concurrent requests are deduplicated where relevant.
- Search and rapidly changing inputs are debounced.
- Caching and invalidation are explicit.
- Full synchronization is not triggered on every resume without justification.
- Payload sizes, compression, pagination, and delta endpoints are considered.
- Timeouts, cancellation, retry policy, and exponential backoff are defined.
- Retry behavior is idempotent or uses idempotency keys.
- Frontend request timing can be correlated with backend traces.

## 6. Offline and synchronization

- Core field actions can be recorded locally during network loss when required.
- Pending operations use a durable queue.
- Queue entries have stable identifiers and retry state.
- Conflicts and server rejection are handled explicitly.
- Successful sync removes or finalizes local operations safely.
- Process termination does not lose pending work.
- Resume performs delta reconciliation rather than blind replacement.
- Uploads can recover from interruption when business requirements demand it.

## 7. Lifecycle and process restoration

- App pause, resume, and app-state changes are handled intentionally.
- Listeners, timers, observers, sockets, and plugin handles are removed.
- In-flight requests can be canceled when their result is no longer useful.
- External Android activities such as camera flows can restore results after process recreation.
- Critical transient state is persisted before it can be lost.
- Logout and session expiry stop sensors, sockets, queues, and privileged work.

## 8. Location, sensors, and background work

- Location starts only for a documented user or business journey.
- Accuracy and frequency match the business requirement.
- Watchers stop at tour end, logout, error, and app-state transitions.
- Positions are batched rather than sent individually when appropriate.
- Reliable deferred work uses WorkManager or another Android-supported mechanism.
- Foreground services are limited to user-visible ongoing tasks.
- Foreground-service notifications and permissions are correct.
- Wake locks are absent or narrowly scoped and released.
- JavaScript timers are not used as the reliability mechanism for background execution.

## 9. Storage and memory

- Preferences, secure secrets, structured offline data, and files use appropriate storage mechanisms.
- Tokens and secrets are not stored in insecure plain-text web storage without a documented threat decision.
- Large images and binary data are not retained in global UI state.
- Repeated screen navigation does not cause unbounded memory growth.
- Temporary files have a cleanup policy.
- Local database queries are indexed and bounded.
- Cache size and eviction are controlled.

## 10. Android project and release build

- Android lint runs in CI.
- Release build uses intended minification and resource shrinking decisions.
- Debug-only logging and diagnostics are disabled or sampled in production.
- Native dependencies and permissions are minimal.
- Macrobenchmark exists for critical journeys or the gap is documented.
- Baseline Profiles exist for important Android code paths or the gap is documented.
- Benchmarks run against a controlled build and device configuration.
- Benchmark results and Perfetto traces are retained as artifacts.

## 11. Frontend and mobile observability

- JavaScript errors are captured.
- Native Android crashes and ANRs are captured through an appropriate platform.
- Source maps and native symbols are uploaded securely for releases.
- Release, environment, app version, and device context are present.
- Key journeys have custom spans or traces.
- API timing includes status and route templates without leaking sensitive payloads.
- Sampling and offline event buffering are controlled.
- Initialization occurs early enough to capture startup failures.
- Presence of an SDK is verified against actual initialization and release configuration.

## 12. Backend performance and tracing

- Backend requests have correlation or trace identifiers.
- Trace context propagates between mobile requests and backend services where supported.
- Endpoint latency, error rate, and throughput are observable.
- Database queries, external calls, queues, and file operations are traced or measured.
- Slow-query controls and indexes are reviewed for critical endpoints.
- Sync and upload endpoints use bounded payloads and idempotent behavior.
- Event-loop delay, CPU, and memory can be diagnosed.
- Backend telemetry excludes secrets and unnecessary personal data.

## 13. CI and performance governance

- One documented command runs fast deterministic performance checks.
- Bundle budgets are automated.
- Static rules detect prohibited patterns with an explicit allowlist mechanism.
- Critical benchmark journeys are named and versioned.
- Baselines are stored with environment metadata.
- Regressions fail CI according to agreed budgets.
- Baseline changes require a documented reason.
- Nightly or release benchmarks run on controlled physical hardware when energy or frame data matters.
- Production Android Vitals or equivalent data is reviewed after release.

## 14. Privacy and security of telemetry

- DSN or public ingestion identifiers are separated from privileged credentials.
- Authentication tokens, addresses, photos, comments, names, and job content are scrubbed by default.
- User identity uses the minimum necessary identifier.
- Telemetry retention and access are defined.
- Consent and legal requirements are considered for production monitoring.
- Debug logs do not expose personal data or secrets.
