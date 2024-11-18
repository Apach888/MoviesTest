//
//  MoviesService.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//


import Foundation

protocol MoviesDataProviderProtocol {
    func fetchPopularMovies(page: Int) async throws -> Movie.Response
}

final class MoviesDataProvider {
    let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}

extension MoviesDataProvider: MoviesDataProviderProtocol {
    func fetchPopularMovies(page: Int) async throws -> Movie.Response {
        let endpoint = MoviesEndpoint.popularMovies(page: page, language: .localeIdentifier)
        return try await apiClient.sendRequest(endpoint: endpoint)
    }
}
