//
//  ContextManager.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

class ContextManagerTests: XCTestCase {
    var targetValidatorMock: TargetValidatorMock!
    var sut: ContextManager!

    override func setUpWithError() throws {
        targetValidatorMock = TargetValidatorMock(value: true)
        sut = ContextManager(targetValidator: targetValidatorMock)
    }
    
    override func tearDownWithError() throws {
        targetValidatorMock = nil
        sut = nil
    }
    
    func testRegisterContext() {
        let _ = sut.register(.global)
        
        XCTAssertEqual(sut.count, 1)
    }
    
    func testRegisterMultipleContexts() {
        let _ = sut.register(.global)
        let _ = sut.register(.custom(name: ""))
        
        XCTAssertEqual(sut.count, 2)
    }
    
    func testGetRegisteredDependenciesManager() {
        let _ = sut.register(.global)
        let _ = sut.get(.global)
        
        XCTAssertEqual(sut.count, 1)
    }
    
    func testGetDependenciesManager() {
        let _ = sut.get(.global)
        
        XCTAssertEqual(sut.count, 1)
    }
    
    func testGetDependenciesManagerForDifferenteContexts() {
        let _ = sut.get(.global)
        let _ = sut.get(.custom(name: ""))
        
        XCTAssertEqual(sut.count, 2)
    }
    
    func testRemoveRegisteredContext() {
        let _ = sut.register(.global)
        sut.remove(.global)
        
        XCTAssertEqual(sut.count, 0)
    }
    
    func testRemoveUndefinedContext() {
        let _ = sut.get(.global)
        sut.remove(.custom(name: ""))
        
        XCTAssertEqual(sut.count, 1)
    }
    
    func testTransformToValidContextShouldReturnGlobalContextWithoutRunningOnTestTarget() {
        let mockFileName = "TestFile"
        targetValidatorMock.value = false
        let context = sut.transformToValidContext(.global, fileName: mockFileName)
        
        var result = false
        if case .global = context {
            result = true
        }
        
        XCTAssert(result)
    }
    
    func testTransformToValidContextShouldReturnGlobalContext() {
        let mockFileName = "TestFile"
        targetValidatorMock.value = true
        let context = sut.transformToValidContext(.global, fileName: mockFileName)
        
        var result = false
        if case .global = context {
            result = true
        }
        
        XCTAssert(result)
    }
    
    func testTransformToValidContextShouldReturnTestsContext() {
        let mockFileName = "TestFile"
        targetValidatorMock.value = true
        
        let _ = sut.register(.tests(name: mockFileName))
        let context = sut.transformToValidContext(.global, fileName: mockFileName)
        
        var result = false
        if case .tests(let name) = context, name == mockFileName {
            result = true
        }
        
        XCTAssert(result)
    }
    
    func testTransformToValidContextShouldReturnCustomContext() {
        let mockFileName = "TestFile"
        targetValidatorMock.value = true
        
        let _ = sut.register(.custom(name: ""))
        let context = sut.transformToValidContext(.custom(name: ""), fileName: mockFileName)
        
        var result = false
        if case .custom(let name) = context, name == "" {
            result = true
        }
        
        XCTAssert(result)
    }
}
