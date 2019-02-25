//
//  ApiClient.swift
//  TheMovieDB
//
//  Created by Fransico D. on 2/21/19.
//  Copyright © 2019 innomar.cl. All rights reserved.
//

import Alamofire
import Foundation

/// This enum contains all the endpoints
enum ApiClient {

    /// this method gets the top rated movies.
    ///
    /// - Parameter onSuccess: lorem
    static func fetchEndpoint(route: APIRouter, onSuccess: @escaping (SuccessCallBack)) {
        guard let request = try? route.asURLRequest(), let url = request.url?.absoluteString else {
            return
        }
        Alamofire.request(url)
            .responseData { response in
                let decoder = JSONDecoder()
                let networkResponse: Result<NetworkResponse> = decoder.decodeResponse(from: response)
                if networkResponse.isSuccess {
                    onSuccess(networkResponse.value, 0)
                } else {
                    onSuccess(nil, -1)
                }
            }
    }
}
