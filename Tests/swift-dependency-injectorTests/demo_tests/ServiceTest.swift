//
//  ServiceTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ServiceTest: XCTestCase {
    private var sut: Service!
    
    override func setUp() {
        Injector.register(Repository.self, implementation: RepositoryMock.instance)
        sut = DummyService()
    }
    
    override func tearDown() {
        Injector.clear()
        sut = nil
    }
    
    func testFetchDataSuccess() throws {
        let expected = [1,2,3,4]
        
        RepositoryMock.shouldSucced = true
        let result = sut.getData()
        
        XCTAssertEqual(result, expected)
    }
    
    func testFetchDataFail() throws {
        let expected = [Int]()
        
        RepositoryMock.shouldSucced = false
        let result = sut.getData()
        
        XCTAssertEqual(result, expected)
    }
}
