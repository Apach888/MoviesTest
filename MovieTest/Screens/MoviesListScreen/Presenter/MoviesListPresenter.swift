//
//  MoviesListPresenter.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

protocol MoviesListPresenterProtocol: AnyObject {
    func fetchMovies()
    func sortMovies()
    func searchMovies(by query: String)
    func didTapMovie(movieId: Int)
    func didTapSort()
}

final class MoviesListPresenter {
    // MARK: - Dependencies
    private let moviesDataProvider: MoviesDataProviderProtocol
    private weak var viewController: MoviesListViewProtocol?
    private let router: MoviesRouterProtocol
    
    // MARK: - State
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var genres: [Int: String] = [:]
    private var movies: [MovieViewModel] = []
    private var filteredMovies: [MovieViewModel] = []
    private var currentSortOption: SortOption = .userScore

    // MARK: - Initialization
    init(
        moviesDataProvider: MoviesDataProviderProtocol,
        viewController: MoviesListViewProtocol,
        router: MoviesRouterProtocol
    ) {
        self.moviesDataProvider = moviesDataProvider
        self.viewController = viewController
        self.router = router
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

                let uniqueMovies = viewModels.filter { newMovie in
                    !movies.contains(where: { $0.id == newMovie.id })
                }

                movies.append(contentsOf: uniqueMovies)
                filteredMovies = movies
                
                viewController?.displayMovies(filteredMovies)
            } catch {
                isFetching = false
                router.navigate(to: .showAlert(message: error.localizedDescription))
            }
        }
    }
    
    func sortMovies() {
        let sortedMovies: [MovieViewModel]
        switch currentSortOption {
        case .alphabet:
            sortedMovies = filteredMovies.sorted { $0.title < $1.title }
        case .releaseDate:
            sortedMovies = filteredMovies.sorted { $0.releaseDate > $1.releaseDate }
        case .userScore:
            sortedMovies = filteredMovies.sorted { $0.voteAverage > $1.voteAverage }
        }
        viewController?.displayMovies(sortedMovies)
    }
    
    func searchMovies(by query: String) {
        if query.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
        sortMovies()
    }
    
    func didTapMovie(movieId: Int) {
        router.navigate(to: .details(movieId: movieId))
    }
    
    func didTapSort() {
        router.navigate(to: .sort(current: currentSortOption) { [weak self] selectedSortOption in
            self?.currentSortOption = selectedSortOption
            self?.sortMovies()
        })
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
