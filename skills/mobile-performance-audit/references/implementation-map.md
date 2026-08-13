# Implementation Map

Use this map to place work in the correct repository.

## Mobile frontend repository

Implement here:

- application startup sequencing;
- route-level lazy loading;
- component rendering and list virtualization;
- central API client and request timing;
- cache, offline state, durable sync queue, and conflict UI;
- image compression, thumbnails, and upload queue orchestration;
- feature-level spans such as `tour.open`, `job.complete`, and `photo.upload`;
- lifecycle handling for JavaScript resources;
- wrapper services for Capacitor plugins;
- frontend observability initialization and source maps;
- performance configuration and fast repository checks.

Do not put privileged observability credentials or backend APM code here.

## Android project inside the mobile repository

Implement here:

- Macrobenchmark module and journeys;
- Baseline Profile module and generation;
- `reportFullyDrawn` integration;
- WorkManager jobs;
- foreground services and notifications;
- native location behavior that must survive WebView suspension;
- Android permissions and manifest declarations;
- release Gradle configuration;
- native crash symbols and Android-specific observability setup;
- Perfetto and Android Studio profiling workflows.

## Backend repository

Implement here:

- backend observability bootstrap;
- HTTP request tracing and correlation IDs;
- trace-context propagation;
- database and external-service instrumentation;
- endpoint budgets, payload limits, and pagination;
- sync, upload, retry, and idempotency behavior;
- queue metrics and job traces;
- server CPU, memory, and event-loop metrics;
- slow-query analysis and indexes;
- backend load and integration tests.

## Observability infrastructure repository or platform

Implement here:

- Sentry organization and projects, or Grafana, Tempo, Loki, Prometheus, and OpenTelemetry Collector;
- dashboards, alerts, retention, sampling defaults, and access control;
- secret storage;
- cross-service routing and environment separation;
- production release-health views.

## CI repository configuration

Implement here:

- lint, build, bundle, and scanner commands;
- Android lint and release build checks;
- benchmark execution and artifact upload;
- regression comparison and failure thresholds;
- scheduled device runs;
- baseline update approval process.

## Capability-to-provider examples

Do not require one provider when another satisfies the capability.

| Capability | Possible implementations |
| --- | --- |
| JavaScript and native crash capture | Sentry Capacitor, Firebase Crashlytics plus web error capture, another mobile APM |
| Frontend traces | Sentry tracing, Grafana Faro, custom OpenTelemetry-compatible instrumentation |
| Backend traces | Sentry backend SDK, OpenTelemetry SDK, vendor APM |
| Android startup and frame benchmarks | Jetpack Macrobenchmark |
| Android code-path optimization | Baseline Profiles |
| Production Android quality | Android Vitals |
| Energy profiling | Controlled physical-device benchmarks, Perfetto, Android Studio tools |
