# @candlefinance/prefs

Wraps UserDefaults (iOS) and SharedPreferences (Android) into a consistent interface for React Native.

## Installation

```sh
npm install @candlefinance/prefs
```

## Usage

This package is optimized for usage with [Effect](https://effect.website), but can also be used in any React Native project.

To use `prefs` **with** Effect, check out the [example app](example/src/App.tsx/).

To use `prefs` **without** Effect, you can use the following bridging functions:

```ts
import { Effect, Option } from 'effect'
import { getPref, setPref, deletePref } from '@candlefinance/prefs'

// SET A VALUE...
// Throws on unexpected errors
await Effect.runPromise(setPref('themeColor', 'black'))

// GET A VALUE...
// Returns `string | undefined`. Throws on unexpected errors.
const themeColor = Option.getOrUndefined(
  await Effect.runPromise(getPref('themeColor'))
)

// DELETE A VALUE...
// Throws on unexpected errors
await Effect.runPromise(deletePref('themeColor'))
```

> **Important Note:** To access prefs saved using this library from native Android code (or to write prefs from native Android code and then access them using this library), initialize SharedPreferences in your native Android code with the file name `com.candlefinance.prefs`.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
