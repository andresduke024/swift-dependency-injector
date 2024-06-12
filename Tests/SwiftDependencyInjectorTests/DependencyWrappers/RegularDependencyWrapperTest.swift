//
//  RegularDependencyWrapperTest.swift
//
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class RegularDependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "RegularDependencyWrapperTest")
    private var injector: Injector!

    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
    }

    func testUnwrapValueRegular() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = buildSut(.regular, .regular)
        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }

    func testUnwrapValueLazy() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = buildSut(.regular, .lazy)

        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }

    func testUnwrapValueSingletonInstance() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut1 = buildSut(.singleton, .lazy)
        let sut2 = buildSut(.singleton, .lazy)

        let result1 = sut1.unwrapValue()
        let result2 = sut2.unwrapValue()

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1?.id, result2?.id)
    }

    func testUnwrapValueRegularInstance() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut1 = buildSut(.regular, .lazy)
        let sut2 = buildSut(.regular, .lazy)

        let result1 = sut1.unwrapValue()
        let result2 = sut2.unwrapValue()

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1?.id, result2?.id)
    }
}

extension RegularDependencyWrapperTest {
    func buildSut(
        _ injectionType: InjectionType,
        _ instantationType: InstantiationType
    ) -> RegularDependencyWrapper<DummyDependencyMockProtocol> {
        
        let args = DependencyWrapperArgs(
            injection: injectionType,
            instantiation: instantationType,
            file: #file,
            line: #line,
            context: injectionContext,
            constrainedTo: nil
        )
        
        return RegularDependencyWrapper(args: args)
    }
}
