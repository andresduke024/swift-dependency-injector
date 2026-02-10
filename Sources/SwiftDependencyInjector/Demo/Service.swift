//
//  Service.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import SwiftDependencyInjectorMacros

protocol Service: Sendable {
    func getData() -> [Int]
}

@InjectableDependency(of: Service.self)
@InjectedConstructor(Repository.self)
struct DummyService: Service  {
    func getData() -> [Int] {
        repository.fetch()
    }
}
