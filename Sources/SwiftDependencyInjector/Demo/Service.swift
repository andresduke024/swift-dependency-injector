//
//  Service.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol Service: Sendable {
    func getData() -> [Int]
}

struct DummyService: Service  {
    @Inject
    private var repository: Repository

    func getData() -> [Int] {
        repository.fetch()
    }
}
