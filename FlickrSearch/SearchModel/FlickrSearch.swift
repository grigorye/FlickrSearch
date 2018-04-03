//
//  FlickrSearchSession.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSURLSession
import Foundation.NSDate

private let session: URLSession = URLSession(configuration: .default)

class FlickrSearch {
    
    let text: String
    let date: Date
    
    func loadMore(page: Int = 1, perPage: Int, completion: @escaping (ValueOrError<FlickrPhotosSearchResult>) -> Void) {
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: date, page: page, perPage: perPage) {
            completion($0)
        }
        task.resume()
    }
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}
