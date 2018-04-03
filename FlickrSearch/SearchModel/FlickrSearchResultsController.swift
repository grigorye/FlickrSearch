//
//  FlickrSearchResultsController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSIndexPath

/// Accumulates the loaded search results. Similar to NSFetchedResultsController. Should be attached to FlickrSearchResultsLoader.
class FlickrSearchResultsController : FlickrSearchResultsLoaderDelegate, PhotosDataSource {
    
    init(delegate: FlickrSearchResultsControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - FlickrSearchResultsLoaderDelegate
    
    func flickrSearchResultsLoaderDidResetSearch(_ loader: FlickrSearchResultsLoader) {
        let text = loader.search.text
        _ = x$(text)
        photos = []
        delegate.searchResultsControllerDidResetSearch(self)
    }
    
    func flickrSearchResultsLoader(_ loader: FlickrSearchResultsLoader, didLoadMorePhotos morePhotos: [Photo]) {
        let text = loader.search.text
        _ = x$(text)
        let oldPhotosCount = x$(photos.count)
        photos += morePhotos
        let indexPaths = (oldPhotosCount..<photos.count).map { IndexPath(item: $0, section: 0) }
        delegate.searchResultsController(self, didLoadMorePhotosAt: indexPaths)
    }
    
    func flickrSearchResultsLoaderDidCompleteLoad(_ loader: FlickrSearchResultsLoader) {
        delegate.searchResultsControllerDidCompleteLoad(self)
    }

    private(set) var photos = [Photo]()
    
    let delegate: FlickrSearchResultsControllerDelegate
}

protocol FlickrSearchResultsControllerDelegate {
    
    func searchResultsControllerDidResetSearch(_ controller: FlickrSearchResultsController)
    
    func searchResultsController(_ controller: FlickrSearchResultsController, didLoadMorePhotosAt indexPaths: [IndexPath])
    
    func searchResultsControllerDidCompleteLoad(_ controller: FlickrSearchResultsController)
}
