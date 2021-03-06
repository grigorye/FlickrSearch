//
//  main.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 30/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UIApplication

#if canImport(GETracing) && canImport(GEFoundation)

@_exported import GETracing
@_exported import GEFoundation

import func GEFoundation.defaultLogger
import var GETracing.loggers

loggers += [
    defaultLogger
]

#endif

let defaultsPlistURL = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
try! loadDefaultsFromSettingsPlistAtURL(defaultsPlistURL)

_ = UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    nil,
    NSStringFromClass(AppDelegate.self)
)
