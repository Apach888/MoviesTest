//
//  MoviesListViewController.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import UIKit
import SnapKit

protocol MoviesListViewProtocol: AnyObject {
    func displayMovies(_ movies: [MovieViewModel])
    func displayError(_ error: String)
}

final class MoviesListViewController: UIViewController {
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MovieViewModel>
    
    // MARK: - UI Elements

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 300)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(MovieCell.self)
        return collectionView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing found."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    private lazy var dataSource: MoviesDiffableDataSource = {
        let dataSource = MoviesDiffableDataSource(collectionView: collectionView)
        return dataSource
    }()

    // MARK: - Properties

    private var presenter: MoviesListPresenterProtocol?
    private var movies: [MovieViewModel] = []
    private var isLoading = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.fetchMovies()
    }

    func set(presenter: MoviesListPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "Movies"
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(nothingFoundLabel)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nothingFoundLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Diffable Data Source Updates

    private func updateSnapshot(with movies: [MovieViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - MoviesListViewProtocol

extension MoviesListViewController: MoviesListViewProtocol {
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    func displayMovies(_ movies: [MovieViewModel]) {
        self.isLoading = false
        self.movies.append(contentsOf: movies)
        updateSnapshot(with: self.movies)
        nothingFoundLabel.isHidden = !self.movies.isEmpty
    }
}

// MARK: - UICollectionViewDelegate

extension MoviesListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 200, !isLoading {
            isLoading = true
            presenter?.fetchMovies()
        }
    }
}
