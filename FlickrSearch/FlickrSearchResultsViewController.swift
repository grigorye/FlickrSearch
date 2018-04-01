//
//  FlickrSearchResultsViewController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

private let showDetailSegueIdentifier = "showDetail"

class FlickrSearchResultsViewController: UICollectionViewController, UISearchBarDelegate, CollectionViewLoadOnScrollTriggerDelegate {

    lazy var collectionViewUpdater = FlickrSearchResultsCollectionViewUpdater(collectionView: collectionView!)
    
    lazy var searchResultsUpdater = FlickrSearchResultsUpdater() … {
        $0.delegate = searchResultsController
    }
    lazy var searchResultsController = FlickrSearchResultsController(delegate: collectionViewUpdater)
    lazy var collectionViewDataSource = FlickrSearchResultsCollectionViewDataSource(dataSource: searchResultsController)
    
    lazy var collectionViewOnLoadOnScrollTrigger = CollectionViewLoadMoreOnScrollTrigger(delegate: self, numberOfScrollableItemsForTrigger: 50)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionView = self.collectionView!
        
        collectionViewDataSource.prepareCollectionView(collectionView)
        collectionViewOnLoadOnScrollTrigger.prepareCollectionView(collectionView)

        let searchBar = UISearchBar() … {
            $0.delegate = self
            $0.placeholder = NSLocalizedString("Search", comment: "")
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
                let photo = searchResultsController.photos[indexPath.row]
                _ = x$(photo)
                let controller = (segue.destination as! UINavigationController).topViewController as! FlickrSearchResultDetailViewController
                controller.photo = photo
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Collection View

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: showDetailSegueIdentifier, sender: self)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultsUpdater.updateSearchResults(for: searchText)
    }
    
    // MARK: - CollectionViewLoadOnScrollTriggerDelegate
    
    func triggerLoadMoreOnScroll(_ trigger: CollectionViewLoadMoreOnScrollTrigger, for collectionView: UICollectionView) {
        assert(collectionView == self.collectionView)
        if !searchResultsUpdater.loading {
            searchResultsUpdater.loadMore()
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
