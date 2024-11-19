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
    
    private enum Constants {
        static let cornerRadius: CGFloat = 12
        static let titleFontSize: CGFloat = 18
        static let genresFontSize: CGFloat = 14
        static let ratingSize: CGFloat = 44
        static let yearFontSize: CGFloat = 14
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 8
        static let overlayOpacity: CGFloat = 0.6
        static let placeholderImageName = "placeholder"
    }
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(Constants.overlayOpacity).cgColor
        ]
        gradient.locations = [0.5, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.genresFontSize)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let ratingView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.ratingSize / 2
        view.backgroundColor = .black.withAlphaComponent(Constants.overlayOpacity)
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .green
        label.textAlignment = .center
        return label
    }()
    
    private let yearContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius / 2
        view.backgroundColor = .black.withAlphaComponent(Constants.overlayOpacity)
        return view
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.yearFontSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layer.sublayers?.first?.frame = gradientView.bounds
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(gradientView)
        gradientView.addSubview(titleLabel)
        gradientView.addSubview(genresLabel)
        containerView.addSubview(ratingView)
        ratingView.addSubview(ratingLabel)
        containerView.addSubview(yearContainerView)
        yearContainerView.addSubview(yearLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.horizontalPadding / 2)
        }
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.bottom.equalTo(genresLabel.snp.top).offset(-Constants.verticalPadding / 2)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.bottom.equalToSuperview().inset(Constants.verticalPadding)
        }
        
        ratingView.snp.makeConstraints { make in
            make.width.height.equalTo(Constants.ratingSize)
            make.trailing.bottom.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        yearContainerView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            make.width.equalTo(50)
            make.height.equalTo(24)
        }
        
        yearLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with movie: MovieViewModel) {
        titleLabel.text = movie.title
        genresLabel.text = movie.genres
        ratingLabel.text = "\(Int(movie.voteAverage * 10))%"
        yearLabel.text = String(movie.releaseDate.prefix(4))
        posterImageView.sd_setImage(
            with: URL(string: movie.posterPath),
            placeholderImage: UIImage(named: Constants.placeholderImageName)
        )
    }
}
