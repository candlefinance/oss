import { NitroModules } from 'react-native-nitro-modules'
import type { Send } from './Send.nitro'
export * from './Send.nitro'

const Send = NitroModules.createHybridObject<Send>('Send')

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
  const stringifiedRequest = JSON.stringify(request)
  const stringifiedResponse = await Send.send(stringifiedRequest)
  return JSON.parse(stringifiedResponse)
}
