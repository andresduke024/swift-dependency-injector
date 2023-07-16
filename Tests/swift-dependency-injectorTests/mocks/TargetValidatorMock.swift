//
//  File.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation
@testable import swift_dependency_injector

struct TargetValidatorMock: TargetValidatorProtocol {
    
    private var value: Bool
    
    init(value: Bool) {
        self.value = value
    }
    
    var isRunningOnTestTarget: Bool { value }
}
