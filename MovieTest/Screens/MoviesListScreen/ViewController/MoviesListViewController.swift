//
//  MoviesListViewController.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import UIKit

@MainActor
protocol MoviesListViewProtocol: AnyObject {
    func displayMovies(_ movies: [MovieViewModel])
    func displayError(_ error: String)
}

class MoviesListViewController: UIViewController {
    // MARK: - UI Elements
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 200)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private var presenter: MoviesListPresenterProtocol?
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, MovieViewModel>!
    private var movies: [MovieViewModel] = []
    private var isLoading = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDiffableDataSource()
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nothingFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Int, MovieViewModel>(
            collectionView: collectionView
        ) { collectionView, indexPath, movieViewModel in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCell.reuseIdentifier,
                for: indexPath
            ) as? MovieCell else {
                fatalError("Unable to dequeue MovieCell.")
            }
            cell.configure(with: movieViewModel)
            return cell
        }
    }
}

// MARK: - MoviesListViewProtocol

extension MoviesListViewController: MoviesListViewProtocol {
    func displayError(_ error: String) {
        print(error)
    }
    
    func displayMovies(_ movies: [MovieViewModel]) {
        self.isLoading = false
        self.movies.append(contentsOf: movies)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.movies)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
        
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