//
//  Logger.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct Logger {
    static var informationLogsAreActive: Bool = true
    
    private static let errorPrefix = ":::::: DEPENDENCY INJECTOR ERROR\n"
    private static let regularPrefix = ":::::: DEPENDENCY INJECTOR\n"
    
    static func log(_ error: Error) {
        guard let injectionError = error as? InjectionErrors else {
            print(errorPrefix, error.localizedDescription)
            return
        }
        
        print(errorPrefix, injectionError.message)
    }
    
    static func log(_ message: String, addErrorPrefix: Bool = false) {
        guard informationLogsAreActive || addErrorPrefix else { return }
        
        let prefix = addErrorPrefix ? errorPrefix : regularPrefix
        print(prefix, message)
    }
}
