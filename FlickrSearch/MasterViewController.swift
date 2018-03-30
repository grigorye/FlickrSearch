//
//  MasterViewController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

typealias Photo = FlickrPhotosSearchResult.Photos.Photo

class MasterViewController: UICollectionViewController, FlickrSearchResultsUpdaterDelegate {

    lazy var searchResultsUpdater = FlickrSearchResultsUpdater() … {
        $0.delegate = self
    }
    private var photos = [Photo]()
    
    var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionView = self.collectionView!

        collectionView.register(UINib(nibName: "MasterItemCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = collectionView?.indexPathsForSelectedItems?.last {
                assert(indexPath.section == 0)
                let object = photos[indexPath.row]
                _ = x$(object)
                #if false
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                #endif
            }
        }
    }

    // MARK: -
    
    func addMorePhotos(_ morePhotos: [Photo]) {
        let collectionView = self.collectionView!
        let oldPhotosCount = photos.count
        photos += morePhotos
        collectionView.performBatchUpdates({
            let indexPaths = (oldPhotosCount..<photos.count).map { IndexPath(item: $0, section: 0) }
            collectionView.insertItems(at: indexPaths)
        }, completion: { (finished) in
            _ = x$(finished)
        })
    }
    
    // MARK: - Flickr search results updater delegate
    
    func flickrSearchResultsUpdaterDidResetSearch(_ updater: FlickrSearchResultsUpdater) {
        photos = []
        collectionView?.reloadData()
    }
    
    func flickrSearchResultsUpdater(_ updater: FlickrSearchResultsUpdater, didLoadMorePhotos morePhotos: [Photo]) {
        DispatchQueue.main.async {
            self.addMorePhotos(morePhotos)
        }
    }

    // MARK: - Collection View

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(indexPath.section == 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let photo = photos[indexPath.row]
        configureCell(cell, withPhoto: photo)
        return cell
    }

    func configureCell(_ cell: UICollectionViewCell, withPhoto photo: Photo) {
        (cell as! MasterItemCell) … {
            $0.textLabel.text = photo.id
        }
    }
}

extension MasterViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfColumns = 3
        let collectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let side = (collectionView.bounds.size.width - collectionViewFlowLayout.minimumInteritemSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)

        return CGSize(width: side, height: side + 50)
    }
}
