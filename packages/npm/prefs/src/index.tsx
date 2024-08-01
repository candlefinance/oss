import { Schema } from '@effect/schema'
import { Effect, Either, Option, pipe } from 'effect'
import { NativeModules, Platform } from 'react-native'
import { discriminateA, oLiftRefinement, type Discriminated } from './utils'

const LINKING_ERROR =
  `The package '@candlefinance/prefs' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n'

// FIXME: Return LINKING_ERROR through normal error channel instead of using Proxy
const prefsNativeModule: {
  getPref: (key: string) => Promise<string | null>
  setPref: (key: string, value: string) => Promise<null>
  deletePref: (key: string) => Promise<null>
} = NativeModules.Prefs
  ? NativeModules.Prefs
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR)
        },
      }
    )

export const S_CNDL_UUID = Schema.UUID.pipe(Schema.brand('CNDL_UUID'))
export const S_CNDL_Int = Schema.Int.pipe(Schema.brand('CNDL_Int'))

export class PrefsError extends Schema.Class<PrefsError>('PrefsError')({
  userInfo: Schema.OptionFromNullOr(Schema.Any),
  nativeStackAndroid: Schema.OptionFromUndefinedOr(
    Schema.Array(
      Schema.Struct({
        lineNumber: S_CNDL_Int,
        file: Schema.String,
        methodName: Schema.String,
        class: Schema.String,
      })
    )
  ),
  nativeStackIOS: Schema.OptionFromUndefinedOr(Schema.Array(Schema.String)),
  domain: Schema.OptionFromUndefinedOr(Schema.String),
  message: Schema.String,
  code: Schema.Literal(
    '@candlefinance.prefs.write_failed',
    '@candlefinance.prefs.non_string_value',
    '@candlefinance.prefs.unexpected',
    '@candlefinance.prefs.unknown_error_response_schema'
  ),
}) {}

const makeError = <Code extends String & PrefsError['code']>(
  error: unknown,
  code: Code
): Discriminated<PrefsError, 'code', Code> =>
  PrefsError.make({
    code: code,
    userInfo: Option.none(),
    message: `${error}`,
    nativeStackAndroid: Option.none(),
    nativeStackIOS: Option.none(),
    domain: Option.none(),
  }) as Discriminated<PrefsError, 'code', Code>

// NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code
// FIXME: Also validate that output is a string?
export const getPref = (
  key: string
): Effect.Effect<
  Option.Option<string>,
  Discriminated<
    PrefsError,
    'code',
    | '@candlefinance.prefs.unexpected'
    | '@candlefinance.prefs.non_string_value'
    | '@candlefinance.prefs.unknown_error_response_schema'
  >
> =>
  pipe(
    Effect.tryPromise({
      try: () => prefsNativeModule.getPref(key),
      catch: (error) =>
        pipe(
          error,
          Schema.decodeUnknownEither(PrefsError),
          Either.getRight,
          Option.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.prefs.unexpected',
                '@candlefinance.prefs.non_string_value',
              ])
            )
          ),
          Option.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    }),
    Effect.map(Option.fromNullable)
  )

export const setPref = (
  key: string,
  value: string
): Effect.Effect<void, PrefsError> =>
  pipe(
    Effect.tryPromise({
      try: () => prefsNativeModule.setPref(key, value),
      catch: (error) =>
        pipe(
          error,
          Schema.decodeUnknownEither(PrefsError),
          Either.getRight,
          Option.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.prefs.unexpected',
                '@candlefinance.prefs.write_failed',
              ])
            )
          ),
          Option.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    })
  )

export const deletePref = (key: string): Effect.Effect<void, PrefsError> =>
  pipe(
    Effect.tryPromise({
      try: () => prefsNativeModule.deletePref(key),
      catch: (error) =>
        pipe(
          error,
          Schema.decodeUnknownEither(PrefsError),
          Either.getRight,
          Option.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.prefs.unexpected',
                '@candlefinance.prefs.write_failed',
              ])
            )
          ),
          Option.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    })
  )
