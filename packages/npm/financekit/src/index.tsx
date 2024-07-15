import { Schema as S } from '@effect/schema'
import { Effect as E, Either, Option as O, flow, pipe } from 'effect'
import { NativeModules, Platform } from 'react-native'
import { discriminateA, oLiftRefinement, type Discriminated } from './utils'

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

export const S_CNDL_UUID = S.UUID.pipe(S.brand('CNDL_UUID'))
export const S_CNDL_Int = S.Int.pipe(S.brand('CNDL_Int'))

const Query = S.Struct({
  limit: S.OptionFromUndefinedOr(S_CNDL_Int),
  offset: S.OptionFromUndefinedOr(S_CNDL_Int),
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
  // TODO: We should define our own models for everything in Financekit.swift as Apple seems to have custom logic in some of their Codable implementations
  // This line for example following apple's own code should always be present but per testing can be undefined
  currencyCode: S.OptionFromUndefinedOr(S.String),
})

const Transaction = S.Struct({
  id: S_CNDL_UUID,
  accountID: S_CNDL_UUID,
  transactionAmount: CurrencyAmount,
  foreignCurrencyAmount: S.OptionFromUndefinedOr(CurrencyAmount),
  creditDebitIndicator: S.Enums(CreditDebitIndicator),
  transactionDescription: S.String,
  originalTransactionDescription: S.String,
  merchantCategoryCode: S.OptionFromUndefinedOr(S_CNDL_Int),
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
      accountID: S_CNDL_UUID,
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
  id: S_CNDL_UUID,
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
  id: S_CNDL_UUID,
  accountID: S_CNDL_UUID,
  currentBalance: CurrentBalance,
})

export const FinancekitError = S.Struct({
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
    '@candlefinance.financekit.account_balances_invalid',
    '@candlefinance.financekit.account_balance_history_invalid',
    '@candlefinance.financekit.accounts_invalid',
    '@candlefinance.financekit.os_version_too_low',
    '@candlefinance.financekit.params_invalid',
    '@candlefinance.financekit.query_invalid',
    '@candlefinance.financekit.transaction_history_invalid',
    '@candlefinance.financekit.transactions_invalid',
    '@candlefinance.financekit.unauthorized_financekit_usage',
    '@candlefinance.financekit.unknown',
    '@candlefinance.financekit.unknown_account_type',
    '@candlefinance.financekit.unknown_authorization_status',
    '@candlefinance.financekit.unknown_current_balance_type',
    '@candlefinance.financekit.unknown_error_response_schema',
    '@candlefinance.financekit.unknown_response_schema',
    '@candlefinance.financekit.android_not_supported'
  ),
})

const makeError = <Code extends String & (typeof FinancekitError.Type)['code']>(
  error: unknown,
  code: Code
): Discriminated<typeof FinancekitError.Type, 'code', Code> =>
  FinancekitError.make({
    code: code,
    userInfo: O.none(),
    message: `${error}`,
    nativeStackAndroid: O.none(),
    nativeStackIOS: O.none(),
    domain: O.none(),
  }) as Discriminated<typeof FinancekitError.Type, 'code', Code>

export function requestAuthorization(): E.Effect<
  typeof AuthorizationStatus.Type,
  Discriminated<
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_authorization_status'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
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
            makeError(
              error,
              '@candlefinance.financekit.unknown_error_response_schema'
            )
          )
        ),
    }),
    E.flatMap(
      flow(
        S.decode(S.String.pipe(S.compose(AuthorizationStatus))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
        )
      )
    )
  )
}

export function authorizationStatus(): E.Effect<
  typeof AuthorizationStatus.Type,
  Discriminated<
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown_authorization_status'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
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
            makeError(
              error,
              '@candlefinance.financekit.unknown_error_response_schema'
            )
          )
        ),
    }),
    E.flatMap(
      flow(
        S.decode(S.String.pipe(S.compose(AuthorizationStatus))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.transactions_invalid'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
            S.decodeUnknownEither(FinancekitError),
            Either.getRight,
            O.flatMap(
              oLiftRefinement(
                discriminateA('code', [
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.transactions_invalid',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.transaction_history_invalid'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.transaction_history_invalid',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Transaction))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.unknown_account_type'
    | '@candlefinance.financekit.accounts_invalid'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.accounts_invalid',
                  '@candlefinance.financekit.unknown_account_type',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.transaction_history_invalid'
    | '@candlefinance.financekit.unknown_account_type'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.transaction_history_invalid',
                  '@candlefinance.financekit.unknown_account_type',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(Account))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.query_invalid'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.account_balances_invalid'
    | '@candlefinance.financekit.unknown_current_balance_type'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.query_invalid',
                  '@candlefinance.financekit.account_balances_invalid',
                  '@candlefinance.financekit.unknown_current_balance_type',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.Array(AccountBalance))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
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
    typeof FinancekitError.Type,
    'code',
    | '@candlefinance.financekit.os_version_too_low'
    | '@candlefinance.financekit.params_invalid'
    | '@candlefinance.financekit.unknown'
    | '@candlefinance.financekit.unknown_error_response_schema'
    | '@candlefinance.financekit.unknown_response_schema'
    | '@candlefinance.financekit.account_balance_history_invalid'
    | '@candlefinance.financekit.unknown_current_balance_type'
    | '@candlefinance.financekit.android_not_supported'
    | '@candlefinance.financekit.unauthorized_financekit_usage'
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
                  '@candlefinance.financekit.android_not_supported',
                  '@candlefinance.financekit.os_version_too_low',
                  '@candlefinance.financekit.params_invalid',
                  '@candlefinance.financekit.account_balance_history_invalid',
                  '@candlefinance.financekit.unknown_current_balance_type',
                  '@candlefinance.financekit.unknown',
                  '@candlefinance.financekit.unauthorized_financekit_usage',
                ])
              )
            ),
            O.getOrElse(() =>
              makeError(
                error,
                '@candlefinance.financekit.unknown_error_response_schema'
              )
            )
          ),
      })
    ),
    E.flatMap(
      flow(
        S.decode(S.parseJson(S.parseJson(S.Array(AccountBalance)))),
        E.mapError((error) =>
          makeError(error, '@candlefinance.financekit.unknown_response_schema')
        )
      )
    )
  )
}
