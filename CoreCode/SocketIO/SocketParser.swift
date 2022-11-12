//
//  SocketParser.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 09/02/22.
//

import Foundation

class SocketParser {

    static func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }

    static func convert<T: Decodable>(datas: [Any]) throws -> [T] {
        return try datas.map { (dict) -> T in
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        }
    }
}
