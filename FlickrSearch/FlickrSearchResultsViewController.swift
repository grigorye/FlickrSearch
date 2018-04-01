//
//  FlickrSearchResultsViewController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

typealias Photo = FlickrPhotosSearchResult.Photos.Photo

private let cellReuseIdentifier = "FlickrSearchResultItemCell"
private let cellNibName = "FlickrSearchResultItemCell"
private let showDetailSegueIdentifier = "showDetail"

class FlickrSearchResultsViewController: UICollectionViewController, FlickrSearchResultsUpdaterDelegate {

    lazy var searchResultsUpdater = FlickrSearchResultsUpdater() … {
        $0.delegate = self
    }
    private var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionView = self.collectionView!

        collectionView.register(UINib(nibName: cellNibName, bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)

        let searchBar = UISearchBar() … {
            $0.delegate = self.searchResultsUpdater
            $0.sizeToFit()
        }
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            if let indexPath = collectionView?.indexPathsForSelectedItems?.last {
                assert(indexPath.section == 0)
                let photo = photos[indexPath.row]
                _ = x$(photo)
                let controller = (segue.destination as! UINavigationController).topViewController as! FlickrSearchResultDetailViewController
                controller.photo = photo
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: -
    
    var batchUpdatesFinished = true
    func addMorePhotos(_ morePhotos: [Photo]) {
        let collectionView = self.collectionView!
        let oldPhotosCount = x$(photos.count)
        photos += morePhotos
        let indexPaths = (oldPhotosCount..<photos.count).map { IndexPath(item: $0, section: 0) }
        batchUpdatesFinished = false
        if oldPhotosCount == 0 { // http://openradar.appspot.com/12954582
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
    
    // MARK: - Flickr search results updater delegate
    
    func flickrSearchResultsUpdaterDidResetSearch(_ updater: FlickrSearchResultsUpdater) {
        let text = updater.search.text
        _ = x$(text)
        photos = []
        collectionView?.reloadData()
    }
    
    func flickrSearchResultsUpdater(_ updater: FlickrSearchResultsUpdater, didLoadMorePhotos morePhotos: [Photo]) {
        let text = updater.search.text
        _ = x$(text)
        self.addMorePhotos(morePhotos)
    }

    // MARK: - Collection View

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: showDetailSegueIdentifier, sender: self)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return x$(photos.count)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(indexPath.section == 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let photo = photos[indexPath.row]
        configureCell(cell, withPhoto: photo)
        return cell
    }

    func configureCell(_ cell: UICollectionViewCell, withPhoto photo: Photo) {
        (cell as! FlickrSearchResultItemCell) … {
            $0.textLabel.text = photo.id
        }
    }
}

extension FlickrSearchResultsViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfColumns = 3
        let collectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let side = (collectionView.bounds.size.width - collectionViewFlowLayout.minimumInteritemSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)

        return CGSize(width: side, height: side + 50)
    }
}
