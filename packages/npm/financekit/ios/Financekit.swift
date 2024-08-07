import FinanceKit

private let CODE_ACCOUNT_BALANCES_INVALID = "@candlefinance.financekit.account_balances_invalid"
private let CODE_ACCOUNT_BALANCE_HISTORY_INVALID = "@candlefinance.financekit.account_balance_history_invalid"
private let CODE_ACCOUNTS_INVALID = "@candlefinance.financekit.accounts_invalid"
private let CODE_LOW_OS_VERSION = "@candlefinance.financekit.os_version_too_low"
private let CODE_PARAMS_INVALID = "@candlefinance.financekit.params_invalid"
private let CODE_QUERY_INVALID = "@candlefinance.financekit.query_invalid"
private let CODE_TRANSACTION_HISTORY_INVALID = "@candlefinance.financekit.transaction_history_invalid"
private let CODE_TRANSACTIONS_INVALID = "@candlefinance.financekit.transactions_invalid"
private let CODE_UNAUTHORIZED_USAGE = "@candlefinance.financekit.unauthorized_financekit_usage"
private let CODE_UNKNOWN = "@candlefinance.financekit.unknown"
private let CODE_UNKNOWN_ACCOUNT_TYPE = "@candlefinance.financekit.unknown_account_type"
private let CODE_UNKNOWN_AUTHORIZATION_STATUS = "@candlefinance.financekit.unknown_authorization_status"
private let CODE_UNKNOWN_CURRENT_BALANCE_TYPE = "@candlefinance.financekit.unknown_current_balance_type"

private let MESSAGE_LOW_OS_VERSION = "You are trying to use FinanceKit but your phone's OS is not 17.4.0 or above"
private let MESSAGE_UNAUTHORIZED_USAGE = "You are trying to use FinanceKit but you did not have the user authorize you to do so first or the user rejected your request"
private let MESSAGE_UNKNOWN_PARAMS_ISSUE = "Your request is invalid. Please verify the format of your parameters or file an issue on GitHub."
private let MESSAGE_UNKNOWN_RESPONSE_ISSUE = "Your request received a response, but it couldn't be processed. Please contact Apple or file an issue on GitHub."
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
                throw UnknownAuthorizationStatusError()
            }
        }
    }
}

final class UnknownAuthorizationStatusError : Error {
    let message : String = MESSAGE_UNKNOWN_AUTHORIZATION_STATUS
}

final class UnknownAccountTypeError : Error {
    let message : String = MESSAGE_UNKNOWN_ACCOUNT_TYPE
}

final class UnknownCurrentBalanceTypeError : Error {
    let message : String = MESSAGE_UNKNOWN_CURRENT_BALANCE_TYPE
}

struct CandleQuery : Codable {
    let limit: Int?
    let offset: Int?
}

@available(iOS 17.4, *)
struct AccountDetailsHistoryParams : Codable {
    let accountID: UUID
    let token: FinanceStore.HistoryToken?
    let isMonitoring: Bool?
}

@available(iOS 17.4, *)
struct AccountHistoryParams : Codable {
    let token: FinanceStore.HistoryToken?
    let isMonitoring: Bool?
}

@available(iOS 17.4, *)
struct CandleChanges<Model> : Encodable where Model : Identifiable, Model : Encodable, Model.ID : Codable {
    public let inserted: [Model]
    public let updated: [Model]
    public let deleted: [Model.ID]
    public let newToken: FinanceStore.HistoryToken
}

@available(iOS 17.4, *)
struct CandleAccount : Encodable, Identifiable {
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
            throw UnknownAccountTypeError()
        }

        self.id = account.id
        self.displayName = account.displayName
        self.accountDescription = account.accountDescription
        self.institutionName = account.institutionName
        self.currencyCode = account.currencyCode
    }
}

@available(iOS 17.4, *)
struct CandleAccountBalance : Encodable, Identifiable {
    public let id: UUID
    public let accountID: UUID
    public let currentBalance: CandleCurrentBalance
}

@available(iOS 17.4, *)
struct CandleCurrentBalance : Encodable {
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
            throw UnknownCurrentBalanceTypeError()
        }
    }
}

@objc(Financekit)
final class Financekit: NSObject {

    private let jsonEncoder = JSONEncoder()
    override init() {
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    @objc(requestAuthorization:withRejecter:)
    func requestAuthorization(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                let status = try await FinanceStore.shared.requestAuthorization()
                resolve(try status.authorizationStatus)
            } catch let error as UnknownAuthorizationStatusError {
                reject(CODE_UNKNOWN_AUTHORIZATION_STATUS, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }

    @objc(authorizationStatus:withRejecter:)
    func authorizationStatus(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                let status = try await FinanceStore.shared.authorizationStatus()
                resolve(try status.authorizationStatus)
            } catch let error as UnknownAuthorizationStatusError {
                reject(CODE_UNKNOWN_AUTHORIZATION_STATUS, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }

    @available(iOS 17.4, *)
    func isAuthorized() async throws -> Bool {
        let authorizationStatus = try await FinanceStore.shared.authorizationStatus()
        return (authorizationStatus == .authorized)
    }

    @objc(transactions:withResolver:withRejecter:)
    func transactions(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                if (try await !self.isAuthorized()) {
                    return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
                }
                guard let queryData = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(CandleQuery.self, from: queryData)
                let query = TransactionQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)

                let transactions = try await FinanceStore.shared.transactions(query: query)
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
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                if (try await !self.isAuthorized()) {
                    return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
                }
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountDetailsHistoryParams.self, from: paramsData)
                let transactionHistory = FinanceStore.shared.transactionHistory(forAccountID: params.accountID, since: params.token, isMonitoring: params.isMonitoring ?? true)
                let transactionList = try await transactionHistory.reduce([]) { partialResult, element in
                    partialResult + [CandleChanges(inserted: element.inserted, updated: element.updated, deleted: element.deleted, newToken: element.newToken)]
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

    @objc(accounts:withResolver:withRejecter:)
    func accounts(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            if (try await !self.isAuthorized()) {
                return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
            }
            do {
                guard let queryData: Data = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(CandleQuery.self, from: queryData)
                let query = AccountQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)

                let accounts = try await FinanceStore.shared.accounts(query: query)
                let financekitAccounts = try accounts.map { account in
                    return try CandleAccount(account: account)
                }

                let data = try jsonEncoder.encode(financekitAccounts)
                guard let stringifiedResponse = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNTS_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedResponse)
            } catch let error as UnknownAccountTypeError {
                reject(CODE_UNKNOWN_ACCOUNT_TYPE, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }

    @objc(accountHistory:withResolver:withRejecter:)
    func accountHistory(stringifiedParams: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                if (try await !self.isAuthorized()) {
                    return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
                }
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountHistoryParams.self, from: paramsData)
                let accountHistory = FinanceStore.shared.accountHistory(since: params.token, isMonitoring: params.isMonitoring ?? true)
                let accountList = try await accountHistory.reduce([]) { partialResult, element in
                    partialResult + [
                        CandleChanges(
                            inserted: try element.inserted.map({ account in try CandleAccount(account: account)}),
                            updated: try element.updated.map({ account in try CandleAccount(account: account)}),
                            deleted: element.deleted, newToken: element.newToken)
                    ]
                }

                let data = try jsonEncoder.encode(accountList)
                guard let stringifiedTransactionList = String(data: data, encoding: .utf8) else {
                    return reject(CODE_TRANSACTION_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedTransactionList)
            } catch let error as UnknownAccountTypeError {
                reject(CODE_UNKNOWN_ACCOUNT_TYPE, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }

    @objc(accountBalances:withResolver:withRejecter:)
    func accountBalances(stringifiedQuery: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                if (try await !self.isAuthorized()) {
                    return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
                }
                guard let queryData: Data = stringifiedQuery.data(using: .utf8) else {
                    return reject(CODE_QUERY_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let queryObject = try JSONDecoder().decode(CandleQuery.self, from: queryData)
                let query = AccountBalanceQuery(sortDescriptors: [], predicate: nil, limit: queryObject.limit, offset: queryObject.offset)
                let balances = try await FinanceStore.shared.accountBalances(query: query)
                let financekitBalances = try balances.map { accountBalance in
                    let currentBalance = try CandleCurrentBalance(currentBalance: accountBalance.currentBalance)
                    return CandleAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: currentBalance)
                }

                let data = try jsonEncoder.encode(financekitBalances)
                guard let stringifiedResponse = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNT_BALANCES_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedResponse)
            } catch let error as UnknownCurrentBalanceTypeError {
                reject(CODE_UNKNOWN_CURRENT_BALANCE_TYPE, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }

    @objc(accountBalanceHistory:withResolver:withRejecter:)
    func accountBalanceHistory(stringifiedParams: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.4, *) else {
            return reject(CODE_LOW_OS_VERSION, MESSAGE_LOW_OS_VERSION, nil)
        }
        Task {
            do {
                if (try await !self.isAuthorized()) {
                    return reject(CODE_UNAUTHORIZED_USAGE, MESSAGE_UNAUTHORIZED_USAGE, nil)
                }
                guard let paramsData: Data = stringifiedParams.data(using: .utf8) else {
                    return reject(CODE_PARAMS_INVALID, MESSAGE_UNKNOWN_PARAMS_ISSUE, nil)
                }
                let params = try JSONDecoder().decode(AccountDetailsHistoryParams.self, from: paramsData)
                let accountBalanceHistory = FinanceStore.shared.accountBalanceHistory(forAccountID: params.accountID, since: params.token, isMonitoring: params.isMonitoring ?? true)
                let accountBalanceList = try await accountBalanceHistory.reduce([]) { partialResult, element in
                    partialResult + [
                        CandleChanges(
                            inserted: try element.inserted.map({ accountBalance in try CandleAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: CandleCurrentBalance(currentBalance: accountBalance.currentBalance))}),
                            updated: try element.updated.map({ accountBalance in try CandleAccountBalance(id: accountBalance.id, accountID: accountBalance.accountID, currentBalance: CandleCurrentBalance(currentBalance: accountBalance.currentBalance))}),
                            deleted: element.deleted,
                            newToken: element.newToken
                        )
                    ]
                }

                let data = try jsonEncoder.encode(accountBalanceList)
                guard let stringifiedAccountBalanceList = String(data: data, encoding: .utf8) else {
                    return reject(CODE_ACCOUNT_BALANCE_HISTORY_INVALID, MESSAGE_UNKNOWN_RESPONSE_ISSUE, nil)
                }
                resolve(stringifiedAccountBalanceList)
            } catch let error as UnknownCurrentBalanceTypeError {
                reject(CODE_UNKNOWN_CURRENT_BALANCE_TYPE, error.message, error)
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
}
