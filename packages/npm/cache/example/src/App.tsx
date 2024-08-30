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
import { Button, StyleSheet, Text, View } from 'react-native';
import { MMKV } from 'react-native-mmkv';

export const storage = new MMKV();

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

const benchmarkMMKV = () => {
  const start = Date.now();
  for (let i = 0; i < 10000; i++) {
    storage.set(`key${i}`, `value${i}`);
  }
  const end = Date.now();
  console.log('write', end - start);

  const start2 = Date.now();
  for (let i = 0; i < 10000; i++) {
    storage.getString(`key${i}`);
  }
  const end2 = Date.now();
  console.log('read', end2 - start2);

  const start3 = Date.now();
  for (let i = 0; i < 10000; i++) {
    storage.delete(`key${i}`);
  }
  const end3 = Date.now();
  console.log('remove', end3 - start3);
};

export default function App() {
  const [cacheValue, setCacheValue] = React.useState<string>('yoo');

  return (
    <View style={styles.container}>
      <Text>{cacheValue}</Text>
      <Button
        title="Write"
        onPress={() => {
          console.log('write');
          write('key', Date.now().toString());
        }}
      />
      <Button
        title="Read"
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
      />
      <Button
        title="Remove"
        onPress={() => {
          remove('key');
          console.log('remove');
        }}
      />
      <Button
        title="Clear"
        onPress={async () => {
          await clear();
          console.log('clear');
        }}
      />
      <Button
        title="Benchmark Sync"
        onPress={() => {
          console.log('benchmark sync read/write/delete 10000 times');
          benchmark();
        }}
      />
      <Button
        title="Benchmark Async"
        onPress={() => {
          console.log('benchmark async read/write/delete 10000 times');
          benchmarkAsync();
        }}
      />
      <Button
        title="Benchmark MMKV"
        onPress={() => {
          console.log('benchmark MMKV read/write/delete 10000 times');
          benchmarkMMKV();
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
