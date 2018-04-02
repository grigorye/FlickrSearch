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

class FlickrSearchResultsCollectionViewUpdater : NSObject, FlickrSearchResultsControllerDelegate {
    
    init(collectionView: UICollectionView, delegate: FlickrSearchResultsCollectionViewUpdaterDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
    }

    // MARK: - FlickrSearchResultsControllerDelegate
    
    func searchResultsControllerDidResetSearch(_ controller: FlickrSearchResultsController) {
        collectionView.reloadData()
    }
    
    private var batchUpdatesFinished = true

    func searchResultsController(_ controller: FlickrSearchResultsController, didLoadMorePhotosAt indexPaths: [IndexPath]) {
        assert(batchUpdatesFinished)
        if (controller.photos.count - indexPaths.count) == 0 { // http://openradar.appspot.com/12954582
            collectionView.reloadData()
        } else {
            batchUpdatesFinished = false
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: { (finished) in
                _ = x$(finished)
                assert(finished)
                self.batchUpdatesFinished = true
                self.delegate.flickrSearchResultsCollectionViewUpdaterDidUpdate(self)
            })
        }
    }

    // MARK: -
    
    let collectionView: UICollectionView
    weak var delegate: FlickrSearchResultsCollectionViewUpdaterDelegate!
}

protocol FlickrSearchResultsCollectionViewUpdaterDelegate : class {
    
    func flickrSearchResultsCollectionViewUpdaterDidUpdate(_ updater: FlickrSearchResultsCollectionViewUpdater)
}
