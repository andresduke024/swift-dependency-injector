//
//  InjectTests.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class InjectTests: XCTestCase {
    private var sut: InjectPropertyWrapperMock!
    private var injector: Injector!

    override func setUpWithError() throws {
        try super.setUpWithError()

        injector = Injector.global
        
        injector.register(MockInjectableProtocol.self) { MockInjectable1() }
        
        sut = InjectPropertyWrapperMock()
    }

    override func tearDownWithError() throws {
        sut = nil
        
        injector.destroy()
    }

    func testInjectionCompletedSuccessfully() {
        
        let result = sut.property.getMockData()

        XCTAssertEqual(result, "mock_data_1")
    }
}

struct InjectPropertyWrapperMock {
    @Inject var property: MockInjectableProtocol
}
