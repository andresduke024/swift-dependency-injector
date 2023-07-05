//
//  ViewModelWithoutInjectionTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ViewModelWithoutInjectionTest: XCTestCase {
    private var sut: ViewModel!
    
    override func setUp() {
        Injector.turnOffLogger()
        sut = ViewModel()
    }
    
    override func tearDown() {
        Injector.remove(Service.self)
        Injector.resetSingleton(of: NetworkManagerMock.self)
        Injector.clear()
        Injector.turnOnLogger()
        sut = nil
    }
    
    func testGetData() throws {
        let expected = [Int]()
        
        sut.loadData()
        
        XCTAssertEqual(sut.data, expected)
    }
}
