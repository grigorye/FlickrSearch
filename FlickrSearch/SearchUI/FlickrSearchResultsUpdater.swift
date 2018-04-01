//
//  SearchResultsUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

protocol FlickrSearchResultsUpdaterDelegate : class {
    func flickrSearchResultsUpdaterDidResetSearch(_ updater: FlickrSearchResultsUpdater)
    func flickrSearchResultsUpdater(_ updater: FlickrSearchResultsUpdater, didLoadMorePhotos morePhotos: [Photo])
}

class FlickrSearchResultsUpdater : NSObject, UISearchResultsUpdating, UISearchBarDelegate {
    
    var search: FlickrSearch!
    
    weak var delegate: FlickrSearchResultsUpdaterDelegate!
    
    // MARK: - FlickrSearchResultsUpdaterDelegate
    
    private func didLoadMorePhotos(_ photos: [Photo]) {
        delegate.flickrSearchResultsUpdater(self, didLoadMorePhotos: photos)
    }
    
    private func didResetSearch() {
        delegate.flickrSearchResultsUpdaterDidResetSearch(self)
    }

    // MARK: - UISearchControllerDelegate
    
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults(for: searchController.searchBar.text!)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchText)
    }
    
    // MARK: -
    
    func updateSearchResults(for text: String) {

        let search = FlickrSearch(text: x$(text), date: Date())
        self.search = search
        
        didResetSearch()

        guard text.trimmingCharacters(in: CharacterSet.whitespaces) != "" else {
            // Flickr doesn't support search with no text.
            return
        }

        search.loadMore { [oldSearch = search] (throwingResult) in
            DispatchQueue.main.async {
                guard x$(oldSearch === self.search) else {
                    // Ignore no longer actual completion.
                    _ = x$(oldSearch.text)
                    return
                }
                dispatch(throwingResult, catch: { error in
                    _ = x$(error)
                    _ = x$((error as NSError).userInfo)
                }, or: { [weak self] in
                    _ = x$($0)
                    //http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
                    let photos = $0.photos.photo
                    self?.didLoadMorePhotos(photos)
                })
            }
        }
    }
}
