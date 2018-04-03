//
//  FlickrSearchLoaderOnlineTests.swift
//  FlickrSearchTests
//
//  Created by Grigory Entin on 02/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

@testable import FlickrSearch
import XCTest

private class X : NSObject, FlickrSearchResultsLoaderDelegate {
    
    var didResetSearch: XCTestExpectation?
    var didLoadMore: XCTestExpectation?
    var didCompleteLoad: XCTestExpectation?
    
    func flickrSearchResultsLoaderDidResetSearch(_ loader: FlickrSearchResultsLoader)
    {
        didResetSearch?.fulfill()
    }
    
    func flickrSearchResultsLoader(_ loader: FlickrSearchResultsLoader, didLoadMorePhotos morePhotos: [Photo]) {
        didLoadMore?.fulfill()
    }
    
    func flickrSearchResultsLoaderDidCompleteLoad(_ loader: FlickrSearchResultsLoader) {
        didCompleteLoad?.fulfill()
    }
}

class FlickrSearchLoaderOnlineTests: XCTestCase {
    
    func test(with text: String, page: Int = 1, pages: Int = 1, shouldCompleteLoad: Bool) {
        
        let x = X()
        x.didResetSearch = expectation(description: "Did Reset Search")
        if shouldCompleteLoad {
            x.didCompleteLoad = expectation(description: "Did Complete Load")
        }
        x.didLoadMore = expectation(description: "Did Load More")
        x.didLoadMore?.expectedFulfillmentCount = pages
        
        let loader = FlickrSearchResultsLoader(delegate: x)
        loader.updateSearchResults(for: text)
        for _ in 0..<(pages - 1) {
            while loader.loading { RunLoop.current.run(until: Date().addingTimeInterval(0.1)) }
            loader.loadMore()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(!loader.loading)
        XCTAssertEqual(loader.loadCompleted, shouldCompleteLoad)
        XCTAssertNotNil(x)
    }
    
    func testKittens() {
        test(with: "Kittens", shouldCompleteLoad: false)
    }
    
    func testKittens2() {
        test(with: "Kittens", page: 2, shouldCompleteLoad: false)
    }
    
    func testUnicode() {
        test(with: "Котята ❤️", shouldCompleteLoad: true)
    }
    
    func testOnePage() {
        test(with: "Kittens ABCD", shouldCompleteLoad: true)
    }
    
    func testTwoPages() {
        test(with: "Kittens ABC", pages: 2, shouldCompleteLoad: true)
    }

    func testEmpty() {
        test(with: "Kittens ABCDE", shouldCompleteLoad: true)
    }

}
