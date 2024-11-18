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
    
    init(moviesDataProvider: MoviesDataProviderProtocol, viewController: MoviesListViewProtocol) {
        self.moviesDataProvider = moviesDataProvider
        self.viewController = viewController
    }
}

extension MoviesListPresenter: MoviesListPresenterProtocol {
    func fetchMovies() {
        let request = MovieRequest(page: 1, language: .localeIdentifier)
        Task {
            do {
                let response = try await moviesDataProvider.fetchPopularMovies(request: request)
                viewController?.displayMovies(response.results)
            } catch {
                viewController?.displayError(error.localizedDescription)
            }
        }
    }
}
