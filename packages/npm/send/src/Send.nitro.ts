import { type HybridObject } from 'react-native-nitro-modules'

interface Parameters {
  parameters: Record<string, string>
}

export interface Request {
  baseURL: string
  path: string
  query: Parameters
  header: Parameters
  method: string
  body: string | null
  utf8ContentTypes: string[]
}

export interface Response {
  statusCode: number
  header: Parameters
  body: string | null
}

export interface Send extends HybridObject<{ ios: 'swift' }> {
  send(request: Request): Promise<Response>
}
