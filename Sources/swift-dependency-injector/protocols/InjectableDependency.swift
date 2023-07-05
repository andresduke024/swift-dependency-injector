//
//  InjectableDependency.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

public protocol InjectableDependency: Initializable {
    static func instance() -> Self
}

public extension InjectableDependency {
    static func instance() -> Self {
        return self.init()
    }
}
