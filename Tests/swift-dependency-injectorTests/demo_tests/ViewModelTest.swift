//
//  ViewModelTest.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ViewModelTest: XCTestCase {
    private var sut: ViewModel!
    
    override func setUp() {
        Injector.register(Service.self, implementation: ServiceMock.instance)
        Injector.register(NetworkManager.self, implementation: NetworkManagerMock.instance)
        sut = ViewModel()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testGetDataSuccess() throws {
        let expected = [1,2,3,4]
        
        ServiceMock.shouldSucced = true
        sut.loadData()
        
        XCTAssertEqual(sut.data, expected)
    }
    
    func testGetDataFail() throws {
        let expected = [Int]()
        
        ServiceMock.shouldSucced = false
        sut.loadData()
        
        XCTAssertEqual(sut.data, expected)
    }
}
