//
//  MoviesModel.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct Movie {
    
    //MARK: - Response
    
    struct Response: Decodable {
        let page: Int
        let results: [Movie.Item]
        let totalPages: Int
        let totalResults: Int
        
        enum CodingKeys: String, CodingKey {
            case page, results
            case totalPages = "total_pages"
            case totalResults = "total_results"
        }
    }
    
    //MARK: - Item
    
    struct Item: Decodable {
        let adult: Bool?
        let backdropPath: String?
        let genreIDS: [Int]
        let id: Int
        let originalLanguage: String?
        let originalTitle: String?
        let overview: String?
        let popularity: Double?
        let posterPath: String
        let releaseDate: String
        let title: String
        let video: Bool?
        let voteAverage: Double
        let voteCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case adult
            case backdropPath = "backdrop_path"
            case genreIDS = "genre_ids"
            case id
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case overview, popularity
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case title, video
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
    
    //MARK: - ViewModel
    
    struct ViewModel {
        let id: Int
        let posterPath: String
        let title: String
        let genreIDS: [Int]
        let voteAverage: Double
        let releaseDate: Date
        
        init(response: Movie.Item) {
            self.id = response.id
            self.posterPath = ""
            self.title = response.title
            self.genreIDS = response.genreIDS
            self.voteAverage = response.voteAverage
            self.releaseDate = response.releaseDate.toDate()
        }
    }
    
    //MARK: - Query Items Parameters
    
    struct Params: Encodable {
        let page: Int
        let language: String
        
        init(page: Int = 1, language: String) {
            self.page = page
            self.language = language
        }
    }
}
