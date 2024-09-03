import FinanceKit
import NitroModules
import Foundation

@available(iOS 17.4, *)
final class FinanceKit: HybridFinanceKitSpec {
    
    var hybridContext = margelo.nitro.HybridContext()
    
    var memorySize: Int {
        return getSizeOf(self)
    }
    
    func requestAuthorization() throws -> NitroModules.Promise<AuthorizationStatus> {
        return Promise.async {
            let status = try await FinanceStore.shared.requestAuthorization()
            switch status {
            case .notDetermined:
                return .notdetermined
            case .denied:
                return .denied
            case .authorized:
                return .authorized
            @unknown default:
                return .notdetermined
            }
        }
    }
    
    func authorizationStatus() throws -> NitroModules.Promise<AuthorizationStatus> {
        return Promise.async {
            let status = try await FinanceStore.shared.authorizationStatus()
            switch status {
            case .notDetermined:
                return .notdetermined
            case .denied:
                return .denied
            case .authorized:
                return .authorized
            @unknown default:
                return .notdetermined
            }
        }
    }
    
    func transactions(query: Query) throws -> NitroModules.Promise<[FinanceKitTransaction]> {
        return Promise.async {
            let transactionQuery = TransactionQuery(
                sortDescriptors: [],
                predicate: nil,
                limit: Int(query.limit),
                offset: Int(query.offset)
            )
            let transactions = try await FinanceStore.shared.transactions(query: transactionQuery)
            return transactions.compactMap(FinanceKitTransaction.init(transaction:))
        }
    }
    
    func transactionHistory(params: AccountDetailsHistoryParams) throws -> NitroModules.Promise<[FinanceKitTransaction]> {
        return Promise.async {
            let transactionHistory = FinanceStore.shared.transactionHistory(
                forAccountID: UUID(uuidString: params.accountID)!
            )
            let transactionList = try await transactionHistory.reduce([]) { partialResult, element in
                partialResult + element.inserted
            }
            return transactionList.compactMap(FinanceKitTransaction.init(transaction:))
        }
    }
    
    func accounts(query: Query) throws -> NitroModules.Promise<[Account]> {
        return Promise.async {
            let accountQuery = AccountQuery(
                sortDescriptors: [],
                predicate: nil,
                limit: Int(query.limit),
                offset: Int(query.offset)
            )
            let accounts = try await FinanceStore.shared.accounts(query: accountQuery)
            return accounts.map { account in
                    .init(
                        id: account.id.uuidString,
                        displayName: account.displayName,
                        accountDescription: account.accountDescription ?? "",
                        institutionName: account.institutionName,
                        currencyCode: account.currencyCode
                    )
            }
        }
    }
    
    func accountHistory(params: AccountDetailsHistoryParams) throws -> NitroModules.Promise<[Account]> {
        return Promise.async {
            let accountHistory = FinanceStore.shared.accountHistory()
            let accountList = try await accountHistory.reduce([]) { partialResult, element in
                partialResult + element.inserted
            }
            return accountList.map { account in
                    .init(
                        id: account.id.uuidString,
                        displayName: account.displayName,
                        accountDescription: account.accountDescription ?? "",
                        institutionName: account.institutionName,
                        currencyCode: account.currencyCode
                    )
            }
        }
    }
    
    func accountHistory(params: AccountHistoryParams) throws -> Promise<[Account]> {
        return Promise.async {
            let accountHistory = FinanceStore.shared.accountHistory()
            let accountList = try await accountHistory.reduce([]) { partialResult, element in
                partialResult + element.inserted
            }
            return accountList.map { account in
                return .init(
                    id: account.id.uuidString,
                    displayName: account.displayName,
                    accountDescription: account.accountDescription ?? "",
                    institutionName: account.institutionName,
                    currencyCode: account.currencyCode
                )
            }
        }
    }
    
    func accountBalances(query: Query) throws -> NitroModules.Promise<[FinanceKitAccountBalance]> {
        return Promise.async {
            let accountBalanceQuery = AccountBalanceQuery(
                sortDescriptors: [],
                predicate: nil,
                limit: Int(query.limit),
                offset: Int(query.offset)
            )
            let balances = try await FinanceStore.shared.accountBalances(query: accountBalanceQuery)
            return balances.compactMap(FinanceKitAccountBalance.init(accountBalance:))
        }
    }
    
    func accountBalanceHistory(params: AccountDetailsHistoryParams) throws -> NitroModules.Promise<[FinanceKitAccountBalance]> {
        return Promise.async {
            let accountBalanceHistory = FinanceStore.shared.accountBalanceHistory(
                forAccountID: UUID(uuidString: params.accountID)!
            )
            let accountBalanceList = try await accountBalanceHistory.reduce([]) { partialResult, element in
                partialResult + element.inserted
            }
            return accountBalanceList.compactMap(FinanceKitAccountBalance.init(accountBalance:))
        }
    }
    
}

extension Date {
    var toJSDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: self)
    }
}

@available(iOS 17.4, *)
extension FinanceKitTransaction {
    init?(transaction: Transaction) {
        return nil
    }
}

@available(iOS 17.4, *)
extension FinanceKitAccountBalance {
    init?(accountBalance: AccountBalance) {
        return nil
    }
}

extension Decimal {
    var toDouble: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
