import {
  accountBalanceHistory,
  accountBalances,
  accountHistory,
  accounts,
  authorizationStatus,
  FinancekitError,
  requestAuthorization,
  S_CNDL_UUID,
  transactionHistory,
  transactions,
} from '@candlefinance/financekit'
import { Effect as E, Option as O, pipe } from 'effect'
import * as React from 'react'

import type { Effect } from 'effect/Effect'
import { StyleSheet, Text, View } from 'react-native'
import './global.ts'

export default function App() {
  const [requestAuthorizationResult, setRequestAuthorizationResult] =
    React.useState('Loading')
  const [authorizationStatusResult, setAuthorizationStatusResult] =
    React.useState('Loading')
  const [transactionsResult, setTransactionsResult] = React.useState('Loading')
  const [transactionHistoryResult, setTransactionHistoryResult] =
    React.useState('Loading')
  const [accountsResult, setAccountsResult] = React.useState('Loading')
  const [accountHistoryResult, setAccountHistoryResult] =
    React.useState('Loading')
  const [accountBalancesResult, setAccountBalancesResult] =
    React.useState('Loading')
  const [accountBalanceHistoryResult, setAccountBalanceHistoryResult] =
    React.useState('Loading')
  const functionToEffect = async <S, T>(inputs: {
    funcInput: S
    func: (input: S) => Effect<T, typeof FinancekitError.Type>
    onResult: React.Dispatch<React.SetStateAction<string>>
  }) => {
    await pipe(
      inputs.func(inputs.funcInput),
      E.mapBoth({
        onSuccess: (a) => 'Success: ' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map(inputs.onResult),
      E.runPromise
    )
  }
  React.useEffect(() => {
    functionToEffect({
      func: requestAuthorization,
      funcInput: undefined,
      onResult: setRequestAuthorizationResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: authorizationStatus,
      funcInput: undefined,
      onResult: setAuthorizationStatusResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: transactions,
      funcInput: { limit: O.none(), offset: O.none() },
      onResult: setTransactionsResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: transactionHistory,
      funcInput: {
        token: O.none(),
        isMonitoring: O.none(),
        accountId: S_CNDL_UUID.make('00000000-0000-0000-0000-000000000000'),
      },
      onResult: setTransactionHistoryResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: accounts,
      funcInput: { limit: O.none(), offset: O.none() },
      onResult: setAccountsResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: accountHistory,
      funcInput: { token: O.none(), isMonitoring: O.none() },
      onResult: setAccountHistoryResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: accountBalances,
      funcInput: { limit: O.none(), offset: O.none() },
      onResult: setAccountBalancesResult,
    })
  }, [])
  React.useEffect(() => {
    functionToEffect({
      func: accountBalanceHistory,
      funcInput: {
        token: O.none(),
        isMonitoring: O.none(),
        accountId: S_CNDL_UUID.make('00000000-0000-0000-0000-000000000000'),
      },
      onResult: setAccountBalanceHistoryResult,
    })
  }, [])

  return (
    <View style={styles.container}>
      <Text>Request Authorization Result: {requestAuthorizationResult}</Text>
      <Text>Authorization Status Result: {authorizationStatusResult}</Text>
      <Text>Transactions Result: {transactionsResult}</Text>
      <Text>Transaction History Result: {transactionHistoryResult}</Text>
      <Text>Accounts Result: {accountsResult}</Text>
      <Text>Account History Result: {accountHistoryResult}</Text>
      <Text>Account Balances Result: {accountBalancesResult}</Text>
      <Text>Account Balance history Result: {accountBalanceHistoryResult}</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
})
