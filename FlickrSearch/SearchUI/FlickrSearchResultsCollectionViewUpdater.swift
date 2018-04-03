//
//  FlickrSearchResultsCollectionViewUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UICollectionView
import Foundation.NSIndexPath
import Foundation.NSObject

/// Synchronizes the fetched search results with the collection view.
class FlickrSearchResultsCollectionViewUpdater : NSObject, FlickrSearchResultsControllerDelegate {
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    // MARK: - FlickrSearchResultsControllerDelegate
    
    func searchResultsControllerDidResetSearch(_ controller: FlickrSearchResultsController) {
        collectionView.reloadData()
    }
    
    private var batchUpdatesFinished = true

    func searchResultsController(_ controller: FlickrSearchResultsController, didLoadMorePhotosAt indexPaths: [IndexPath]) {
        assert(x$(batchUpdatesFinished) || true)
        /*if (controller.photos.count - indexPaths.count) == 0 { // http://openradar.appspot.com/12954582
            collectionView.reloadData()
        } else*/ do {
            batchUpdatesFinished = false
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: { (finished) in
                _ = x$(finished)
                assert(finished)
                self.batchUpdatesFinished = true
            })
        }
    }

    func searchResultsControllerDidCompleteLoad(_ controller: FlickrSearchResultsController) {
        _ = x$(controller)
    }
    
    // MARK: -
    
    let collectionView: UICollectionView
}

protocol FlickrSearchResultsCollectionViewUpdaterDelegate : class {
    
    func flickrSearchResultsCollectionViewUpdaterDidUpdate(_ updater: FlickrSearchResultsCollectionViewUpdater)
}
