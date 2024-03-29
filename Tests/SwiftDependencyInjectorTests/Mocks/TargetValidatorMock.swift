//
//  File.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

struct TargetValidatorMock: TargetValidatorProtocol {

    var value: Bool

    init(value: Bool) {
        self.value = value
    }

    var isRunningOnTestTarget: Bool { value }

    func copy() -> TargetValidatorProtocol {
        TargetValidatorMock(value: self.value)
    }
}
