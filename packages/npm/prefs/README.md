<br/>
<div align="center">
  <a href="https://www.npmjs.com/package/@candlefinance/prefs">
  <img src="https://img.shields.io/npm/dm/@candlefinance/prefs" alt="npm downloads" />
</a>
  <a alt="discord users online" href="https://discord.gg/qnAgjxhg6n" 
  target="_blank"
  rel="noopener noreferrer">
    <img alt="discord users online" src="https://img.shields.io/discord/986610142768406548?label=Discord&logo=discord&logoColor=white&cacheSeconds=3600"/>
</div>
<br/>
<h1 align="center">
   Prefs
</h1>

Wraps UserDefaults (iOS) and SharedPreferences (Android) into a consistent interface for React Native.

## Installation

To install `prefs` with **npm**:

```sh
npm install @candlefinance/prefs
```

To install `prefs` with **yarn**:

```sh
yarn add @candlefinance/prefs
```

## Usage

This package is designed for usage with [Effect](https://effect.website), but also exposes a Promise-based interface that can be used in any React Native project.

To use `prefs` **with** Effect, check out the [example app](example/src/App.tsx/):

```ts
import { getPref, setPref, deletePref } from '@candlefinance/prefs'
```

To use `prefs` **without** Effect (functions throw a `PrefError` on unexpected issues):

```ts
import { getPref, setPref, deletePref } from '@candlefinance/prefs/promises'

await setPref('themeColor', 'black')

// string | undefined
const themeColor = await getPref('themeColor')

await deletePref('themeColor')
```

### Important Notes

- Effect requires that `TextEncoder`/`TextDecoder` be defined at runtime. If you don't already have a polyfill, we recommend installing [fast-text-encoding](https://github.com/samthor/fast-text-encoding) using NPM or Yarn and adding `import 'fast-text-encoding'` at the top of your app's `index.js` file.
- SharedPreferences on Android does not expose a default app-wide instance (like UserDefaults on iOS). To a) access prefs saved using this library from native Android code, or b) write prefs from native Android code and then access them using this library, [initialize SharedPreferences](https://developer.android.com/training/data-storage/shared-preferences) in your native Android code with the file name `com.candlefinance.prefs`.

- Both SharedPreferences and UserDefaults support saving various data types including strings, arrays, and numbers. This library only supports saving and retrieving string values. If you attempt to retrieve a non-string value set via native code, this library will return a PrefError with the code `@candlefinance.prefs.non_string_value`.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
