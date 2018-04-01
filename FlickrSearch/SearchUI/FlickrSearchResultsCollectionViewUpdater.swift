//
//  FlickrSearchResultsCollectionViewUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UICollectionView
import Foundation

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
        batchUpdatesFinished = false
        if (controller.photos.count - indexPaths.count) == 0 { // http://openradar.appspot.com/12954582
            collectionView.reloadData()
        } else {
            assert(batchUpdatesFinished)
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: { (finished) in
                _ = x$(finished)
                assert(finished)
                self.batchUpdatesFinished = true
            })
        }
    }

    // MARK: -
    
    let collectionView: UICollectionView
}

