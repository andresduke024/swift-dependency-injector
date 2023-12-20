//
//  RepositoryMock.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import swift_dependency_injector

class RepositorySuccessMock: Repository, InjectableDependency {
    required init() {}

    func fetch() -> [Int] { [1, 2, 3, 4] }
}

class RepositoryFailMock: Repository, InjectableDependency {
    required init() {}

    func fetch() -> [Int] { [] }
}
