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

private let thumbnailCache = URLImageCache(countLimit: 50)

class FlickrSearchResultItemCell : UICollectionViewCell {
    
    private var dataTask: URLSessionDataTask!
    
    var photo: Photo! {
        didSet {
            textLabel.text = photo.title
            if let cachedImage = thumbnailCache.image(for: photo?.largeSquareURL) {
                imageView.image = cachedImage
                return
            }
            var dataTask: URLSessionDataTask!
            dataTask = session.dataTask(with: photo.largeSquareURL) { (data, response, error) in
                DispatchQueue.main.async {
                    guard dataTask! === self.dataTask else {
                        return
                    }
                    _ = x$((data: data, error: error))
                    self.completePhotoLoad(data, response, error)
                }
            }
            self.dataTask = dataTask
            if let cachedResponse = sessionConfiguration.urlCache?.cachedResponse(for: dataTask.currentRequest!) {
                let data = cachedResponse.data
                let response = cachedResponse.response
                _ = x$(data, name: "cachedResponseData")
                completePhotoLoad(data, response, nil)
            } else {
                x$(dataTask, name: "nonCachedDataTask").resume()
            }
        }
    }
    
    private func completePhotoLoad(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let cachedImage = thumbnailCache.image(for: response?.url) {
            imageView.image = cachedImage
            return
        }
        if UserDefaults.standard.bool(forKey: "decompressThumbnailsInBackground") {
            DispatchQueue.global().async { [dataTask = self.dataTask!] in
                let image = UIImage.image(forData: data, response, error)
                thumbnailCache.add(image, for: response)
                DispatchQueue.main.async {
                    guard dataTask === self.dataTask else {
                        return
                    }
                    self.imageView.image = image
                }
            }
        } else {
            let image = UIImage.image(forData: data, response, error)
            imageView.image = image
            thumbnailCache.add(image, for: response)
        }
    }
    
    // MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _ = x$(dataTask, name: "canceledDataTask")
        dataTask?.cancel()
        dataTask = nil
        imageView.image = nil
    }
    
    // MARK: -
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
}
