//
//  HTTPMethod.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import Foundation

enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}


struct Constants {
    struct API {
        static let baseURL = "https://api.themoviedb.org/3"
        static let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODcxYzIyMDYyZTllZjdlZTkyNmFhM2JhMTM0MGRhNiIsIm5iZiI6MTczMTg3MzA5NS4zODY0ODM3LCJzdWIiOiI2Mzg5MTI4N2QzODhhZTAwOTYxYWM2YjciLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.dD8rgyzlJX9J9A4QYCg1SNlusy1HVhl2bW84QkQtSsQ"
        static let timeoutIntervalForRequest: TimeInterval = 60
        static let timeoutIntervalForResource: TimeInterval = 300
    }
    
    struct Header {
        static let authorizationKey = "Authorization"
        static let authorizationValuePrefix = "Bearer "
    }
}
