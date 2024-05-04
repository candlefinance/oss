import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { send } from '@candlefinance/send';

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
  const [result, setResult] = React.useState<string | undefined>();

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
      utf8ContentTypes: ['text/javascript'],
      headerParameters: {
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    })
      .then((response) => {
        console.log('SUCCESS', response);
        setResult(response.body ?? undefined);
      })
      .catch((error) => {
        console.log('FAILURE', serializeError(error));
        setResult(serializeError(error));
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
