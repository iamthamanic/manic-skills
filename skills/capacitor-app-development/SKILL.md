---
name: capacitor-app-development
description: Guides Capacitor app development — core concepts, CLI, capacitor.config, splash/icons, deep links, platforms, edge-to-edge, safe areas, live reload, storage, files, security, CI/CD, SPM/CocoaPods, Android/iOS troubleshooting, plus Capgo/plugin performance patterns. Use when working on Capacitor apps, native sync, config, plugins, Capgo updater, or mobile troubleshooting. Do not use for creating new Capacitor apps from scratch, writing custom plugin native code, IAP setup, major version upgrades, Cordova migration, or framework-only Angular/React/Vue patterns (use those Capawesome skills if installed).
disable-model-invocation: false
metadata:
  author: local-extended
  base: https://github.com/capawesome-team/skills/tree/main/skills/capacitor-app-development
  extended-with: capacitor-best-practices (Capgo, performance, plugin hygiene)
---

# Capacitor App Development

Capawesome `capacitor-app-development` plus local Capgo/performance extensions. Router skill: match the topic, read the reference, then apply to the project.

## Prerequisites

1. **Capacitor 6, 7, or 8** app already created and initialized.
2. Node.js and npm (Node 18+ Cap 6, Node 20+ Cap 7, Node 22+ Cap 8).
3. **Android**: Android Studio. **iOS**: Xcode on macOS.

## Agent Behavior

- **Auto-detect before asking.** Platforms (`android/`, `ios/`), framework configs, `@capacitor/core` version, iOS manager (`Podfile` vs SPM), and Capgo vs Capawesome live-update packages.
- **Route to the right reference.** Use the topic index; read that file before answering.
- **One topic at a time.** No general dump unless asked.
- **Actionable output.** Exact paths, commands, diffs.
- **Capgo projects:** prefer `references/performance-and-plugins.md` for updater, biometric credentials, and lazy plugin loading. Prefer Capawesome `security.md` / `storage.md` for generic secure storage.

## Procedures

### Step 1: Identify the Topic

Match the request to the index. Multi-topic → sequential. If another Capawesome skill covers it (creation, React, plugins catalog, upgrades, IAP, cloud), say so and use that skill if installed.

### Step 2: Analyze the Project

1. `@capacitor/core` version in `package.json`
2. `android/` / `ios/` present
3. Framework (vite/angular/next/etc.)
4. `capacitor.config.ts` vs `.json`
5. CocoaPods vs SPM
6. Live updates: `@capgo/capacitor-updater` vs `@capawesome/capacitor-live-update`

### Step 3: Read Reference and Apply

Read the matched reference, then adapt to this repo.

## Topic Index

| Topic | Reference |
| ----- | --------- |
| Core concepts (native bridge, how Capacitor works) | `references/core-concepts.md` |
| Capacitor platforms (Android, iOS, Electron, PWA) | `references/platforms.md` |
| Capacitor CLI commands | `references/cli.md` |
| App configuration (`capacitor.config.ts`) | `references/app-configuration.md` |
| Splash screens and app icons | `references/splash-screens-and-icons.md` |
| Deep links and universal links | `references/deep-links.md` |
| Android edge-to-edge support | `references/edge-to-edge.md` |
| Android safe area handling | `references/safe-area.md` |
| Live reload setup | `references/live-reload.md` |
| Storage solutions | `references/storage.md` |
| File handling best practices | `references/file-handling.md` |
| Security best practices | `references/security.md` |
| iOS package managers (SPM, CocoaPods) | `references/ios-package-managers.md` |
| CI/CD for Capacitor apps | `references/ci-cd.md` |
| Testing (unit and E2E) | `references/testing.md` |
| Cross-platform best practices | `references/cross-platform-best-practices.md` |
| Android troubleshooting | `references/troubleshooting-android.md` |
| iOS troubleshooting | `references/troubleshooting-ios.md` |
| Capgo live updates, plugin perf, biometric credentials, bridge hygiene | `references/performance-and-plugins.md` |

## Error Handling

- **`npx cap sync` fails**: Align `@capacitor/core` and `@capacitor/cli`. CocoaPods: `cd ios/App && pod install`. Android: Gradle sync in Android Studio.
- **Android build fails after config**: `cd android && ./gradlew clean`, rebuild.
- **iOS build fails after config**: Xcode Clean Build Folder, or delete `ios/App/Pods` and `pod install`.
- **Plugin not found at runtime**: `npx cap sync` after install; verify native project registration.
- **Live reload not connecting**: Same LAN; `server.url` uses correct LAN IP; cleartext only in dev.
- **Deep links not working**: Check `apple-app-site-association` / `assetlinks.json` and signing certs.

## Related Skills (install from Capawesome if needed)

```bash
npx skills add https://github.com/capawesome-team/skills --skill <name> -g -y
```

- `capacitor-app-creation`, `capacitor-react`, `capacitor-vue`, `capacitor-angular`
- `capacitor-plugins`, `capacitor-plugin-development`
- `capacitor-app-upgrades`, `capacitor-in-app-purchases`
- `capawesome-cloud`, `capgo-cloud-migration`

## Source

- Base: [capawesome-team/skills …/capacitor-app-development](https://github.com/capawesome-team/skills/tree/main/skills/capacitor-app-development)
- Extended locally with Capgo/performance patterns formerly in `capacitor-best-practices`
