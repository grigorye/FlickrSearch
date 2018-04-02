//
//  FlickrSearchResultItemCell.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 28.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UICollectionViewCell
import UIKit.UIImageView
import UIKit.UILabel
import Foundation

private let sessionConfiguration = URLSessionConfiguration.default … {
    $0.urlCache = URLCache(memoryCapacity: URLCache.shared.memoryCapacity, diskCapacity: 1024 * 1024 * 100, diskPath: "FlickrSearchResultItem")
}

private let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)

class FlickrSearchResultItemCell : UICollectionViewCell {
    
    private var dataTask: URLSessionDataTask!
    
    var photo: Photo! {
        didSet {
            textLabel.text = photo.title
            var dataTask: URLSessionDataTask!
            dataTask = session.dataTask(with: photo.url) { (data, response, error) in
                guard dataTask! === self.dataTask else {
                    assert((error as? URLError)?.code == .cancelled)
                    return
                }
                DispatchQueue.main.async {
                    self.completePhotoLoad(x$(data), x$(response), x$(error))
                }
            }
            self.dataTask = dataTask
            if let cachedResponse = sessionConfiguration.urlCache?.cachedResponse(for: dataTask.currentRequest!) {
                completePhotoLoad(x$(cachedResponse.data), x$(cachedResponse.response), nil)
            } else {
                x$(dataTask).resume()
            }
        }
    }
    
    private func completePhotoLoad(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        setImageView(imageView, from: data, response, error)
    }
    
    // MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        x$(dataTask)?.cancel()
        dataTask = nil
        imageView.image = nil
    }
    
    // MARK: -
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
}
