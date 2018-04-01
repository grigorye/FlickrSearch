//
//  FlickrSearchModelElements.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

typealias Photo = FlickrPhotosSearchResult.Photos.Photo

protocol PhotosDataSource {
    var photos: [Photo] { get }
}
