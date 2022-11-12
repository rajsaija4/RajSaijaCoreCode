//
//  TradingAccountObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 23/02/22.
//

import Foundation

class TradingAccountObject: NSObject, Codable {
    var id: String = ""
    var account_number: String = ""
    var status: String = ""
    var crypto_status: String = ""
    var currency: String = ""
    var buying_power: String = ""
    var regt_buying_power: String = ""
    var daytrading_buying_power: String = ""
    var non_marginable_buying_power: String = ""
    var cash: String = ""
    var cash_withdrawable: String = ""
    var cash_transferable: String = ""
    var accrued_fees: String = ""
    var pending_transfer_out: String = ""
    var pending_transfer_in: String = ""
    var portfolio_value: String = ""
    var pattern_day_trader: Bool = false
    var trading_blocked: Bool = false
    var transfers_blocked: Bool = false
    var account_blocked: Bool = false
    var created_at: String = ""
    var trade_suspended_by_user: Bool = false
    var multiplier: String = ""
    var shorting_enabled: Bool = false
    var equity: String = ""
    var last_equity: String = ""
    var long_market_value: String = ""
    var short_market_value: String = ""
    var initial_margin: String = ""
    var maintenance_margin: String = ""
    var last_maintenance_margin: String = ""
    var sma: String = ""
    var daytrade_count: Int = 0
    var previous_close: String = ""
    var last_long_market_value: String = ""
    var last_short_market_value: String = ""
    var last_cash: String = ""
    var last_initial_margin: String = ""
    var last_regt_buying_power: String = ""
    var last_daytrading_buying_power: String = ""
    var last_buying_power: String = ""
    var last_daytrade_count: Int = 0
    var clearing_broker: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.account_number = dictionary["account_number"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.crypto_status = dictionary["crypto_status"] as? String ?? ""
        self.currency = dictionary["currency"] as? String ?? ""
        self.buying_power = dictionary["buying_power"] as? String ?? ""
        self.regt_buying_power = dictionary["regt_buying_power"] as? String ?? ""
        self.daytrading_buying_power = dictionary["daytrading_buying_power"] as? String ?? ""
        self.non_marginable_buying_power = dictionary["non_marginable_buying_power"] as? String ?? ""
        self.cash = dictionary["cash"] as? String ?? ""
        self.cash_withdrawable = dictionary["cash_withdrawable"] as? String ?? ""
        self.cash_transferable = dictionary["cash_transferable"] as? String ?? ""
        self.accrued_fees = dictionary["accrued_fees"] as? String ?? ""
        self.pending_transfer_out = dictionary["pending_transfer_out"] as? String ?? ""
        self.pending_transfer_in = dictionary["pending_transfer_in"] as? String ?? ""
        self.portfolio_value = dictionary["portfolio_value"] as? String ?? ""
        self.pattern_day_trader = dictionary["pattern_day_trader"] as? Bool ?? false
        self.trading_blocked = dictionary["trading_blocked"] as? Bool ?? false
        self.transfers_blocked = dictionary["transfers_blocked"] as? Bool ?? false
        self.account_blocked = dictionary["account_blocked"] as? Bool ?? false
        self.created_at = dictionary["created_at"] as? String ?? ""
        self.trade_suspended_by_user = dictionary["trade_suspended_by_user"] as? Bool ?? false
        self.multiplier = dictionary["multiplier"] as? String ?? ""
        self.shorting_enabled = dictionary["shorting_enabled"] as? Bool ?? false
        self.equity = dictionary["equity"] as? String ?? ""
        self.last_equity = dictionary["last_equity"] as? String ?? ""
        self.long_market_value = dictionary["long_market_value"] as? String ?? ""
        self.short_market_value = dictionary["short_market_value"] as? String ?? ""
        self.initial_margin = dictionary["initial_margin"] as? String ?? ""
        self.maintenance_margin = dictionary["maintenance_margin"] as? String ?? ""
        self.last_maintenance_margin = dictionary["last_maintenance_margin"] as? String ?? ""
        self.sma = dictionary["sma"] as? String ?? ""
        self.daytrade_count = dictionary["daytrade_count"] as? Int ?? 0
        self.previous_close = dictionary["previous_close"] as? String ?? ""
        self.last_long_market_value = dictionary["last_long_market_value"] as? String ?? ""
        self.last_short_market_value = dictionary["last_short_market_value"] as? String ?? ""
        self.last_cash = dictionary["last_cash"] as? String ?? ""
        self.last_initial_margin = dictionary["last_initial_margin"] as? String ?? ""
        self.last_regt_buying_power = dictionary["last_regt_buying_power"] as? String ?? ""
        self.last_daytrading_buying_power = dictionary["last_daytrading_buying_power"] as? String ?? ""
        self.last_buying_power = dictionary["last_buying_power"] as? String ?? ""
        self.last_daytrade_count = dictionary["last_daytrade_count"] as? Int ?? 0
        self.clearing_broker = dictionary["clearing_broker"] as? String ?? ""
    }
}
