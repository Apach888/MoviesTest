//
//  APIClient.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation
import Alamofire
import Network

protocol APIClientProtocol {
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    
    // MARK: - Properties
    private let session: Session
    private let reachabilityManager: NetworkReachabilityManager?
    
    // MARK: - Initializer
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.Session.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = APIConstants.Session.timeoutIntervalForResource
        self.session = Session(configuration: configuration)
        self.reachabilityManager = NetworkReachabilityManager()
    }
    
    // MARK: - ApiClient Protocol Method
    func sendRequest<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard reachabilityManager?.isReachable == true else {
            throw APIError(message: "No Internet Connection", success: false)
        }
        
        let urlRequest = try endpoint.asURLRequest()
        
        do {
            let dataResponse = await session.request(urlRequest).serializingData().response
            return try processResponse(dataResponse: dataResponse)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(errorCode: 0, message: "Unknown API error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Process Response
    private func processResponse<T: Decodable>(dataResponse: DataResponse<Data, AFError>) throws -> T {
        guard let response = dataResponse.response else {
            throw APIError(errorCode: 0, message: "Invalid HTTP response")
        }
        
        guard let data = dataResponse.data else {
            throw APIError(errorCode: response.statusCode, message: "No data received from server")
        }
        
        if (200...299).contains(response.statusCode) {
            return try decodeData(data, as: T.self)
        } else {
            if let apiError = try? decodeData(data, as: APIError.self) {
                throw apiError
            }
            throw APIError(
                statusCode: response.statusCode,
                errorCode: 0,
                message: "Unknown server error"
            )
        }
    }
    
    // MARK: - Decode Data
    private func decodeData<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
