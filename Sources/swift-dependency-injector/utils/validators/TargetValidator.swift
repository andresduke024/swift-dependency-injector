//
//  TargetValidator.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation

struct TargetValidator: TargetValidatorProtocol {
    /// To know if the application which is using the package is running unit tests.
    var isRunningOnTestTarget: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
