import { type HybridObject } from 'react-native-nitro-modules'

export type Method =
  | 'GET'
  | 'POST'
  | 'PUT'
  | 'DELETE'
  | 'PATCH'
  | 'HEAD'
  | 'OPTIONS'
  | 'CONNECT'
  | 'TRACE'

export interface Request {
  baseURL: string
  path: string
  queryParameters: Record<string, string>
  headerParameters: Record<string, string>
  method: Method
  body: string | null
  utf8ContentTypes: string[]
}

export interface Response {
  statusCode: number
  headerParameters: Record<string, string>
  body: string | null
}

export interface Send extends HybridObject<{ ios: 'swift' }> {
  send(request: Request): Promise<Response>
}
