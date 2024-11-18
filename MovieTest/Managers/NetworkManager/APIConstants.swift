//
//  APIConstants.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct APIConstants {
    
    //MARK: - Session
    
    struct Session {
        static let timeoutIntervalForRequest: TimeInterval = 60
        static let timeoutIntervalForResource: TimeInterval = 300
    }
    
    //MARK: - Header
    
    struct Header {
        static let contentTypeKey: String = "Content-Type"
        static let contentTypeValue: String = "application/json"
        
        static let acceptKey: String = "accept"
        
        static let authorizationKey: String = "Authorization"
        static let authorizationKeyType: String = "Bearer"
    }
}
