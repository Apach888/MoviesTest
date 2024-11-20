//
//  MoviesListPresenter.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation
import SDWebImage

enum FetchType {
    case initialLoad
    case refresh
    case loadMore
}

protocol MoviesListPresenterProtocol: AnyObject {
    var isFetchingData: Bool { get }
    var hasMorePages: Bool { get }
    func fetchMovies(fetchType: FetchType)
    func searchMovies(by query: String)
    func didTapMovie(movieId: Int)
    func didTapSort()
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
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
    private var currentSortOption: SortOption = .userScore
    private var currentQuery: String = ""

    // MARK: - Computed Properties
    var isFetchingData: Bool {
        return isFetching
    }

    var hasMorePages: Bool {
        return currentPage <= totalPages
    }

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

    // MARK: - Public Methods
    func fetchMovies(fetchType: FetchType) {
        switch fetchType {
        case .initialLoad:
            handleInitialLoad()
        case .refresh:
            handleRefresh()
        case .loadMore:
            handleLoadMore()
        }
    }

    func searchMovies(by query: String) {
        currentQuery = query
        let displayedMovies = filterMovies(by: currentQuery)
        viewController?.displayMovies(displayedMovies, shouldScrollToTop: true)
    }

    func didTapMovie(movieId: Int) {
        router.navigateToDetailScreen(id: movieId)
    }

    func didTapSort() {
        router.showSortActionSheet(current: currentSortOption) { [weak self] selectedSortOption in
            guard let self else { return }
            self.currentSortOption = selectedSortOption
            self.sortMovies()
            let displayedMovies = self.filterMovies(by: self.currentQuery)
            self.viewController?.displayMovies(displayedMovies, shouldScrollToTop: true)
        }
    }

    // MARK: - Private Methods
    private func handleInitialLoad() {
        resetPagination()
        fetchMoviesFromAPI(shouldScrollToTop: false)
    }

    private func handleRefresh() {
        resetPagination()
        clearCache()
        currentQuery = ""
        fetchMoviesFromAPI(shouldScrollToTop: false)
    }

    private func handleLoadMore() {
        guard hasMorePages, !isFetching else { return }
        fetchMoviesFromAPI(shouldScrollToTop: false)
    }

    private func resetPagination() {
        currentPage = 1
        totalPages = 1
        movies.removeAll()
    }

    private func fetchMoviesFromAPI(shouldScrollToTop: Bool) {
        guard !isFetching else { return }
        isFetching = true
        viewController?.showLoadingIndicator(true)

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            defer {
                self.isFetching = false
                self.viewController?.showLoadingIndicator(false)
                self.viewController?.endRefreshing()
            }

            do {
                if genres.isEmpty {
                    genres = try await self.fetchGenres()
                }

                let response = try await self.moviesDataProvider.fetchPopularMovies(
                    request: .init(page: currentPage, language: .localeIdentifier)
                )

                self.totalPages = response.totalPages

                let viewModels = response.results.map { movie in
                    let genreNames = movie.genreIDs.compactMap { self.genres[$0] }.joined(separator: ", ")
                    return MovieViewModel(from: movie, genres: genreNames)
                }

                // Update currentPage after successful fetch
                self.currentPage += 1

                self.movies.append(contentsOf: viewModels)

                self.sortMovies()
                let displayedMovies = self.filterMovies(by: self.currentQuery)
                self.viewController?.displayMovies(displayedMovies, shouldScrollToTop: shouldScrollToTop)
            } catch let error as APIError {
                self.router.showAlert(message: error.message)
            } catch {
                self.router.showAlert(message: error.localizedDescription)
            }
        }
    }

    private func fetchGenres() async throws -> [Int: String] {
        let genreResponse = try await moviesDataProvider.fetchGenres(language: .localeIdentifier)
        return genreResponse.genres.reduce(into: [Int: String]()) { result, genre in
            result[genre.id] = genre.name
        }
    }

    private func sortMovies() {
        switch currentSortOption {
        case .alphabet:
            movies.sort { $0.title < $1.title }
        case .releaseDate:
            movies.sort { $0.releaseDate > $1.releaseDate }
        case .userScore:
            movies.sort { $0.voteAverage > $1.voteAverage }
        }
    }

    private func filterMovies(by query: String) -> [MovieViewModel] {
        if query.isEmpty {
            return movies
        } else {
            return movies.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
    }

    private func clearCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
    }
}
