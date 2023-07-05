//
//  Injectable.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

@propertyWrapper
public struct Injectable<Value> {
    private let dependency: Value?
    private let injectionType: InjectionType

    public var wrappedValue: Value? { dependency }
    public var projectedValue: Value? { DependenciesContainer.shared.get(with: injectionType) }
    
    public init(_ injectionType: InjectionType = .regular, file: String = #file, line: Int = #line) {
        self.dependency = DependenciesContainer.shared.get(with: injectionType)
        self.injectionType = injectionType
        
        if dependency == nil {
            let message = "Not implementation found for '\(Value.self)' injection.\n File: \(file) \(line)"
            Logger.log(message, addErrorPrefix: true)
        }
    }
}
