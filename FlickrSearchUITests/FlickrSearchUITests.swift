//
//  FlickrSearchUITests.swift
//  FlickrSearchUITests
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest

class FlickrSearchUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func typeForthAndBack(text: String, delay: TimeInterval) {
        let searchField = XCUIApplication().searchFields["Search"]
        searchField.tap()
        
        for c in text {
            searchField.typeText("\(c)")
            Thread.sleep(forTimeInterval: delay)
        }
        for _ in (0..<text.count) {
            searchField.typeText("" + XCUIKeyboardKey.delete.rawValue)
            Thread.sleep(forTimeInterval: delay)
        }
    }
    
    func testTyping(delay: TimeInterval) {
        for _ in 0..<10 {
            typeForthAndBack(text: "Kittens", delay: delay)
        }
    }
    
    func testTypingWithNoDelay() {
        #if false
        // Workaround for typeText sometimes failing to wait for KeyEventComplete in Simulator
        let oldContinueAfterFailure = continueAfterFailure
        defer { continueAfterFailure = oldContinueAfterFailure }
        #endif

        testTyping(delay: 0)
    }
    
    func testTypingWithSmallDelay() {
        testTyping(delay: 0.1)
    }
    
    func testTypingWithMediumDelay() {
        testTyping(delay: 0.2)
    }
    
    func testTypingWithLongEnoughDelay() {
        testTyping(delay: 0.5)
    }
}
