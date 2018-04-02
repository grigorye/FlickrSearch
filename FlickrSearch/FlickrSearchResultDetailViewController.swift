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
                setImageView(self.imageView, from: x$(data), x$(response), x$(error))
            }
        }
        if let cachedResponse = sessionConfiguration.urlCache?.cachedResponse(for: dataTask.currentRequest!) {
            setImageView(imageView, from: x$(cachedResponse.data), x$(cachedResponse.response), nil)
        } else {
            x$(dataTask).resume()
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
