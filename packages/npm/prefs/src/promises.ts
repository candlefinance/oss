import * as prefs from '.'
import { Effect as E, Option as O } from 'effect'

export const getPref = (key: string): Promise<string | undefined> =>
  E.runPromise(prefs.getPref(key).pipe(E.map(O.getOrUndefined)))

export const setPref = (key: string, value: string): Promise<void> =>
  E.runPromise(prefs.setPref(key, value))

export const deletePref = (key: string): Promise<void> =>
  E.runPromise(prefs.deletePref(key))
