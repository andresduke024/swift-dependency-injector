//
//  InitializersContainerMapperTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class InitializersContainerMapperTest: XCTestCase {

    func testMapManyImplementations() {
        let implementations: [String: @Sendable () -> DummyDependencyMockProtocol?] = [
            "one": { DummyDependencyOneMock() },
            "two": { DummyDependencyTwoMock() }
        ]

        let result = InitializersContainerMapper.map(implementations)
        XCTAssertEqual(result.count, 2)
    }

    func testMapOneImplementation() {

        let result = InitializersContainerMapper.map("one", { DummyDependencyOneMock() })
        XCTAssertEqual(result.count, 1)
    }
}
