import * as prefs from '.'
import { Effect, Option, Either, identity } from 'effect'

export const getPref = (key: string): Promise<string | undefined> =>
  prefs
    .getPref(key)
    .pipe(
      Effect.map(Option.getOrUndefined),
      Effect.either,
      Effect.map(Either.getOrThrowWith(identity)),
      Effect.runPromise
    )

export const setPref = (key: string, value: string): Promise<void> =>
  prefs
    .setPref(key, value)
    .pipe(
      Effect.either,
      Effect.map(Either.getOrThrowWith(identity)),
      Effect.runPromise
    )

export const deletePref = (key: string): Promise<void> =>
  prefs
    .deletePref(key)
    .pipe(
      Effect.either,
      Effect.map(Either.getOrThrowWith(identity)),
      Effect.runPromise
    )
