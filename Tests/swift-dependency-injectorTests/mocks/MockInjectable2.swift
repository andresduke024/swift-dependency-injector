//
//  MockInjectable2.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import Foundation
@testable import swift_dependency_injector

final class MockInjectable2: MockInjectableProtocol {
    static let key: String = "2"

    func getMockData() -> String { "mock_data_2" }
}
