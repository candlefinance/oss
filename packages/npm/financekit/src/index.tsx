import { Schema as S } from '@effect/schema'
import { Effect as E, flow, pipe } from 'effect'
import { NativeModules, Platform } from 'react-native'

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

export function requestAuthorization(): E.Effect<
  typeof AuthorizationStatus.Type,
  'unknown_authorization_status' | 'unexpected' | 'unsupported_os_version'
> {
  return pipe(
    E.tryPromise({
      try: financekitNativeModule.requestAuthorization,
      catch: (error) => {
        if (error instanceof Error && 'code' in error) {
          switch (error.code) {
            case '@candlefinance.financekit.unknown_authorization_status':
              return 'unknown_authorization_status'
            case '@candlefinance.financekit.os_version_too_low':
              return 'unsupported_os_version'
            case '@candlefinance.financekit.unknown':
            default:
              return 'unexpected'
          }
        } else {
          return 'unexpected'
        }
      },
    }),
    E.flatMap(
      flow(
        S.decode(S.parseJson(AuthorizationStatus)),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function authorizationStatus(): E.Effect<
  typeof AuthorizationStatus.Type,
  'unsupported_os_version' | 'unexpected' | 'unknown_authorization_status'
> {
  return pipe(
    E.tryPromise({
      try: financekitNativeModule.authorizationStatus,
      catch: (error) => {
        if (error instanceof Error && 'code' in error) {
          switch (error.code) {
            case '@candlefinance.financekit.unknown_authorization_status':
              return 'unknown_authorization_status'
            case '@candlefinance.financekit.os_version_too_low':
              return 'unsupported_os_version'
            case '@candlefinance.financekit.unknown':
            default:
              return 'unexpected'
          }
        } else {
          return 'unexpected'
        }
      },
    }),
    E.flatMap(
      flow(
        S.decode(S.parseJson(AuthorizationStatus)),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

// NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code
export function transactions(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof Transaction.Type)[],
  'invalid_query' | 'unexpected' | 'unsupported_os_version'
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError(() => 'invalid_query' as const),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.transactions(stringifiedQuery),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.query_invalid':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function transactionHistory(
  params: typeof AccountDetailsHistoryParams.Type
): E.Effect<
  readonly (typeof Transaction.Type)[],
  'invalid_params' | 'unexpected' | 'unsupported_os_version'
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountDetailsHistoryParams)),
    E.mapError(() => 'invalid_params' as const),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () => financekitNativeModule.transactionHistory(stringifiedParams),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.params_invalid':
              case '@candlefinance.financekit.transaction_history_invalid':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function accounts(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof Account.Type)[],
  'invalid_query' | 'unexpected' | 'unsupported_os_version'
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError(() => 'invalid_query' as const),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.accounts(stringifiedQuery),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.query_invalid':
              case '@candlefinance.financekit.accounts_invalid':
              case '@candlefinance.financekit.unknown_account_type':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function accountHistory(
  params: typeof AccountHistoryParams.Type
): E.Effect<
  readonly (typeof Account.Type)[],
  'invalid_params' | 'unexpected' | 'unsupported_os_version'
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountHistoryParams)),
    E.mapError(() => 'invalid_params' as const),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () => financekitNativeModule.accountHistory(stringifiedParams),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.params_invalid':
              case '@candlefinance.financekit.transaction_history_invalid':
              case '@candlefinance.financekit.unknown_account_type':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function accountBalances(
  query: typeof Query.Type
): E.Effect<
  readonly (typeof AccountBalance.Type)[],
  'unexpected' | 'unsupported_os_version' | 'invalid_query'
> {
  return pipe(
    query,
    S.encode(S.parseJson(Query)),
    E.mapError(() => 'invalid_query' as const),
    E.flatMap((stringifiedQuery) =>
      E.tryPromise({
        try: () => financekitNativeModule.accountBalances(stringifiedQuery),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.query_invalid':
              case '@candlefinance.financekit.account_balances_invalid':
              case '@candlefinance.financekit.unknown_current_balance_type':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(AccountBalance))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}

export function accountBalanceHistory(
  params: typeof AccountDetailsHistoryParams.Type
): E.Effect<
  readonly (typeof AccountBalance.Type)[],
  'unexpected' | 'unsupported_os_version' | 'invalid_params'
> {
  return pipe(
    params,
    S.encode(S.parseJson(AccountDetailsHistoryParams)),
    E.mapError(() => 'invalid_params' as const),
    E.flatMap((stringifiedParams) =>
      E.tryPromise({
        try: () =>
          financekitNativeModule.accountBalanceHistory(stringifiedParams),
        catch: (error) => {
          if (error instanceof Error && 'code' in error) {
            switch (error.code) {
              case '@candlefinance.financekit.os_version_too_low':
                return 'unsupported_os_version'
              case '@candlefinance.financekit.params_invalid':
              case '@candlefinance.financekit.account_balance_history_invalid':
              case '@candlefinance.financekit.unknown_current_balance_type':
              case '@candlefinance.financekit.unknown':
              default:
                return 'unexpected'
            }
          } else {
            return 'unexpected'
          }
        },
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.parseJson(S.Array(AccountBalance)))),
        E.mapError(() => 'unexpected' as const)
      )
    )
  )
}
