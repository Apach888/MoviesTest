//
//  APIError.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct APIError: Error {
    var statusCode: Int
    let errorCode: Int
    let message: String
    let success: Bool

    init(statusCode: Int = 0, errorCode: Int = 0, message: String, success: Bool = false) {
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.message = message
        self.success = success
    }

    private enum CodingKeys: String, CodingKey {
        case statusCode
        case errorCode = "status_code"
        case message = "status_message"
        case success
    }
}

extension APIError: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode) ?? 0
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        message = try container.decode(String.self, forKey: .message)
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
    }
}
