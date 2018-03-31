//
//  FlickrSearchRequests.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 29.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

struct FlickrStat : Decodable {
    var stat: String
}

struct FlickrFail : Decodable {
    var code: Int
    var message: String
}

struct FlickrPhotosSearchResult : Decodable {
    var photos: Photos

    struct Photos : Decodable {
        var page: Int
        var pages: Int
        var perpage: Int
        var total: String
        var photo: [Photo]

        struct Photo : Decodable {
            var farm: Int
            var id: String
            var owner: String
            var secret: String
            var server: String
        }
    }
}

enum FlickrSearchError: Swift.Error {
    case noData
    case badResponse(URLResponse?)
    case badHTTPResponseStatus(HTTPURLResponse, body: OptionallyDecodedString)
    case badFlickrStat(String, body: OptionallyDecodedString)
    case decodingError(DecodingError, body: OptionallyDecodedString)
    case flickrFail(FlickrFail)
}

extension URLSession {
    
    func dataTaskForFlickrSearch(apiKey: String, text: String, date: Date, page: Int = 1, completion: @escaping (@escaping () throws -> FlickrPhotosSearchResult) -> Void) -> URLSessionDataTask {
        let percentEscapedText = text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&safe_search=1&page=\(page)&text=\(percentEscapedText)")!
        
        let task = dataTask(with: x$(url)) { (data, response, error) in
            dispatch(completion) {
                typealias E = FlickrSearchError
                if let error = error {
                    throw x$(error)
                }
                guard let data = data else {
                    throw x$(E.noData)
                }
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    throw x$(E.badResponse(response))
                }
                guard httpURLResponse.statusCode == 200 else {
                    throw x$(E.badHTTPResponseStatus(httpURLResponse, body: OptionallyDecodedString(data)))
                }
                #if false
                let json = try JSONSerialization.jsonObject(with: data)
                _ = x$(json)
                #endif
                let stat = try JSONDecoder().decode(FlickrStat.self, from: data)
                let result: FlickrPhotosSearchResult = try {
                    do {
                        switch stat.stat {
                        case "ok":
                            return try JSONDecoder().decode(FlickrPhotosSearchResult.self, from: data)
                        case "fail":
                            let fail = try JSONDecoder().decode(FlickrFail.self, from: data)
                            throw E.flickrFail(fail)
                        case let badStat:
                            throw E.badFlickrStat(badStat, body: OptionallyDecodedString(data))
                        }
                    } catch let e as DecodingError {
                        throw E.decodingError(e, body: OptionallyDecodedString(data))
                    }
                }()
                x$($0(result))
            }
        }
        return task
    }
}
