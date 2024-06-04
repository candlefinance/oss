import { NativeModules, Platform } from 'react-native'

const LINKING_ERROR =
  `The package '@candlefinance/send' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n'

const Send = NativeModules.Send
  ? NativeModules.Send
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR)
        },
      }
    )

export type Request = {
  baseURL: string
  path: string
  queryParameters: Record<string, string>
  headerParameters: Record<string, string>
  method:
    | 'GET'
    | 'POST'
    | 'PUT'
    | 'DELETE'
    | 'PATCH'
    | 'HEAD'
    | 'OPTIONS'
    | 'CONNECT'
    | 'TRACE'
  body: string | null
  utf8ContentTypes: string[]
}

export type Response = {
  statusCode: number
  headerParameters: Record<string, string>
  body: string | null
}

export async function send(request: Request): Promise<Response> {
  // NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code
  const stringifiedRequest = JSON.stringify(request)
  const stringifiedResponse = await Send.send(stringifiedRequest)
  return JSON.parse(stringifiedResponse)
}
