//
//  ObservedInjectableTests.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class ObservedInjectableTests: XCTestCase {

    @ObservedInjectable var sut: MockInjectableProtocol?
    private var injector: Injector!

    override func setUpWithError() throws {
        try super.setUpWithError()

        injector = Injector.build(context: .global)
    }

    override func tearDownWithError() throws {
        injector.destroy()
    }

    func testInjectionCompletedSuccessfully() {
        injector.register(MockInjectableProtocol.self, defaultDependency: MockInjectable1.key, implementations: [
            MockInjectable1.key: MockInjectable1.instance,
            MockInjectable2.key: MockInjectable2.instance
        ])

        let result = sut?.getMockData()

        XCTAssertEqual(result, "mock_data_1")
    }

    func testInjectionCompletedSuccessfullyWithDependencyChange() {
        injector.register(MockInjectableProtocol.self, defaultDependency: MockInjectable1.key, implementations: [
            MockInjectable1.key: MockInjectable1.instance,
            MockInjectable2.key: MockInjectable2.instance
        ])

        injector.updateDependencyKey(of: MockInjectableProtocol.self, newKey: MockInjectable2.key)

        let result = sut?.getMockData()

        XCTAssertEqual(result, "mock_data_2")
    }

    func testInjectionIncompletedWithDependencyChange() {
        injector.register(MockInjectableProtocol.self, implementation: MockInjectable1.instance)

        injector.updateDependencyKey(of: MockInjectableProtocol.self, newKey: MockInjectable2.key)

        let result = sut?.getMockData()

        XCTAssertNil(result)
    }

    func testInjectionIncompleted() {
        injector.destroy()

        let result = sut?.getMockData()

        XCTAssertNil(result)
    }
}
