//
//  MockInjectable1.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import Foundation
@testable import SwiftDependencyInjector

protocol MockInjectableProtocol: Sendable {
    func getMockData() -> String
}

struct MockInjectable1: MockInjectableProtocol {
    static let key: String = "1"

    func getMockData() -> String { "mock_data_1" }
}

struct MockInjectable2: MockInjectableProtocol {
    static let key: String = "2"

    func getMockData() -> String { "mock_data_2" }
}
