//
//  RepositoryMock.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

struct RepositorySuccessMock: Repository {
    func fetch() -> [Int] { [1, 2, 3, 4] }
}

struct RepositoryFailMock: Repository {
    func fetch() -> [Int] { [] }
}
