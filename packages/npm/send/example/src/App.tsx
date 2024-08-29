import { send } from '@candlefinance/send'
import React, { useState } from 'react'
import {
  Image,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native'

const serializeError = (error: unknown) => {
  console.log('SERIALIZING ERROR', error, error instanceof Error)
  if (error instanceof Error) {
    return JSON.stringify({
      ...error,
      message: error.message,
      stack: error.stack ?? 'NOT_INCLUDED',
      name: error.name,
    })
  } else {
    return JSON.stringify(error)
  }
}

const App = () => {
  const [data, setData] = useState<{
    trackName: string
    artistName: string
    artworkUrl100: string
    description: string
    version: string
    screenshotUrls: string[]
  } | null>()

  React.useEffect(() => {
    send({
      baseURL: 'https://itunes.apple.com',
      method: 'GET',
      path: '/lookup',
      query: {
        parameters: {
          bundleId: 'com.trycandle.candle',
          country: 'US',
        },
      },
      body: null,
      utf8ContentTypes: ['application/json', 'text/html', 'text/javascript'],
      header: {
        parameters: {
          'Cache-Control': 'no-cache',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      },
    }).then((result) => {
      if (result.error) {
        console.log('ERROR', serializeError(result.error))
      } else {
        setData(JSON.parse(result.response?.body as any).results[0])
      }
    })
  }, [])

  if (!data) {
    return (
      <View style={styles.container}>
        <Text>Loading...</Text>
      </View>
    )
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.title}>{data.trackName}</Text>
        <Text style={styles.artist}>{data.artistName}</Text>
        <Text style={styles.description}>v{data.version}</Text>
        <Image source={{ uri: data.artworkUrl100 }} style={styles.icon} />
        <Text style={styles.description}>
          {data.description.slice(0, 299)}...
        </Text>
        <ScrollView horizontal>
          {data.screenshotUrls.map((url, index) => (
            <Image
              key={index}
              source={{ uri: url }}
              style={styles.screenshot}
            />
          ))}
        </ScrollView>
      </ScrollView>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  artist: {
    fontSize: 18,
    marginBottom: 8,
  },
  icon: {
    borderRadius: 24,
    borderCurve: 'continuous',
    width: 100,
    height: 100,
    marginBottom: 16,
  },
  description: {
    fontSize: 16,
    marginBottom: 16,
  },
  screenshot: {
    borderRadius: 24,
    borderCurve: 'continuous',
    width: 200,
    height: 400,
    marginRight: 8,
  },
})

export default App
