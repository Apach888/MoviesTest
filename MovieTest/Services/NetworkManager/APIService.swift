//
//  APIService.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import Foundation
import Alamofire
import Network

/// Protocol defining methods for sending API requests.
protocol APIClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T
}

/// Extension providing a default implementation for APIClient.
extension APIClient {
    
    /// Alamofire Session with custom configuration.
    var session: Session {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = Constants.API.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = Constants.API.timeoutIntervalForResource
        return Session(configuration: configuration)
    }
    
    /// Sends a request to the specified endpoint and decodes the response.
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Check for internet connectivity
        guard await isConnectedToInternet() else {
            throw APIError.noInternetConnection
        }
        
        // Create the URLRequest from the endpoint
        let urlRequest = try endpoint.asURLRequest()
        
        // Perform the request using Alamofire
        let dataTask = session.request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
        
        // Await the response
        let response = await dataTask.response
        
        // Handle the response
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            // Map Alamofire error to APIError
            throw handleNetworkError(error: error, response: response.response)
        }
    }
    
    /// Checks for internet connectivity using NWPathMonitor.
    private func isConnectedToInternet() async -> Bool {
        let monitor = NWPathMonitor()
        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
                monitor.cancel()
            }
            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
        }
    }
    
    /// Maps Alamofire errors to custom APIError.
    private func handleNetworkError(error: AFError, response: HTTPURLResponse?) -> APIError {
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError(
                    statusCode: statusCode,
                    message: HTTPURLResponse.localizedString(forStatusCode: statusCode)
                )
            default:
                return .unknownError(error: error)
            }
        } else if error.isSessionTaskError || error.isInvalidURLError {
            return .noInternetConnection
        } else if error.isResponseSerializationError {
            return .decodingFailed
        } else if error.isExplicitlyCancelledError {
            return .requestCancelled
        } else {
            return .unknownError(error: error)
        }
    }
}
