//
//  StringExtension.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

extension String {

    /// To join a set of strings into one string by separating all the substrings with a specific separator.
    /// - Parameters:
    ///   - strings: A set of strings
    ///   - separator: To define the separator used in the resulted string.
    /// - Returns: A a set of strings joined into one.
    static func join(
        _ strings: String...,
        separator: String
    ) -> String {
        let joinedString = strings.reduce("") { partialResult, item in
            "\(partialResult)\(item)\(separator)"
        }

        return String(joinedString.dropLast())
    }
}
