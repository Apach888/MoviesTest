//
//  Bundle+Extension.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

extension Bundle {
    var apiScheme: String {
        guard let configuration = infoDictionary?["APIConfiguration"] as? [String: Any],
              let value = configuration["Scheme"] as? String else {
            fatalError("API Scheme is not configured in Info.plist")
        }
        return value
    }
    
    var apiHost: String {
        guard let configuration = infoDictionary?["APIConfiguration"] as? [String: Any],
              let value = configuration["Host"] as? String else {
            fatalError("API Host is not configured in Info.plist")
        }
        return value
    }
    
    var apiAccessToken: String {
        guard let configuration = infoDictionary?["APIConfiguration"] as? [String: Any],
              let value = configuration["AccessToken"] as? String else {
            fatalError("API AccessToken is not configured in Info.plist")
        }
        return value
    }
}
