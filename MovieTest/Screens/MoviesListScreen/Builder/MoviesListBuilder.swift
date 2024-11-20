//
//  MoviesListBuilder.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import UIKit

final class MoviesListBuilder {
    
    func build() -> UIViewController {
        let apiClient = APIClient()
        let moviesDataProvider = MoviesDataProvider(apiClient: apiClient)
        let router = MoviesRouter()
        let viewController = MoviesListViewController()
        let presenter = MoviesListPresenter(
            moviesDataProvider: moviesDataProvider,
            viewController: viewController,
            router: router
        )
        viewController.set(presenter: presenter)
        router.view = viewController
        return viewController
    }
}
