//
//  ServiceMock.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import swift_dependency_injector

class ServiceSuccessMock: Service, InjectableDependency {
    required init() {}

    func getData() -> [Int] { [1, 2, 3, 4] }
}

class ServiceFailMock: Service, InjectableDependency {
    required init() {}

    func getData() -> [Int] { [] }
}
