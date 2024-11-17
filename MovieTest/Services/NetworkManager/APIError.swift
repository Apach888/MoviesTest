//
//  APIError.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(statusCode: Int, message: String)
    case unauthorized
    case forbidden
    case notFound
    case noInternetConnection
    case timeout
    case requestCancelled
    case unknownError(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingFailed:
            return "Failed to decode the response."
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .unauthorized:
            return "You are not authorized to access this resource."
        case .forbidden:
            return "Access to this resource is forbidden."
        case .notFound:
            return "The requested resource was not found."
        case .noInternetConnection:
            return "You are offline. Please, enable your Wi-Fi or connect using cellular data."
        case .timeout:
            return "The request timed out."
        case .requestCancelled:
            return "The request was cancelled."
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
