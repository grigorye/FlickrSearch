//
//  FlickrSearchModelElements.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSURL

typealias Photo = FlickrPhotosSearchResult.Photos.Photo

protocol PhotosDataSource {
    var photos: [Photo] { get }
}

extension Photo {
    var url: URL {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        let url = URL(string: urlString)!
        return url
    }
    var largeSquareURL: URL {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
        let url = URL(string: urlString)!
        return url
    }
}
