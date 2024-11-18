//
//  MoviesDiffableDataSource.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import UIKit

final class MoviesDiffableDataSource: UICollectionViewDiffableDataSource<Int, MovieViewModel> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, movie in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCell.reuseIdentifier,
                for: indexPath
            ) as? MovieCell else {
                fatalError("Unable to dequeue MovieCell.")
            }
            cell.configure(with: movie)
            return cell
        }
    }
}
