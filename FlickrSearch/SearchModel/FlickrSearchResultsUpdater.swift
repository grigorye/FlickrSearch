//
//  FlickrSearchResultsUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSDate

protocol FlickrSearchResultsUpdaterDelegate : class {
    
    func flickrSearchResultsUpdaterDidResetSearch(_ updater: FlickrSearchResultsUpdater)
    
    func flickrSearchResultsUpdater(_ updater: FlickrSearchResultsUpdater, didLoadMorePhotos morePhotos: [Photo])
}

class FlickrSearchResultsUpdater {
    
    var search: FlickrSearch!
    var page: Int!
    
    weak var delegate: FlickrSearchResultsUpdaterDelegate!
    
    // MARK: - FlickrSearchResultsUpdaterDelegate
    
    private func didLoadMorePhotos(_ photos: [Photo]) {
        page = page + 1
        delegate.flickrSearchResultsUpdater(self, didLoadMorePhotos: photos)
    }
    
    private func didResetSearch() {
        page = 1
        delegate.flickrSearchResultsUpdaterDidResetSearch(self)
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
        
        loadMore()
    }
    
    private(set) var loading = false
    
    func loadMore() {
        let search = self.search!
        loading = true
        search.loadMore(page: page) { [oldSearch = search] (throwingResult) in
            DispatchQueue.main.async {
                guard x$(oldSearch === self.search) else {
                    // Ignore no longer actual completion.
                    _ = x$(oldSearch.text)
                    return
                }
                assert(self.loading)
                self.loading = false
                dispatch(throwingResult, catch: { error in
                    _ = x$(error)
                    _ = x$((error as NSError).userInfo)
                }, or: {
                    _ = x$($0)
                    //http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
                    let photos = $0.photos.photo
                    self.didLoadMorePhotos(photos)
                })
            }
        }
    }
}
