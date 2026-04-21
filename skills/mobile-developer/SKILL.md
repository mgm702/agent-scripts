---
name: Mobile Developer
description: React Native development with step-by-step guidance and explanations — assumes React knowledge, handles standalone and monorepo layouts.
triggers:
  - react native
  - mobile app
  - ios app
  - android app
  - mobile developer
  - react native setup
  - app store
  - expo
---

# Mobile Developer

React Native development guide. Assumes you know React. Explains the *why* behind each RN-specific decision — the framework has meaningful differences from web that aren't obvious coming from React.

---

## When to Use

- Setting up a new React Native project (standalone or inside an existing monorepo)
- Implementing any mobile-specific feature: navigation, native modules, platform code
- Debugging Metro, native crashes, or bridge issues
- Publishing to App Store or Google Play

---

## 1. Project Setup

### Two layouts

**Standalone** — RN project is the entire repo:
```
my-app/
  ios/
  android/
  src/
  package.json
```

**Monorepo** (e.g., alongside existing `backend/` + `frontend/`) — add `mobile/` as a sibling:
```
project/
  backend/       ← existing Rails/Go API
  frontend/      ← existing web React app
  mobile/        ← new React Native app lives here
    ios/
    android/
    src/
    package.json
```

Why a sibling directory rather than inside `frontend/`? RN has its own Metro bundler, native build systems (Xcode/Gradle), and node_modules. Mixing it with a web app creates bundler conflicts and confuses both toolchains.

### Prerequisites

1. **Node** — use the same version manager as your other JS projects (nvm/fnm)
2. **Watchman** — `brew install watchman`; Metro uses it for file watching; without it, file changes are missed silently
3. **Xcode** (iOS) — install from App Store; then install Command Line Tools: `xcode-select --install`
4. **CocoaPods** — `sudo gem install cocoapods`; manages iOS native dependencies
5. **Android Studio** (Android) — install SDK, set `ANDROID_HOME` in your shell profile

### Create the project

```bash
# Inside monorepo: cd into mobile/ first, or use --directory
npx @react-native-community/cli@latest init MyApp

# This creates: ios/, android/, src/, App.tsx, package.json
```

**Why not Expo?** Expo is great for demos and teams without native experience. Use bare React Native when you need custom native modules, full control over the build, or you're deploying to an enterprise environment with specific SDK requirements.

### iOS first-run

```bash
cd ios && pod install && cd ..
npx react-native run-ios
```

`pod install` links native dependencies declared in `Gemfile`/`Podfile`. Run it every time you add a native module. This is the RN equivalent of `npm install` but for the iOS native layer.

### Android first-run

Start an emulator from Android Studio (AVD Manager), then:
```bash
npx react-native run-android
```

---

## 2. Project Structure

```
mobile/
  android/          ← Gradle project; rarely touch directly
  ios/              ← Xcode project; open MyApp.xcworkspace (not .xcodeproj)
  src/
    components/     ← shared UI components
    screens/        ← full-screen views registered with navigation
    navigation/     ← navigator definitions (Stack, Tab, Drawer)
    hooks/          ← custom hooks (same as web)
    store/          ← state management (Zustand, Context)
    services/       ← API calls, storage, native module wrappers
    utils/
  App.tsx           ← root component; mounts NavigationContainer
  index.js          ← entry point; registers App with AppRegistry
```

**Why `index.js` instead of just `App.tsx`?** React Native uses `AppRegistry.registerComponent` to hand your root component to the native runtime. This is different from web where ReactDOM.render goes into a DOM node. `index.js` is the bridge between native and JS.

**Why `screens/` separate from `components/`?** Screens are registered with the navigator and receive navigation props. Components are reusable UI. Mixing them makes navigation refactors painful.

---

## 3. Navigation

Use **React Navigation** — the community standard. Install:

```bash
npm install @react-navigation/native
npm install @react-navigation/native-stack  # or bottom-tabs, drawer
npm install react-native-screens react-native-safe-area-context
cd ios && pod install && cd ..
```

**Why React Navigation instead of React Router?** React Router is built for the browser's history stack. Mobile navigation has a fundamentally different model: multiple simultaneous stacks, tab bars that persist state, gesture-driven back navigation, and hardware back button (Android). React Navigation maps to native navigation primitives.

### Basic setup

```tsx
// App.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Detail" component={DetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

**Why `NavigationContainer` at the root?** It owns the navigation state tree — similar to how Redux `Provider` or React Router `BrowserRouter` owns their state. Navigation state must be global because any screen can navigate to any other screen.

### Navigator types

| Navigator | Use when |
|---|---|
| `NativeStack` | Standard push/pop flow; uses native UINavigationController (iOS) / FragmentManager (Android) |
| `BottomTabs` | Primary app sections (Home, Search, Profile) |
| `Drawer` | Secondary navigation, settings, less-frequent destinations |

Nest navigators for complex apps: a `BottomTabs` navigator where each tab contains its own `NativeStack`.

### Navigating between screens

```tsx
// From any screen component:
navigation.navigate('Detail', { id: 123 });

// Go back:
navigation.goBack();

// Access params:
const { id } = route.params;
```

---

## 4. State Management

Same tools as web React work in RN: `useState`, `useReducer`, Context, Zustand, Redux.

**Mobile-specific concerns:**

**Background state loss** — when the OS kills your app (low memory), in-memory state is lost. If state must survive app restarts, persist it:
- [`react-native-mmkv`](https://github.com/mrousavy/react-native-mmkv) — fastest option; synchronous reads; good for Zustand middleware
- `AsyncStorage` — built-in async key-value store; slower but no native install

**Zustand + MMKV persistence:**
```ts
import { MMKV } from 'react-native-mmkv';
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

const storage = new MMKV();

export const useStore = create(
  persist(
    (set) => ({ user: null, setUser: (user) => set({ user }) }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => ({
        getItem: (key) => storage.getString(key) ?? null,
        setItem: (key, value) => storage.set(key, value),
        removeItem: (key) => storage.delete(key),
      })),
    }
  )
);
```

**AppState** — know when your app goes to background/foreground:
```ts
import { AppState } from 'react-native';

useEffect(() => {
  const sub = AppState.addEventListener('change', (state) => {
    if (state === 'active') { /* refresh data */ }
  });
  return () => sub.remove();
}, []);
```

---

## 5. Native Modules

Sometimes you need to access a device API that RN doesn't expose out of the box (Bluetooth, biometrics, NFC, custom camera behavior).

**Decision order:**
1. Check if RN core includes it (`Vibration`, `Alert`, `Linking`, `Camera` roll via `CameraRoll`)
2. Search [reactnative.directory](https://reactnative.directory) for a community module
3. Write your own only if nothing exists or existing modules are unmaintained

**How the bridge works (old architecture):**
JS ↔ serialized JSON ↔ native thread. Each call crosses the bridge asynchronously. Avoid rapid-fire bridge calls in animations — use `react-native-reanimated` instead (runs on the UI thread via JSI).

**New Architecture (JSI):** RN 0.74+ enables the new architecture by default. JSI lets JS hold direct references to native objects — no serialization, no async round-trip. Community modules are migrating; check `react-native.directory` for JSI support status.

---

## 6. Platform-Specific Code

**Inline check:**
```tsx
import { Platform } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 24,
  },
});
```

**Platform-specific files** — RN's bundler automatically picks the right one:
```
Button.ios.tsx      ← used on iOS
Button.android.tsx  ← used on Android
Button.tsx          ← fallback for both (or web if using react-native-web)
```

Use file suffixes for larger platform divergences; use `Platform.OS` inline for small differences.

---

## 7. Debugging

### Metro bundler
Metro is the JS bundler for RN (equivalent to webpack/Vite for web). It runs when you `run-ios` or `run-android`. If Metro gets stuck:
```bash
npx react-native start --reset-cache
```

### In-app developer menu
Shake the device (or `Cmd+D` in iOS Simulator, `Cmd+M` in Android Emulator) to open the dev menu. Enable "Fast Refresh" — saves you from manual reloads.

### React Native Debugger
Standalone app that combines Chrome DevTools + React DevTools + Redux DevTools. More reliable than the browser-based debugger for RN.

### Flipper
Desktop app for inspecting network requests, SQLite, AsyncStorage, React component tree, and performance. Connect via USB or simulator. Install the React Native Performance plugin for frame-rate monitoring.

### Native crash logs

**iOS:**
- Xcode → Window → Devices and Simulators → select device → View Device Logs
- Or check `~/Library/Logs/DiagnosticReports/` for symbolicated crash reports

**Android:**
```bash
adb logcat | grep -i "fatal\|error\|react"
```
For symbolicated Android stack traces: Android Studio → Analyze → Analyze Stack Trace.

---

## 8. Testing

```bash
npm install --save-dev @testing-library/react-native
```

**How RN testing differs from web:**
- No DOM — RN renders to native views, not HTML. `@testing-library/react-native` provides a virtual renderer that mirrors the component tree without a device.
- Native modules must be mocked — any module that calls native code (camera, storage, etc.) needs a Jest mock. Most popular libraries ship their own mocks.
- Animations don't run by default — use `jest.useFakeTimers()` or `act()` to flush animation frames in tests.

**Basic component test:**
```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';

test('button triggers callback', () => {
  const onPress = jest.fn();
  render(<MyButton onPress={onPress} label="Submit" />);
  fireEvent.press(screen.getByText('Submit'));
  expect(onPress).toHaveBeenCalledTimes(1);
});
```

**E2E with Detox** (for critical flows only — slow to run):
```bash
npm install detox --save-dev
detox init
detox build --configuration ios.sim.debug
detox test --configuration ios.sim.debug
```

---

## 9. Publishing

### iOS — App Store

**Step 1: Configure signing**
- Xcode → your target → Signing & Capabilities
- Team: select your Apple Developer account
- Bundle Identifier: must match what you registered in App Store Connect
- Provisioning Profile: let Xcode manage it automatically

**Step 2: Increment version**
- `ios/MyApp/Info.plist` → `CFBundleShortVersionString` (user-visible, e.g. `1.2.0`)
- `CFBundleVersion` (build number, increment for every upload, e.g. `42`)

**Step 3: Archive**
- Set the scheme to "Any iOS Device (arm64)" — not a simulator
- Product → Archive
- Xcode Organizer opens automatically when done

**Step 4: Upload**
- Organizer → Distribute App → App Store Connect → Upload
- Wait ~10 min for processing in App Store Connect

**Step 5: TestFlight**
- App Store Connect → your app → TestFlight → add internal/external testers
- External testers require a brief Apple review (~24h)

**Step 6: Submit for review**
- App Store Connect → your app → + Version → fill metadata → Submit for Review
- First submission: ~24–48h review. Updates: usually same day.

### Android — Google Play

**Step 1: Generate a signing keystore** (once per app, store it securely)
```bash
keytool -genkey -v -keystore my-release-key.keystore \
  -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```
Store this keystore outside the repo. If you lose it, you cannot update the app.

**Step 2: Configure signing in Gradle**
`android/app/build.gradle`:
```groovy
android {
  signingConfigs {
    release {
      storeFile file(MYAPP_RELEASE_STORE_FILE)
      storePassword MYAPP_RELEASE_STORE_PASSWORD
      keyAlias MYAPP_RELEASE_KEY_ALIAS
      keyPassword MYAPP_RELEASE_KEY_PASSWORD
    }
  }
  buildTypes {
    release { signingConfig signingConfigs.release }
  }
}
```
Store credentials in `~/.gradle/gradle.properties`, not in the repo.

**Step 3: Build the AAB** (preferred over APK for Play Store)
```bash
cd android
./gradlew bundleRelease
# Output: android/app/build/outputs/bundle/release/app-release.aab
```

**Step 4: Upload to Play Console**
- Play Console → your app → Release → Production (or Internal Testing first)
- Upload the `.aab` → fill release notes → Review release → Rollout

**First submission** requires a full review (~3–7 days). Updates typically review in a few hours.

---

## 10. Common Pitfalls

**Safe area insets**
The notch, Dynamic Island, and home indicator eat into your layout. Wrap screens in `<SafeAreaView>` from `react-native-safe-area-context` — not the built-in one, which doesn't handle all devices correctly.

**Keyboard avoiding**
The software keyboard slides over your content on both platforms. Use `KeyboardAvoidingView` with `behavior="padding"` (iOS) or `behavior="height"` (Android):
```tsx
<KeyboardAvoidingView
  behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
  style={{ flex: 1 }}
>
```

**Android back button**
Android has a hardware/gesture back button. RN's navigator handles it automatically within a stack, but you need `BackHandler` to intercept it for custom behavior (e.g., show a confirmation dialog before exiting):
```ts
useEffect(() => {
  const sub = BackHandler.addEventListener('hardwareBackPress', () => {
    showExitConfirmation();
    return true; // true = prevent default back action
  });
  return () => sub.remove();
}, []);
```

**Font scaling**
Users can increase system font size. RN scales fonts by default. If your layout breaks, add `allowFontScaling={false}` to specific `<Text>` components where it causes layout issues — but prefer designing layouts that accommodate scaling.

**Deep links**
Configure in `ios/AppDelegate.mm` and `android/app/src/main/AndroidManifest.xml`, then wire into React Navigation's linking config. Test with:
```bash
# iOS Simulator
xcrun simctl openurl booted "myapp://path/to/screen"
# Android
adb shell am start -W -a android.intent.action.VIEW -d "myapp://path/to/screen"
```
