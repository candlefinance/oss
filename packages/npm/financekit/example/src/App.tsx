import {
  accountBalanceHistory,
  accountBalances,
  accountHistory,
  accounts,
  authorizationStatus,
  requestAuthorization,
  transactionHistory,
  transactions,
  uuid,
} from '@candlefinance/financekit'
import { Effect as E, Option as O, pipe } from 'effect'
import * as React from 'react'

import { StyleSheet, Text, View } from 'react-native'
import './global.js'

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
  React.useEffect(() => {
    pipe(
      requestAuthorization(),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setRequestAuthorizationResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      authorizationStatus(),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setAuthorizationStatusResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      transactions({ limit: O.none(), offset: O.none() }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setTransactionsResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      transactionHistory({
        token: O.none(),
        isMonitoring: O.none(),
        accountId: uuid.make('00000000-0000-0000-0000-000000000000'),
      }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setTransactionHistoryResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      accounts({ limit: O.none(), offset: O.none() }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setAccountsResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      accountHistory({ token: O.none(), isMonitoring: O.none() }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setAccountHistoryResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      accountBalances({ limit: O.none(), offset: O.none() }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setAccountBalancesResult(_)),
      E.runPromise
    )
  }, [])
  React.useEffect(() => {
    pipe(
      accountBalanceHistory({
        token: O.none(),
        isMonitoring: O.none(),
        accountId: uuid.make('00000000-0000-0000-0000-000000000000'),
      }),
      E.mapBoth({
        onSuccess: (a) => 'Success:' + a,
        onFailure: (e) => 'Failure: ' + e.code,
      }),
      E.merge,
      E.map((_) => setAccountBalanceHistoryResult(_)),
      E.runPromise
    )
  }, [])

  return (
    <View style={styles.container}>
      <Text>Request Authorization Result: {requestAuthorizationResult}</Text>
      <Text>Authorization Status Result: {authorizationStatusResult}</Text>
      <Text>Transactions Result: {transactionsResult}</Text>
      <Text>Transaction History Result: {transactionHistoryResult}</Text>
      <Text>accounts Result: {accountsResult}</Text>
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
