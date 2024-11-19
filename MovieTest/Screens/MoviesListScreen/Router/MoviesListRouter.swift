//
//  MoviesListRouter.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 19.11.2024.
//

import UIKit

enum SortOption: CaseIterable {
    case alphabet
    case releaseDate
    case userScore
    
    var name: String {
        switch self {
        case .alphabet:
            return "Алфавит"
        case .releaseDate:
            return "Дата"
        case .userScore:
            return "Score"
        }
    }
}

protocol MoviesRouterProtocol: AnyObject {
    func navigateToDetailScreen(id: Int)
    func showSortActionSheet(current: SortOption, onSelect: ((SortOption) -> Void)?)
    func showAlert(message: String)
}

final class MoviesRouter: MoviesRouterProtocol {
    weak var view: UIViewController?
    
    // MARK: - Private Methods
    
    func navigateToDetailScreen(id: Int) {
        guard let navigationController = view?.navigationController else { return }
//        let detailsVC = DetailsAssembly(movieId: movieId).assemble()
//        detailsVC.navigationItem.largeTitleDisplayMode = .never
//        navigationController.pushViewController(detailsVC, animated: true)
    }
    
    func showSortActionSheet(current: SortOption, onSelect: ((SortOption) -> Void)?) {
        guard let view else { return }
        
        let alert = UIAlertController(
            title: "Sort Movies",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        SortOption.allCases.forEach { option in
            let action = UIAlertAction(
                title: option.name,
                style: .default
            ) { _ in
                onSelect?(option)
            }
            if option == current {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        view.present(alert, animated: true)
    }
    
    func showAlert(message: String) {
        guard let view else { return }
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        view.present(alert, animated: true)
    }
}
