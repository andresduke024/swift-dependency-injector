//
//  Service.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol Service: InjectableDependency {
    func getData() -> [Int]
}

final class DummyService: Service  {
    @Inject
    private var repository: Repository

    required init() {}

    func getData() -> [Int] {
        repository.fetch()
    }
}
