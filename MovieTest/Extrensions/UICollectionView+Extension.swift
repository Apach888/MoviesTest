//
//  UICollectionView+Extension.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 19.11.2024.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        self.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(identifier)")
        }
        return cell
    }
}
