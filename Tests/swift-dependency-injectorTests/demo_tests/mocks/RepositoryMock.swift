//
//  RepositoryMock.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import swift_dependency_injector

class RepositoryMock: Repository, InjectableDependency {
    required init() {}
    
    static var shouldSucced: Bool = true
    
    func fetch() -> [Int] {
        return Self.shouldSucced ? [1,2,3,4] : []
    }
}
