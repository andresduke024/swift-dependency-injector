//
//  InjectTests.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class InjectTests: XCTestCase {

    @Inject var sut: MockInjectableProtocol
    private var injector: Injector!

    override func setUpWithError() throws {
        try super.setUpWithError()

        injector = Injector.build(context: .global)
    }

    override func tearDownWithError() throws {
        injector.destroy()
    }

    func testInjectionCompletedSuccessfully() {
        injector.register(MockInjectableProtocol.self, implementation: MockInjectable1.instance)

        let result = sut.getMockData()

        XCTAssertEqual(result, "mock_data_1")
    }
}
