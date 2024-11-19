//
//  MoviesListPresenter.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

protocol MoviesListPresenterProtocol: AnyObject {
    func fetchMovies()
}

final class MoviesListPresenter {
    // MARK: - Dependencies
    private let moviesDataProvider: MoviesDataProviderProtocol
    private weak var viewController: MoviesListViewProtocol?
    
    // MARK: - State
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var genres: [Int: String] = [:]
    
    // MARK: - Initialization
    init(
        moviesDataProvider: MoviesDataProviderProtocol,
        viewController: MoviesListViewProtocol
    ) {
        self.moviesDataProvider = moviesDataProvider
        self.viewController = viewController
    }
}

extension MoviesListPresenter: MoviesListPresenterProtocol {
    func fetchMovies() {
        guard !isFetching, currentPage <= totalPages else { return }
        
        isFetching = true
        
        Task { @MainActor in
            do {
                if genres.isEmpty {
                    genres = try await fetchGenres()
                }
                
                let response = try await moviesDataProvider.fetchPopularMovies(
                    request: MovieRequest(page: currentPage, language: .localeIdentifier)
                )
                
                totalPages = response.totalPages
                currentPage += 1
                isFetching = false
                
                let viewModels = response.results.map { movie in
                    let genreNames = movie.genreIDs.compactMap { genres[$0] }.joined(separator: ", ")
                    return MovieViewModel(from: movie, genres: genreNames)
                }
                
                viewController?.displayMovies(viewModels)
            } catch {
                isFetching = false
                viewController?.displayError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchGenres() async throws -> [Int: String] {
        let genreResponse = try await moviesDataProvider.fetchGenres(language: .localeIdentifier)
        return genreResponse.genres.reduce(into: [Int: String]()) { result, genre in
            result[genre.id] = genre.name
        }
    }
}
