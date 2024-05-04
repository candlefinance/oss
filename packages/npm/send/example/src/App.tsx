import * as React from 'react';

import { send } from '@candlefinance/send';
import { StyleSheet, Text, View } from 'react-native';

export const serializeError = (error: unknown) => {
  if (error instanceof Error) {
    return JSON.stringify({
      ...error,
      message: error.message,
      stack: error.stack ?? 'NOT_INCLUDED',
      name: error.name,
    });
  } else {
    return JSON.stringify(error);
  }
};

export default function App() {
  const [result, setResult] = React.useState<string>('waiting...');

  React.useEffect(() => {
    send({
      baseURL: 'https://itunes.apple.com',
      method: 'GET',
      path: '/lookup',
      queryParameters: {
        bundleId: 'com.trycandle.candle',
        country: 'US',
      },
      body: null,
      utf8ContentTypes: ['application/json', 'text/html', 'text/javascript'],
      headerParameters: {
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    })
      .then((response) => {
        console.log('SUCCESS', response);
        setResult(response.body ?? 'no body');
      })
      .catch((error) => {
        console.log('FAILURE', serializeError(error));
        setResult(`[${error.code}] ${error.message}`);
      });
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
