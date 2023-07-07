//
//  Utils.swift
//  
//
//  Created by Andres Duque on 6/07/23.
//

import Foundation

/// Common utilities
struct Utils {
    
    /// To know if the application which is using the package is running unit tests
    static var isRunningOnTestTarget: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
