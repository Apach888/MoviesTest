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
    let posterPath: String
    let releaseDate: String
    let genres: String
    let voteAverage: Double
    
    init(from movie: MovieItem, genres: String) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = "https://image.tmdb.org/t/p/w500" + movie.posterPath
        self.releaseDate = String(movie.releaseDate.prefix(4))
        self.genres = genres
        self.voteAverage = movie.voteAverage
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieViewModel, rhs: MovieViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
