//
//  Service.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol Service {
    func getData() -> [Int]
}

class DummyService: Service, InjectableDependency {
    @Injectable
    private var repository: Repository?

    required init() {}

    func getData() -> [Int] {
        repository?.fetch() ?? []
    }
}
