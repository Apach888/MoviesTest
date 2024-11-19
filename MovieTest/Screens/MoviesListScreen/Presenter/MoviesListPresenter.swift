//
//  MoviesListPresenter.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

protocol MoviesListPresenterProtocol: AnyObject {
    func fetchMovies()
    func sortMovies(by option: String)
    func searchMovies(by query: String)
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
    private var movies: [MovieViewModel] = [] // Full list of movies
    private var filteredMovies: [MovieViewModel] = [] // Filtered list of movies for search

    // MARK: - Initialization
    init(
        moviesDataProvider: MoviesDataProviderProtocol,
        viewController: MoviesListViewProtocol
    ) {
        self.moviesDataProvider = moviesDataProvider
        self.viewController = viewController
    }
}

// MARK: - MoviesListPresenterProtocol

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
                    let genreNames = movie.genreIDs.compactMap { genres[$0] }.joined(separator: .separator)
                    return MovieViewModel(from: movie, genres: genreNames)
                }
                
                movies.append(contentsOf: viewModels)
                filteredMovies = movies // Reset filteredMovies after fetching new data
                viewController?.displayMovies(filteredMovies)
            } catch {
                isFetching = false
                viewController?.displayError(error.localizedDescription)
            }
        }
    }
    
    func sortMovies(by option: String) {
        switch option {
        case "By Title":
            filteredMovies.sort { $0.title < $1.title }
        case "By Rating":
            filteredMovies.sort { $0.voteAverage > $1.voteAverage }
        case "By Release Date":
            filteredMovies.sort { $0.releaseDate > $1.releaseDate }
        default:
            break
        }
        viewController?.displayMovies(filteredMovies)
    }
    
    func searchMovies(by query: String) {
        if query.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
        viewController?.displayMovies(filteredMovies)
    }
}

// MARK: - Private Methods

extension MoviesListPresenter {
    private func fetchGenres() async throws -> [Int: String] {
        let genreResponse = try await moviesDataProvider.fetchGenres(language: .localeIdentifier)
        return genreResponse.genres.reduce(into: [Int: String]()) { result, genre in
            result[genre.id] = genre.name
        }
    }
}
