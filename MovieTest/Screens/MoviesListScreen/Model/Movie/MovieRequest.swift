//
//  MovieRequest.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

struct MovieRequest: Encodable {
    let page: Int
    let language: String

    init(page: Int = 1, language: String) {
        self.page = page
        self.language = language
    }
}
