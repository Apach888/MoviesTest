//
//  MovieResponse.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct MovieResponse: Decodable {
    let page: Int
    let results: [MovieItem]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieItem: Decodable, Hashable {
    let id: Int
    let title: String
    let posterPath: String
    let releaseDate: String
    let genreIDs: [Int]
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case genreIDs = "genre_ids"
        case voteAverage = "vote_average"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MovieItem, rhs: MovieItem) -> Bool {
        lhs.id == rhs.id
    }
}
