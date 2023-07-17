//
//  Logger.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct Logger {
    /// To define if the messages that are only informative will be printed on console or not.
    static var informationLogsAreActive: Bool = true
    static var isActive: Bool = true
    
    /// Some prefixes to identifies the package's logs into the console.
    private static let errorPrefix = "::: DEPENDENCY INJECTOR ERROR:"
    private static let regularPrefix = "::: DEPENDENCY INJECTOR ->"
    
    /// To print an InjectionErrors into console
    /// - Parameter error: Some InjectionError
    static func log(_ error: InjectionErrors) {
        guard isActive else { return }
        let errorName = "\(error.name) ->"
        print(errorPrefix, errorName, error.message)
    }
    
    /// To print a message into console.
    /// - Parameters:
    ///   - message: The message that is going to be printed.
    static func log(_ message: String) {
        guard isActive, informationLogsAreActive else { return }
        print(regularPrefix, message)
    }
}
