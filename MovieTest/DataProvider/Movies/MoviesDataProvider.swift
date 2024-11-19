//
//  MoviesService.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

protocol MoviesDataProviderProtocol {
    func fetchPopularMovies(request: MovieRequest) async throws -> MovieResponse
    func fetchGenres(language: String) async throws -> GenreResponse
}

final class MoviesDataProvider {
    let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}

extension MoviesDataProvider: MoviesDataProviderProtocol {
    func fetchPopularMovies(request: MovieRequest) async throws -> MovieResponse {
        let endpoint = MoviesEndpoint.popularMovies(page: request.page, language: request.language)
        return try await apiClient.sendRequest(endpoint: endpoint)
    }

    func fetchGenres(language: String) async throws -> GenreResponse {
        let endpoint = MoviesEndpoint.genres(language: language)
        return try await apiClient.sendRequest(endpoint: endpoint)
    }
}
