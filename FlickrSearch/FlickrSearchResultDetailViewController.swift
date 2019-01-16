//
//  FlickrSearchResultDetailViewController.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28/03/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit

private let sessionConfiguration = URLSessionConfiguration.default … {
    $0.urlCache = URLCache(memoryCapacity: URLCache.shared.memoryCapacity, diskCapacity: 1024 * 1024 * 100, diskPath: "FlickrSearchResultDetailView")
}

private let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)

class FlickrSearchResultDetailViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!

    private func configureView() {
        let dataTask = session.dataTask(with: photo.url) { (data, response, error) in
            DispatchQueue.main.async {
                _ = x$((data: data, error: error))
                setImageView(self.imageView, from: data, response, error)
            }
        }
        if let cachedResponse = sessionConfiguration.urlCache?.cachedResponse(for: dataTask.currentRequest!) {
            let data = cachedResponse.data
            let response = cachedResponse.response
            _ = x$((data: data, response: response), name: "cachedResponse")
            setImageView(imageView, from: data, response, nil)
        } else {
            x$(dataTask, name: "nonCachedDataTask").resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }

    var photo: Photo! {
        willSet {
            assert(photo == nil)
        }
    }
}
