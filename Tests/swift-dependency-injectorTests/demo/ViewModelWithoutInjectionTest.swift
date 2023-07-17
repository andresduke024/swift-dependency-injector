//
//  ViewModelWithoutInjectionTest.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ViewModelWithoutInjectionTest: XCTestCase {
    private var injector: Injector!
    private var sut: ViewModel!
    
    override func setUp() {
        injector = Injector.build(context: .tests(name: "ViewModel"))
        
        injector.turnOffLogger()
        injector.remove(Service.self)
        injector.resetSingleton(of: NetworkManager.self)
        injector.clear()
        sut = ViewModel()
    }

    override func tearDown() {
        injector.turnOnLogger()
        injector.destroy()
        sut = nil
    }

    func testGetData() throws {
        let expected = [Int]()

        sut.loadData()

        XCTAssertEqual(sut.data, expected)
    }
}
