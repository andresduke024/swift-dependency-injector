//
//  InitializersContainerMapperTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class InitializersContainerMapperTest: XCTestCase {

    func testMapManyImplementations() {
        let implementations: [String: () -> DummyDependencyMockProtocol?] = [
            "one": DummyDependencyOneMock.instance,
            "two": DummyDependencyTwoMock.instance
        ]

        let result = InitializersContainerMapper.map(implementations)
        XCTAssertEqual(result.count, 2)
    }

    func testMapOneImplementation() {

        let result = InitializersContainerMapper.map("one", DummyDependencyOneMock.instance)
        XCTAssertEqual(result.count, 1)
    }
}
