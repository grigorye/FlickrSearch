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

class FlickrSearchResultsUpdater : NSObject, UISearchResultsUpdating {
    
    var search: FlickrSearch!
    
    weak var delegate: FlickrSearchResultsUpdaterDelegate!
    
    private func didLoadMorePhotos(_ photos: [Photo]) {
        delegate.flickrSearchResultsUpdater(self, didLoadMorePhotos: photos)
    }
    
    private func didResetSearch() {
        delegate.flickrSearchResultsUpdaterDidResetSearch(self)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        
        guard text != "" else {
            // Flickr doesn't support search with no text.
            return
        }
        
        let search = FlickrSearch(text: x$(text), date: Date())
        self.search = search
        
        didResetSearch()
        
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
