//
//  SearchResultsUpdater.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

class FlickrSearchResultsUpdater : NSObject, UISearchResultsUpdating {
    
    var search: FlickrSearch!
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        
        guard text != "" else {
            // Flickr doesn't support search with no text.
            return
        }
        
        let search = FlickrSearch(text: x$(text), date: Date())
        self.search = search
        
        search.loadMore { [oldSearch = search] in
            guard x$(oldSearch === self.search) else {
                // Ignore no longer actual completion.
                _ = x$(oldSearch.text)
                return
            }
            dispatch($0, catch: { error in
                _ = x$(error)
                _ = x$((error as NSError).userInfo)
            }, or: {
                _ = x$($0)
            })
        }
    }
}
