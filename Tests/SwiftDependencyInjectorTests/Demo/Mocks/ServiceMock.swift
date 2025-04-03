//
//  ServiceMock.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

struct ServiceSuccessMock: Service {
    func getData() -> [Int] { [1, 2, 3, 4] }
}

struct ServiceFailMock: Service {
    func getData() -> [Int] { [] }
}
