///
/// FinanceKitTransaction.hpp
/// Sat Aug 31 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#if __has_include(<NitroModules/JSIConverter.hpp>)
#include <NitroModules/JSIConverter.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif
#if __has_include(<NitroModules/NitroDefines.hpp>)
#include <NitroModules/NitroDefines.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif

// Forward declaration of `CurrencyAmount` to properly resolve imports.
namespace margelo::nitro::financekit { struct CurrencyAmount; }
// Forward declaration of `FinanceKitCreditDebitIndicator` to properly resolve imports.
namespace margelo::nitro::financekit { enum class FinanceKitCreditDebitIndicator; }
// Forward declaration of `FinanceKitTransactionType` to properly resolve imports.
namespace margelo::nitro::financekit { enum class FinanceKitTransactionType; }
// Forward declaration of `FinanceKitTransactionStatus` to properly resolve imports.
namespace margelo::nitro::financekit { enum class FinanceKitTransactionStatus; }

#include <string>
#include "CurrencyAmount.hpp"
#include "FinanceKitCreditDebitIndicator.hpp"
#include "FinanceKitTransactionType.hpp"
#include "FinanceKitTransactionStatus.hpp"

namespace margelo::nitro::financekit {

  /**
   * A struct which can be represented as a JavaScript object (FinanceKitTransaction).
   */
  struct FinanceKitTransaction {
  public:
    std::string id     SWIFT_PRIVATE;
    std::string accountID     SWIFT_PRIVATE;
    CurrencyAmount transactionAmount     SWIFT_PRIVATE;
    CurrencyAmount foreignCurrencyAmount     SWIFT_PRIVATE;
    FinanceKitCreditDebitIndicator creditDebitIndicator     SWIFT_PRIVATE;
    std::string transactionDescription     SWIFT_PRIVATE;
    std::string originalTransactionDescription     SWIFT_PRIVATE;
    double merchantCategoryCode     SWIFT_PRIVATE;
    std::string merchantName     SWIFT_PRIVATE;
    FinanceKitTransactionType transactionType     SWIFT_PRIVATE;
    FinanceKitTransactionStatus status     SWIFT_PRIVATE;
    std::string transactionDate     SWIFT_PRIVATE;
    std::string postedDate     SWIFT_PRIVATE;

  public:
    explicit FinanceKitTransaction(std::string id, std::string accountID, CurrencyAmount transactionAmount, CurrencyAmount foreignCurrencyAmount, FinanceKitCreditDebitIndicator creditDebitIndicator, std::string transactionDescription, std::string originalTransactionDescription, double merchantCategoryCode, std::string merchantName, FinanceKitTransactionType transactionType, FinanceKitTransactionStatus status, std::string transactionDate, std::string postedDate): id(id), accountID(accountID), transactionAmount(transactionAmount), foreignCurrencyAmount(foreignCurrencyAmount), creditDebitIndicator(creditDebitIndicator), transactionDescription(transactionDescription), originalTransactionDescription(originalTransactionDescription), merchantCategoryCode(merchantCategoryCode), merchantName(merchantName), transactionType(transactionType), status(status), transactionDate(transactionDate), postedDate(postedDate) {}
  };

} // namespace margelo::nitro::financekit

namespace margelo::nitro {

  using namespace margelo::nitro::financekit;

  // C++ FinanceKitTransaction <> JS FinanceKitTransaction (object)
  template <>
  struct JSIConverter<FinanceKitTransaction> {
    static inline FinanceKitTransaction fromJSI(jsi::Runtime& runtime, const jsi::Value& arg) {
      jsi::Object obj = arg.asObject(runtime);
      return FinanceKitTransaction(
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "id")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "accountID")),
        JSIConverter<CurrencyAmount>::fromJSI(runtime, obj.getProperty(runtime, "transactionAmount")),
        JSIConverter<CurrencyAmount>::fromJSI(runtime, obj.getProperty(runtime, "foreignCurrencyAmount")),
        JSIConverter<FinanceKitCreditDebitIndicator>::fromJSI(runtime, obj.getProperty(runtime, "creditDebitIndicator")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "transactionDescription")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "originalTransactionDescription")),
        JSIConverter<double>::fromJSI(runtime, obj.getProperty(runtime, "merchantCategoryCode")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "merchantName")),
        JSIConverter<FinanceKitTransactionType>::fromJSI(runtime, obj.getProperty(runtime, "transactionType")),
        JSIConverter<FinanceKitTransactionStatus>::fromJSI(runtime, obj.getProperty(runtime, "status")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "transactionDate")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "postedDate"))
      );
    }
    static inline jsi::Value toJSI(jsi::Runtime& runtime, const FinanceKitTransaction& arg) {
      jsi::Object obj(runtime);
      obj.setProperty(runtime, "id", JSIConverter<std::string>::toJSI(runtime, arg.id));
      obj.setProperty(runtime, "accountID", JSIConverter<std::string>::toJSI(runtime, arg.accountID));
      obj.setProperty(runtime, "transactionAmount", JSIConverter<CurrencyAmount>::toJSI(runtime, arg.transactionAmount));
      obj.setProperty(runtime, "foreignCurrencyAmount", JSIConverter<CurrencyAmount>::toJSI(runtime, arg.foreignCurrencyAmount));
      obj.setProperty(runtime, "creditDebitIndicator", JSIConverter<FinanceKitCreditDebitIndicator>::toJSI(runtime, arg.creditDebitIndicator));
      obj.setProperty(runtime, "transactionDescription", JSIConverter<std::string>::toJSI(runtime, arg.transactionDescription));
      obj.setProperty(runtime, "originalTransactionDescription", JSIConverter<std::string>::toJSI(runtime, arg.originalTransactionDescription));
      obj.setProperty(runtime, "merchantCategoryCode", JSIConverter<double>::toJSI(runtime, arg.merchantCategoryCode));
      obj.setProperty(runtime, "merchantName", JSIConverter<std::string>::toJSI(runtime, arg.merchantName));
      obj.setProperty(runtime, "transactionType", JSIConverter<FinanceKitTransactionType>::toJSI(runtime, arg.transactionType));
      obj.setProperty(runtime, "status", JSIConverter<FinanceKitTransactionStatus>::toJSI(runtime, arg.status));
      obj.setProperty(runtime, "transactionDate", JSIConverter<std::string>::toJSI(runtime, arg.transactionDate));
      obj.setProperty(runtime, "postedDate", JSIConverter<std::string>::toJSI(runtime, arg.postedDate));
      return obj;
    }
    static inline bool canConvert(jsi::Runtime& runtime, const jsi::Value& value) {
      if (!value.isObject()) {
        return false;
      }
      jsi::Object obj = value.getObject(runtime);
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "id"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "accountID"))) return false;
      if (!JSIConverter<CurrencyAmount>::canConvert(runtime, obj.getProperty(runtime, "transactionAmount"))) return false;
      if (!JSIConverter<CurrencyAmount>::canConvert(runtime, obj.getProperty(runtime, "foreignCurrencyAmount"))) return false;
      if (!JSIConverter<FinanceKitCreditDebitIndicator>::canConvert(runtime, obj.getProperty(runtime, "creditDebitIndicator"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "transactionDescription"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "originalTransactionDescription"))) return false;
      if (!JSIConverter<double>::canConvert(runtime, obj.getProperty(runtime, "merchantCategoryCode"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "merchantName"))) return false;
      if (!JSIConverter<FinanceKitTransactionType>::canConvert(runtime, obj.getProperty(runtime, "transactionType"))) return false;
      if (!JSIConverter<FinanceKitTransactionStatus>::canConvert(runtime, obj.getProperty(runtime, "status"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "transactionDate"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "postedDate"))) return false;
      return true;
    }
  };

} // namespace margelo::nitro
