//
//  MoviesListViewController.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import UIKit

protocol MoviesListViewProtocol: AnyObject {
    func displayMovies(_ movies: [MovieItem])
    func displayError(_ error: String)
}

class MoviesListViewController: UIViewController {
    
    private var presenter: MoviesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter?.fetchMovies()
    }
    
    func set(presenter: MoviesListPresenterProtocol) {
        self.presenter = presenter
    }
}

extension MoviesListViewController: MoviesListViewProtocol {
    func displayMovies(_ movies: [MovieItem]) {
        print("Movies fetched: \(movies)")
    }
    
    func displayError(_ error: String) {
        print("Error: \(error)")
    }
}
