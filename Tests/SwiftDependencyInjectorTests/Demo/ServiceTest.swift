//
//  ServiceTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class ServiceTest: XCTestCase {
    private var injector: Injector!

    override func setUp() {
        injector = Injector.build(context: .tests(name: "Service"))
    }

    override func tearDown() {
        injector.destroy()
    }

    func testFetchDataSuccess() throws {
        let expected = [1, 2, 3, 4]

        injector.register(Repository.self) { RepositorySuccessMock() }
        let sut = DummyService()

        let result = sut.getData()

        XCTAssertEqual(result, expected)
    }

    func testFetchDataFail() throws {
        let expected = [Int]()

        injector.register(Repository.self) { RepositoryFailMock() }
        let sut = DummyService()

        let result = sut.getData()

        XCTAssertEqual(result, expected)
    }
}
