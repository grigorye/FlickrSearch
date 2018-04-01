//
//  FlickrSearchResultsController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSIndexPath

/// Think of NSFetchedResultsController combined with NSManagedObjectContext.
class FlickrSearchResultsController : FlickrSearchResultsUpdaterDelegate, PhotosDataSource {
    
    init(delegate: FlickrSearchResultsControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - FlickrSearchResultsUpdaterDelegate
    
    func flickrSearchResultsUpdaterDidResetSearch(_ updater: FlickrSearchResultsUpdater) {
        let text = updater.search.text
        _ = x$(text)
        photos = []
        delegate.searchResultsControllerDidResetSearch(self)
    }
    
    func flickrSearchResultsUpdater(_ updater: FlickrSearchResultsUpdater, didLoadMorePhotos morePhotos: [Photo]) {
        let text = updater.search.text
        _ = x$(text)
        let oldPhotosCount = x$(photos.count)
        photos += morePhotos
        let indexPaths = (oldPhotosCount..<photos.count).map { IndexPath(item: $0, section: 0) }
        delegate.searchResultsController(self, didLoadMorePhotosAt: indexPaths)
    }

    private(set) var photos = [Photo]()
    
    let delegate: FlickrSearchResultsControllerDelegate
}

protocol FlickrSearchResultsControllerDelegate {
    
    func searchResultsControllerDidResetSearch(_ controller: FlickrSearchResultsController)
    
    func searchResultsController(_ controller: FlickrSearchResultsController, didLoadMorePhotosAt indexPaths: [IndexPath])
}
