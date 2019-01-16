//
//  URLImageCache.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 1/16/19.
//  Copyright © 2019 Grigory Entin. All rights reserved.
//

import UIKit
import Foundation

/// Nothing but a wrapper around NSCache<NSURL, UIImage> with some default configuration/reporting.
class URLImageCache : NSObject {
    
    init(countLimit: Int) {
        self.countLimit = countLimit
    }
    
    func add(_ image: UIImage?, for response: URLResponse?) {
        if let url = response?.url, let image = image {
            reporterQueue.async {
                self.reporter.willCache(image)
            }
            nscache.setObject(image, forKey: url as NSURL)
        }
    }
    
    func image(for url: URL?) -> UIImage? {
        guard let url = url, let image = nscache.object(forKey: url as NSURL) else {
            return nil
        }
        reporterQueue.async {
            self.reporter.didHit(image)
        }
        return image
    }
    
    // MARK: -
    
    private let reporter = Reporter()
    private let reporterQueue = DispatchQueue(label: "com.grigorye.URLImageCache.Reporter")
    
    private class Reporter: NSObject {
        
        private var cachedImages: [UIImage] = []
        
        // MARK: -
        
        func willEvict(_ image: UIImage) {
            _ = x$((image: image, cachedImagesCount: cachedImages.count))
            let index = cachedImages.index(of: image)!
            cachedImages.remove(at: index)
        }
        
        func willCache(_ image: UIImage) {
            _ = x$((image: image, cachedImagesCount: cachedImages.count))
            cachedImages += [image]
        }
        
        func didHit(_ image: UIImage) {
            _ = x$(image, name: "image")
        }
    }
    
    private let countLimit: Int
    
    private lazy var nscache = NSCache<NSURL, UIImage>() … {
        $0.countLimit = self.countLimit
        $0.delegate = self
    }
}

extension URLImageCache : NSCacheDelegate {
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        let image = obj as! UIImage
        reporterQueue.async {
            self.reporter.willEvict(image)
        }
    }
}
