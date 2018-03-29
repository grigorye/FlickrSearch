//
//  OptionallyDecodedString.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 29/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSData

enum OptionallyDecodedString {
    case string(String)
    case data(Data)
    
    init(_ data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            self = .string(string)
        } else {
            self = .data(data)
        }
    }
}
