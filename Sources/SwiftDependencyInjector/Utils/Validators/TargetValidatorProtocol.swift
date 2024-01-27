//
//  TargetValidatorProtocol.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation

protocol TargetValidatorProtocol {
    /// To know if the application which is using the package is running unit tests.
    var isRunningOnTestTarget: Bool { get }

    /// To get a new instance of the class (new memory reference).
    func copy() -> TargetValidatorProtocol
}
