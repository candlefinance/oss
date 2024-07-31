import 'fast-text-encoding'

import { deletePref, getPref, setPref } from '@candlefinance/prefs'
import { Effect, Option, pipe } from 'effect'
import * as React from 'react'
import { StyleSheet, Text, View } from 'react-native'

export default function App() {
  const [summary, setSummary] = React.useState('Loading...')

  React.useEffect(() => {
    const formatResponse = (response: Option.Option<string>) =>
      Option.getOrElse(response, () => '<unset>')
    void Effect.runPromise(
      pipe(
        // GET PREF
        getPref('themeColor'),
        Effect.tap((response) =>
          setSummary('BEFORE SETTING: ' + formatResponse(response))
        ),

        // SET PREF
        Effect.tap(() => Effect.sleep('2 seconds')),
        Effect.tap(() => setPref('themeColor', 'black')),
        Effect.flatMap(() => getPref('themeColor')),
        Effect.tap((response) =>
          setSummary('AFTER SETTING: ' + formatResponse(response))
        ),

        // DELETE PREF
        Effect.tap(() => Effect.sleep('2 seconds')),
        Effect.tap(() => deletePref('themeColor')),
        Effect.flatMap(() => getPref('themeColor')),
        Effect.tap((response) =>
          setSummary('AFTER DELETING: ' + formatResponse(response))
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
