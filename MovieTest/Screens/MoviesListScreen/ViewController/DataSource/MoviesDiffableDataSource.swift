//
//  MoviesDiffableDataSource.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import UIKit

enum Section {
    case main
}

final class MoviesDiffableDataSource: UICollectionViewDiffableDataSource<Section, MovieViewModel> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(MovieCell.self, for: indexPath)
            cell.configure(with: movie)
            return cell
        }
    }
}
