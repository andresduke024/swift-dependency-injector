//
//  ObservedInjectTests.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class ObservedInjectTests: XCTestCase {

    @ObservedInject var sut: MockInjectableProtocol
    private var injector: Injector!

    override func setUpWithError() throws {
        try super.setUpWithError()

        injector = Injector.build(context: .global)

        injector.register(MockInjectableProtocol.self, defaultDependency: MockInjectable1.key, implementations: [
            MockInjectable1.key: MockInjectable1.instance,
            MockInjectable2.key: MockInjectable2.instance
        ])
    }

    override func tearDownWithError() throws {
        injector.destroy()
    }

    func testInjectionCompletedSuccessfully() {
        let result = sut.getMockData()

        XCTAssertEqual(result, "mock_data_1")
    }

    func testInjectionCompletedSuccessfullyWithDependencyChange() {
        injector.updateDependencyKey(of: MockInjectableProtocol.self, newKey: MockInjectable2.key)

        let result = sut.getMockData()

        XCTAssertEqual(result, "mock_data_2")
    }
}
