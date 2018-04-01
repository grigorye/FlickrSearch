//
//  CollectionViewLoadMoreOnScrollTrigger.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UIScrollView
import UIKit.UICollectionView
import Foundation.NSObject
import ObjectiveC

class CollectionViewLoadMoreOnScrollTrigger : NSObject, UIScrollViewDelegate {
    
    let numberOfScrollableItemsForTrigger: Int
    
    init(delegate: CollectionViewLoadOnScrollTriggerDelegate, numberOfScrollableItemsForTrigger: Int) {
        self.delegate = delegate
        self.numberOfScrollableItemsForTrigger = numberOfScrollableItemsForTrigger
    }

    func prepareCollectionView(_ collectionView: UICollectionView) {
        nextDelegate = collectionView.delegate ?? noNextScrollViewDelegate
        (collectionView as UIScrollView).delegate = self
    }
    
    // MARK: -
    
    func shouldLoadMore(for collectionView: UICollectionView) -> Bool {
        guard let indexPathForLastVisibleItem = collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row }).last else {
            return false
        }
        
        guard (collectionView.numberOfItems(inSection: 0) - indexPathForLastVisibleItem.row) < numberOfScrollableItemsForTrigger else {
            return false
        }
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        
        if x$(shouldLoadMore(for: collectionView)) {
            delegate.triggerLoadMoreOnScroll(self, for: collectionView)
        }
        
        nextDelegate.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: -
    
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || nextDelegate.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if (nextDelegate.responds(to: (aSelector))) {
            return nextDelegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    
    // MARK: -
    
    private weak var nextDelegate: UIScrollViewDelegate!
    private(set) weak var delegate: CollectionViewLoadOnScrollTriggerDelegate!
}

protocol CollectionViewLoadOnScrollTriggerDelegate : class {
    
    func triggerLoadMoreOnScroll(_ trigger: CollectionViewLoadMoreOnScrollTrigger, for collectionView: UICollectionView)
}

private class NoNextScrollViewDelegate : NSObject, UIScrollViewDelegate {}
private let noNextScrollViewDelegate = NoNextScrollViewDelegate()
