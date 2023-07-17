//
//  ViewModelTest.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ViewModelTest: XCTestCase {
    private let contextName = "ViewModel"
    private var injector: Injector!
    
    override func setUp() {
        injector = Injector.build(context: .tests(name: contextName))
        injector.register(NetworkManager.self, implementation: NetworkManagerMock.instance)
    }
    
    override func tearDown() {
        injector.destroy()
    }
    
    func testGetDataSuccess() throws {
        let expected = [1,2,3,4]
        
        injector.register(Service.self, implementation: ServiceSuccessMock.instance)
        let sut = ViewModel()
        
        sut.loadData()
        
        XCTAssertEqual(sut.data, expected)
    }
    
    func testGetDataFail() throws {
        let expected = [Int]()
        
        injector.register(Service.self, implementation: ServiceFailMock.instance)
        let sut = ViewModel()
        
        sut.loadData()
        
        XCTAssertEqual(sut.data, expected)
    }
}
