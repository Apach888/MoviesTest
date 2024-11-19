//
//  GenreResponse.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 19.11.2024.
//

import Foundation

struct GenreResponse: Decodable {
    let genres: [GenreItem]
}

struct GenreItem: Decodable {
    let id: Int
    let name: String
}
