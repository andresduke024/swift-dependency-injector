//
//  MockInjectable1.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import Foundation
@testable import swift_dependency_injector

final class MockInjectable1: MockInjectableProtocol {
    static let key: String = "1"

    func getMockData() -> String { "mock_data_1" }
}
