//
//  Repository.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

enum RepositoryType: String {
    case local
    case remote
}

protocol Repository: InjectableDependency {
    func fetch() -> [Int]
}

final class LocalRepository: Repository {
    required init() {}

    func fetch() -> [Int] { [1, 2, 3, 4] }
}

final class RemoteRepository: Repository {
    required init() {}

    func fetch() -> [Int] { [5, 6, 7, 8] }
}
