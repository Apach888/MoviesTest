//
//  MoviesListViewController.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 17.11.2024.
//

import UIKit
import SnapKit

protocol MoviesListViewProtocol: AnyObject {
    func displayMovies(_ movies: [MovieViewModel], shouldScrollToTop: Bool)
    func showLoadingIndicator(_ isLoading: Bool)
    func endRefreshing()
}

final class MoviesListViewController: UIViewController {

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieViewModel>

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
        let layout = MoviesCompositionalLayout.createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(MovieCell.self)
        collectionView.refreshControl = refreshControl
        collectionView.prefetchDataSource = self
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

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Properties

    private var presenter: MoviesListPresenterProtocol?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDismissKeyboardGesture()
        presenter?.fetchMovies(fetchType: .initialLoad)
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

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func didTapSortButton() {
        presenter?.didTapSort()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleRefresh() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter?.fetchMovies(fetchType: .refresh)
    }

    // MARK: - Diffable Data Source Updates

    private func updateSnapshot(with movies: [MovieViewModel], shouldScrollToTop: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            if shouldScrollToTop, !movies.isEmpty {
                let firstIndexPath = IndexPath(item: 0, section: 0)
                self.collectionView.scrollToItem(at: firstIndexPath, at: .top, animated: true)
            }
        }
    }
}

// MARK: - MoviesListViewProtocol

extension MoviesListViewController: MoviesListViewProtocol {
    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showLoadingIndicator(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    func displayMovies(_ movies: [MovieViewModel], shouldScrollToTop: Bool = false) {
        refreshControl.endRefreshing()
        updateSnapshot(with: movies, shouldScrollToTop: shouldScrollToTop)
        nothingFoundLabel.isHidden = !movies.isEmpty
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension MoviesListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let presenter = presenter else { return }
        guard let maxIndexPath = indexPaths.max() else { return }

        if maxIndexPath.row >= collectionView.numberOfItems(inSection: 0) - 5 {
            if !presenter.isFetchingData && presenter.hasMorePages {
                presenter.fetchMovies(fetchType: .loadMore)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MoviesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedMovie = dataSource.itemIdentifier(for: indexPath) else { return }
        presenter?.didTapMovie(movieId: selectedMovie.id)
    }
}

// MARK: - UISearchBarDelegate

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.searchMovies(by: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
