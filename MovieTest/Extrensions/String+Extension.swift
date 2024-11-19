//
//  String+Extension.swift
//  MovieTest
//
//  Created by Protsak Dmytro on 18.11.2024.
//

import Foundation

extension String {
    
    static let empty = ""
    static let separator = ", "

    static var localeIdentifier: Self {
        guard
            let languageCode = Locale.current.languageCode,
            let regionCode = Locale.current.regionCode
        else {
            return .empty
        }
        return "\(languageCode)-\(regionCode)"
    }
    
    var languageCode: String? {
        return self.split(separator: "-").first.map(String.init)
    }
    
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self) ?? Date.distantPast
    }
}


