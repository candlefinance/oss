<br/>
<div align="center">
  <a href="https://www.npmjs.com/package/@candlefinance/send">
  <img src="https://img.shields.io/npm/dm/@candlefinance/send" alt="npm downloads" />
</a>
  <a alt="discord users online" href="https://discord.gg/qnAgjxhg6n" 
  target="_blank"
  rel="noopener noreferrer">
    <img alt="discord users online" src="https://img.shields.io/discord/986610142768406548?label=Discord&logo=discord&logoColor=white&cacheSeconds=3600"/>
</div>
<br/>
<h1 align="center">
   Send
</h1>

Uses URLSession on iOS and OkHttp on Android to provide a fast, low-level networking layer for React Native.

## Installation

To install `send` with **npm**:

```sh
npm install @candlefinance/send
```

To install `send` with **yarn**:

```sh
yarn add @candlefinance/send
```

## Usage

```js
import { send } from '@candlefinance/send'

const response = await send({
  baseURL: 'https://itunes.apple.com',
  method: 'GET',
  path: '/lookup',
  queryParameters: {
    bundleId: 'com.trycandle.candle',
    country: 'US',
  },
  body: null,
  utf8ContentTypes: ['text/javascript'],
  headerParameters: {
    'Cache-Control': 'no-cache',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
})
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
