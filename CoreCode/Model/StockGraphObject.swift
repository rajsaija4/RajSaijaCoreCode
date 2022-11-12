//
//  StockGraphObject.swift
//  projectName
//
//  companyName on 07/03/22.
//

import Foundation

class StockGraphObject: NSObject, Codable {
    var t: String = ""
    var o: Double = 0.0
    var h: Double = 0.0
    var l: Double = 0.0
    var c: Double = 0.0
    var v: Int = 0
    var n: Double = 0.0
    var vw: Double = 0.0
    
    init(_ dictionary: [String: Any]) {
        self.t = dictionary["t"] as? String ?? ""
        self.o = dictionary["o"] as? Double ?? 0.0
        self.h = dictionary["h"] as? Double ?? 0.0
        self.l = dictionary["l"] as? Double ?? 0.0
        self.c = dictionary["c"] as? Double ?? 0.0
        self.v = dictionary["v"] as? Int ?? 0
        self.n = dictionary["n"] as? Double ?? 0.0
        self.vw = dictionary["vw"] as? Double ?? 0.0
    }
}
