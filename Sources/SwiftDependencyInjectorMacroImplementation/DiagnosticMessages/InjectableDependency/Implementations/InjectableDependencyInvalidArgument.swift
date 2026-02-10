//
//  InjectableDependencyInvalidArgument.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

struct InjectableDependencyInvalidArgument: InjectableDependencyDiagnosticBase {
    var id: String { "InjectableDependencyInvalidArgument" }
    
    var message: String {
        "Invalid argument for @InjectableDependency"
    }
}
