//
//  SocketIOManager.swift
//  projectName
//
//  companyName on 09/02/22.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {

    static let shared = SocketIOManager()
    
    // MARK: - Properties
    let manager = SocketManager(socketURL: URL(string: Constants.URLS.SOCKET_URL)!, config: [.log(false), .compress])
    var socket: SocketIOClient? = nil

    // MARK: - Life Cycle
    override init() {
        super.init()
        
//        self.setupSocket()
//        self.setupDashboardSocketEvents()
//        self.setupStockSocketEvents()
//        self.setupAlertSocketEvents()
//        self.setupBuySellSocketEvents()
//        self.setupBuySellFractionalSocketEvents()
//        self.setupWatchlistSocketEvents()
//        self.setupMarketSocketEvents()
//        self.setupThemeSocketEvents()
//        self.setupPortfolioSocketEvents()
//        self.setupOrdersSocketEvents()
//        self.setupModifyBuySellSocketEvents()
//        self.socket?.connect()
    }

    func stop() {
        self.socket?.removeAllHandlers()
    }

    func disconnectSocket() {
        self.socket?.removeAllHandlers()
        self.socket?.disconnect()
        debugPrint("socket Disconnected")
    }
    
    // MARK: - Socket Setup -
    func setupSocket() {
        self.socket = self.manager.defaultSocket
    }
    
    //MARK: - DASHBOARD SOCKET -
    func setupDashboardSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Dashboard Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateDashboardBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Dashboard Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateDashboardTrades), object: dictdata)
        }
    }

    //MARK: - STOCK DETAIL SOCKET -
    func setupStockSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Stock Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateStockBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Stock Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateStockTrades), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_QUOTES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Stock Quotes Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateStockQuotes), object: dictdata)
        }
    }
    
    //MARK: - ALERT SOCKET -
    func setupAlertSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Alert Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateAlertBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Alert Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateAlertTrades), object: dictdata)
        }
    }
    
    //MARK: - BUYSELL SOCKET -
    func setupBuySellSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - BuySell Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateBuySellBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - BuySell Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateBuySellTrades), object: dictdata)
        }
    }
    
    //MARK: - BUYSELL FRACTIONAL SOCKET -
    func setupBuySellFractionalSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - BuySell Fractional Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateBuySellFractionalBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - BuySell Fractional Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateBuySellFractionalTrades), object: dictdata)
        }
    }
    
    //MARK: - WATCHLIST SOCKET -
    func setupWatchlistSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Watchlist Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateWatchlistBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Watchlist Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateWatchlistTrades), object: dictdata)
        }
    }
    
    //MARK: - MARKET SOCKET -
    func setupMarketSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Market Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateMarketBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Market Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateMarketTrades), object: dictdata)
        }
    }
    
    //MARK: - SEARCH THEME SOCKET -
    func setupThemeSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Theme Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateThemeBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Theme Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateThemeTrades), object: dictdata)
        }
    }
    
    //MARK: - PORTFOLIO SOCKET -
    func setupPortfolioSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Portfolio Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdatePortfolioBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Portfolio Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdatePortfolioTrades), object: dictdata)
        }
    }
    
    //MARK: - ORDERS SOCKET -
    func setupOrdersSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Orders Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateOrdersBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Orders Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateOrdersTrades), object: dictdata)
        }
    }
    
    //MARK: - MODIFY BUYSELL SOCKET -
    func setupModifyBuySellSocketEvents() {
//        if self.socket?.status != SocketIOStatus.notConnected {
            self.socket?.on(clientEvent: .connect) {data, ack in
                debugPrint("Connected")
            }
//        }
        
        self.socket?.on(SUBSCRIBE_BARS) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Modify BuySell Daily Bar Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateModifyBuySellBars), object: dictdata)
        }
        
        self.socket?.on(SUBSCRIBE_TRADES) { (dataArray, socketAck) in
            debugPrint("Socket Manager - Modify BuySell Trades Data found")
            var dictdata = Dictionary<String,Any>()
            dictdata["data"] = dataArray[0] as! Dictionary<String,Any>
            NotificationCenter.default.post(name: Notification.Name(kUpdateModifyBuySellTrades), object: dictdata)
        }
    }
    
    // MARK: - SOCKET EMITS -
    func emitSubscribe(Data : [String : AnyObject]) {
        debugPrint("Emit Subscribe data")
        socket?.emit(EMIT_SUBSCRIBE, Data)
    }
}
