import * as React from 'react';

import {
  clear,
  read,
  readAsync,
  remove,
  removeAsync,
  write,
  writeAsync,
} from '@candlefinance/cache';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';

const benchmark = () => {
  const start = Date.now();
  for (let i = 0; i < 10000; i++) {
    write(`key${i}`, `value${i}`);
  }
  const end = Date.now();
  console.log('write', end - start);

  const start2 = Date.now();
  for (let i = 0; i < 10000; i++) {
    read(`key${i}`);
  }
  const end2 = Date.now();
  console.log('read', end2 - start2);

  const start3 = Date.now();
  for (let i = 0; i < 10000; i++) {
    remove(`key${i}`);
  }
  const end3 = Date.now();
  console.log('remove', end3 - start3);
};

const benchmarkAsync = async () => {
  const start = Date.now();
  for (let i = 0; i < 10000; i++) {
    await writeAsync(`key${i}`, `value${i}`);
  }
  const end = Date.now();
  console.log('write', end - start);

  const start2 = Date.now();
  for (let i = 0; i < 10000; i++) {
    await readAsync(`key${i}`);
  }
  const end2 = Date.now();
  console.log('read', end2 - start2);

  const start3 = Date.now();
  for (let i = 0; i < 10000; i++) {
    await removeAsync(`key${i}`);
  }
  const end3 = Date.now();
  console.log('remove', end3 - start3);
};

export default function App() {
  const [cacheValue, setCacheValue] = React.useState<string>('yoo');

  return (
    <View style={styles.container}>
      <View style={{ height: 30 }} />
      <Text>{cacheValue}</Text>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={() => {
          console.log('write');
          write('key', 'Hello World');
        }}
      >
        <Text>Write</Text>
      </TouchableOpacity>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={() => {
          try {
            const value = read('key');
            console.log('read', value);
            if (value !== undefined) {
              setCacheValue(value);
            } else {
              setCacheValue('empty');
            }
          } catch {
            setCacheValue('empty');
          }
        }}
      >
        <Text>Read</Text>
      </TouchableOpacity>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={() => {
          remove('key');
          console.log('remove');
        }}
      >
        <Text>Remove</Text>
      </TouchableOpacity>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={async () => {
          clear();
          console.log('clear');
        }}
      >
        <Text>clear</Text>
      </TouchableOpacity>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={() => {
          console.log('benchmark sync read/write/delete 10000 times');
          benchmark();
        }}
      >
        <Text>benchmark sync</Text>
      </TouchableOpacity>
      <View style={{ height: 30 }} />
      <TouchableOpacity
        onPress={() => {
          console.log('benchmark async read/write/delete 10000 times');
          benchmarkAsync();
        }}
      >
        <Text>benchmark async </Text>
      </TouchableOpacity>
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
