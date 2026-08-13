# Performance, Plugins & Capgo Patterns

Local extensions beyond Capawesome defaults. Prefer these when the project already uses Capgo (`@capgo/*`) or when reviewing performance/plugin hygiene.

## Keep Capacitor Packages in Sync

```bash
npm install @capacitor/core@latest @capacitor/cli@latest
npm install @capacitor/ios@latest @capacitor/android@latest
npx cap sync
```

Core and platform packages must share the same major version. After any plugin install, always `npx cap sync`. On CocoaPods iOS: `cd ios/App && pod install`.

## Plugin Install Pattern

**Correct**

```bash
npm install @capgo/capacitor-native-biometric
npx cap sync
# CocoaPods only:
cd ios/App && pod install && cd ../..
```

**Incorrect:** install without sync — native bridge will not find the plugin at runtime.

## Check Availability Before Native Calls

```typescript
import { NativeBiometric } from '@capgo/capacitor-native-biometric';

async function authenticate() {
  const { isAvailable } = await NativeBiometric.isAvailable();
  if (!isAvailable) return authenticateWithPassword();

  try {
    await NativeBiometric.verifyIdentity({
      reason: 'Authenticate to access your account',
      title: 'Biometric Login',
    });
    return true;
  } catch {
    return false;
  }
}
```

## Lazy-Load Heavy Plugins

```typescript
async function scanDocument() {
  const { DocumentScanner } = await import('@capgo/capacitor-document-scanner');
  return DocumentScanner.scanDocument();
}
```

Avoid importing many native plugins at app startup — it increases bundle size and bridge registration cost.

## Minimize Bridge Calls

Batch data into one Preferences/Storage write instead of many small keys:

```typescript
await Preferences.set({
  key: 'userData',
  value: JSON.stringify({ name, email, preferences }),
});
```

## Camera / Image Defaults

Prefer `CameraResultType.Uri`, quality ~80, and a max width (e.g. 1024). Avoid Base64 for large photos.

## Secure Credentials (Capgo)

Do not put passwords/tokens in `@capacitor/preferences`. For Capgo biometric credential storage:

```typescript
import { NativeBiometric } from '@capgo/capacitor-native-biometric';

await NativeBiometric.setCredentials({
  username: 'user@example.com',
  password: 'secret',
  server: 'api.myapp.com',
});

const credentials = await NativeBiometric.getCredentials({
  server: 'api.myapp.com',
});
```

Also see `security.md` for Capawesome secure-preferences and general rules.

## Capgo Live Updates

When the project uses `@capgo/capacitor-updater` (not Capawesome Live Update):

```typescript
import { CapacitorUpdater } from '@capgo/capacitor-updater';

CapacitorUpdater.notifyAppReady();

CapacitorUpdater.addListener('updateAvailable', async (update) => {
  const bundle = await CapacitorUpdater.download({
    url: update.url,
    version: update.version,
  });
  await CapacitorUpdater.set(bundle); // apply on next start
});
```

Download in background; apply on restart. Do not force `reload()` while the user is active.

If migrating Capgo → Capawesome Cloud, use the `capgo-cloud-migration` skill from Capawesome (install separately if needed).

## WebView / Native Perf Notes

- Android: `android:hardwareAccelerated="true"` on `<application>`.
- Prefer fewer bridge round-trips; keep heavy work off the UI thread on the native side when custom plugins are involved.

## Plugin Error Handling

Always catch plugin errors. Treat user cancel and permission denial as expected paths, not crashes.

```typescript
try {
  return await Camera.getPhoto({ quality: 90, resultType: CameraResultType.Uri });
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  if (message.includes('cancelled') || message.includes('permission')) return null;
  console.error('Camera error:', error);
  throw error;
}
```

## Platform Detection

```typescript
import { Capacitor } from '@capacitor/core';

if (Capacitor.isNativePlatform()) { /* native */ }
if (Capacitor.getPlatform() === 'ios') { /* iOS only */ }
```

## Deployment Checklist (Extra)

- [ ] No committed `server.url` / cleartext for production
- [ ] ProGuard enabled for Android release
- [ ] Real-device test (not only simulators)
- [ ] Permissions declared and justified
- [ ] Deep links, backgrounding, push, biometrics smoke-tested
