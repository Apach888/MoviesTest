//
//  MoviesEndpoint.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation
import Alamofire

enum MoviesEndpoint {
    case popularMovies(page: Int, language: String)
    case genres(language: String)
}

extension MoviesEndpoint: Endpoint {
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        case .genres:
            return "/3/genre/movie/list"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .popularMovies, .genres:
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
        case .genres(let language):
            return [
                "language": language
            ]
        }
    }
}
