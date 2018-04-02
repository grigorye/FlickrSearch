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

class CollectionViewLoadMoreTrigger : NSObject, UIScrollViewDelegate {
    
    init(delegate: CollectionViewLoadMoreTriggerDelegate) {
        self.delegate = delegate
    }

    func prepareCollectionView(_ collectionView: UICollectionView) {
        nextDelegate = collectionView.delegate ?? noNextScrollViewDelegate
        (collectionView as UIScrollView).delegate = self
    }
    
    func triggerLoadMoreIfNecessary(for collectionView: UICollectionView) {
        if (shouldLoadMore(for: collectionView)) {
            delegate.triggerLoadMore(self, for: collectionView)
        }
    }
    
    // MARK: -
    
    func shouldLoadMore(for collectionView: UICollectionView) -> Bool {
        return delegate.shouldLoadMoreFor(self)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        
        triggerLoadMoreIfNecessary(for: collectionView)
        
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
    private(set) weak var delegate: CollectionViewLoadMoreTriggerDelegate!
}

protocol CollectionViewLoadMoreTriggerDelegate : class {
    
    func shouldLoadMoreFor(_ trigger: CollectionViewLoadMoreTrigger) -> Bool
    func triggerLoadMore(_ trigger: CollectionViewLoadMoreTrigger, for collectionView: UICollectionView)
}

private class NoNextScrollViewDelegate : NSObject, UIScrollViewDelegate {}
private let noNextScrollViewDelegate = NoNextScrollViewDelegate()
