//
//  MovieCell.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import UIKit
import SDWebImage

final class MovieCell: UICollectionViewCell {
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let posterHeightMultiplier: CGFloat = 0.75
        static let titleTopOffset: CGFloat = 8
        static let horizontalPadding: CGFloat = 8
        static let placeholderImageName = "placeholder"
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(Constants.posterHeightMultiplier)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(Constants.titleTopOffset)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with movie: MovieViewModel) {
        titleLabel.text = movie.title
        posterImageView.sd_setImage(
            with: movie.posterURL,
            placeholderImage: UIImage(named: Constants.placeholderImageName)
        )
    }
}
