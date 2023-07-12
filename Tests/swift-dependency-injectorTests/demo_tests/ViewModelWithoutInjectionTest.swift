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
        Injector.remove(Service.self)
        Injector.resetSingleton(of: NetworkManager.self)
        Injector.clear()
        sut = ViewModel()
    }

    override func tearDown() {
        Injector.turnOnLogger()
        sut = nil
    }

    func testGetData() throws {
        let expected = [Int]()

        sut.loadData()

        XCTAssertEqual(sut.data, expected)
    }
}
