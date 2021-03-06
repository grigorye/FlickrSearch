//
//  FlickrSearchResultsCollectionViewDataSource.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 01/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UICollectionView
import UIKit.UICollectionViewCell
import Foundation.NSObject

private let cellReuseIdentifier = "FlickrSearchResultItemCell"
private let cellNibName = "FlickrSearchResultItemCell"

/// (Passive) search results collection view data source.
class FlickrSearchResultsCollectionViewDataSource : NSObject, UICollectionViewDataSource {

    init(dataSource: PhotosDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: -
    
    func prepareCollectionView(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: cellNibName, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.dataSource = self
    }
    
    func configureCell(_ cell: UICollectionViewCell, withPhoto photo: Photo) {
        (cell as! FlickrSearchResultItemCell) … {
            $0.photo = photo
        }
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return x$(dataSource.photos.count, name: "photosCount")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(indexPath.section == 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let photo = dataSource.photos[indexPath.row]
        configureCell(cell, withPhoto: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        assert(kind == UICollectionElementKindSectionFooter)
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        return footerView
    }
    
    // MARK: -
    
    let dataSource: PhotosDataSource
}
