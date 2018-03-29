//
//  FlickrSearchRequestsOnlineTests.swift
//  FlickrSearchTests
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrSearchRequestsOnlineTests: XCTestCase {
    
    // MARK: - Goods
    
    func test(with text: String, page: Int = 1) {
        let session = URLSession(configuration: .default)
        let taskCompleted = expectation(description: "Task completed")
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: Date(), page: page) {
            dispatch($0, catch: { error in
                XCTFail("\(error)")
                taskCompleted.fulfill()
            }, or: {
                XCTAssert(0 < $0.photos.photo.count)
                _ = x$($0.photos.total)
                _ = x$($0.photos.photo.last)
                taskCompleted.fulfill()
            })
        }
        task.resume()
        waitForExpectations(timeout: 2)
    }
    
    func testKittens() {
        test(with: "Kittens")
    }
    
    func testKittens2() {
        test(with: "Kittens", page: 2)
    }
    
    func testUnicode() {
        test(with: "Котята ❤️")
    }
    
    // MARK: - Bads

    func test(with text: String, expectedErrorHandler: @escaping (Error) -> Void) {
        let session = URLSession(configuration: .default)
        let taskCompleted = expectation(description: "Task completed")
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: Date()) {
            dispatch($0, catch: { error in
                expectedErrorHandler(error)
                taskCompleted.fulfill()
            }, or: {
                XCTFail("\($0)")
                taskCompleted.fulfill()
            })
        }
        task.resume()
        waitForExpectations(timeout: 2)
    }
    
    func testFailureOnEmpty() {
        test(with: "", expectedErrorHandler: { error in
            switch error {
            case FlickrSearchError.flickrFail(let flickrFail) where flickrFail.code == 3:
                _ = x$(flickrFail.message)
            default:
                XCTFail("\(error)")
            }
        })
    }
}
