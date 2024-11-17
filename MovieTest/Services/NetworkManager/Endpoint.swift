//
//  Endpoint.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import Foundation
import Alamofire

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    
    func asURLRequest() throws -> URLRequest
}

extension Endpoint {
    var baseURL: URL {
        return URL(string: Constants.API.baseURL)!
    }
    
    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(.accept("application/json"))
        headers.add(.contentType("application/json"))
        headers.add(name: Constants.Header.authorizationKey, value: Constants.Header.authorizationValuePrefix + Constants.API.accessToken)
        return headers
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method, headers: headers)
        request.timeoutInterval = Constants.API.timeoutIntervalForRequest
        return try encoding.encode(request, with: parameters)
    }
}
