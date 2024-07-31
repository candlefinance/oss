import 'fast-text-encoding'

import { deletePref, getPref, setPref } from '@candlefinance/prefs'
import { Effect as E } from 'effect'
import * as React from 'react'
import { StyleSheet, Text, View } from 'react-native'

export default function App() {
  const [summary, setSummary] = React.useState('Loading...')

  React.useEffect(() => {
    void E.runPromise(
      E.Do.pipe(
        E.tap(() =>
          getPref('foo').pipe(
            E.tap((response) => setSummary('BEFORE SETTING: ' + response))
          )
        ),
        E.tap(() => E.sleep('2 seconds')),
        E.tap(() => setPref('foo', 'bar')),
        E.tap(() =>
          getPref('foo').pipe(
            E.tap((response) => setSummary('AFTER SETTING: ' + response))
          )
        ),
        E.tap(() => E.sleep('2 seconds')),
        E.tap(() => deletePref('foo')),
        E.tap(() =>
          getPref('foo').pipe(
            E.tap((response) => setSummary('AFTER DELETING: ' + response))
          )
        )
      )
    )
  }, [])

  return (
    <View style={styles.container}>
      <Text>{summary}</Text>
    </View>
  )
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
})
