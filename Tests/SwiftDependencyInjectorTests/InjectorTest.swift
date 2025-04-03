//
//  InjectorTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class InjectorTest: XCTestCase {

    private var contextManagerMock: ContextManagerMock!
    private var sut: Injector!

    private let contextManagerMockKey = "mock_key"
    
    override func setUpWithError() throws {
        contextManagerMock = ContextManagerMock()
        
        DependenciesContainer.reset(registerGlobalContextManager: false)
        DependenciesContainer.add(contextManagerMockKey, contextManagerMock)
        
        sut = Injector.build(context: .custom(name: ""))
    }

    override func tearDownWithError() throws {
        contextManagerMock = nil
        
        DependenciesContainer.reset()
        
        sut = nil
    }
    
    private var dependenciesManagerMockProperties: DependenciesManagerMockProperties {
        contextManagerMock.properties.dependenciesManager.properties
    }

    func testRegisterManyImplementations() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let result = dependenciesManagerMockProperties.registerManyImplementationsWasCall
        XCTAssertTrue(result)
    }

    func testRegisterOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self) { DummyDependencyOneMock() }

        let result = dependenciesManagerMockProperties.registerOneImplementationWasCall
        XCTAssertTrue(result)
    }

    func testAddManyImplementations() {
        sut.add(DummyDependencyMockProtocol.self, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let result = dependenciesManagerMockProperties.addManyImplementationsWasCall
        XCTAssertTrue(result)
    }

    func testAddOneImplementation() {
        sut.add(DummyDependencyMockProtocol.self, key: "") { DummyDependencyOneMock() }

        let result = dependenciesManagerMockProperties.addOneImplementationWasCall
        XCTAssertTrue(result)
    }


    func testResetSingleton() {
        sut.resetSingleton(of: DummyDependencyMockProtocol.self)

        let result = dependenciesManagerMockProperties.resetSingletonWasCall
        XCTAssertTrue(result)
    }

    func testRemove() {
        sut.remove(DummyDependencyMockProtocol.self)

        let result = dependenciesManagerMockProperties.removeWasCall
        XCTAssertTrue(result)
    }

    func testClear() {
        sut.clear()

        let result = dependenciesManagerMockProperties.clearWasCall
        XCTAssertTrue(result)
    }

    func testRemoveContext() {
        sut.destroy()

        let result = contextManagerMock.properties.removeWassCall
        XCTAssertTrue(result)
    }
}
