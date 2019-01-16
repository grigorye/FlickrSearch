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
        super.init()
        prepareLoadMore()
    }
    
    /// MARK: -
    
    private func prepareLoadMore() {
        savedFooterReferenceSize = collectionViewFlowLayout.footerReferenceSize
        hideLoadMore()
    }
    
    private func unhideLoadMore() {
        collectionViewFlowLayout.footerReferenceSize = savedFooterReferenceSize
    }
    
    private func hideLoadMore() {
        collectionViewFlowLayout.footerReferenceSize = .zero
    }

    private var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
    }
    
    // MARK: - FlickrSearchResultsControllerDelegate
    
    func searchResultsControllerDidResetSearch(_ controller: FlickrSearchResultsController) {
        collectionView.reloadData()
        hideLoadMore()
    }
    
    func searchResultsController(_ controller: FlickrSearchResultsController, didLoadMorePhotosAt indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }, completion: { (finished) in
            _ = x$(finished, name: "finished")
            assert(finished)
        })
        unhideLoadMore()
    }

    func searchResultsControllerDidCompleteLoad(_ controller: FlickrSearchResultsController) {
        _ = x$(controller)
        hideLoadMore()
    }
    
    // MARK: -
    
    let collectionView: UICollectionView
    private var savedFooterReferenceSize: CGSize!
}

protocol FlickrSearchResultsCollectionViewUpdaterDelegate : class {
    
    func flickrSearchResultsCollectionViewUpdaterDidUpdate(_ updater: FlickrSearchResultsCollectionViewUpdater)
}
