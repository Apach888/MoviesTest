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
            let cell = collectionView.dequeueReusableCell(MovieCell.self, for: indexPath)
            cell.configure(with: movie)
            return cell
        }
    }
}
