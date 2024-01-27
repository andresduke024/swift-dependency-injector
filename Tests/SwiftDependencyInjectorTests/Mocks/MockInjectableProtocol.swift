//
//  MockInjectableProtocol.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import Foundation
@testable import SwiftDependencyInjector

protocol MockInjectableProtocol: InjectableDependency {
    func getMockData() -> String
}
