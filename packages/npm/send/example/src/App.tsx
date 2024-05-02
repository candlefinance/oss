import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { send } from '@candlefinance/send';

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
      utf8ContentTypes: ['text/javascript'],
      headerParameters: {
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    }).then(({ body }) => setResult(body ?? 'NULL'));
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
