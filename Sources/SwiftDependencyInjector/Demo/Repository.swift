//
//  Repository.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import SwiftDependencyInjectorMacros

enum RepositoryType: String {
    case local
    case remote
}

protocol Repository: Sendable {
    func fetch() -> [Int]
}

@InjectableDependency(
    of: InjectableDependencyArgs(
        Repository.self,
        key: RepositoryType.local.rawValue
    )
)
struct LocalRepository: Repository {
    func fetch() -> [Int] { [1, 2, 3, 4] }
}

@InjectableDependency(
    of: InjectableDependencyArgs(
        Repository.self,
        key: RepositoryType.remote.rawValue
    )
)
struct RemoteRepository: Repository {
    func fetch() -> [Int] { [5, 6, 7, 8] }
}
