//
//  ValueOrError.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 02/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

enum ValueOrError<T> {
    case error(Error)
    case value(T)
}

extension ValueOrError {
    
    var error: Error! {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
    var value: T! {
        switch self {
        case .value(let value):
            return value
        default:
            return nil
        }
    }
    
    init(valueGenerator block: () throws -> T) {
        do {
            let value = try block()
            self = .value(value)
        } catch {
            self = .error(error)
        }
    }
}
