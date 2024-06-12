//
//  ObservedDependencyWrapperTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class ObservedDependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "ObservedDependencyWrapperTest")
    private var injector: Injector!

    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
        DependenciesContainer.reset()
    }

    func testUnwrapValue() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = buildSut()

        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }

    func testUnwrapValueWithValueChange() {
        injector.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: DummyDependencyOneMock.instance,
            DummyDependencyType.second: DummyDependencyTwoMock.instance
        ])

        let sut = buildSut()

        let result1 = sut.unwrapValue()

        injector.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.second)

        let result2 = sut.unwrapValue()

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1?.id, result2?.id)
    }

    func testUnwrapValueWithErrorOnInit() {
        let newInjectionContext = InjectionContext.tests(name: "newContext")
        let injector = Injector.build(context: newInjectionContext)
        
        let sut = buildSut()

        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)

        _ = sut.unwrapValue()

        XCTAssertNotNil(sut.value)
    }

    func testDependencyPublisingError() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)

        let mockContextManager = ContextManagerMock()
        DependenciesContainer.setContextManager(mockContextManager)

        let sut = buildSut()

        mockContextManager.dependenciesManager.publisher.send(completion: .failure(.abstractionAlreadyRegistered("DummyDependencyMockProtocol", injectionContext)))

        XCTAssertNil(sut.value)
    }
}

extension ObservedDependencyWrapperTest {
    func buildSut(context: InjectionContext? = nil) -> ObservedDependencyWrapper<DummyDependencyMockProtocol> {
        let args = DependencyWrapperArgs(context: context ?? injectionContext)
        return ObservedDependencyWrapper(args: args)
    }
}
