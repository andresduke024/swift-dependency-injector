//
//  RemoteRepositoryTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class RemoteRepositoryTest: XCTestCase {
    private var sut: RemoteRepository!

    override func setUp() {
        sut = RemoteRepository()
    }

    override func tearDown() {
        sut = nil
    }

    func testFetchData() throws {
        let expected = [5, 6, 7, 8]

        let result = sut.fetch()

        XCTAssertEqual(result, expected)
    }
}
