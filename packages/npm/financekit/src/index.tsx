import { NativeModules, Platform } from 'react-native'
import { Schema as S } from '@effect/schema'
import { pipe } from 'effect'

const LINKING_ERROR =
  `The package '@candlefinance/financekit' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n'

const Financekit = NativeModules.Financekit
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
  limit: S.optional(S.Int),
  offset: S.optional(S.Int),
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
  foreignCurrencyAmount: S.optional(CurrencyAmount),
  creditDebitIndicator: S.Enums(CreditDebitIndicator),
  transactionDescription: S.String,
  originalTransactionDescription: S.String,
  merchantCategoryCode: S.optional(S.Int),
  merchantName: S.optional(S.String),
  transactionType: S.Enums(TransactionType),
  status: S.Enums(TransactionStatus),
  transactionDate: S.DateFromString,
  postedDate: S.optional(S.DateFromString),
})

const AccountHistoryParams = S.Struct({
  token: S.optional(S.String),
  isMonitoring: S.optional(S.Boolean),
})

const AccountDetailsHistoryParams = AccountHistoryParams.pipe(
  S.extend(
    S.Struct({
      accountId: S.UUID,
    })
  )
)

const AccountCreditInformation = S.Struct({
  creditLimit: S.optional(CurrencyAmount),
  nextPaymentDueDate: S.optional(S.DateFromString),
  minimumNextPaymentAmount: S.optional(CurrencyAmount),
  overduePaymentAmount: S.optional(CurrencyAmount),
})

const Account = S.Struct({
  id: S.UUID,
  displayName: S.String,
  accountDescription: S.optional(S.String),
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

export async function requestAuthorization(): Promise<
  typeof AuthorizationStatus.Type
> {
  return pipe(
    await Financekit.requestAuthorization(),
    S.decodeSync(S.parseJson(AuthorizationStatus))
  )
}

export async function authorizationStatus(): Promise<
  typeof AuthorizationStatus.Type
> {
  return pipe(
    await Financekit.authorizationStatus(),
    S.decodeSync(S.parseJson(AuthorizationStatus))
  )
}

// NOTE: The React Native bridge stringifies all objects anyway; we just do it manually so we can take advantage of Swift.Codable and kotlinx.serialization to simplify the native code

export async function transactions(
  query: typeof Query.Type
): Promise<readonly (typeof Transaction.Type)[]> {
  const stringifiedQuery = pipe(query, S.encodeSync(S.parseJson(Query)))
  const stringifiedTransactions =
    await Financekit.transactions(stringifiedQuery)
  return pipe(
    stringifiedTransactions,
    S.decodeSync(S.parseJson(S.Array(Transaction)))
  )
}

export async function transactionHistory(
  params: typeof AccountDetailsHistoryParams.Type
): Promise<readonly (typeof Transaction.Type)[]> {
  const stringifiedParams = pipe(
    params,
    S.encodeSync(S.parseJson(AccountDetailsHistoryParams))
  )
  const stringifiedTransactionHistory =
    await Financekit.transactionHistory(stringifiedParams)
  return pipe(
    stringifiedTransactionHistory,
    S.decodeSync(S.parseJson(S.Array(Transaction)))
  )
}

export async function accounts(
  query: typeof Query.Type
): Promise<readonly (typeof Account.Type)[]> {
  const stringifiedQuery = pipe(query, S.encodeSync(S.parseJson(Query)))
  const stringifiedAccounts = await Financekit.accounts(stringifiedQuery)
  return pipe(stringifiedAccounts, S.decodeSync(S.parseJson(S.Array(Account))))
}

export async function accountHistory(
  params: typeof AccountHistoryParams.Type
): Promise<readonly (typeof Account.Type)[]> {
  const stringifiedParams = pipe(
    params,
    S.encodeSync(S.parseJson(AccountHistoryParams))
  )
  const stringifiedAccountHistory =
    await Financekit.accountHistory(stringifiedParams)
  return pipe(
    stringifiedAccountHistory,
    S.decodeSync(S.parseJson(S.Array(Account)))
  )
}

export async function accountBalances(
  query: typeof Query.Type
): Promise<readonly (typeof AccountBalance.Type)[]> {
  const stringifiedQuery = pipe(query, S.encodeSync(S.parseJson(Query)))
  const stringifiedAccountBalances =
    await Financekit.accountBalances(stringifiedQuery)
  return pipe(
    stringifiedAccountBalances,
    S.decodeSync(S.parseJson(S.Array(AccountBalance)))
  )
}

export async function accountBalanceHistory(
  params: typeof AccountDetailsHistoryParams.Type
): Promise<readonly (typeof AccountBalance.Type)[]> {
  const stringifiedParams = pipe(
    params,
    S.encodeSync(S.parseJson(AccountDetailsHistoryParams))
  )
  const stringifiedAccountBalanceHistory =
    await Financekit.accountBalanceHistory(stringifiedParams)
  return pipe(
    stringifiedAccountBalanceHistory,
    S.decodeSync(S.parseJson(S.parseJson(S.Array(AccountBalance))))
  )
}
