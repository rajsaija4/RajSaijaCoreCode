//
//  SnapshotObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 16/03/22.
//

import Foundation

class SnapshotObject: NSObject, Codable {
    var objLatestTrade: LatestTradeObject = LatestTradeObject.init([:])
    var objLatestQuote: LatestQuoteObject = LatestQuoteObject.init([:])
    var objMinuteBar: BarObject = BarObject.init([:])
    var objDailyBar: BarObject = BarObject.init([:])
    var objPrevDailyBar: BarObject = BarObject.init([:])
    
    init(_ dictionary: [String: Any]) {
        if let latestTrade = dictionary["latestTrade"] as? Dictionary<String, Any> {
            self.objLatestTrade = LatestTradeObject.init(latestTrade)
        }
        if let latestQuote = dictionary["latestQuote"] as? Dictionary<String, Any> {
            self.objLatestQuote = LatestQuoteObject.init(latestQuote)
        }
        if let minuteBar = dictionary["minuteBar"] as? Dictionary<String, Any> {
            self.objMinuteBar = BarObject.init(minuteBar)
        }
        if let dailyBar = dictionary["dailyBar"] as? Dictionary<String, Any> {
            self.objDailyBar = BarObject.init(dailyBar)
        }
        if let prevDailyBar = dictionary["prevDailyBar"] as? Dictionary<String, Any> {
            self.objPrevDailyBar = BarObject.init(prevDailyBar)
        }
    }
}

//MARK: - LATEST TRADE OBJECT
class LatestTradeObject: NSObject, Codable {
    var t: String = ""
    var x: String = ""
    var p: Double = 0.0
    var s: Int = 0
    var c: [String] = []
    var i: Int = 0
    var z: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.t = dictionary["t"] as? String ?? ""
        self.x = dictionary["x"] as? String ?? ""
        self.p = dictionary["p"] as? Double ?? 0.0
        self.s = dictionary["s"] as? Int ?? 0
        self.c = dictionary["c"] as? [String] ?? []
        self.i = dictionary["i"] as? Int ?? 0
        self.z = dictionary["z"] as? String ?? ""
    }
}

//MARK: - LATEST QUOTE OBJECT
class LatestQuoteObject: NSObject, Codable {
    var t: String = ""
    var ax: String = ""
    var ap: Double = 0.0
    var as_: Int = 0
    var bx: String = ""
    var bp: Double = 0.0
    var bs: Int = 0
    var c: [String] = []
    var z: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.t = dictionary["t"] as? String ?? ""
        self.ax = dictionary["ax"] as? String ?? ""
        self.ap = dictionary["ap"] as? Double ?? 0.0
        self.as_ = dictionary["as"] as? Int ?? 0
        self.bx = dictionary["bx"] as? String ?? ""
        self.bp = dictionary["bp"] as? Double ?? 0.0
        self.bs = dictionary["bs"] as? Int ?? 0
        self.c = dictionary["c"] as? [String] ?? []
        self.z = dictionary["z"] as? String ?? ""
    }
}

//MARK: - BAR OBJECT
class BarObject: NSObject, Codable {
    var t: String = ""
    var o: Double = 0.0
    var h: Double = 0.0
    var l: Double = 0.0
    var c: Double = 0.0
    var v: Int = 0
    var n: Int = 0
    var vw: Double = 0.0
    
    init(_ dictionary: [String: Any]) {
        self.t = dictionary["t"] as? String ?? ""
        self.o = dictionary["o"] as? Double ?? 0.0
        self.h = dictionary["h"] as? Double ?? 0.0
        self.l = dictionary["l"] as? Double ?? 0.0
        self.c = dictionary["c"] as? Double ?? 0.0
        self.v = dictionary["v"] as? Int ?? 0
        self.n = dictionary["n"] as? Int ?? 0
        self.vw = dictionary["vw"] as? Double ?? 0.0
    }
}
