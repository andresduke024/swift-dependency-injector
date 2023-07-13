//
//  DependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation
import Combine

/// Base class used to encapsulate the common behavior of a dependency wrapper.
/// **It should not be instantiate**
open class DependencyWrapper<Abstraction> {
    
    /// The name of the file where the wrapped implementation is being used.
    let filePath: String
    
    /// The specific line of the file where the wrapped implementation is being used.
    let line: Int
    
    /// To store the current injected implementation.
    var value: Abstraction?
    
    init(_ filePath: String, _ line: Int) {
        self.filePath = filePath
        self.line = line
        
        manageOnInitInstantiation()
    }
    
    /// To manage and define the way and the moment at the implementation has to be instantiated.
    /// **Must override**
    open func manageOnInitInstantiation() { }
    
    /// A facade function  used to perform all the validations and processes required before obtain an injected implementation.
    /// **Must override**
    /// - Returns: An optional implementation of the given abstraction.
    open func unwrapValue() -> Abstraction? { nil }
    
    /// To validate if an injection was completed successfully
    final func checkInjectionError() {
        guard value == nil else { return }
        
        let abstractionName = Utils.createName(for: Abstraction.self)
        let error: InjectionErrors = .noImplementationFoundOnInjection(abstractionName, file: "\(filePath) \(line)")
        Logger.log(error)
    }
}
