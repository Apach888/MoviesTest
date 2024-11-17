//
//  APIService.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import Foundation
import Alamofire
import Network

protocol APIService {
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T
}

extension APIService {
    
    var session: Session {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = Constants.API.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = Constants.API.timeoutIntervalForResource
        return Session(configuration: configuration)
    }
    
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard await isConnectedToInternet() else {
            throw APIError.noInternetConnection
        }
        
        let urlRequest = try endpoint.asURLRequest()
        
        let dataTask = session.request(urlRequest)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
        
        let response = await dataTask.response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw handleNetworkError(error: error, response: response.response)
        }
    }
    
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
