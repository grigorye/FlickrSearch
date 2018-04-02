//
//  Sugar.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

#if !(canImport(GETracing) && canImport(GEFoundation))

import Foundation

infix operator … : MultiplicationPrecedence

@discardableResult
func …<T>(_ v: T, block: (inout T) throws -> Void) rethrows -> T {
    var mutableV = v
    try block(&mutableV)
    return mutableV
}

#if true

func x$<T>(_ v: T) -> T {
    return v
}

#else

private func xx$<T>(_ v: T) -> String {
    var s = ""
    debugPrint(v, to: &s)
    return s
}

private func printDumped(_ type: String, _ s: String, function: String, file: String, line: Int) {
    print("\(URL(fileURLWithPath: file).lastPathComponent):\(line)|\(function):\n\(s)")
}

func x$<T>(_ v: T?, function: String = #function, file: String = #file, line: Int = #line) -> T? {
    printDumped("\(type(of: v))", xx$(v), function: function, file: file, line: line)
    return v
}

func x$<T>(_ v: T, function: String = #function, file: String = #file, line: Int = #line) -> T {
    printDumped("\(type(of: v))", xx$(v), function: function, file: file, line: line)
    return v
}

#endif

#endif
