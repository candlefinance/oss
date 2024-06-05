import FinanceKit

private let CODE_ACCOUNT_BALANCES_INVALID: String = "@candlefinance.financekit.account_balances_invalid"
private let CODE_ACCOUNT_BALANCE_HISTORY_INVALID: String = "@candlefinance.financekit.account_balance_history_invalid"
private let CODE_ACCOUNTS_INVALID: String = "@candlefinance.financekit.accounts_invalid"
private let CODE_PARAMS_INVALID: String = "@candlefinance.financekit.params_invalid"
private let CODE_QUERY_INVALID = "@candlefinance.financekit.query_invalid"
private let CODE_TRANSACTION_HISTORY_INVALID = "@candlefinance.financekit.transaction_history_invalid"
private let CODE_TRANSACTIONS_INVALID = "@candlefinance.financekit.transactions_invalid"
private let CODE_UNKNOWN = "@candlefinance.financekit.unknown"
private let CODE_UNKNOWN_ACCOUNT_TYPE = "@candlefinance.financekit.unknown_account_type"
private let CODE_UNKNOWN_AUTHORIZATION_STATUS = "@candlefinance.financekit.unknown_authorization_status"
private let CODE_UNKNOWN_CURRENT_BALANCE_TYPE = "@candlefinance.financekit.unknown_current_balance_type"

private let MESSAGE_UNKNOWN_PARAMS_ISSUE: String = "Your request is invalid. Please verify the format of your parameters or file an issue on GitHub."
private let MESSAGE_UNKNOWN_RESPONSE_ISSUE: String = "Your request received a response, but it couldn't be processed. Please contact Apple or file an issue on GitHub."
private let MESSAGE_UNKNOWN = "Something went wrong. Please file an issue on GitHub or try again."
private let MESSAGE_UNKNOWN_ACCOUNT_TYPE = "An Account with an unknown type was received from Apple's APIs. Please file an issue on GitHub."
private let MESSAGE_UNKNOWN_AUTHORIZATION_STATUS = "An AuthorizationStatus with an unknown type was received from Apple's APIs. Please file an issue on Github."
private let MESSAGE_UNKNOWN_CURRENT_BALANCE_TYPE = "A CurrentBalance with an unknown type was received from Apple's APIs. Please file an issue on GitHub."

@available(iOS 17.4, *)
extension AuthorizationStatus {
    var authorizationStatus: String {
        get throws {
            switch self {
            case .authorized:
                return "authorized"
            case .denied:
                return "denied"
            case .notDetermined:
                return "notDetermined"
            @unknown default:
                throw FinancekitError.unknownAuthorizationStatus
            }
        }
    }
}

enum FinancekitError: Error {
    case unknownAccountType
    case unknownAuthorizationStatus
    case unknownCurrentBalanceType
    var message : String {
        switch self {
            
        case .unknownAuthorizationStatus:
            return MESSAGE_UNKNOWN_AUTHORIZATION_STATUS
        case .unknownAccountType:
            return MESSAGE_UNKNOWN_ACCOUNT_TYPE
        case .unknownCurrentBalanceType:
            return MESSAGE_UNKNOWN_CURRENT_BALANCE_TYPE
        }
    }
}

struct FinanceKitQuery : Codable {
    let limit: Int?
    let offset: Int?
}

@available(iOS 17.4, *)
struct AccountDetailsHistoryParams : Codable {
    let accountId: UUID
    let token: FinanceStore.HistoryToken?
    let isMonitoring: Bool?
}

@available(iOS 17.4, *)
struct AccountHistoryParams : Codable {
    let token: FinanceStore.HistoryToken?
    let isMonitoring: Bool?
}

@available(iOS 17.4, *)
struct FinanceKitChanges<Model> : Encodable where Model : Identifiable, Model : Encodable, Model.ID : Codable {
    public let inserted: [Model]
    public let updated: [Model]
    public let deleted: [Model.ID]
    public let newToken: FinanceStore.HistoryToken
}

@available(iOS 17.4, *)
struct FinanceKitAccount : Encodable, Identifiable {
    public let _tag: String
    public let id: UUID
    public let displayName: String
    public let accountDescription: String?
    public let institutionName: String
    public let currencyCode: String
    public let creditInformation: AccountCreditInformation?
    init(account: Account) throws {
        switch account {
        case .asset:
            self._tag = "asset"
            self.creditInformation = nil
            
        case .liability(let liabilityAccount):
            self._tag = "liability"
            self.creditInformation = liabilityAccount.creditInformation
        @unknown default:
            throw FinancekitError.unknownAccountType
        }
        
        self.id = account.id
        self.displayName = account.displayName
        self.accountDescription = account.accountDescription
        self.institutionName = account.institutionName
        self.currencyCode = account.currencyCode
    }
}

@available(iOS 17.4, *)
struct FinanceKitAccountBalance : Encodable, Identifiable {
    public let id: UUID
    public let accountID: UUID
    public let currentBalance: FinanceKitCurrentBalance
}

@available(iOS 17.4, *)
struct FinanceKitCurrentBalance : Encodable {
    public let _tag: String
    public let booked: Balance?
    public let available: Balance?
    init(currentBalance: CurrentBalance) throws {
        switch currentBalance {
        case .available(let balance):
            self._tag = "available"
            self.available = balance
            self.booked = nil
        case .booked(let balance):
            self._tag = "booked"
            self.booked = balance
            self.available = nil
        case .availableAndBooked(let available, let booked):
            self._tag = "availableAndBooked"
            self.available = available
            self.booked = booked
        @unknown default:
            throw FinancekitError.unknownCurrentBalanceType
        }
    }
}

@available(iOS 17.4, *)
@objc(Financekit)
final class Financekit: NSObject {
    
    private let store = FinanceStore.shared
    private let jsonEncoder = JSONEncoder()
    override init() {
        jsonEncoder.dateEncodingStrategy = .iso8601
    }
    
    @objc(requestAuthorization:withRejecter:)
    func requestAuthorization(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                let status = try await store.requestAuthorization()
                resolve(try status.authorizationStatus)
            } catch let error as FinancekitError {
                switch error {
                case .unknownAuthorizationStatus:
                    reject(CODE_UNKNOWN_AUTHORIZATION_STATUS, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(authorizationStatus:withRejecter:)
    func authorizationStatus(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                let status = try await store.authorizationStatus()
                resolve(try status.authorizationStatus)
            } catch let error as FinancekitError {
                switch error {
                case .unknownAuthorizationStatus:
                    reject(CODE_UNKNOWN_AUTHORIZATION_STATUS, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(transactions:withResolve:withRejecter:)
    func transactions(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let queryData = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(FinanceKitQuery.self, from: queryData)
                let query = TransactionQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)
                
                let transactions = try await store.transactions(query: query)
                let data = try jsonEncoder.encode(transactions)
                guard let stringifiedResponse = String(data: data, encoding: .utf8) else {
                    return reject(CODE_TRANSACTIONS_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedResponse)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(transactionHistory:withResolver:withRejecter:)
    func transactionHistory(stringifiedParams: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountDetailsHistoryParams.self, from: paramsData)
                let transactionHistory = store.transactionHistory(forAccountID: params.accountId, since: params.token, isMonitoring: params.isMonitoring ?? true)
                let transactionList = try await transactionHistory.reduce([]) { partialResult, element in
                    partialResult + [FinanceKitChanges(inserted: element.inserted, updated: element.updated, deleted: element.deleted, newToken: element.newToken)]
                }
                
                let data = try jsonEncoder.encode(transactionList)
                guard let stringifiedTransactionList = String(data: data, encoding: .utf8) else {
                    return reject(CODE_TRANSACTION_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedTransactionList)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(account:withResolve:withRejecter:)
    func account(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let queryData: Data = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(FinanceKitQuery.self, from: queryData)
                let query = AccountQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)
                
                let accounts = try await store.accounts(query: query)
                let financekitAccounts = try accounts.map { account in
                    return try FinanceKitAccount(account: account)
                }
                
                let data = try jsonEncoder.encode(financekitAccounts)
                guard let stringifiedResponse = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNTS_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedResponse)
            } catch let error as FinancekitError {
                switch error {
                case .unknownAccountType:
                    reject(CODE_UNKNOWN_ACCOUNT_TYPE, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(accountHistory:withResolver:withRejecter:)
    func accountHistory(stringifiedParams: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountHistoryParams.self, from: paramsData)
                let accountHistory = store.accountHistory(since: params.token, isMonitoring: params.isMonitoring ?? true)
                let accountList = try await accountHistory.reduce([]) { partialResult, element in
                    partialResult + [
                        FinanceKitChanges(
                            inserted: try element.inserted.map({ account in try FinanceKitAccount(account: account)}),
                            updated: try element.updated.map({ account in try FinanceKitAccount(account: account)}),
                            deleted: element.deleted, newToken: element.newToken)
                    ]
                }
                
                let data = try jsonEncoder.encode(accountList)
                guard let stringifiedTransactionList = String(data: data, encoding: .utf8) else {
                    return reject(CODE_TRANSACTION_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedTransactionList)
            } catch let error as FinancekitError {
                switch error {
                case .unknownAccountType:
                    reject(CODE_UNKNOWN_ACCOUNT_TYPE, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(accountBalances:withResolve:withRejecter:)
    func accountBalances(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let queryData: Data = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(FinanceKitQuery.self, from: queryData)
                let query = AccountBalanceQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)
                let balances = try await store.accountBalances(query: query)
                let financekitBalances = try balances.map { accountBalance in
                    let currentBalance = try FinanceKitCurrentBalance(currentBalance: accountBalance.currentBalance)
                    return FinanceKitAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: currentBalance)
                }
                
                let data = try jsonEncoder.encode(balances)
                guard let stringifiedResponse = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNT_BALANCES_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedResponse)
            } catch let error as FinancekitError {
                switch error {
                case .unknownCurrentBalanceType:
                    reject(CODE_UNKNOWN_CURRENT_BALANCE_TYPE, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
    
    @objc(accountBalanceHistory:withResolver:withRejecter:)
    func accountBalanceHistory(stringifiedParams: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        Task {
            do {
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountDetailsHistoryParams.self, from: paramsData)
                let accountBalanceHistory = store.accountBalanceHistory(forAccountID: params.accountId, since: params.token, isMonitoring: params.isMonitoring ?? true)
                let accountBalanceList = try await accountBalanceHistory.reduce([]) { partialResult, element in
                    partialResult + [
                        FinanceKitChanges(
                            inserted: try element.inserted.map({ accountBalance in try FinanceKitAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: FinanceKitCurrentBalance(currentBalance: accountBalance.currentBalance))}),
                            updated: try element.updated.map({ accountBalance in try FinanceKitAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: FinanceKitCurrentBalance(currentBalance: accountBalance.currentBalance))}),
                            deleted: element.deleted,
                            newToken: element.newToken
                        )
                    ]
                }
                
                let data = try jsonEncoder.encode(accountBalanceList)
                guard let stringifiedAccountBalanceList = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNT_BALANCE_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                    return reject(CODE_ACCOUNT_BALANCE_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedAccountBalanceList)
            } catch let error as FinancekitError {
                switch error {
                case .unknownCurrentBalanceType:
                    reject(CODE_UNKNOWN_CURRENT_BALANCE_TYPE, error.message, error)
                default:
                    reject(CODE_UNKNOWN, error.message, error)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
}
