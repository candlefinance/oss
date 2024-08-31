import 'fast-text-encoding'

// import {
//   accountBalanceHistory,
//   accountBalances,
//   accountHistory,
//   accounts,
//   authorizationStatus,
//   FinancekitError,
//   requestAuthorization,
//   S_CNDL_UUID,
//   transactionHistory,
//   transactions,
// } from '@candlefinance/financekit'
import * as React from 'react'
import { StyleSheet, Text, View } from 'react-native'

export default function App() {
  const [requestAuthorizationResult] = React.useState('Loading')
  const [authorizationStatusResult] = React.useState('Loading')
  const [transactionsResult] = React.useState('Loading')
  const [transactionHistoryResult] = React.useState('Loading')
  const [accountsResult] = React.useState('Loading')
  const [accountHistoryResult] = React.useState('Loading')
  const [accountBalancesResult] = React.useState('Loading')
  const [accountBalanceHistoryResult] = React.useState('Loading')

  React.useEffect(() => {
    // functionToEffect({
    //   func: requestAuthorization,
    //   funcInput: undefined,
    //   onResult: setRequestAuthorizationResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: authorizationStatus,
    //   funcInput: undefined,
    //   onResult: setAuthorizationStatusResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: transactions,
    //   funcInput: { limit: O.none(), offset: O.none() },
    //   onResult: setTransactionsResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: transactionHistory,
    //   funcInput: {
    //     token: O.none(),
    //     isMonitoring: O.none(),
    //     accountID: S_CNDL_UUID.make('00000000-0000-0000-0000-000000000000'),
    //   },
    //   onResult: setTransactionHistoryResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: accounts,
    //   funcInput: { limit: O.none(), offset: O.none() },
    //   onResult: setAccountsResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: accountHistory,
    //   funcInput: { token: O.none(), isMonitoring: O.none() },
    //   onResult: setAccountHistoryResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: accountBalances,
    //   funcInput: { limit: O.none(), offset: O.none() },
    //   onResult: setAccountBalancesResult,
    // })
  }, [])
  React.useEffect(() => {
    // functionToEffect({
    //   func: accountBalanceHistory,
    //   funcInput: {
    //     token: O.none(),
    //     isMonitoring: O.none(),
    //     accountID: S_CNDL_UUID.make('00000000-0000-0000-0000-000000000000'),
    //   },
    //   onResult: setAccountBalanceHistoryResult,
    // })
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
