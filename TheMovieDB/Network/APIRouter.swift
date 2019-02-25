//
//  APIRouter.swift
//  Networking
//
//  Created by Alaeddine Messaoudi on 26/11/2017.
//  Copyright © 2017 Alaeddine Me. All rights reserved.
//

import Alamofire

/// This enum will build your endpoints, via Router Pattern.
enum APIRouter: URLRequestConvertible {

    case popular(page: Int)
    case topRated(page: Int)

    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .topRated:
            return .get
        case .popular:
            return .get
        }
    }

    // MARK: - Path
    private var path: String {
        switch self {
        case .popular:
            return "/popular"
        case .topRated:
            return "/top_rated"
        }
    }

    // MARK: - Parameters, but they are use on the url query.
    private var parameters: Parameters? {
        switch self {
        case .popular(let page):
            return ["page": page]
        case .topRated(let page):
            return ["page": page]
        }
    }

    // MARK: - URLRequestConvertible
    /// returns the request base on your router
    /// it will add your query url items, like apikey and page number.
    /// it will set your method {post,get}
    /// it will set headers, like accept, contentype, etc.
    ///
    /// - Returns: URLRequest
    /// - Throws: some unhandle error.
    func asURLRequest() throws -> URLRequest {
        //Build full path url
        let url = try Constants.ProductionServer.baseURL.asURL().appendingPathComponent(path)

        guard let params = self.parameters, let pageInt = params["page"] as? Int else {
            return URLRequest(url: url) //just returns url
        }

        //Add url query Items.
        let urlQueryItems = url
            .appendQueryItem("api_key", value: "34738023d27013e6d1b995443764da44")
            .appendQueryItem("page", value: String(pageInt))

        var urlRequest = URLRequest(url: urlQueryItems)

        // HTTP Method
        urlRequest.httpMethod = method.rawValue

        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)

        debugPrint("calling network urlRequest:", urlRequest)
        return urlRequest
    }
}
