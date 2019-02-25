//
//  AlamofireExtension.swift
//  TheMovieDB
//
//  Created by Fransico D. on 2/22/19.
//  Copyright © 2019 innomar.cl. All rights reserved.
//

import Alamofire

/// this typealias returns the response from the network and code 0,-1
typealias SuccessCallBack = (NetworkResponse?, Int) -> Void

extension JSONDecoder {
    /// Doing manual Generic Decoder of Codables. Until Alamofire 5 is ready, we need to do our generic codables by hand
    ///
    /// - Parameter response: network response
    /// - Returns: network result ready in this case a Result<NetworkResponse>
    func decodeResponse<T: Decodable>(from response: DataResponse<Data>) -> Result<T> {
        guard response.error == nil else {
            print(response.error!)
            return .failure(response.error!)
        }

        guard let responseData = response.data else {
            print("didn't get any data from API")
            return .failure(NSError())
        }

        do {
            let item = try decode(T.self, from: responseData)
            return .success(item)
        } catch {
            print("error trying to decode response")
            print(error)
            return .failure(error)
        }
    }
}

extension URL {

    @discardableResult
    /// appens query url items
    ///
    /// - Parameters:
    ///   - queryItem: key
    ///   - value: value
    /// - Returns: URL with your url query items ready via components.
    func appendQueryItem(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else {
            return absoluteURL
        }

        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // create query item if value is not nil
        guard let value = value else {
            return absoluteURL
        }
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // append the new query item in the existing query items array
        queryItems.append(queryItem)

        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)

        // returns the url from new url components
        return urlComponents.url!
    }
}
