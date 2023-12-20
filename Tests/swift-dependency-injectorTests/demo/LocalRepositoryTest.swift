//
//  LocalRepositoryTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class LocalRepositoryTest: XCTestCase {
    private var sut: LocalRepository!

    override func setUp() {
        sut = LocalRepository()
    }

    override func tearDown() {
        sut = nil
    }

    func testFetchData() throws {
        let expected = [1, 2, 3, 4]

        let result = sut.fetch()

        XCTAssertEqual(result, expected)
    }
}
