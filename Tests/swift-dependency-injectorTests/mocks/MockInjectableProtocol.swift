//
//  MockInjectableProtocol.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import Foundation
@testable import swift_dependency_injector

protocol MockInjectableProtocol: InjectableDependency {
    func getMockData() -> String
}
