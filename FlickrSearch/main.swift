//
//  main.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 30/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UIApplication

#if canImport(GETracing) && canImport(GEFoundation)

import func GEFoundation.defaultLogger
import var GETracing.loggers

UserDefaults.standard.register(defaults: ["traceEnabled":true, "defaultLogKind":"print", "sourceLabelsEnabled":true])

loggers += [
    defaultLogger
]

#endif

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    nil,
    NSStringFromClass(AppDelegate.self)
)
