//
//  MovieCell.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import UIKit
import SnapKit
import SDWebImage

final class MovieCell: UICollectionViewCell {
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let posterHeightMultiplier: CGFloat = 0.6
        static let verticalSpacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 12
        static let placeholderImageName = "placeholder"
        static let titleFontSize: CGFloat = 16
        static let detailsFontSize: CGFloat = 14
    }
    
    // MARK: - UI Elements
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.detailsFontSize, weight: .regular)
        label.textColor = .gray
        return label
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailsLabel)
        
        posterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(Constants.posterHeightMultiplier)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(Constants.verticalSpacing)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        detailsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with movie: MovieViewModel) {
        titleLabel.text = "\(movie.title), \(movie.releaseDate.prefix(4))"
        detailsLabel.text = "Rating: \(String(format: "%.1f", movie.voteAverage))/10"
        posterImageView.sd_setImage(
            with: URL(string: movie.posterPath),
            placeholderImage: UIImage(named: Constants.placeholderImageName)
        )
    }
}
