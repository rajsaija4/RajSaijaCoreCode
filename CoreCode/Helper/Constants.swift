// 
//  Constants.swift
//  projectName
//
//  companyName on 22/10/21.
//

import UIKit
import CoreLocation

let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
let defaults = UserDefaults.standard

var objUserDetail = UserDetail()

let ALPHA_NUMERIC: String = " ,-.ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
let NUMERIC: String = ".1234567890"
let fakeUDID = "8a84f85d87b06b1dae1b47d448f85e6e"

let kWebViewSource: String = "var meta = document.createElement('meta');" +
"meta.name = 'viewport';" +
"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
"var head = document.getElementsByTagName('head')[0];" +
"head.appendChild(meta);"

let DATE_FORMAT: String = "dd/MM/yyyy"

let DEBUG: Bool = true

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

let successCode = 1
let invalidTokenCode = 500

typealias isAcceptCondition = (_ isConfirm: Bool, _ stringValue1: String, _ stringValue2: String) ->()

struct Constants {
    
    struct URLS {
        //URL
        static let BASE_DOMAIN = "http:"
        static let BASE_URL = "http://"
        static let SOCKET_URL = "http://"
        
        static let SIGNUP = "auth/register"
        static let LOGIN = "auth/login"
        static let TRADING_ACCOUNT = "auth/getTradingAcc"
        static let GET_PROFILE = "auth/getProfile"
        static let GET_NATIONALITY = "auth/nationandNationality"
        static let UPDATE_NATIONALITY = "auth/nationality"
        static let UPLOAD_DOCUMENT = "auth/uploadDocs"
        static let UPDATE_W8BEN_FORM = "auth/W8BENForm"
        static let UPDATE_W8BEN_DECLARATION = "auth/updateWBENDeclaration"
        static let FORGOT_PASSWORD = "auth/forgotOtp"
        static let VERIFY_OTP = "auth/verifyOtp"
        static let CREATE_NEW_PASSWORD = "auth/updateForgotPassword"
        static let UPDATE_PROFILE_IMAGE = "auth/updateProfileImage"
        static let UPDATE_CONTACT_INFO = "auth/updateContactInfo"
        static let CHANGE_PASSWORD = "auth/creteNewPass"
        static let SUPPORT = "static-pages/support"
        static let GET_WATCHLIST = "thirdPartyWatchlist"
        static let UPDATE_WATCHLIST = "thirdPartyWatchlist/updateWatchlist"
        static let DELETE_WATCHLIST = "thirdPartyWatchlist/deleteWatchlist"
        static let DELETE_STOCK_WATCHLIST = "thirdPartyWatchlist/removeSymbolFromWatchlist"
        static let SEARCH_SHARE_NAME = "shares/searchShareByName"
        static let SEARCH_SHARE_SYMBOL = "shares/getShareBySymbol"
        static let ADD_STOCK_WATCHLIST = "thirdPartyWatchlist/addSymoltoWatchlist"
        static let GET_STOCKLIST = "shares/getAllShare"
        static let GET_DEFAULT_STOCKLIST = "defaultList"
        static let GET_POPULAR_STOCK = "popularStocks"
        static let GET_POPULAR_ETFS = "ETFS"
        static let GET_MOST_BOUGHT = "mb"
        static let GET_ANALYST_PICK = "analystPick"
        static let GET_STATEMENT_HISTORY = "transaction"
        static let GET_STATEMENT_TRANSFER = "transfer"
        static let GET_STATEMENT_DIVIDEND = "dividend/all"
        static let GET_CATEGORY = "category"
        static let GET_INDUSTRY_TYPE = "news/industryType"
        static let GET_NEWS_INDUSTRY = "news/industries"
        static let GET_NEWS_SYMBOL = "news/newsBySymbol"
        static let GET_PORTFOLIO = "position"
        static let GET_PORTFOLIO_FILTER = "position/?sorting="
        static let GET_ALERT = "alert"
        static let GET_ORDER = "order"
        static let GET_ORDER_DETAIL_ID = "order/getOrderById"
        static let CANCEL_ORDER = "order/deleteOrderById"
        static let UPDATE_ORDER = "order/updateorder"
        static let GET_RECENT_TRANSFER = "transfer/recentTransfers"
        static let GET_MARKET_STATUS = "time/clock"
        static let GET_DASHBOARD_GRAPH = "position/getPortfolioHistory"
        static let CONTACT_US = "contactus"
        static let ADD_FUNDS_HISTORY = "payment/PaymentByUser"
        static let WITHDRAW_FUNDS_HISTORY = "transfer/allTransferUser"
        static let GET_STATEMENT = "order/allOrders"
        static let GET_BANK = "bank"
        static let GET_CARD = "card"
        static let ADD_FUND = "payment/addFund"
        static let ADD_WITHDRAW = "transfer/bankTransfer"
        static let GET_NOTIFICATION = "notifications"
        static let GET_COMMISSION = "settings/getCommission"
        static let CURRENCY_CONVERTER = "payment/currencyConverter"
    }
    
    struct Color {
        static let TAB_BARTINT = UIColor.init(hexString: "FFFFFF")!
        static let TAB_NORMAL = UIColor.init(hexString: "ACACAC")!
        static let TAB_SELECTED = UIColor.init(hexString: "000000")!
        
        static let THEME_GREEN = UIColor.init(hex: 0x81CF01)
        static let THEME_BLUE = UIColor.init(hex: 0x27B1FC)
        
        static let SEARCHBAR_PLACEHOLDER = UIColor.init(hex: 0x9F9F9F)
        static let SEARCHBAR_IMAGE = UIColor.init(hex: 0x9F9F9F)
    }
    
    struct Font {
        static let ARIAL_ROUNDED_BOLD = "ArialRoundedMTBold"
        static let ARIAL_ROUNDED_REGULAR = "Arial-Rounded"
        
        static let YUGOTHIC_UI_SEMILIGHT = "YuGothicUI-Semilight"
        static let YUGOTHIC_UI_LIGHT = "YuGothicUI-Light"
        static let YUGOTHIC_UI_REGULAR = "YuGothicUI-Regular"
        static let YUGOTHIC_UI_SEMIBOLD = "YuGothicUI-Semibold"
        static let YUGOTHIC_UI_BOLD = "YuGothicUI-Bold"
    }
    
    struct ScreenSize {
        static let SCREEN_RECT = UIScreen.main.bounds
        static let SCREEN_WIDTH = SCREEN_RECT.size.width
        static let SCREEN_HEIGHT = SCREEN_RECT.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType {
        static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
        static let IS_IPHONE_11_PRO_MAX = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 896.0
        static let IS_IPHONE_12_PRO = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 844.0
        static let IS_IPHONE_12_PRO_MAX = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 926.0
        
        //IPAD
        static let IS_IPAD_PRO = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 768.0
        static let IS_IPAD_PRO_2ndGEN = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 834.0
        static let IS_IPAD_PRO_4thGEN = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
        static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 810.0
        static let IS_IPAD_AIR_3rdGEN = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 834.0
        static let IS_IPAD_AIR_4thGEN = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 820.0
        //WIDTH
        //1024
        //1194
        //1366
        //1080
        //1112
        //1180
    }
}

struct Document {
    let uploadParameterKey: String
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String
    var image: UIImage?
}

//MARK: - ENUM -

enum JPEGQualityType: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

enum MyError: Error {
    case FoundNil(String)
}

enum TextFieldImageSide {
    case left
    case right
}

//DEVICE
enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

//API REQUEST
enum REQUEST : Int {
    case notStarted = 0
    case started
    case failedORNoMoreData
}

//MARK: - KEYS -

let kAppName = "projectName"
let kDeviceType = "ios"
var kInternetUnavailable = "Please check your internet connection and try again."
var kNetworkError = "Sorry we are unable to connect with the server, please try again later"
let kPleaseWait = "Please Wait"
let kAlert = "Alert"

//USERDEFAULTS KEYS
let kAuthToken = "_token"
let configurationData = "configData"
let isOnBoradingScreenDisplayed = "isOnBoradingScreenDisplayed"
let kRememberMe = "rememberMe"
let kRememberEmail = "rememberEmail"
let kRememberPassword = "rememberPassword"
let kLoggedInUserData = "loggedInUserData"
let kNotifcation = "pushNotification"
let kIsDarkModeEnable = "isDarkModeEnable"
let kUpdateNationality = "UpdateNationality"
let kUpdateDocument = "UpdateDocument"
let kUpdateW8BenForm = "UpdateW8BenForm"
let kUpdateW8BenDeclaration = "UpdateW8BenDeclaration"
let kUpdateWatchlist = "UpdateWatchlist"
let kUpdateAlert = "UpdateAlert"
let kUpdateOrder = "UpdateOrder"
let kUpdateTradingAccount = "UpdateTradingAccount"
let kUpdatePortfolio = "UpdatePortfolio"
let kAddCardDetail = "AddCardDetail"
let kUpdateCardDetail = "UpdateCardDetail"

//NOTIFICATIONCENTER KEYS
let biometricLockEnabled = "biometricLockEnabled"
let userEmail = "loggedInUserEmail"
let userPassword = "loggedInUserPassword"

//SOCKET.IO KEYS
let EMIT_TYPE_BARS   = "bars"       //live Open/Close Price
let EMIT_TYPE_TRADES = "trades"     //live price
let EMIT_TYPE_QUOTES = "quotes"     //live bid/ask

//SOCKET.IO 'EMIT' KEYS
let EMIT_SUBSCRIBE = "subscribe"

//SOCKET.IO 'ON' KEYS
let SUBSCRIBE_BARS   = "subscribe_daily_bars"  //live Open/Close Price
let SUBSCRIBE_TRADES = "subscribe_trades"      //live price
let SUBSCRIBE_QUOTES = "subscribe_quotes"      //live bid/ask

//SOCKET.IO NOTIFICATION KEYS
let kUpdateDashboardBars = "UpdateDashboardBars"
let kUpdateDashboardTrades = "UpdateDashboardTrades"
let kUpdateStockBars = "UpdateStockBars"
let kUpdateStockTrades = "UpdateStockTrades"
let kUpdateStockQuotes = "UpdateStockQuotes"
let kUpdateAlertBars = "UpdateAlertBars"
let kUpdateAlertTrades = "UpdateAlertTrades"
let kUpdateBuySellBars = "UpdateBuySellBars"
let kUpdateBuySellTrades = "UpdateBuySellTrades"
let kUpdateBuySellFractionalBars = "UpdateBuySellFractionalBars"
let kUpdateBuySellFractionalTrades = "UpdateBuySellFractionalTrades"
let kUpdateWatchlistBars = "UpdateWatchlistBars"
let kUpdateWatchlistTrades = "UpdateWatchlistTrades"
let kUpdatePortfolioBars = "UpdatePortfolioBars"
let kUpdatePortfolioTrades = "UpdatePortfolioTrades"
let kUpdateOrdersBars = "UpdateOrdersBars"
let kUpdateOrdersTrades = "UpdateOrdersTrades"
let kUpdateMarketBars = "UpdateMarketBars"
let kUpdateMarketTrades = "UpdateMarketTrades"
let kUpdateThemeBars = "UpdateThemeBars"
let kUpdateThemeTrades = "UpdateThemeTrades"
let kUpdateModifyBuySellBars = "UpdateModifyBuySellBars"
let kUpdateModifyBuySellTrades = "UpdateModifyBuySellTrades"
