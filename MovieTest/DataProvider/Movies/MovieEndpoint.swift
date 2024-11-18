//
//  MovieEndpoint.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation
import Alamofire

enum MoviesEndpoint {
    case popularMovies(page: Int, language: String)
}

extension MoviesEndpoint: Endpoint {
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .popularMovies:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .popularMovies(let page, let language):
            return [
                "page": page,
                "language": language
            ]
        }
    }
}
