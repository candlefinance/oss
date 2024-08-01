# @candlefinance/prefs

Wraps UserDefaults (iOS) and SharedPreferences (Android) into a consistent interface for React Native.

## Installation

```sh
npm install @candlefinance/prefs
```

## Usage

This package is designed for usage with [Effect](https://effect.website), but also exposes a Promise-based interface that can be used in any React Native project.

To use `prefs` **with** Effect, import `@candlefinance/prefs`. Sample code is available in the [example app](example/src/App.tsx/).

To use `prefs` **without** Effect, import `@candlefinance/prefs/promises`. Sample code:

```ts
import { Effect, Option } from 'effect'
import { getPref, setPref, deletePref } from '@candlefinance/prefs/promises'

// SET A VALUE...
// Throws on unexpected errors
await setPref('themeColor', 'black')

// GET A VALUE...
// Returns `string | undefined`. Throws on unexpected errors.
const themeColor = getPref('themeColor')

// DELETE A VALUE...
// Throws on unexpected errors
await deletePref('themeColor')
```

> **Important Notes**
>
> - SharedPreferences on Android does not expose a default app-wide instance (like UserDefaults on iOS). To a) access prefs saved using this library from native Android code, or b) write prefs from native Android code and then access them using this library, initialize SharedPreferences in your native Android code with the file name `com.candlefinance.prefs`.
> - Both SharedPreferences and UserDefaults support saving various data types including strings, arrays, and numbers. This library only supports saving and retrieving string values. If you attempt to retrieve a non-string value set in native Android code, this library will return an error with the code `@candlefinance.prefs.non_string_value`.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
