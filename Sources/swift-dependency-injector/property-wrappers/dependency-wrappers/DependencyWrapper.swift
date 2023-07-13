//
//  DependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation
import Combine

open class DependencyWrapper<Value> {
    let filePath: String
    let line: Int
    
    var value: Value?
    
    let id = UUID()
    
    var abstractionName: String {
        String(describing: Value.self)
    }
    
    init(
        _ filePath: String,
        _ line: Int
    ) {
        self.filePath = filePath
        self.line = line
        
        manageOnInitInstantiation()
    }
    
    open func manageOnInitInstantiation() { }
    
    open func unwrapValue() -> Value? { return nil }
    
    /// To validate if an injection was completed successfully
    /// - Parameter dependency: the obtained implementation of the given abstraction (Value)
    final func checkInjectionError() {
        guard value == nil else { return }
        
        let error: InjectionErrors = .noImplementationFoundOnInjection(abstrationName: abstractionName, file: "\(filePath) \(line)")
        Logger.log(error)
    }
}
