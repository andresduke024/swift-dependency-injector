//
//  RegularDependencyWrapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

final class RegularDependencyWrapper<Value>: DependencyWrapper<Value> {
    
    /// To define the type of injection that we are going to use when try to get an implementation from the container
    let injectionType: InjectionType

    private let instantiationType: InstantiationType
        
    init(_ injectionType: InjectionType, _ instantiationType: InstantiationType, _ filePath: String, _ line: Int) {
        self.injectionType = injectionType
        self.instantiationType = instantiationType
        super.init(filePath, line)
    }
    
    override func manageOnInitInstantiation() {
        if instantiationType == .lazy {
            let file = (filePath as NSString).lastPathComponent
            Logger.log("\(Value.self) injected as 'lazy' on \(file) at line \(line) is waiting to first call to be instantiate")
            return
        }
        
        self.value = DependenciesContainer.shared.get(with: injectionType)
        checkInjectionError()
    }
    
    override func unwrapValue() -> Value? {
        if value == nil, instantiationType == .lazy {
            value = DependenciesContainer.shared.get(with: injectionType)
        }
        
        checkInjectionError()
        return value
    }
}
