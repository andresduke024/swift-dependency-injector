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

protocol Repository: Sendable {
    func fetch() -> [Int]
}

struct LocalRepository: Repository {
    func fetch() -> [Int] { [1, 2, 3, 4] }
}

struct RemoteRepository: Repository {
    func fetch() -> [Int] { [5, 6, 7, 8] }
}
