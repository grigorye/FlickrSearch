//
//  FlickrSearchRequestsOnlineTests.swift
//  FlickrSearchTests
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

@testable import FlickrSearch
import XCTest

class FlickrSearchRequestsOnlineTests: XCTestCase {
    
    // MARK: - Goods
    
    func test(with text: String, page: Int = 1, expectEmpty: Bool = false) {
        let session = URLSession(configuration: .default)
        let taskCompleted = expectation(description: "Task completed")
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: Date(), page: page) { (searchResultOrError) in
            defer { taskCompleted.fulfill() }
            guard let searchResult = searchResultOrError.value else {
                XCTFail("\(searchResultOrError.error!)")
                return
            }
            if expectEmpty {
                XCTAssertEqual(0, searchResult.photos.photo.count)
            } else {
                XCTAssert(0 < searchResult.photos.photo.count)
            }
            _ = x$((totalPhotos: searchResult.photos.total, lastPhoto: searchResult.photos.photo.last))
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
    
    func testOne() {
        test(with: "Kittens ABCD")
    }
    
    func testEmpty() {
        test(with: "Kittens ABCDE", expectEmpty: true)
    }

    // MARK: - Bads

    func test(with text: String, expectedErrorHandler: @escaping (Error) -> Void) {
        let session = URLSession(configuration: .default)
        let taskCompleted = expectation(description: "Task completed")
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: Date()) { (searchResultOrError) in
            defer { taskCompleted.fulfill() }
            guard let error = searchResultOrError.error else {
                XCTFail("\(searchResultOrError.value!)")
                return
            }
            expectedErrorHandler(error)
        }
        task.resume()
        waitForExpectations(timeout: 2)
    }
    
    func testFailureOnEmpty() {
        test(with: "", expectedErrorHandler: { error in
            switch error {
            case FlickrSearchError.flickrFail(let flickrFail) where flickrFail.code == 3:
                _ = x$(flickrFail.message, name: "message")
            default:
                XCTFail("\(error)")
            }
        })
    }
}
