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
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search movies by title"
        searchBar.delegate = self
        searchBar.searchBarStyle = .default
        searchBar.tintColor = .black
        return searchBar
    }()
    
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
        title = "Popular Movies"
        view.backgroundColor = .white
        setupNavigationBar()
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(nothingFoundLabel)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nothingFoundLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        let sortButton = UIBarButtonItem(
            title: "Sort",
            style: .plain,
            target: self,
            action: #selector(didTapSortButton)
        )
        navigationItem.rightBarButtonItem = sortButton
    }

    // MARK: - Actions

    @objc private func didTapSortButton() {
        let actionSheet = UIAlertController(title: "Sort Movies", message: nil, preferredStyle: .actionSheet)
        
        let sortByTitleAction = UIAlertAction(title: "By Title", style: .default) { [weak self] _ in
            self?.presenter?.sortMovies(by: "By Title")
        }
        
        let sortByRatingAction = UIAlertAction(title: "By Rating", style: .default) { [weak self] _ in
            self?.presenter?.sortMovies(by: "By Rating")
        }
        
        let sortByReleaseDateAction = UIAlertAction(title: "By Release Date", style: .default) { [weak self] _ in
            self?.presenter?.sortMovies(by: "By Release Date")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(sortByTitleAction)
        actionSheet.addAction(sortByRatingAction)
        actionSheet.addAction(sortByReleaseDateAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
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
        updateSnapshot(with: movies)
        nothingFoundLabel.isHidden = !movies.isEmpty
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

// MARK: - UISearchBarDelegate

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.searchMovies(by: searchText)
    }
}
