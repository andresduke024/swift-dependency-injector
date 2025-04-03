//
//  Logger.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct Logger {
    /// To print an InjectionErrors into console
    /// - Parameter error: Some InjectionError
    static func log(_ error: InjectionErrors) {
        guard Properties.isLoggerActive else { return }
        let errorName = "\(error.name) ->"
        print("::: DEPENDENCY INJECTOR ERROR:", errorName, error.message)
    }

    /// To print a message into console.
    /// - Parameters:
    ///   - message: The message that is going to be printed.
    static func log(_ message: String) {
        guard Properties.isLoggerActive, Properties.informationLogsAreActive else { return }
        print("::: DEPENDENCY INJECTOR ->", message)
    }
}
