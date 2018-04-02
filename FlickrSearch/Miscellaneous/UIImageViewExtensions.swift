//
//  UIImageViewExtensions.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 02/04/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import UIKit.UIImageView

extension UIImage {
    class func image(forData data: Data?, _ response: URLResponse?, _ error: Error?) -> UIImage? {
        if let error = error {
            _ = x$(error)
            return nil
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            _ = x$(response)
            return nil
        }
        guard 200 == httpResponse.statusCode else {
            _ = x$(httpResponse)
            return nil
        }
        guard let data = data else {
            _ = x$(Data?.none)
            return nil
        }
        return UIImage(data: data)!
    }
}

func setImageView(_ imageView: UIImageView, from data: Data?, _ response: URLResponse?, _ error: Error?) {
    imageView.image = UIImage.image(forData: data, response, error)
}
