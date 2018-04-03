//
//  FlickrSearchResultsViewController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

private let showDetailSegueIdentifier = "showDetail"

class FlickrSearchResultsViewController: UICollectionViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        configureSearchInput()
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

    // MARK: - RoutingToDetailView

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: showDetailSegueIdentifier, sender: self)
    }
    
    // MARK: - InitiatingSearch (UISearchBarDelegate)
    
    func configureSearchInput() {
        let searchBar = UISearchBar() … {
            $0.delegate = self
            $0.placeholder = NSLocalizedString("Search", comment: "")
            $0.sizeToFit()
        }
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultsLoader.updateSearchResults(for: searchText)
    }
    
    // MARK: - TriggeringLoadMore
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        triggerLoadMoreIfNecessary()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        triggerLoadMoreIfNecessary()
    }
    
    // MARK: - MaintainingItemSize
    
    lazy var onceInViewWillLayoutSubviews: () = {
        collectionViewFlowLayout.itemSize = itemSize(forCollectionViewSize: collectionView!.bounds.size)
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _ = onceInViewWillLayoutSubviews
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionViewFlowLayout.itemSize = itemSize(forCollectionViewSize: size)
    }
    
    // MARK: - DataSource
    
    func configureDataSource() {
        let collectionView = self.collectionView!
        
        collectionViewDataSource.prepareCollectionView(collectionView)
    }
    
    private lazy var collectionViewDataSource = FlickrSearchResultsCollectionViewDataSource(dataSource: searchResultsController)
    
    // MARK: - SharedProperties
    
    private lazy var searchResultsController = FlickrSearchResultsController(delegate: FlickrSearchResultsCollectionViewUpdater(collectionView: collectionView!))
    
    private lazy var searchResultsLoader = FlickrSearchResultsLoader(delegate: searchResultsController)
}

// MARK: - LoadMore

extension FlickrSearchResultsViewController {
    func triggerLoadMoreIfNecessary() {
        if shouldLoadMore() {
            triggerLoadMore()
        }
    }
    
    private func shouldLoadMore() -> Bool {
        guard nil != searchResultsLoader.search else {
            return false
        }
        
        guard !searchResultsLoader.loading else {
            return false
        }
        
        guard !searchResultsLoader.loadCompleted else {
            return false
        }

        let collectionView = self.collectionView!
        
        let heightToBeScrolled = (collectionView.contentSize.height) - (collectionView.contentOffset.y) - (collectionView.bounds.height)
        
        let heightToBeScrolledForLoadMore = CGFloat(UserDefaults.standard.double(forKey: "heightToBeScrolledForLoadMore"))
        assert(0 < heightToBeScrolledForLoadMore)
        
        guard (heightToBeScrolled) < heightToBeScrolledForLoadMore else {
            return false
        }
        
        return true
    }
    
    var perPage: Int {
        return (flickrDefaultPerPage - flickrDefaultPerPage % numberOfColumns) - searchResultsController.photos.count % numberOfColumns
    }
    
    private func triggerLoadMore() {
        if !searchResultsLoader.loading {
            searchResultsLoader.loadMore(perPage: x$(perPage))
        }
    }
}

extension FlickrSearchResultsViewController {
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var numberOfColumns: Int {
        let numberOfColumns = UserDefaults.standard.integer(forKey: "numberOfColumnsInSearchResults")
        assert(0 < numberOfColumns)
        return numberOfColumns
    }
    
    func itemSize(forCollectionViewSize collectionViewSize: CGSize) -> CGSize {
        let side = (collectionViewSize.width - collectionViewFlowLayout.minimumInteritemSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        
        return CGSize(width: side, height: side + min(side * 0.4, 50))
    }
}
