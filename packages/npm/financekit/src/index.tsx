import { Schema as S } from '@effect/schema'
import { Effect as E, Option as O, flow, pipe } from 'effect'
import { NativeModules, Platform } from 'react-native'
import {
  discriminateA,
  oLiftRefinement,
  type Discriminated,
} from './discrimination_utils'

const LINKING_ERROR =
  `The package '@candlefinance/financekit' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n'

const financekitNativeModule: Record<
  'requestAuthorization' | 'authorizationStatus',
  () => Promise<string>
> &
  Record<
    | 'transactions'
    | 'transactionHistory'
    | 'accounts'
    | 'accountHistory'
    | 'accountBalances'
    | 'accountBalanceHistory',
    (stringParam: string) => Promise<string>
  > = NativeModules.Financekit
  ? NativeModules.Financekit
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR)
        },
      }
    )

const AuthorizationStatus = S.Literal('authorized', 'denied', 'notDetermined')

const Query = S.Struct({
  limit: S.OptionFromUndefinedOr(S.Int),
  offset: S.OptionFromUndefinedOr(S.Int),
})

// TODO: Convert to and from S.String to ensure these don't break in the future. Applies to all enums
enum CreditDebitIndicator {
  credit,
  debit,
}

enum TransactionType {
  unknown,
  adjustment,
  atm,
  billPayment,
  check,
  deposit,
  directDeposit,
  dividend,
  fee,
  interest,
  pointOfSale,
  transfer,
  withdrawal,
  standingOrder,
  directDebit,
  loan,
  refund,
}

enum TransactionStatus {
  authorized,
  memo,
  pending,
  booked,
  rejected,
}

const CurrencyAmount = S.Struct({
  amount: S.NumberFromString,
  currencyCode: S.String,
})

const Transaction = S.Struct({
  id: S.UUID,
  accountId: S.UUID,
  transactionAmount: CurrencyAmount,
  foreignCurrencyAmount: S.OptionFromUndefinedOr(CurrencyAmount),
  creditDebitIndicator: S.Enums(CreditDebitIndicator),
  transactionDescription: S.String,
  originalTransactionDescription: S.String,
  merchantCategoryCode: S.OptionFromUndefinedOr(S.Int),
  merchantName: S.OptionFromUndefinedOr(S.String),
  transactionType: S.Enums(TransactionType),
  status: S.Enums(TransactionStatus),
  // FIXME: Replace with Luxon DateTime
  transactionDate: S.DateFromString,
  postedDate: S.OptionFromUndefinedOr(S.DateFromString),
})

const AccountHistoryParams = S.Struct({
  token: S.OptionFromUndefinedOr(S.String),
  isMonitoring: S.OptionFromUndefinedOr(S.Boolean),
})

const AccountDetailsHistoryParams = AccountHistoryParams.pipe(
  S.extend(
    S.Struct({
      accountId: S.UUID,
    })
  )
)

const AccountCreditInformation = S.Struct({
  creditLimit: S.OptionFromUndefinedOr(CurrencyAmount),
  nextPaymentDueDate: S.OptionFromUndefinedOr(S.DateFromString),
  minimumNextPaymentAmount: S.OptionFromUndefinedOr(CurrencyAmount),
  overduePaymentAmount: S.OptionFromUndefinedOr(CurrencyAmount),
})

const Account = S.Struct({
  id: S.UUID,
  displayName: S.String,
  accountDescription: S.OptionFromUndefinedOr(S.String),
  institutionName: S.String,
  currencyCode: S.String,
}).pipe(
  S.extend(
    S.Union(
      S.TaggedStruct('asset', {}),
      S.TaggedStruct('liability', {
        creditInformation: AccountCreditInformation,
      })
    )
  )
)

const Balance = S.Struct({
  amount: CurrencyAmount,
  asOfDate: S.DateFromString,
  creditDebitIndicator: S.Enums(CreditDebitIndicator),
})

const CurrentBalance = S.Union(
  S.TaggedStruct('available', {
    available: Balance,
  }),
  S.TaggedStruct('booked', {
    booked: Balance,
  }),
  S.TaggedStruct('availableAndBooked', {
    available: Balance,
    booked: Balance,
  })
)

const AccountBalance = S.Struct({
  id: S.UUID,
  accountID: S.UUID,
  currentBalance: CurrentBalance,
})

class FinancekitError extends S.TaggedError<FinancekitError>()(
  'FinancekitError',
  {
    code: S.Literal(
      '@candlefinance.financekit.account_balances_invalid',
      '@candlefinance.financekit.account_balance_history_invalid',
      '@candlefinance.financekit.accounts_invalid',
      '@candlefinance.financekit.os_version_too_low',
      '@candlefinance.financekit.params_invalid',
      '@candlefinance.financekit.query_invalid',
      '@candlefinance.financekit.transaction_history_invalid',
      '@candlefinance.financekit.transactions_invalid',
      '@candlefinance.financekit.unknown',
      '@candlefinance.financekit.unknown_account_type',
      '@candlefinance.financekit.unknown_authorization_status',
      '@candlefinance.financekit.unknown_current_balance_type',
      '@candlefinance.financekit.unknown_parsing_error'
    ),
    backingError: S.Any,
  }
) {}

const makeError = <CODE extends String & FinancekitError['code']>(
  error: any,
  code: CODE
): Discriminated<FinancekitError, 'code', CODE> =>
  new FinancekitError({
    code: code,
    backingError: error,
    // TODO: Can this be done without a hard cast?
  }) as Discriminated<FinancekitError, 'code', CODE>

export function requestAuthorization(): E.Effect<
  typeof AuthorizationStatus.Type,
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_authorization_status'
    | '@candlefinance.financekit.unknown_parsing_error'
  >
> {
  return pipe(
    E.tryPromise({
      try: financekitNativeModule.requestAuthorization,
      catch: (error) =>
        pipe(
          error,
          S.decodeUnknownOption(FinancekitError),
          O.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.financekit.os_version_too_low',
                '@candlefinance.financekit.unknown',
                '@candlefinance.financekit.unknown_authorization_status',
              ])
            )
          ),
          O.getOrElse(() =>
            makeError(error, '@candlefinance.financekit.unknown_parsing_error')
          )
        ),
    }),
    E.flatMap(
      flow(
        S.decode(S.parseJson(AuthorizationStatus)),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function authorizationStatus(): E.Effect<
  typeof AuthorizationStatus.Type,
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown_authorization_status'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
  >
> {
  return pipe(
    E.tryPromise({
      try: financekitNativeModule.authorizationStatus,
      catch: (error) =>
        pipe(
          error,
          S.decodeUnknownOption(FinancekitError),
          O.flatMap(
            oLiftRefinement(
              discriminateA('code', [
                '@candlefinance.financekit.unknown_authorization_status',
                '@candlefinance.financekit.os_version_too_low',
                '@candlefinance.financekit.unknown',
              ])
            )
          ),
          O.getOrElse(() =>
            makeError(error, '@candlefinance.financekit.unknown_parsing_error')
          )
        ),
    }),
    E.flatMap(
      flow(
        S.decode(S.parseJson(AuthorizationStatus)),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

// NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code
export function transactions(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof Transaction.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.transactions_invalid'
  >
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.query_invalid')
    ),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.transactions(stringifiedQuery),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.transactions_invalid',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function transactionHistory(
  params: typeof AccountDetailsHistoryParams.Type
): E.Effect<
  readonly (typeof Transaction.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.transaction_history_invalid'
  >
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountDetailsHistoryParams)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.params_invalid')
    ),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () => financekitNativeModule.transactionHistory(stringifiedParams),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.transaction_history_invalid',
                  '@candlefinance.financekit.unknown',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function accounts(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof Account.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.unknown_account_type'
    | '@candlefinance.financekit.accounts_invalid'
  >
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.query_invalid')
    ),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.accounts(stringifiedQuery),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.accounts_invalid',
                  '@candlefinance.financekit.unknown_account_type',
                  '@candlefinance.financekit.unknown',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function accountHistory(
  params: typeof AccountHistoryParams.Type
): E.Effect<
  readonly (typeof Account.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.transaction_history_invalid'
    | '@candlefinance.financekit.unknown_account_type'
  >
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountHistoryParams)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.params_invalid')
    ),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () => financekitNativeModule.accountHistory(stringifiedParams),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.transaction_history_invalid',
                  '@candlefinance.financekit.unknown_account_type',
                  '@candlefinance.financekit.unknown',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function accountBalances(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof AccountBalance.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.account_balances_invalid'
    | '@candlefinance.financekit.unknown_current_balance_type'
  >
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.query_invalid')
    ),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.accountBalances(stringifiedQuery),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.account_balances_invalid',
                  '@candlefinance.financekit.unknown_current_balance_type',
                  '@candlefinance.financekit.unknown',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(AccountBalance))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}

export function accountBalanceHistory(
  params: typeof AccountDetailsHistoryParams.Type
): E.Effect<
  readonly (typeof AccountBalance.Type)[],
  Discriminated<
    FinancekitError,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_parsing_error'
    | '@candlefinance.financekit.account_balance_history_invalid'
    | '@candlefinance.financekit.unknown_current_balance_type'
  >
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountDetailsHistoryParams)),
    E.mapError((error) =>
      makeError(error, '@candlefinance.financekit.params_invalid')
    ),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () =>
          financekitNativeModule.accountBalanceHistory(stringifiedParams),
        catch: (error) =>
          pipe(
            error,
            S.decodeUnknownOption(FinancekitError),
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.account_balance_history_invalid',
                  '@candlefinance.financekit.unknown_current_balance_type',
                  '@candlefinance.financekit.unknown',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_parsing_error'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.parseJson(S.Array(AccountBalance)))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_parsing_error')
        )
      )
    )
  )
}
