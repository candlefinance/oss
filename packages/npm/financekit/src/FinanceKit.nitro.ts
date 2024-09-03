import { type HybridObject } from 'react-native-nitro-modules'

type AuthorizationStatus = 'authorized' | 'denied' | 'notDetermined'

interface Query {
  limit: number
  offset: number
}

type FinanceKitCreditDebitIndicator = 'credit' | 'debit' | 'none'

type FinanceKitTransactionType =
  | 'unknown'
  | 'adjustment'
  | 'atm'
  | 'billPayment'
  | 'check'
  | 'deposit'
  | 'directDeposit'
  | 'dividend'
  | 'fee'
  | 'interest'
  | 'pointOfSale'
  | 'transfer'
  | 'withdrawal'
  | 'standingOrder'
  | 'directDebit'
  | 'loan'
  | 'refund'

enum FinanceKitTransactionStatus {
  authorized,
  memo,
  pending,
  booked,
  rejected,
}

interface CurrencyAmount {
  amount: number
  currencyCode: string
}

interface FinanceKitTransaction {
  id: string
  accountID: string
  transactionAmount: CurrencyAmount
  foreignCurrencyAmount: CurrencyAmount
  creditDebitIndicator: FinanceKitCreditDebitIndicator
  transactionDescription: string
  originalTransactionDescription: string
  merchantCategoryCode: number
  merchantName: string
  transactionType: FinanceKitTransactionType
  status: FinanceKitTransactionStatus
  transactionDate: string
  postedDate: string
}

interface AccountHistoryParams {
  token: string
  isMonitoring: boolean
}

interface AccountDetailsHistoryParams {
  accountID: string
  token: string
  isMonitoring: boolean
}

interface Account {
  id: string
  displayName: string
  accountDescription: string
  institutionName: string
  currencyCode: string
}

interface Balance {
  amount: CurrencyAmount
  asOfDate: string
  creditDebitIndicator: FinanceKitCreditDebitIndicator
}

interface Available {
  available: Balance
}

interface Booked {
  booked: Balance
}

interface AvailableAndBooked {
  available: Balance
  booked: Balance
}

interface CurrentBalance {
  available: Available
  booked: Booked
  availableAndBooked: AvailableAndBooked
}

interface FinanceKitAccountBalance {
  id: string
  accountID: string
  currentBalance: CurrentBalance
}

export interface FinanceKit extends HybridObject<{ ios: 'swift' }> {
  requestAuthorization(): Promise<AuthorizationStatus>
  authorizationStatus(): Promise<AuthorizationStatus>
  transactions(query: Query): Promise<FinanceKitTransaction[]>
  transactionHistory(
    params: AccountDetailsHistoryParams
  ): Promise<FinanceKitTransaction[]>
  accounts(query: Query): Promise<Account[]>
  accountHistory(params: AccountHistoryParams): Promise<Account[]>
  accountBalances(query: Query): Promise<FinanceKitAccountBalance[]>
  accountBalanceHistory(
    params: AccountDetailsHistoryParams
  ): Promise<FinanceKitAccountBalance[]>
}
