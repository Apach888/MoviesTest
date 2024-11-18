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

class MoviesListPresenter {
    private let moviesDataProvider: MoviesDataProviderProtocol
    private weak var viewController: MoviesListViewProtocol?
    
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    
    init(moviesDataProvider: MoviesDataProviderProtocol, viewController: MoviesListViewProtocol) {
        self.moviesDataProvider = moviesDataProvider
        self.viewController = viewController
    }
}

extension MoviesListPresenter: MoviesListPresenterProtocol {
    func fetchMovies() {
        guard !isFetching, currentPage <= totalPages else { return }
        
        isFetching = true
        let request = MovieRequest(page: currentPage, language: .localeIdentifier)
        
        Task {
            do {
                let response = try await moviesDataProvider.fetchPopularMovies(request: request)
                totalPages = response.totalPages
                currentPage += 1
                isFetching = false

                // Конвертируем MovieItem в MovieViewModel
                let viewModels = response.results.map { MovieViewModel(movie: $0) }
                await viewController?.displayMovies(viewModels)
            } catch {
                isFetching = false
                await viewController?.displayError(error.localizedDescription)
            }
        }
    }
}
