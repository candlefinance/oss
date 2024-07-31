import { Schema as S } from '@effect/schema'
import { Effect as E, Either, Option as O, pipe } from 'effect'
import { NativeModules, Platform } from 'react-native'
import { discriminateA, oLiftRefinement, type Discriminated } from './utils'

const LINKING_ERROR =
  `The package '@candlefinance/prefs' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n'

// FIXME: Return LINKING_ERROR through normal error channel instead of using Proxy
const prefsNativeModule: {
  getPref: (key: string) => Promise<string>
  setPref: (key: string, value: string) => Promise<void>
  deletePref: (key: string) => Promise<void>
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

export const S_CNDL_UUID = S.UUID.pipe(S.brand('CNDL_UUID'))
export const S_CNDL_Int = S.Int.pipe(S.brand('CNDL_Int'))

export const PrefsError = S.Struct({
  userInfo: S.OptionFromNullOr(S.Any),
  nativeStackAndroid: S.OptionFromUndefinedOr(
    S.Array(
      S.Struct({
        lineNumber: S_CNDL_Int,
        file: S.String,
        methodName: S.String,
        class: S.String,
      })
    )
  ),
  nativeStackIOS: S.OptionFromUndefinedOr(S.Array(S.String)),
  domain: S.OptionFromUndefinedOr(S.String),
  message: S.String,
  code: S.Literal(
    '@candlefinance.prefs.key_not_found',
    '@candlefinance.prefs.unknown',
    '@candlefinance.prefs.unknown_error_response_schema'
  ),
})

const makeError = <Code extends String & (typeof PrefsError.Type)['code']>(
  error: unknown,
  code: Code
): Discriminated<typeof PrefsError.Type, 'code', Code> =>
  PrefsError.make({
    code: code,
    userInfo: O.none(),
    message: `${error}`,
    nativeStackAndroid: O.none(),
    nativeStackIOS: O.none(),
    domain: O.none(),
  }) as Discriminated<typeof PrefsError.Type, 'code', Code>

// NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code
// FIXME: Also validate that output is a string?
export const getPref = (
  key: string
): E.Effect<
  string,
  Discriminated<
    typeof PrefsError.Type,
    'code',
    | '@candlefinance.prefs.key_not_found'
    | '@candlefinance.prefs.unknown'
    | '@candlefinance.prefs.unknown_error_response_schema'
  >
> =>
  pipe(
    E.tryPromise({
      try: () => prefsNativeModule.getPref(key),
      catch: (error) =>
        pipe(
          error,
          S.decodeUnknownEither(PrefsError),
          Either.getRight,
          O.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.prefs.key_not_found',
                '@candlefinance.prefs.unknown',
              ])
            )
          ),
          O.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    })
  )

export const setPref = (
  key: string,
  value: string
): E.Effect<
  void,
  Discriminated<
    typeof PrefsError.Type,
    'code',
    | '@candlefinance.prefs.unknown'
    | '@candlefinance.prefs.unknown_error_response_schema'
  >
> =>
  pipe(
    E.tryPromise({
      try: () => prefsNativeModule.setPref(key, value),
      catch: (error) =>
        pipe(
          error,
          S.decodeUnknownEither(PrefsError),
          Either.getRight,
          O.flatMap(
            oLiftRefinement(
              discriminateA('code', ['@candlefinance.prefs.unknown'])
            )
          ),
          O.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    })
  )

export const deletePref = (
  key: string
): E.Effect<
  void,
  Discriminated<
    typeof PrefsError.Type,
    'code',
    | '@candlefinance.prefs.key_not_found'
    | '@candlefinance.prefs.unknown'
    | '@candlefinance.prefs.unknown_error_response_schema'
  >
> =>
  pipe(
    E.tryPromise({
      try: () => prefsNativeModule.deletePref(key),
      catch: (error) =>
        pipe(
          error,
          S.decodeUnknownEither(PrefsError),
          Either.getRight,
          O.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.prefs.unknown',
                '@candlefinance.prefs.key_not_found',
              ])
            )
          ),
          O.getOrElse(() =>
            makeError(
              error,
              '@candlefinance.prefs.unknown_error_response_schema'
            )
          )
        ),
    })
  )
