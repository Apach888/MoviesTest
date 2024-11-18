//
//  MovieViewModel.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct MovieViewModel: Hashable {
    let id: Int
    let title: String
    let posterURL: URL?
    let releaseYear: String
    let rating: String

    init(movie: MovieItem) {
        self.id = movie.id
        self.title = movie.title
        self.posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")
        self.releaseYear = String(movie.releaseDate.prefix(4))
        self.rating = String(format: "%.1f", movie.voteAverage)
    }
}
