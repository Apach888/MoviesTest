//
//  Endpoint.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation
import Alamofire

protocol Endpoint: URLRequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders { get }
}

extension Endpoint {
    
    var baseURL: URL? {
        var components = URLComponents()
        components.scheme = Bundle.main.apiScheme
        components.host = Bundle.main.apiHost
        return components.url
    }
    
    var headers: HTTPHeaders {
        [
            APIConstants.Header.acceptKey: APIConstants.Header.contentTypeValue,
            APIConstants.Header.contentTypeKey: APIConstants.Header.contentTypeValue,
            APIConstants.Header.authorizationKey: "\(APIConstants.Header.authorizationKeyType) \(Bundle.main.apiAccessToken)"
        ]
    }
    
    var encoding: ParameterEncoding {
        method == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let baseURL = baseURL else {
            throw APIError(message: "Invalid base URL. Please check the URL components.", success: false)
        }
        
        let url = baseURL.appendingPathComponent(path)
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)
        urlRequest = try encoding.encode(urlRequest, with: parameters)
        return urlRequest
    }
}
