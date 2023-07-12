//
//  Logger.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct Logger {
    /// To define if the messages that are only informative will be printed on console or not
    static var informationLogsAreActive: Bool = true
    
    /// Some prefixes to identifies the package's logs into the console
    private static let errorPrefix = ":::::: DEPENDENCY INJECTOR ERROR ->"
    private static let regularPrefix = ":::::: DEPENDENCY INJECTOR ->"
    
    /// To cast and print an error message into console
    /// - Parameter error: Some kind of 'Error'. Mostly of type InjectionErrors
    static func log(_ error: Error) {
        guard let injectionError = error as? InjectionErrors else {
            print(errorPrefix, error.localizedDescription)
            return
        }
        
        print(errorPrefix, injectionError.message)
    }
    
    /// To print a message into console
    /// - Parameters:
    ///   - message: The message that is going to be printed
    ///   - addErrorPrefix: To know if the header of the message is going to use the "error" suffix
    static func log(_ message: String, addErrorPrefix: Bool = false) {
        guard informationLogsAreActive || addErrorPrefix else { return }
        
        let prefix = addErrorPrefix ? errorPrefix : regularPrefix
        print(prefix, message)
    }
}
