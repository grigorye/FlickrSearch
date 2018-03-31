//
//  FlickrSearchSession.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

private let session: URLSession = URLSession(configuration: .default)

class FlickrSearch {
    
    let text: String
    let date: Date
    
    func loadMore(completion: @escaping (@escaping () throws -> FlickrPhotosSearchResult) -> Void) {
        let task = session.dataTaskForFlickrSearch(apiKey: apiKey, text: text, date: date) {
            completion($0)
        }
        task.resume()
    }
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }
}
