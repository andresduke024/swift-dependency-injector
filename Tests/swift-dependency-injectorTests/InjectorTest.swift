//
//  InjectorTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class InjectorTest: XCTestCase {

    private let contextManagerMock = ContextManagerMock()
    private var sut: Injector!
    
    override func setUpWithError() throws {
        sut = Injector.build(context: .custom(name: ""))
        DependenciesContainer.setContextManager(contextManagerMock)
    }

    override func tearDownWithError() throws {
        sut = nil
        DependenciesContainer.reset()
    }
    
    func testRegisterManyImplementations() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let result = contextManagerMock.dependenciesManager.registerManyImplementationsWasCall
        XCTAssertTrue(result)
    }
    
    func testRegisterOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        
        let result = contextManagerMock.dependenciesManager.registerOneImplementationWasCall
        XCTAssertTrue(result)
    }
    
    func testAddManyImplementations() {
        sut.add(DummyDependencyMockProtocol.self, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let result = contextManagerMock.dependenciesManager.addManyImplementationsWasCall
        XCTAssertTrue(result)
    }
    
    func testAddOneImplementation() {
        sut.add(DummyDependencyMockProtocol.self, key: "", implementation: DummyDependencyOneMock.instance)
        
        let result = contextManagerMock.dependenciesManager.addOneImplementationWasCall
        XCTAssertTrue(result)
    }
    
    func testUpdateDependencyKey() {
        sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: "")
        
        let result = contextManagerMock.dependenciesManager.updateDependencyKeyWasCall
        XCTAssertTrue(result)
    }
    
    func testResetSingleton() {
        sut.resetSingleton(of: DummyDependencyMockProtocol.self)
        
        let result = contextManagerMock.dependenciesManager.resetSingletonWasCall
        XCTAssertTrue(result)
    }
    
    func testRemove() {
        sut.remove(DummyDependencyMockProtocol.self)
        
        let result = contextManagerMock.dependenciesManager.removeWasCall
        XCTAssertTrue(result)
    }
    
    func testClear() {
        sut.clear()
        
        let result = contextManagerMock.dependenciesManager.clearWasCall
        XCTAssertTrue(result)
    }
    
    func testRemoveContext() {
        sut.destroy()
        
        let result = contextManagerMock.removeWassCall
        XCTAssertTrue(result)
    }
}
