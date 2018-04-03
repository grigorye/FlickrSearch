//
//  FlickrSearchResultsUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation.NSDate

/// Maintaints a sequence of (text based) flickr photos search requests, with ability to restart with a new text. Delivers results via delegate.
class FlickrSearchResultsLoader {
    
    init(delegate: FlickrSearchResultsLoaderDelegate) {
        self.delegate = delegate
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
        assert(!loadCompleted)
        let search = self.search!
        loading = true
        search.loadMore(page: page) { [oldSearch = search] (searchResultOrError) in
            DispatchQueue.main.async {
                guard x$(oldSearch === self.search) else {
                    // Ignore no longer actual completion.
                    _ = x$(oldSearch.text)
                    return
                }
                
                assert(self.loading)
                self.loading = false
                
                guard let searchResult = searchResultOrError.value else {
                    let error = searchResultOrError.error!
                    _ = x$(error)
                    _ = x$((error as NSError).userInfo)
                    return
                }

                let photos = x$(searchResult).photos.photo
                self.didLoadMorePhotos(photos)
                
                if searchResult.photos.page == searchResult.photos.pages {
                    self.didCompleteLoad()
                }
            }
        }
    }
    
    // MARK: -
    
    private func didLoadMorePhotos(_ photos: [Photo]) {
        page = page + 1
        delegate.flickrSearchResultsLoader(self, didLoadMorePhotos: photos)
    }
    
    private func didResetSearch() {
        page = 1
        loadCompleted = false
        delegate.flickrSearchResultsLoaderDidResetSearch(self)
    }
    
    private func didCompleteLoad() {
        loadCompleted = true
    }
    
    // MARK: -
    
    private(set) var search: FlickrSearch!
    private(set) var loadCompleted = false
    private(set) weak var delegate: FlickrSearchResultsLoaderDelegate!
    
    private var page: Int!
}

protocol FlickrSearchResultsLoaderDelegate : class {
    
    func flickrSearchResultsLoaderDidResetSearch(_ loader: FlickrSearchResultsLoader)
    
    func flickrSearchResultsLoader(_ loader: FlickrSearchResultsLoader, didLoadMorePhotos morePhotos: [Photo])
    
    func flickrSearchResultsLoaderDidCompleteLoad(_ loader: FlickrSearchResultsLoader)
}
